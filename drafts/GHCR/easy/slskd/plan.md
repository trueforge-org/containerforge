# slskd — implementation plan
> Source: ./draft.md · Target: apps/slskd/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 0.26.2 (tag `0.26.2`, published 2026-10-23). Matches the chart image `ghcr.io/slskd/slskd:0.26.2`. Source: `gh api repos/slskd/slskd/releases/latest` |
| Renovate | `datasource=github-releases depName=slskd/slskd versioning=semver` (tags have no `v` prefix) |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`; upstream image label `AGPL-3.0-only`). Use `AGPL-3.0-only` in the bake `LICENSE` to match the upstream label. https://github.com/slskd/slskd/blob/master/LICENSE |
| Source URL | https://github.com/slskd/slskd |
| Download (amd64) | https://github.com/slskd/slskd/releases/download/0.26.2/slskd-0.26.2-linux-x64.zip (glibc build; do NOT use `linux-musl-x64`, the Ubuntu base is glibc) |
| Download (arm64) | https://github.com/slskd/slskd/releases/download/0.26.2/slskd-0.26.2-linux-arm64.zip |
| Checksum source | None published on the release (no sha or sum asset). UNVERIFIED: no upstream checksum. Plan: pin a SHA256 per arch, see section 4. |
| Bundled .NET runtime | Confirmed from `bin/publish` at commit `e472ecd`: `dotnet publish ... --self-contained --runtime $runtime -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true`. The zip is self-contained, so no apt .NET runtime is needed. This resolves the draft's open caveat. (Zip contents not inspected; the single-file self-extract is the point to verify on the first run.) |
| Upstream Dockerfile reviewed | https://github.com/slskd/slskd/blob/e472ecd/Dockerfile. Runtime `mcr.microsoft.com/dotnet/runtime-deps:10.0-noble`; installs `jq wget tini gosu`; creates `slskd` 1000:1000; `/.net` chmod 777 (`DOTNET_BUNDLE_EXTRACT_BASE_DIR=/.net`); a custom `/entrypoint.sh` handles `--user`, PUID/PGID (`gosu`) and root modes; `ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]`; `CMD ["./slskd"]`; `WORKDIR /slskd`; `HEALTHCHECK ... wget -q -O - http://localhost:${SLSKD_HTTP_PORT}/health`. |
| Env vars (real) | From the upstream Dockerfile `ENV` (v0.26.2 at `e472ecd`): `SHELL`, `DOTNET_EnableDiagnostics=0`, `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/.net`, `DOTNET_gcServer=0`, `DOTNET_gcConcurrent=1`, `DOTNET_GCHeapHardLimit=0x80000000`, `DOTNET_GCConserveMemory=9`, `SLSKD_UMASK=0022`, `SLSKD_HTTP_PORT=5030`, `SLSKD_HTTPS_PORT=5031`, `SLSKD_SLSK_LISTEN_PORT=50300`, `SLSKD_APP_DIR=/app`. Entrypoint also reads `PUID`, `PGID`. App config options use `SLSKD_*` (`docs/config.md`): `SLSKD_CONFIG`, `SLSKD_DOWNLOADS_DIR`, `SLSKD_INCOMPLETE_DIR`, `SLSKD_SHARED_DIR`, `SLSKD_SHARE_CACHE_STORAGE_MODE`, `SLSKD_UPLOAD_SLOTS`, `SLSKD_DOWNLOAD_SLOTS`, `SLSKD_HEADLESS`, `SLSKD_REMOTE_CONFIGURATION`. |
| Soulseek credentials | Account username and password are needed to connect (draft, inferred). UNVERIFIED: exact `SLSKD_SLSK_USERNAME` / `SLSKD_SLSK_PASSWORD` names not confirmed in `docs/config.md`; confirm in the Soulseek section before writing `settings.yaml`. |
| Ports | 5030/tcp HTTP web UI; 5031/tcp HTTPS (optional, TLS); 50300/tcp Soulseek peer listener. |
| Data paths | `SLSKD_APP_DIR` (config `slskd.yml`, state, logs). Downloads, incomplete and shares paths are user-configured (`SLSKD_DOWNLOADS_DIR`, `SLSKD_INCOMPLETE_DIR`, `SLSKD_SHARED_DIR`). |
| arm64 | Yes: `slskd-0.26.2-linux-arm64.zip`. |
| copy-from | `ghcr.io/slskd/slskd:0.26.2` exists but is not needed: the release zip is used directly. |
| Dependencies | None. |

## 2. Target layout

- `apps/slskd/Dockerfile`
- `apps/slskd/docker-bake.hcl`
- `apps/slskd/settings.yaml`
- `apps/slskd/start.sh` (replaces upstream `/entrypoint.sh`; no `gosu`, no PUID/PGID, no `tini`)
- `apps/slskd/container-test.yaml`

No `defaults/`, `etc/`, `health/` needed. The app creates its own config on first start. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The draft and the .NET rule say ubuntu. The .NET runtime is bundled in the release zip (section 1), so the final stage needs no runtime package. Build stage (only for `unzip` and the checksum) uses the same base. Closest sibling: `apps/webgrabplus` (.NET on ubuntu, per the fenrus plan reference) and `apps/valkey` for the `health/` pattern.

## 4. Dockerfile

1. `FROM <ubuntu> AS fetch`: `ARG VERSION`, `ARG TARGETARCH`, `ARG SHA256_X64`, `ARG SHA256_ARM64`, `USER root`. Install `unzip` (UNVERIFIED whether the base has it; check at build time).
2. Map `amd64` to `x64`, `arm64` to `arm64`; any other arch fails with `exit 1`.
3. Download `slskd-${VERSION}-linux-${ARCH}.zip` to `/tmp`, verify with the pinned SHA256 for that arch, unzip to `/tmp/slskd`.
   - No upstream checksum exists. Pin the hashes computed from the downloaded assets and note in the Dockerfile comment that they were computed locally (not upstream). Flag in PR.
4. Final stage: `FROM <ubuntu>`, `ARG VERSION`, `USER root`.
   - `COPY --from=fetch /tmp/slskd /app`. Set `chown -R apps:apps /app && chmod -R 755 /app`. Keep the upstream `LICENSE` at `/usr/share/licenses/slskd/LICENSE` if the zip ships one (UNVERIFIED), otherwise copy the file from the repo at tag `0.26.2`.
   - `rm -rf /tmp/*`.
5. `ENV SLSKD_APP_DIR=/config SLSKD_HTTP_PORT=5030 SLSKD_HTTPS_PORT=5031 SLSKD_SLSK_LISTEN_PORT=50300 SLSKD_UMASK=0022 DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/.net DOTNET_EnableDiagnostics=0 DOTNET_gcServer=0 DOTNET_gcConcurrent=1 DOTNET_GCHeapHardLimit=0x80000000 DOTNET_GCConserveMemory=9 HOME=/config`.
   - `DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/.net` replaces upstream `/.net`. `/tmp` is writable under read-only rootfs (`--tmpfs /tmp`). The single-file bundle extracts there at start.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5030 5031 50300`, `VOLUME /config`, `CMD ["/start.sh"]`.

Do not install `tini`, `gosu`, `jq` or `wget`. `start.sh` handles PID 1 by `exec`.

## 5. docker-bake.hcl

- `APP = "slskd"`
- `VERSION` default `0.26.2`, preceded by `// renovate: datasource=github-releases depName=slskd/slskd versioning=semver`
- `LICENSE = "AGPL-3.0-only"`, `SOURCE = "https://github.com/slskd/slskd"`
- Standard targets. Pass `SHA256_X64` and `SHA256_ARM64` as `args` in `image`, next to `VERSION`.
- Validate: `cd apps/slskd && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/slskd/slskd"`.
- `ports`:
  - `5030`, tcp, `required: true` (web UI and health endpoint)
  - `5031`, tcp, `required: false` (HTTPS, optional)
  - `50300`, tcp, `required: false` (peer listener; verify whether it is required for a working connection)
- `env`:
  - `SLSKD_HTTP_PORT`, default `"5030"`, required false
  - `SLSKD_HTTPS_PORT`, default `"5031"`, required false
  - `SLSKD_SLSK_LISTEN_PORT`, default `"50300"`, required false
  - `SLSKD_UMASK`, default `"0022"`, required false
  - `SLSKD_DOWNLOADS_DIR`, default `/config/downloads`, required false
  - `SLSKD_INCOMPLETE_DIR`, default `/config/incomplete`, required false
  - `SLSKD_SHARED_DIR`, default empty, required false (user-configured; nothing shared by default)
  - `SLSKD_SLSK_USERNAME`, `SLSKD_SLSK_PASSWORD`, required false, default empty. Names UNVERIFIED (section 1). Add only after confirmation.
  - `TZ`, default `"Etc/UTC"`, required false
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. start.sh

Idempotent, works with empty `/config`:

```
#!/usr/bin/env bash
set -eu
umask "${SLSKD_UMASK:-0022}"
export SLSKD_DOWNLOADS_DIR="${SLSKD_DOWNLOADS_DIR:-/config/downloads}"
export SLSKD_INCOMPLETE_DIR="${SLSKD_INCOMPLETE_DIR:-/config/incomplete}"
mkdir -p "${SLSKD_DOWNLOADS_DIR}" "${SLSKD_INCOMPLETE_DIR}"
exec /app/slskd
```

- Do not write to `/app`. Config (`slskd.yml`) and state live in `SLSKD_APP_DIR=/config`.
- Upstream's `--user`, PUID/PGID and root branches are removed: the container always runs as `apps`.
- Upstream's `mountpoint -q` warning is dropped (the volume is always `/config`).
- Do not seed a config file; slskd writes its defaults on first start (UNVERIFIED on the first run).
- The Soulseek password must stay out of argv: pass it only via env, never as a flag.
- Bind: slskd web listens on all interfaces by default (UNVERIFIED: confirm with `ss -ltn` on the first run; if it binds loopback, set the address option per `docs/config.md`).

## 8. container-test.yaml

```
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180

tcp:
- port: '5030'
- port: '50300'

http:
- port: '5030'
  path: /health
```

- Probe `5030` (web UI and `/health`, as upstream HEALTHCHECK does).
- Probe `50300` for the peer listener. Verify it opens without Soulseek credentials; if it does not, narrow with a comment per the build-test protocol.
- `5031` is not probed: TLS is optional and disabled by default. Note in the file, per the rule that every declared port needs a probe. Declare it in `settings.yaml` only if the image really opens it by default (UNVERIFIED: check `ss -ltn` on the first run; if not open, remove from settings).
- `timeoutSeconds: 180`: upstream healthcheck has `start-period=60m` (not a test budget). The web UI should answer within minutes; confirm on the run and adjust.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root by default (`runAsUser 0`, chart) and uses `gosu` for PUID/PGID. Target: `USER apps`, no privilege drop, no `gosu`.
- Upstream `/.net` (chmod 777) becomes `/tmp/.net` via `DOTNET_BUNDLE_EXTRACT_BASE_DIR`.
- Upstream `/app` (app data, pvc in chart) becomes `/config` (`SLSKD_APP_DIR=/config`). Chart mounts `/app` as data pvc: user migrates data from `/app` to `/config`.
- Downloads and shares: draft lists `/share`, `/downloads/incomplete`, `/downloads/complete` pvcs. Target defaults them under `/config` (section 6) to keep one required volume. Users mount other paths and set `SLSKD_*_DIR` to match.
- Draft security expectations (`runAsUser 0`, `readOnlyRootFilesystem false`) are reconciled: target is non-root and read-only compatible. Stricter than the chart; flag for the user.
- Port 50300 and 5030 are above 1024, so no `NET_BIND_SERVICE` needed.

## 10. Risks, caveats and open questions

- Soulseek network account is required to connect (draft, inferred). Test run has no env vars, so the connect path is not tested by the suite; exercise it manually with a test account only.
- Bundled .NET runtime: confirmed by the publish script, not by inspecting the zip. Verify on the first run that `/tmp/.net` extraction works under `--read-only --tmpfs /tmp` (a common failure: `DOTNET_BUNDLE_EXTRACT_BASE_DIR` not writable).
- No upstream checksum; pinned hashes are local. Flag.
- `5031` and `50300` exposure: confirm what listens by default before finalising `settings.yaml` (section 6, 8).
- Upstream image runs as root unless `--user` is given: behaviour changes for users who rely on PUID/PGID. Document in the PR.
- Blockers: none known. Musl builds exist, but we use glibc (no blocker). No GPU, no privileged need.

## 11. Build and test steps

From `apps/slskd/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name slskd-probe --read-only --tmpfs /tmp -v slskd-probe-config:/config slskd:0.26.2`, then `docker logs -f slskd-probe`. Expected readiness signal: the web UI listening on port 5030 (exact text UNVERIFIED, confirm on the run). Expect Soulseek connection errors without credentials; they count as non-fatal only if the process stays up and the web UI responds. Cleanup: `docker rm -f slskd-probe; docker volume rm slskd-probe-config`.
4. `forgetool containers test --image slskd:0.26.2 --config ./apps/slskd/container-test.yaml`. If forgetool is unavailable, probe 5030 `/health` and 50300 by hand.
5. Repeat step 3 with the same volume to check restart idempotence.
6. arm64: build only if the amd64 loop is green and the failure is arm64-specific (protocol rule).

## 12. PR checklist

- Branch: `feat/add-slskd`
- Commit: `feat(slskd): add new container`
- PR title: `feat(slskd): add new container`
- Body: PR template at `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested: arm64 build, Soulseek login, peer connectivity, and the locally computed checksums.
- Do not tick "Built container locally" unless the build and run above were done.
