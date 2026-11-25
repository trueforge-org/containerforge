# guacd — implementation plan
> Source: ./draft.md · Target: apps/guacd/ · Difficulty: medium (the draft says easy, but the apt route it assumes does not exist, see section 1) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.6.0` (released 2025-06-23; newest directory in the Apache dist listing and newest non-RC tag on 2026-11-23). Same as the draft's chart image `guacamole/guacd:1.6.0`. |
| Renovate | `datasource=github-tags depName=apache/guacamole-server versioning=semver`. Tags have no `v` prefix (`1.6.0`) and also have `-RC1..3` pre-releases, which semver treats as pre-releases. |
| License | Apache-2.0 (`LICENSE` in the 1.6.0 tarball is the Apache License 2.0 text). |
| Source | https://github.com/apache/guacamole-server |
| Artifact | There is no prebuilt binary. Source tarball: `https://archive.apache.org/dist/guacamole/1.6.0/source/guacamole-server-1.6.0.tar.gz`. Architecture independent source, compiled per arch in the build stage. |
| Checksum source | Apache publishes `guacamole-server-1.6.0.tar.gz.sha256`: `8bc45675da96d7b6f39728160181e3d4ff3c08f460f6d26de5805b642bf13f2b` (also recomputed from the downloaded file, identical). A `.asc` signature exists too. |
| apt route in the draft | WRONG. packages.ubuntu.com lists `guacd` only for jammy (1.3.0-1.1) and noble (1.3.0-1.3ubuntu1). There is no `guacd` for resolute (26.04), and a source package search for `guacd` finds nothing newer. The draft says it is "present in resolute"; it is not. Even if it were, 1.3.0 would not match the 1.6.0 the chart uses. So the plan builds from source. |
| Upstream Dockerfile | Reviewed (tag 1.6.0): multi-stage on `alpine:3.18`, compiles FreeRDP 2, libssh2, libtelnet, libvncclient, libwebsockets into `/opt/guacamole`, then guacamole-server via `autobuild.sh`, final alpine runtime with `ca-certificates font-noto-cjk ghostscript netcat-openbsd shadow terminus-font ttf-dejavu ttf-liberation`, `LC_ALL=C.UTF-8`, `LD_LIBRARY_PATH=/opt/guacamole/lib`, user `guacd` (1000), `EXPOSE 4822`, `HEALTHCHECK nc -z 127.0.0.1 4822`, `ENTRYPOINT /opt/guacamole/entrypoint.sh`. Alpine/musl means `COPY --from=guacamole/guacd` is unusable on glibc Ubuntu, as the draft says. |
| Upstream entrypoint | `exec /opt/guacamole/sbin/guacd -f -b 0.0.0.0 -L "${LOG_LEVEL:-${GUACD_LOG_LEVEL:-info}}" "$@"`. `GUACD_LOG_LEVEL` is deprecated in favour of `LOG_LEVEL` (prints a warning). |
| guacd flags (source `src/guacd/conf-args.c`, getopt `"l:b:p:L:C:K:fv"`) | `-l` port, `-b` bind host, `-p` pid file, `-L` log level, `-C` TLS certificate, `-K` TLS key, `-f` foreground, `-v` version. The default bind host is `localhost` (`conf.h`), so `-b 0.0.0.0` is required for other containers to connect. Default port 4822. |
| Build options | `configure.ac` (1.6.0) supports FreeRDP 2 (`freerdp2 freerdp-client2 winpr2`) and FreeRDP 3 (`freerdp3 freerdp-client3 winpr3`) and has `--with-rdp/ssh/vnc/telnet/webp/websockets/pulse/pango/terminal` and `--enable-guacenc`, `--enable-guaclog`. |
| Resolute dev packages found on packages.ubuntu.com | `freerdp3-dev`, `libwinpr3-dev`, `libvncserver-dev`, `libssh2-1-dev`, `libwebsockets-dev`, `libssl-dev`, `uuid-dev`, `libtool-bin`, `libtelnet-dev` (0.23), `libpango1.0-dev` (1.57.0), `libcairo2-dev` (1.18.4), `libjpeg-turbo8-dev`, `libwebp-dev`, `libpulse-dev`, `libvorbis-dev`. Not found or not checked: `libpng-dev` (page timed out), `libossp-uuid-dev`, `ghostscript`. UNVERIFIED, confirm in the first build. |
| Runtime writes | guacd itself writes nothing unless a connection asks for session recording or drive redirection: the Guacamole client passes `recording-path` and `drive-path` parameters, which the chart mounts at `/var/lib/guacamole/recordings` and `/var/lib/guacamole/drive`. The FreeRDP plugin reads `getenv("HOME")` (`src/protocols/rdp/client.c`). |
| Ports | `4822/tcp` (guacd protocol). No web UI. |

## 2. Target layout

```
apps/guacd/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (no config file needed: all options are flags). No `root/`. `DOWNSTREAM_CHANGES.md` is not needed now; if the future `guacamole` web client app or a chart consumes `ghcr.io/trueforge-org/guacd` as a runtime dependency that is not a `FROM`, so none either. The image name for this app is `guacd`; the draft folder `../guacamole/` (chart `guacamole`, role sidecar `guacdImage`) uses the same image and gets no separate app, see `../guacamole/plan.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

Used for both the build stage and the final stage (same glibc and library versions, which matters for the `ldd`-derived package list). C daemon, so no language runtime. Closest sibling by shape: a source build into a runtime stage like the Go rule (`COPY --from=build`), and `apps/valkey` for pinned-version discipline. The ubuntu base already provides `curl`, `tini`, `ca-certificates`, `tzdata`, `fontconfig`, `wget`, `tar`, `xz-utils`, `jq` and `libssl3` (verified in `apps/ubuntu/Dockerfile`), so do not install them again.

## 4. Dockerfile

Two stages. Build stage:

1. `FROM ... AS build`, `ARG VERSION`, `ARG SHA256=8bc45675da96d7b6f39728160181e3d4ff3c08f460f6d26de5805b642bf13f2b` (must be changed together with `VERSION`; Renovate cannot update it), `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends` with: `build-essential autoconf automake libtool libtool-bin pkg-config libcairo2-dev libjpeg-turbo8-dev libpng-dev uuid-dev libssl-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libwebp-dev libpulse-dev libvorbis-dev freerdp3-dev libwinpr3-dev dpkg-dev`, then `rm -rf /var/lib/apt/lists/*`. These are build-only, not the app, so no version pins. Drop any name that does not exist in resolute after the first build attempt and note it in the PR.
3. Download and verify: `curl -fsSL -o /tmp/gs.tgz "https://archive.apache.org/dist/guacamole/${VERSION}/source/guacamole-server-${VERSION}.tar.gz"`, `echo "${SHA256}  /tmp/gs.tgz" | sha256sum -c -`, `tar xzf /tmp/gs.tgz -C /tmp`.
4. Build and install to a staging root: `cd /tmp/guacamole-server-${VERSION} && ./configure --prefix=/usr/local --disable-guaclog --disable-guacenc && make -j"$(nproc)" && make install DESTDIR=/target`. (`--disable-guaclog` as upstream does; `--disable-guacenc` also drops the ffmpeg dependency, both option names exist in `configure.ac`.) The FreeRDP plugin installs to `$(pkg-config --variable=libdir freerdp3)/freerdp3` under `/target`.
5. License files: `install -D LICENSE NOTICE -t /target/usr/share/licenses/guacd/` (the tarball contains both, verified).
6. Runtime package list, same idea as upstream `list-dependencies.sh`: `ldd /target/usr/local/sbin/guacd /target/usr/local/lib/libguac-client-*.so /target/usr/lib/*/freerdp3/*guac*.so` (adjust the glob to the real plugin path), take the resolved libraries outside `/target`, map with `dpkg -S`, `sort -u` into `/target/deps.txt` (package names only). Run `ldd` with `LD_LIBRARY_PATH=/target/usr/local/lib`, otherwise the freshly staged `libguac` is reported as not found, and fail the build on any other `not found`. On a merged-`/usr` Ubuntu `ldd` can print `/lib/...` paths while the dpkg database records `/usr/lib/...` (or the reverse), so resolve each path with `readlink -f` and fail if `dpkg -S` finds no owner. Do not hard code library package names, because Ubuntu's `t64` renames are easy to get wrong.

Final stage:

7. `FROM ... ` (same base), `ARG VERSION`, `USER root`, `COPY --from=build /target/ /`.
8. `RUN apt-get update && xargs -a /deps.txt apt-get install -y --no-install-recommends fonts-dejavu-core fonts-liberation ghostscript && rm -f /deps.txt && rm -rf /var/lib/apt/lists/* && ldconfig` (fonts and ghostscript mirror the upstream runtime for SSH/telnet terminals and PDF printing; verify the package names exist). `ldconfig` makes `/usr/local/lib/libguac*.so` resolvable without `LD_LIBRARY_PATH`.
9. `RUN install -d -o apps -g apps /var/lib/guacamole/recordings /var/lib/guacamole/drive`.
10. `ENV HOME=/tmp LC_ALL=C.UTF-8` (HOME is read by the FreeRDP plugin and must be writable; `/tmp` is the scratch path).
11. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 4822`, `VOLUME /config /var/lib/guacamole/recordings /var/lib/guacamole/drive`. guacd persists nothing in `/config`; it is declared to match the repo convention and the settings schema.

The `HEALTHCHECK` is inherited from the ubuntu base (`/healthcheck.sh` reads `/container-test.yaml`), so do not add a `nc` one.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "guacd" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=apache/guacamole-server versioning=semver
  default = "1.6.0"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/apache/guacamole-server" }
```

Plus the standard blocks from `apps/adguardhome-sync/docker-bake.hcl` (`docker-metadata-action`, `group "default"`, `image` with `args.VERSION` and the two OCI labels, `image-local` with `type=docker` and tag `${APP}:${VERSION}`, `image-all` with amd64 and arm64). `ARG VERSION` in both Dockerfile stages must be 1.6.0. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/apache/guacamole-server"
ports:
  - port: 4822
    protocol: tcp
    required: true
env:
  - name: LOG_LEVEL        # trace|debug|info|warning|error
    default: "info"
    required: false
  - name: GUACD_LOG_LEVEL  # deprecated upstream alias read as fallback
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config                       # mandatory in the settings schema; guacd stores nothing there
    required: false
  - path: /var/lib/guacamole/recordings # session recordings
    required: false
  - path: /var/lib/guacamole/drive      # RDP drive redirection
    required: false
dependencies: []
```

Use the block style (`name`, `default`, `required`) of `apps/bazarr/settings.yaml`. `/config` is listed because the settings schema requires a `/config` entry in `volumes`, although nothing is persisted there. No hard dependency; the consumer is a Guacamole web client, which is not a ContainerForge app yet (checked: there is no `apps/guacamole`).

## 7. start.sh

```bash
#!/usr/bin/env bash

# Same behaviour as the upstream entrypoint. guacd binds to localhost by default, so -b 0.0.0.0 is mandatory
# for other containers (the Guacamole web client) to reach it.
if [ -n "${GUACD_LOG_LEVEL:-}" ]; then
  echo "WARNING: GUACD_LOG_LEVEL is deprecated, use LOG_LEVEL." >&2
fi

exec /usr/local/sbin/guacd -f -b 0.0.0.0 -l 4822 -L "${LOG_LEVEL:-${GUACD_LOG_LEVEL:-info}}" "$@"
```

Idempotent, no seeding (nothing in `/config`), no writes to `/app`, scratch goes to `/tmp` through `HOME`, `exec` for signals. Extra arguments passed as container `CMD` are appended, which is how upstream lets users add `-C`/`-K` for TLS. The binary path `/usr/local/sbin/guacd` follows from `--prefix=/usr/local`; confirm after the build with `docker run --rm --entrypoint sh guacd:1.6.0 -c 'command -v guacd'`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '4822'
filePaths:
- /usr/local/sbin/guacd
- /usr/local/lib/libguac-client-rdp.so
- /usr/local/lib/libguac-client-ssh.so
- /usr/local/lib/libguac-client-vnc.so
```

The TCP probe covers the only port in `settings.yaml`. The `filePaths` prove the protocol plugins were really built (a missing `-dev` package would silently disable a protocol at `configure` time). The plugin file names follow upstream's `libguac-client-*.so` glob and are UNVERIFIED individually. The test runs without env vars, which is the normal startup here, so nothing is skipped. Note the TCP check passes even if guacd were bound only to localhost; `-b 0.0.0.0` is therefore verified by hand in section 11. The compiled daemon starts instantly; note that forgetool enforces a 180 s minimum, so `60` has no effect beyond documentation.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or privilege | Remap |
| --- | --- |
| Alpine user `guacd` UID 1000 | Base user `apps`. |
| Chart `runAsUser 1000/runAsGroup 1001`, `readOnlyRootFilesystem: false` | Not needed. Everything is installed under `/usr/local` and `/usr/lib` at build time. |
| `$HOME` for FreeRDP | `HOME=/tmp`. |
| Recordings (`/var/lib/guacamole/recordings`) and drive (`/var/lib/guacamole/drive`) | Real volumes owned by `apps`; on a read-only rootfs they must be mounted, otherwise those features fail (guacd logs the error). |
| `/tc-init`, configmap seed scripts from the chart | Belong to the web client chart, not this image. |
| Privileged | Not needed (no device access). |

## 10. Risks, caveats and open questions

- The draft's apt plan is invalid for 26.04 (section 1); the source build is slower and has more moving parts (FreeRDP 3 from Ubuntu instead of upstream's FreeRDP 2 build; 1.6.0 supports both per `configure.ac`, but runtime behaviour with FreeRDP 3 from Ubuntu is UNVERIFIED).
- Package names and `t64` renames in resolute are partly UNVERIFIED (section 1); the `ldd`/`dpkg -S` step is there to avoid guessing runtime names.
- The SHA-256 is pinned and not renovated; keep it in step with `VERSION`.
- guacd has no authentication: anyone who can reach 4822 can make it connect to any host reachable from its network. Keep it on an internal network only (say so in the PR).
- guacd alone is useless (draft caveat): the web client (`guacamole/guacamole`, Tomcat, port 8080, its own config) is a different image, not covered here.
- RDP/VNC/SSH target hosts must be reachable from the container network (draft caveat, inferred).
- Compile time under QEMU for arm64 may be long; no arm64 blocker otherwise.
- Not a database app, so the DB exception does not apply.

## 11. Build and test steps

```sh
cd apps/guacd
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name guacd-probe --read-only --tmpfs /tmp \
  -v guacd-probe-config:/config guacd:1.6.0
docker logs -f guacd-probe
docker run --rm --network container:guacd-probe docker.io/nicolaka/netshoot nc -vz 127.0.0.1 4822
# prove it is not localhost-only: connect from a second container by IP
IP=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' guacd-probe)
docker run --rm docker.io/nicolaka/netshoot nc -vz "$IP" 4822
docker exec guacd-probe sh -c 'ldd /usr/local/lib/libguac-client-rdp.so | grep "not found"'   # expect no output
docker rm -f guacd-probe; docker volume rm guacd-probe-config
forgetool containers test --image guacd:1.6.0 --config ./apps/guacd/container-test.yaml
```

Expected readiness log (guacd, level info): `Guacamole proxy daemon (guacd) version 1.6.0 started` followed by `Listening on host 0.0.0.0, port 4822` (format strings confirmed in `src/guacd/daemon.c` of the 1.6.0 tarball; the printed host is the resolved bound address). The container must stay running and the second-container `nc` must succeed. Best end-to-end check (manual): run the Guacamole web client against it with a VNC or SSH target.

## 12. PR checklist

- [ ] Branch `feat/add-guacd` from `main`; commit and PR title `feat(guacd): add new container`.
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` filled in, only applicable boxes checked.
- [ ] `🤖 This PR is AI generated.` in the Notes section.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- [ ] `docker buildx bake --print` exits 0.
- [ ] Mention in the PR that the draft's apt install was replaced by a source build because resolute has no `guacd` package.
- [ ] Honest untested list: arm64, RDP/VNC/SSH sessions through a real web client, recording and drive paths, and the exact package and plugin names until a build has run. Do not tick "Built container locally" unless it was.
