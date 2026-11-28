# dispatch — implementation plan
> Source: ./draft.md · Target: apps/dispatch/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `v0.7` (latest GitHub release, published 2020-05-08; draft's chart tag is `latest`, so v0.7 is what we pin) |
| Renovate | `datasource=github-releases depName=khlieng/dispatch versioning=loose` (tag has a `v` prefix) |
| License | MIT (GitHub SPDX `MIT`). The release tarball contains only the `dispatch` binary, so the license text must be fetched separately (see section 4). |
| Source | https://github.com/khlieng/dispatch |
| amd64 URL | `https://github.com/khlieng/dispatch/releases/download/v0.7/dispatch_0.7_linux_x64.tar.gz` |
| arm64 URL | `https://github.com/khlieng/dispatch/releases/download/v0.7/dispatch_0.7_linux_arm64.tar.gz` |
| Checksums | Release asset `checksums.txt` (format `<sha256>  <file>`). The Dockerfile reads the value from this file at build time. Checked on 2026-11-23: x64 `7a94cb965de08919a32523116265e7facb69deaa6cfc916adbb34f4083f9e1d9`, arm64 `bf68249f5bbcaafa50f4b72c8401dfe858405705f76985d88d2460737235dca3`. |
| Binary | Static Go ELF (no NEEDED libraries, checked with `readelf -d`), frontend embedded. Tarball content: `dispatch` only. Works on glibc Ubuntu. |
| Upstream Dockerfile | Reviewed: builds on `golang:alpine`, runtime `alpine`, `EXPOSE 80/tcp`, `VOLUME ["/data"]`, `ENTRYPOINT ["/dispatch"]`, `CMD ["--dir=/data"]`. |
| CLI flags (`commands/dispatch.go`) | Persistent: `--dir` (config and data), `--data`, `--conf`, `--reset-config`. Root: `-a/--address`, `-p/--port` (default 80), `--dev`, `-v/--version`. |
| Config | `config.toml` inside `--dir`. If missing, the app writes the embedded `config.default.toml` (mode 0600). Defaults that matter (file at tag `v0.7`): `address = ""`, `port = 80`, `[https] enabled = true, port = 443` (own cert or Let's Encrypt), `[auth] anonymous = true, login = true, registration = true`. The `v0.7` file and server code have no identd or DCC feature. The config file is watched and reloaded live. |
| Env vars | None found: no `AutomaticEnv`/`SetEnvPrefix` in the code (search returned 0). All configuration is flags and `config.toml`. |
| Ports | 80 HTTP (default), 443 HTTPS (default on). Both are privileged, so the plan overrides them with the flag and a seeded config. |
| Data | boltdb, bleve indexes, logs and uploaded certs under `--dir`. |
| Project health | Last push 2023-01-06, last release 2020-05-08, not archived. Frozen upstream. |

## 2. Target layout

```
apps/dispatch/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.toml      # seeded to /config/config.toml when missing (copy-if-missing)
```

`defaults/` is needed because the default config binds privileged ports and enables HTTPS; it is on the `.dockerignore` allow-list. Never `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
```

Static Go binary, so the plain ubuntu base is enough. Closest sibling: `apps/adguardhome-sync` (tarball into `/app`, `defaults/` seeded with `cp -n`, `VOLUME /config`).

## 4. Dockerfile

Pattern of `apps/adguardhome-sync/Dockerfile` with a checksum step and license:

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`; `ENV HOME=/config` (as the sibling).
2. Arch mapping inside one `RUN`: `case "${TARGETARCH}" in amd64) A=x64;; arm64) A=arm64;; *) exit 1;; esac`.
3. Download (VERSION is `v0.7`, files use `0.7`):
   - `curl -fsSL -o /tmp/dispatch.tar.gz "https://github.com/khlieng/dispatch/releases/download/${VERSION}/dispatch_${VERSION#v}_linux_${A}.tar.gz"`
   - `curl -fsSL -o /tmp/checksums.txt "https://github.com/khlieng/dispatch/releases/download/${VERSION}/checksums.txt"`
   - Verify: `(cd /tmp && grep " dispatch_${VERSION#v}_linux_${A}.tar.gz\$" checksums.txt | sed 's#  .*#  dispatch.tar.gz#' | sha256sum -c -)`.
4. `tar xzf /tmp/dispatch.tar.gz -C /app dispatch` (tarball is flat, only `dispatch`).
5. License (not in the tarball): `mkdir -p /usr/share/licenses/dispatch && curl -fsSL -o /usr/share/licenses/dispatch/LICENSE "https://raw.githubusercontent.com/khlieng/dispatch/${VERSION}/LICENSE"`. `LICENSE` exists at tag `v0.7` (MIT).
6. `chown -R apps:apps /app && chmod -R 755 /app`; `rm /tmp/dispatch.tar.gz /tmp/checksums.txt`.
7. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080`; `VOLUME /config`.

No apt packages (`ca-certificates` is in the base for IRC TLS verification).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "dispatch" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=khlieng/dispatch versioning=loose
  default = "v0.7"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/khlieng/dispatch" }
```

Plus `docker-metadata-action`, `group "default"`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64, arm64) exactly as in `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/khlieng/dispatch"
ports:
  - port: 8080
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

Only `TZ` (read by the Go runtime). Do not invent `DISPATCH_*` variables; the app reads none. Port 8080 matches the seeded `port` and the flag in `start.sh`. No dependencies. Port 443 is not listed because the seeded config disables HTTPS.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# seed config only when missing; never overwrite user edits
mkdir -p /config
[ -f /config/config.toml ] || cp /defaults/config.toml /config/config.toml

cd /config
exec /app/dispatch --dir=/config --address=0.0.0.0 --port=8080
```

`defaults/config.toml` is upstream `config.default.toml` (v0.7) with two edits: `port = 8080`, `[https] enabled = false`. TLS is left to a reverse proxy; users can re-enable them in `/config/config.toml` (ports above 1024 only). Keep the rest of the upstream defaults. Take the file content from the `v0.7` tag. The flags are bound to viper (`commands/dispatch.go`), and an explicitly set flag takes precedence over the config file, so `--address` and `--port` win.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/dispatch
- /usr/share/licenses/dispatch/LICENSE
```

Every port in `settings.yaml` (8080) has a probe. No env vars are needed to start. Match the keys against a sibling that uses both `tcp` and `http` (for example `apps/it-tools`); if the schema allows only one per port, keep `http`. DB exception: not applicable.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/data` (chart volume, upstream `--dir=/data`) | `--dir=/config`. The draft says `/config`, the chart `/data`; use `/config` and document the migration (move `/data` contents). |
| `config.toml` auto-write | Pre-seeded from `/defaults`, and `/config` is writable. |
| Ports 80, 443 | Port 8080 via flag and config; HTTPS off, so no privileged bind as UID 568. |
| Let's Encrypt cache `<dir>/letsencrypt` | Only if the user turns it on; under `/config`. |
| Home dir (`go-homedir` default dir) | Not used because `--dir` is explicit; `HOME=/config` anyway. |

Chart expectations (UID 0, writable rootfs) are not carried over: runs as `apps` (568), read-only rootfs OK, not privileged.

## 10. Risks, caveats and open questions

- Upstream is frozen (last release 2020, last commit 2023): old Go dependencies, no security updates. Renovate will never move it. Flag in the PR.
- Users' IRC logins and settings live in `/config` (bolt DB). Anonymous access is on by default in upstream config; consider setting `auth.anonymous = false` in `defaults/config.toml` (open question, changes upstream default).
- Behind a reverse proxy the client uses WebSockets on the same port; nothing to change in the image.
- Check after the first run that nothing writes outside `/config` and `/tmp`.
- Checksum values come from the release's `checksums.txt`, fine but they are published by the same account as the binaries.

## 11. Build and test steps

```sh
cd apps/dispatch
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dispatch-probe --read-only --tmpfs /tmp -v dispatch-probe-config:/config -p 8080:8080 dispatch:v0.7
docker logs -f dispatch-probe     # expect "[HTTP] Listening on port 8080" and "Storing data at /config"
curl -fsS http://127.0.0.1:8080/ | head
forgetool containers test --image dispatch:v0.7 --config ./apps/dispatch/container-test.yaml
docker rm -f dispatch-probe; docker volume rm dispatch-probe-config
```

Also restart with the same volume and confirm `/config/config.toml` is not overwritten, and that `docker exec dispatch-probe ss -ltn` shows only 8080 (no 80/443; `ss` may not be in the base, then probe the ports from another container).

## 12. PR checklist

- Branch `feat/add-dispatch`; commit `feat(dispatch): add new container`; target `main`; PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; check `license/cla`).
- Untested until run: arm64 binary, IRC connection to a real server, config reload, DCC downloads, live Let's Encrypt.
- Mention that upstream is unmaintained.
