# sshwifty — implementation plan
> Source: ./draft.md · Target: apps/sshwifty/ · Difficulty: easy · Role: main · Verified on 2026-11-23 (re-checked 2026-11-24)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `0.4.13-beta-release` (released 2026-11-24 as GitHub tag/release `0.4.13-beta-release-prebuild`, marked Latest). The draft links `0.4.12-beta-release`, which is now one release behind. 0.4.13 fixes two critical security issues (credentials kept in browser localStorage; unbounded WebSocket message size), so do not pin 0.4.12. |
| Renovate | `datasource=github-releases depName=nirui/sshwifty versioning=loose extractVersion=^(?<version>.+)-prebuild$` (the release tag is `<version>-prebuild`, and `VERSION` keeps the `0.4.13-beta-release` part). The recent releases (0.4.6 to 0.4.13) all use the `-prebuild` suffix and are not flagged prerelease. UNVERIFIED: older tag styles and the Renovate behaviour itself. |
| License | AGPL v3 or later: the header of `sshwifty.go` at the release tag says "either version 3 of the License, or (at your option) any later version" (`LICENSE.md` is the AGPL v3 text). SPDX `AGPL-3.0-or-later`. |
| Source URL | https://github.com/nirui/sshwifty/ (the draft says `niruix/sshwifty`, which is only the Docker Hub user; the GitHub owner is `nirui`) |
| amd64 | https://github.com/nirui/sshwifty/releases/download/0.4.13-beta-release-prebuild/sshwifty_0.4.13-beta-release_linux_amd64.tar.gz (HTTP 206 checked) |
| arm64 | https://github.com/nirui/sshwifty/releases/download/0.4.13-beta-release-prebuild/sshwifty_0.4.13-beta-release_linux_arm64.tar.gz (HTTP 206 checked) |
| Checksum source | `SUM.sha512` asset in the same release (sha512). amd64 `b66183178ade529f308055aa1283d3a83b0c32f77fb07eb07f21d8fadcac15d0ea9104f6f133eb66959e0e3281c66d8f99175c5bc55a91f4ed785aa7571339f7`, arm64 `53e5a0fb5ab030e6a24bc725cb7daacd89c31464c60d1d5aa79da77c235f81da69e38addb145d9c5e50e7f292ce17990c14d363e781088b0c1e2d5369e7e230f`. Verify in the Dockerfile with `sha512sum -c` from the downloaded `SUM.sha512` (the file also lists other platforms, so filter with `grep`). A GPG signature (`GPG.asc`) is also shipped; not used. |
| Archive content (amd64) | `sshwifty_linux_amd64` (statically linked Go ELF, 23 MB), `LICENSE.md`, `DEPENDENCIES.md`, `README.md`, `Note`, `SUM.sha512`, `GPG.asc`, `preset.example.json`, `sshwifty.conf.example.json`, `src`. The arm64 archive holds `sshwifty_linux_arm64`. Static binary, so glibc vs musl is irrelevant. |
| Upstream Dockerfile | https://raw.githubusercontent.com/nirui/sshwifty/master/Dockerfile reviewed: Debian multi-stage build, final `alpine:latest`, `adduser -D sshwifty`, `USER sshwifty`, `EXPOSE 8182`, `ENTRYPOINT ["/sshwifty.sh"]` which writes `SSHWIFTY_DOCKER_TLSCERT` and `SSHWIFTY_DOCKER_TLSCERTKEY` to `/tmp/cert` and `/tmp/certkey` and then runs `/sshwifty`. |
| Env vars (Dockerfile ENV list and README) | `SSHWIFTY_HOSTNAME`, `SSHWIFTY_SHAREDKEY`, `SSHWIFTY_DIALTIMEOUT` (10), `SSHWIFTY_SOCKS5`, `SSHWIFTY_SOCKS5_USER`, `SSHWIFTY_SOCKS5_PASSWORD`, `SSHWIFTY_HOOK_BEFORE_CONNECTING`, `SSHWIFTY_HOOKTIMEOUT` (30), `SSHWIFTY_LISTENINTERFACE` (0.0.0.0), `SSHWIFTY_LISTENPORT` (8182), `SSHWIFTY_INITIALTIMEOUT`, `SSHWIFTY_READTIMEOUT`, `SSHWIFTY_WRITETIMEOUT`, `SSHWIFTY_HEARTBEATTIMEOUT`, `SSHWIFTY_READDELAY`, `SSHWIFTY_WRITEELAY` (sic, upstream spelling), `SSHWIFTY_TLSCERTIFICATEFILE`, `SSHWIFTY_TLSCERTIFICATEKEYFILE`, `SSHWIFTY_DOCKER_TLSCERT`, `SSHWIFTY_DOCKER_TLSCERTKEY`, `SSHWIFTY_PRESETS`, `SSHWIFTY_SERVERMESSAGE`, `SSHWIFTY_ONLYALLOWPRESETREMOTES`; also in 0.4.13 README/binary: `SSHWIFTY_ALLOWEDORIGINS`, `SSHWIFTY_PINNEDSSHHOSTFINGERPRINTS`, `SSHWIFTY_CONFIG` (config file path). |
| Config precedence | README: the loader tries file(s) from default paths first, and only when all fail uses env vars; `SSHWIFTY_CONFIG=<file>` forces one file. The example file `sshwifty.conf.example.json` has `ListenInterface` `127.0.0.1`, so a config file must be edited to listen on all interfaces. |
| Port | 8182/http (draft correct) |
| State | None. Optional config file only (the draft: "optional config in /config"). |

## 2. Target layout

```
apps/sshwifty/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` is needed (env-only start works with an empty `/config`). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: static Go binary, no runtime packages. `curl`, `tar`, `ca-certificates` are in the ubuntu base. Closest sibling: `apps/adguardhome-sync` (GitHub release tarball, `/app`, start.sh `exec`).

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `ARG TARGETARCH` (`amd64`/`arm64` match upstream names).
2. `USER root`, one RUN:
   ```sh
   base="https://github.com/nirui/sshwifty/releases/download/${VERSION}-prebuild"
   file="sshwifty_${VERSION}_linux_${TARGETARCH}.tar.gz"
   curl -fsSL -o "/tmp/${file}" "${base}/${file}"
   curl -fsSL -o /tmp/SUM.sha512 "${base}/SUM.sha512"
   (cd /tmp && grep "${file}\$" SUM.sha512 | sha512sum -c -)
   mkdir -p /tmp/x /usr/share/licenses/sshwifty
   tar xzf "/tmp/${file}" -C /tmp/x
   install -m 0755 "/tmp/x/sshwifty_linux_${TARGETARCH}" /app/sshwifty
   cp /tmp/x/LICENSE.md /tmp/x/DEPENDENCIES.md /usr/share/licenses/sshwifty/
   install -d /usr/share/doc/sshwifty && cp /tmp/x/sshwifty.conf.example.json /tmp/x/preset.example.json /usr/share/doc/sshwifty/
   chown -R apps:apps /app && chmod -R 755 /app
   rm -rf /tmp/*
   ```
   The `SUM.sha512` lines are `<hash>  ./<file>`; the `grep` on the file name still matches. Confirm the exact format at build time.
3. `ENV HOME=/config`, no cache variables needed.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8182`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP = "sshwifty"`
- `VERSION`, preceded by `// renovate: datasource=github-releases depName=nirui/sshwifty versioning=loose extractVersion=^(?<version>.+)-prebuild$`, default `"0.4.13-beta-release"`
- `LICENSE = "AGPL-3.0-or-later"`, `SOURCE = "https://github.com/nirui/sshwifty/"`
- Targets: `docker-metadata-action`, `image` (args.VERSION and OCI source/licenses labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Run `docker buildx bake --print`. If the odd `-beta-release` version string makes the image tag awkward, keep it anyway so `VERSION` equals the Dockerfile `ARG`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/nirui/sshwifty/"
ports:
  - port: 8182
    protocol: tcp
    required: true
env:
  - {name: SSHWIFTY_LISTENINTERFACE, default: "0.0.0.0", required: false}
  - {name: SSHWIFTY_LISTENPORT, default: "8182", required: false}
  - {name: SSHWIFTY_SHAREDKEY, default: "", required: false}
  - {name: SSHWIFTY_HOSTNAME, default: "", required: false}
  - {name: SSHWIFTY_ALLOWEDORIGINS, default: "", required: false}
  - {name: SSHWIFTY_DIALTIMEOUT, default: "10", required: false}
  - {name: SSHWIFTY_SOCKS5, default: "", required: false}
  - {name: SSHWIFTY_SOCKS5_USER, default: "", required: false}
  - {name: SSHWIFTY_SOCKS5_PASSWORD, default: "", required: false}
  - {name: SSHWIFTY_PRESETS, default: "", required: false}
  - {name: SSHWIFTY_ONLYALLOWPRESETREMOTES, default: "", required: false}
  - {name: SSHWIFTY_SERVERMESSAGE, default: "", required: false}
  - {name: SSHWIFTY_TLSCERTIFICATEFILE, default: "", required: false}
  - {name: SSHWIFTY_TLSCERTIFICATEKEYFILE, default: "", required: false}
  - {name: SSHWIFTY_DOCKER_TLSCERT, default: "", required: false}
  - {name: SSHWIFTY_DOCKER_TLSCERTKEY, default: "", required: false}
  - {name: SSHWIFTY_CONFIG, default: "", required: false}
  - {name: SSHWIFTY_HOOK_BEFORE_CONNECTING, default: "", required: false}
  - {name: SSHWIFTY_HOOKTIMEOUT, default: "", required: false}
  - {name: SSHWIFTY_PINNEDSSHHOSTFINGERPRINTS, default: "", required: false}
  - {name: SSHWIFTY_INITIALTIMEOUT, default: "", required: false}
  - {name: SSHWIFTY_READTIMEOUT, default: "", required: false}
  - {name: SSHWIFTY_WRITETIMEOUT, default: "", required: false}
  - {name: SSHWIFTY_HEARTBEATTIMEOUT, default: "", required: false}
  - {name: SSHWIFTY_READDELAY, default: "", required: false}
  - {name: SSHWIFTY_WRITEELAY, default: "", required: false}
  - {name: SSHWIFTY_DEBUG, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: false
dependencies: []
```
Write the env entries in the multi-line form siblings use. The list covers the variables read in `sshwifty.go` and `loader_enviro.go` (the two `SSHWIFTY_DOCKER_*` ones are handled by `start.sh`, as by the upstream wrapper). When a config file is used, the other env vars are ignored. `/config` is only for an optional config file, hence `required: false`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
export SSHWIFTY_LISTENINTERFACE="${SSHWIFTY_LISTENINTERFACE:-0.0.0.0}"
export SSHWIFTY_LISTENPORT="${SSHWIFTY_LISTENPORT:-8182}"
# optional TLS material passed as env (same as the upstream image); keep it in /tmp, mode 0600
if [ -n "${SSHWIFTY_DOCKER_TLSCERT:-}" ] && [ -n "${SSHWIFTY_DOCKER_TLSCERTKEY:-}" ]; then
  umask 077
  printf '%s\n' "${SSHWIFTY_DOCKER_TLSCERT}" > /tmp/cert
  printf '%s\n' "${SSHWIFTY_DOCKER_TLSCERTKEY}" > /tmp/certkey
  export SSHWIFTY_TLSCERTIFICATEFILE=/tmp/cert SSHWIFTY_TLSCERTIFICATEKEYFILE=/tmp/certkey
fi
# a user-provided config file wins over env, only when it exists
if [ -z "${SSHWIFTY_CONFIG:-}" ] && [ -s /config/sshwifty.conf.json ]; then
  export SSHWIFTY_CONFIG=/config/sshwifty.conf.json
fi
cd /config
exec /app/sshwifty
```
Idempotent; nothing is seeded into `/config` (an example is in `/usr/share/doc/sshwifty/`). Binds `0.0.0.0` by default because upstream's example config uses `127.0.0.1`. No writes to `/app`. Secrets stay in env, never in args. Do not log `SSHWIFTY_SHAREDKEY`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8182'
  path: /
tcp:
- port: '8182'
filePaths:
- /app/sshwifty
- /usr/share/licenses/sshwifty/LICENSE.md
```
Runs with no env, so env-only defaults are tested. `GET /` serves the embedded UI (HTTP 200 expected; confirm, and if the app answers a different status with an empty `AllowedOrigins`, assert that status). The TLS and config-file paths are not covered by the test: run them by hand. `timeoutSeconds` as in `apps/adguardhome-sync` (not set there).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runtime writes: only the TLS temp files written by the upstream wrapper (`/tmp/cert`, `/tmp/certkey`), which we keep in `/tmp`. The app has no database or log files.
- Binary in `/app` is read-only, owned by `apps` (568); port 8182 is unprivileged. The chart's `runAsNonRoot false` / `runAsUser 0` is not needed.
- `/config` holds only an optional `sshwifty.conf.json`; there is no extra persistence (draft: none).
- Without `SSHWIFTY_CONFIG` the app searches `<user home>/.config/sshwifty.conf.json`, `/etc/sshwifty.conf.json` and `sshwifty.conf.json` next to the binary (`application/configuration/loader_file.go`), then falls back to env vars. The home comes from Go's `user.Current()`, which normally reads the passwd entry rather than `HOME` (UNVERIFIED for this static binary), so rely on the explicit `SSHWIFTY_CONFIG` set in `start.sh`, not on `HOME`.

## 10. Risks, caveats and open questions

- Draft caveat: no user accounts. Without `SSHWIFTY_SHAREDKEY` anyone who can reach the port can use the client to reach internal SSH hosts (SSRF-like). Document the key, `SSHWIFTY_ONLYALLOWPRESETREMOTES` and a reverse proxy in the PR; do not set a default key.
- 0.4.13 fixes critical issues in 0.4.12 and earlier; this plan targets 0.4.13 (draft links 0.4.12).
- 0.4.13 introduces CORS/`Origin` handling changes and "empty `AllowedOrigins` is not verified"; behind a proxy set `SSHWIFTY_ALLOWEDORIGINS` as needed (UNVERIFIED exact semantics).
- Version string `0.4.13-beta-release` and the `-prebuild` tag make the Renovate regex fragile; verify with a dry run.
- Draft says arm64 depends on upstream: confirmed, `linux_arm64` is published and listed in `SUM.sha512`.
- The docs mention `SSHWIFTY_WRITEELAY` (typo in upstream); keep the exact spelling.

## 11. Build and test steps

```sh
cd apps/sshwifty
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create sshwifty-probe-config
docker run --rm -d --name sshwifty-probe --read-only --tmpfs /tmp \
  -v sshwifty-probe-config:/config sshwifty:0.4.13-beta-release
docker logs -f sshwifty-probe
forgetool containers test --image sshwifty:0.4.13-beta-release --config ./apps/sshwifty/container-test.yaml
docker rm -f sshwifty-probe; docker volume rm sshwifty-probe-config
```
Readiness signal: a log line from the server about listening/serving on `0.0.0.0:8182` (exact text UNVERIFIED), the process stays up and `GET /` answers. Manual extras: connect from a second container; run with `SSHWIFTY_DOCKER_TLSCERT`/`KEY` on `--read-only`; run with a mounted `/config/sshwifty.conf.json` (copy of the example with `ListenInterface` `0.0.0.0`).

## 12. PR checklist

- Branch `feat/add-sshwifty`, commit and PR title `feat(sshwifty): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` and put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` shows the status).
- State what is untested unless run: arm64 build/run, TLS env path, config-file path, SharedKey/origin behaviour, Renovate regex.
- Do not tick "Built container locally" unless it was built and run.
