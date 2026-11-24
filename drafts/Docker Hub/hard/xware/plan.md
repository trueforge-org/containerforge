# xware — implementation plan
> Source: ./draft.md · Target: apps/xware/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | UNVERIFIED: no upstream version number. The only artifact is `xware.tar.bz` committed in `github.com/caiguai/docker-xware` (last push 2017-02-04, Docker Hub `caiguai/docker-xware:latest`, last updated 2017-02-04, ~200k pulls). Proposed image version: `0.0.0-20170204` style date tag, or the repo commit `2ea1f2f62c173d44beaef2a44005cc2696d2710c`. |
| Renovate | Not applicable: there is no upstream release feed. Use `// renovate: datasource=git-refs depName=https://github.com/caiguai/docker-xware versioning=loose` only as a comment marker, knowing no update will come. |
| License | UNVERIFIED and likely proprietary. Xunlei (Thunder) closed-source binary; neither the caiguai repo nor the tarball carries a license (GitHub license field empty). No SPDX id; the only honest value is `LicenseRef-Proprietary-Xunlei`. Redistribution rights are NOT established. |
| Source | https://github.com/caiguai/docker-xware (draft links only https://www.xunlei.com/ and https://help.xunlei.com/) |
| Download | `https://github.com/caiguai/docker-xware/raw/2ea1f2f62c173d44beaef2a44005cc2696d2710c/xware.tar.bz` (1,821,102 bytes). Only x86; no arm64. |
| Checksum | Upstream publishes none. Observed sha256 of the file at HEAD: `2142d2f80cd1f657a5be51b8d1191c4a21eb96b19644887965e47685222ec201` (compute and pin at implementation). |
| Archive contents | `portal`, `lib/vod_httpserver`, `lib/ETMDaemon`, `lib/EmbedThunderManager`. All are ELF 32-bit i386 executables, interpreter `/lib/ld-linux.so.2`, linked against glibc symbols no newer than 2.2 (checked with `strings`). `ETMDaemon` reads `../cfg/etd.cfg`, writes `/tmp/thunder/` (crashinfo, softdog). `portal` runs `wget -O %s http://127.0.0.1:%d/getsysinfo` (local control port). |
| Upstream Dockerfile | Reviewed: `debian:wheezy-slim`, installs old i386 libs from bundled `.deb` files (`libc6-i386`, `lib32z1`, `libncursesw5`, `libprocps0`, `procps`), `ADD xware.tar.bz /xware/bin/`, `VOLUME /xware/TDDOWNLOAD`, `EXPOSE 9000`, `CMD ./start.sh`. |
| start.sh (upstream) | Rewrites `/etc/resolv.conf` (needs root), then loops: if `vod_httpserver` is not running, run `./bin/portal`; sleeps 60s. README runs it with `--net=host` and `-v data:/xware/TDDOWNLOAD`. |
| Port | `9000` (upstream `EXPOSE`; the draft's `2345/http` is NOT supported by anything found). Protocol and bind address UNVERIFIED (likely localhost only, used by `portal`). |
| Env vars | None in upstream. |
| Service status | Xunlei Xware remote download relies on Xunlei cloud (activation code shown in logs, bound at the Xunlei remote-download site); service availability today UNVERIFIED. |

## 2. Target layout

```
apps/xware/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`, `etc/`, `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: vendor binary on ubuntu (draft). Closest sibling: `apps/adguardhome-sync` (download + extract to `/app`). The base lacks 32-bit libs, so `libc6-i386` (and `lib32z1`/`libncursesw6` equivalents) are added via `dpkg --add-architecture i386` or the amd64 multilib package `libc6-i386`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Fail early on non-amd64: `RUN test "${TARGETARCH}" = "amd64"` (the binaries are i386-only; `image-all` must be amd64 only, see section 5).
3. `apt-get update && apt-get install -y --no-install-recommends libc6-i386 lib32z1 && rm -rf /var/lib/apt/lists/*` (package names for 26.04 UNVERIFIED; `libncursesw5`/`libprocps0` from the upstream Debian wheezy debs are likely unnecessary because the binaries need only libc, check with `ldd` using `LD_TRACE_LOADED_OBJECTS=1 /lib/ld-linux.so.2 ./portal`).
4. Download and verify:
   ```
   curl -fsSL -o /tmp/xware.tar.bz "https://github.com/caiguai/docker-xware/raw/${XWARE_REF}/xware.tar.bz" && \
   echo "${XWARE_SHA256}  /tmp/xware.tar.bz" | sha256sum -c - && \
   mkdir -p /app/xware && tar xjf /tmp/xware.tar.bz -C /app/xware
   ```
   (`bzip2` is needed for `tar -j`; add to apt list if the base lacks it.)
5. Config dir: `rm -rf /app/xware/cfg; ln -s /config/cfg /app/xware/cfg` (binary reads `../cfg/etd.cfg` relative to `lib/`), and `ln -s /config/TDDOWNLOAD /app/xware/TDDOWNLOAD` for downloads.
6. License files: no license exists upstream. Store a `NOTICE` with source URL, commit and the sha256 in `/usr/share/licenses/xware/NOTICE` (written by the Dockerfile with `printf`).
7. `chown -R root:root /app && chmod -R a+rX /app`; `rm -rf /tmp/*`.
8. `ENV HOME=/tmp`, `EXPOSE 9000`, `VOLUME /config`, `WORKDIR /app/xware`, `CMD ["/start.sh"]`.
9. `USER apps`, then `COPY --chmod=0755 . /`. Image ends with `USER apps`.

## 5. docker-bake.hcl

- `APP` = `xware`
- `VERSION`:
  ```hcl
  // renovate: datasource=git-refs depName=https://github.com/caiguai/docker-xware versioning=loose
  default = "2ea1f2f"
  ```
  (a short commit sha stands in for a version; the Dockerfile uses the full sha through a second variable `XWARE_REF` and `XWARE_SHA256`). Final choice of version string UNVERIFIED, needs maintainer approval.
- `LICENSE` = `LicenseRef-Proprietary-Xunlei` (see section 10), `SOURCE` = `https://github.com/caiguai/docker-xware/`
- `image-all` MUST list only `linux/amd64` (not the usual two platforms) because the binaries are i386.
- Other targets as in `apps/adguardhome-sync/docker-bake.hcl`; validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/caiguai/docker-xware/"
ports:
  - port: 9000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No `dependencies`. Port 9000 comes from the upstream `EXPOSE`; the draft's 2345 is dropped as unsupported by evidence.

## 7. start.sh

- `set -euo pipefail`; `mkdir -p /config/cfg /config/TDDOWNLOAD /tmp/thunder`.
- No `/etc/resolv.conf` rewrite (upstream needs root; use the container's DNS).
- Loop equivalent to upstream but with signal handling and no `ps | grep`: run `/app/xware/portal` in the foreground under `exec` is not possible if `portal` daemonizes its children (UNVERIFIED), so: start `./portal` in background, `trap 'kill 0' TERM INT`, then `while pgrep -x vod_httpserver >/dev/null || pgrep -x portal >/dev/null; do sleep 60; done` and re-launch `portal` if both are gone (same idea as upstream). Final command: `wait`.
- Print the activation code location hint: the code appears in the portal output (stdout), which is already visible in `docker logs`.
- The service has no listening address option, so no binding changes are possible.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '9000'
filePaths:
- /app/xware/portal
- /app/xware/lib/ETMDaemon
- /usr/share/licenses/xware/NOTICE
```

`timeoutSeconds`: take the default used by `apps/adguardhome-sync` (none) and add a modest value if the daemon is slow. Caveat: whether port 9000 actually listens without activation and without Xunlei cloud reachability is UNVERIFIED; if it does not, replace the `tcp` probe with a process check only if the schema accepts one, and document why. Do not weaken it silently.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/xware/cfg/*` (config, device id, binding state) | symlink `/app/xware/cfg` -> `/config/cfg` |
| `/xware/TDDOWNLOAD` | symlink to `/config/TDDOWNLOAD` (downloads on the persistent volume; users can bind-mount a larger disk on `/config/TDDOWNLOAD`) |
| `/tmp/thunder/*` | already `/tmp` (`--tmpfs /tmp`) |
| `/etc/resolv.conf` rewrite | removed |

Draft expected runAsUser 0, writable rootfs. Target is UID 568, read-only rootfs; this is plausible but UNVERIFIED because the binaries are closed. `net=host` (upstream README) is not required by the container itself; Xunlei LAN features may need it.

## 10. Risks, caveats and open questions

- BLOCKER candidate: licensing. Closed-source Xunlei binary with no license, shipped inside a third-party GitHub repo; distributing it in `ghcr.io/trueforge-org` is likely not permitted. Recommend the maintainers decide before any build; the safer outcome is to not publish this image.
- Binary is i386 only, 2017-era; no arm64 (`image-all` amd64 only) and glibc/ld compatibility on Ubuntu 26.04 is UNVERIFIED.
- Depends on Xunlei cloud services; the remote-download service may no longer work (UNVERIFIED), which would make the container pointless.
- Port 9000 vs the draft's 2345: unverified which is correct, and the binding may be localhost only.
- Unpinned upstream `latest` of an abandoned image: the plan pins by commit and sha256 instead.
- Container needs outbound internet.

## 11. Build and test steps

```sh
cd apps/xware
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create xware-probe-config
docker run --rm -d --name xware-probe --read-only --tmpfs /tmp \
  -v xware-probe-config:/config xware:2ea1f2f
docker logs -f xware-probe
forgetool containers test --image xware:2ea1f2f --config ./apps/xware/container-test.yaml
docker rm -f xware-probe; docker volume rm xware-probe-config
```

Expected readiness signal: `portal` output with an activation code or `vod_httpserver`/`ETMDaemon` running (UNVERIFIED wording); `ss -ltn` shows 9000. Without network, a failure to reach Xunlei cloud should not exit the loop.

## 12. PR checklist

- Branch `feat/add-xware`, commit `feat(xware): add new container`, PR title the same, target `main`. Hold the PR until the licensing question is answered.
- PR template filled in; Notes contains `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: everything runtime (i386 libs on 26.04, port 9000, Xunlei cloud, read-only rootfs), arm64 not supported, license unresolved.
