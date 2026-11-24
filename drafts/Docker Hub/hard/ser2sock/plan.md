# ser2sock — implementation plan
> Source: ./draft.md · Target: apps/ser2sock/ · Difficulty: hard in the draft (serial hardware), medium to build · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.5.5 (git tag `v1.5.5`, 2017-11-28, newest tag on the tags page). The GitHub "latest release" API returned 404, so there are no formal releases, only tags. |
| Draft tag | `docker.io/tenstartups/ser2sock:latest` (Alpine, `Dockerfile.x64`, clones the master branch). Not used: musl, rolling. |
| Renovate | `datasource=github-tags depName=nutechsoftware/ser2sock versioning=loose extractVersion=^v(?<version>.+)$` (tags are `v1.5.5`, `v1.5.4`, ... and an old `V1.4.1`). UNVERIFIED: that the upper-case `V` tags do not confuse the regex (they are far older). |
| License | GPL-3.0 (COPYING file; the repo license link says GPL-3.0). SPDX `GPL-3.0-only`. UNVERIFIED: only vs or-later. |
| Source | https://github.com/nutechsoftware/ser2sock |
| Download URLs | None. Source archive: `https://github.com/nutechsoftware/ser2sock/archive/refs/tags/v${VERSION}.tar.gz` (standard GitHub URL, UNVERIFIED by fetch). |
| Checksum | No published checksum. Pin the tag, and optionally pin a sha256 computed once with `curl -L ... | sha256sum` as `ARG SRC_SHA256` (UNVERIFIED, not computed in this session). |
| Build | Autotools: `autoreconf -f -i`, `./configure`, `make`; the OpenSSL dev package is needed for SSL (README). A Debian packaging route (`debuild -i -us -uc -b`) also exists and is not used. |
| Config | `/etc/ser2sock/ser2sock.conf`; options `-p` socket port, `-s` serial device (for example `/dev/ttyUSB0`), `-b` baud rate (default 9600), `-f` override config file path (README). The tenstartups wrapper also passes `-i 0.0.0.0` (listen on all interfaces) and calls `-f` as "foreground", which conflicts with the README. UNVERIFIED: run `ser2sock -h` in the built image and resolve this. The config key names are not listed in the README (UNVERIFIED). |
| Ports | No built-in default is documented (`-p` is required). The tenstartups wrapper uses `LISTENER_PORT` default 10000. The draft guessed 2000. The plan uses 10000 (verified wrapper default). |
| Env vars | None are read by ser2sock itself. The reference wrapper reads `SERIAL_DEVICE` (required), `LISTENER_PORT` (default 10000), `BAUD_RATE` (default 9600). Our `start.sh` reads the same names. |
| Upstream Dockerfile reviewed | tenstartups/ser2sock `Dockerfile.x64` at 9553300 and its `entrypoint.sh` (summaries): `alpine:latest`, build tools plus LibreSSL headers, `git clone` + `configure` + `make`, binary to `/usr/local/bin`, config to `/etc/`, entrypoint `exec ser2sock` with `-p $LISTENER_PORT -s $SERIAL_DEVICE -i 0.0.0.0 -b $BAUD_RATE`, `EXPOSE $LISTENER_PORT`. |

## 2. Target layout

- `apps/ser2sock/Dockerfile`
- `apps/ser2sock/docker-bake.hcl`
- `apps/ser2sock/settings.yaml`
- `apps/ser2sock/container-test.yaml`
- `apps/ser2sock/start.sh`

No `defaults/` (settings are passed on the command line). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build stage and the final stage. Plain C binary, glibc on ubuntu. Closest sibling for a compiled-then-copied binary: `apps/adguardhome-sync` (final layout) with the build stage rule from the Dockerfile instructions.

## 4. Dockerfile

1. Build stage `FROM <ubuntu base above> AS build`, `ARG VERSION`, `USER root`:
   ```dockerfile
   RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential autoconf automake libtool pkg-config libssl-dev ca-certificates curl && \
       curl -fsSL -o /tmp/ser2sock.tar.gz "https://github.com/nutechsoftware/ser2sock/archive/refs/tags/v${VERSION}.tar.gz" && \
       mkdir /tmp/src && tar xzf /tmp/ser2sock.tar.gz -C /tmp/src --strip-components=1 && \
       cd /tmp/src && autoreconf -f -i && ./configure --prefix=/usr/local && make && make DESTDIR=/out install
   ```
   Check that `make install` places the binary and the sample config under `/out` (UNVERIFIED); otherwise copy `ser2sock` and `ser2sock.conf` by hand.
2. Final stage `FROM <ubuntu base above>`, `ARG VERSION`, `USER root`: install runtime packages only: `libssl3t64` (check whether the base already has it), `socat` (used for the test PTY, section 7). `rm -rf /var/lib/apt/lists/*`.
3. `COPY --from=build /out/usr/local/bin/ser2sock /usr/local/bin/ser2sock`; config sample to `/defaults/ser2sock.conf` (only if used).
4. Licenses: `mkdir -p /usr/share/licenses/ser2sock && cp /tmp/src/COPYING` in the build stage, then `COPY --from=build /usr/share/licenses/ser2sock /usr/share/licenses/ser2sock`.
5. `ENV HOME=/config LISTENER_PORT=10000 BAUD_RATE=9600`.
6. `USER apps`, then `COPY --chmod=0755 . /`. The user `apps` already belongs to group 20 (`dialout`) in the ubuntu base (`usermod -aG 10,20,...`), which is what allows opening `/dev/ttyUSB*` when the device is passed in.
7. `EXPOSE 10000`, `VOLUME /config`, `WORKDIR /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "ser2sock" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=nutechsoftware/ser2sock versioning=loose extractVersion=^v(?<version>.+)$
  default = "1.5.5"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/nutechsoftware/ser2sock" }
```
Targets: `docker-metadata-action`, `image` (arg `VERSION`, OCI labels), `image-local` (tag `${APP}:${VERSION}`, `type=docker`), `image-all` (`linux/amd64`, `linux/arm64`; both compile natively from source), `group "default"` with `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/nutechsoftware/ser2sock"`.
- `ports`: `10000` tcp, required false (user-configurable through `LISTENER_PORT`; if changed, `EXPOSE` and the published port change with it).
- `env`: `SERIAL_DEVICE` default `""`, required false (empty means demo mode, see section 7); `LISTENER_PORT` default `10000`, required false; `BAUD_RATE` default `9600`, required false; `TZ` default `Etc/UTC`, required false.
- `volumes`: `/config` required false (nothing is persisted by default; kept for an optional custom `ser2sock.conf` passed with `-f`).
- `dependencies:` none.

## 7. start.sh

- `set -eu`; defaults `LISTENER_PORT="${LISTENER_PORT:-10000}"`, `BAUD_RATE="${BAUD_RATE:-9600}"`.
- If `SERIAL_DEVICE` is set: `[ -e "$SERIAL_DEVICE" ] || { echo "serial device $SERIAL_DEVICE not found, pass it with --device"; exit 1; }`.
- If it is empty (container test, no hardware): create a virtual serial pair in `/tmp` so the listener can be tested: `socat -d -d pty,raw,echo=0,link=/tmp/ttyV0 pty,raw,echo=0,link=/tmp/ttyV1 &` and use `/tmp/ttyV0`; log `no SERIAL_DEVICE set, running in demo mode on a virtual port`. UNVERIFIED that ser2sock accepts a PTY and that it stays up without data; if not, fall back to filePaths and healthCommands and state that the port probe is replaced (not allowed to be dropped silently, escalate to the user).
- Final command, bound to all interfaces, foreground flag per `ser2sock -h`: `exec ser2sock -p "$LISTENER_PORT" -s "$SERIAL_DEVICE" -b "$BAUD_RATE" -i 0.0.0.0 [foreground flag]`. The `-i` and foreground options come from the tenstartups wrapper and are UNVERIFIED against the 1.5.5 source; confirm with `ser2sock -h`.
- No writes to `/app` or `/config`; the config file is not seeded because the command line carries all settings.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '10000'
filePaths:
- /usr/local/bin/ser2sock
```
The test has no env and no serial device, so the tcp probe depends on the demo mode in section 7. The real-device path (`SERIAL_DEVICE` set) is not covered by the test.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 568 and read-only rootfs (medium confidence): confirmed possible. Run as `apps`, nothing writes to `/app`.
- Write paths: the virtual serial links and `socat` in `/tmp` (demo mode only); ser2sock may write a PID file or log (UNVERIFIED; check `--help` and the config sample, remap to `/tmp` or stdout).
- Hardware: the device must be passed with `--device /dev/ttyUSB0` (or `devices:` in compose). The container user needs access: group 20 (dialout) is present in the image, but the host device's group id may differ; use `--group-add <gid>` or a udev rule. This is not privileged mode and not a blocker.
- Draft says "extra persistence: none (config is /config)": matches.

## 10. Risks, caveats and open questions

- The source is old (last tag 2017) and the README's version note is older still; the project may be unmaintained. Confirm with the user that this is acceptable.
- The tenstartups/README conflict on the `-f` flag and the undocumented default port (draft 2000 vs wrapper 10000).
- PTY demo mode may not work; if so the test needs a different approach (open question).
- Serial hardware cannot be tested in CI, so the real-device path is untested.
- Not a blocker: arm64 builds natively, no GPU, no privileged mode. Alpine/musl is not used.

## 11. Build and test steps

Follow `.github/instructions/build-test-protocol.instructions.md` for `apps/ser2sock`, one app at a time, 10 rounds at most.

```sh
cd apps/ser2sock
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create ser2sock-probe-config
docker run --rm -d --name ser2sock-probe --read-only --tmpfs /tmp \
  -v ser2sock-probe-config:/config ser2sock:1.5.5
docker logs -f ser2sock-probe
forgetool containers test --image ser2sock:1.5.5 --config ./apps/ser2sock/container-test.yaml
docker rm -f ser2sock-probe; docker volume rm ser2sock-probe-config
```

- Expected readiness signal: a log line showing the listener started on port 10000 (UNVERIFIED wording) in demo mode and the port open.
- Always start with an empty `/config` volume (fresh volume each round).
- By-hand checks outside the test: run with --device /dev/ttyUSB0 -e SERIAL_DEVICE=/dev/ttyUSB0 on a host with a real adapter (or a socat PTY pair) and connect with nc to port 10000.
- Only try arm64 if an amd64 build is green and a failure is arm64-specific.

## 12. PR checklist

- Branch `feat/add-ser2sock` from a freshly pulled `main`; commit and PR title `feat(ser2sock): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` keeping its sections; check only the boxes that apply. Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows the status). Only the user can sign it.
- Confirm: changes only in `apps/ser2sock/`; `ARG VERSION` matches `docker-bake.hcl`; `docker buildx bake --print` passes; final `USER apps`; `COPY --chmod=0755 . /` present; runs read-only with empty `/config`; no assertion weakened.
- Not tested, to state honestly in the PR unless done: real serial hardware, arm64, the PTY demo mode assumption, baud rates other than 9600.
