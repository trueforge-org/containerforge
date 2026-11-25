# pocket-id — implementation plan
> Source: ./draft.md · Target: apps/pocket-id/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | v2.19.3, published 2026-11-15 (https://api.github.com/repos/pocket-id/pocket-id/releases/latest). Chart tag `ghcr.io/pocket-id/pocket-id:v2.19.3`. The `VERSION` in bake is `2.19.3` (no `v`); the release asset names use the `v`-less form. |
| Renovate | `datasource=github-releases depName=pocket-id/pocket-id versioning=semver` (UNVERIFIED: versioning string; semver matches the tags). |
| License | BSD-2-Clause (GitHub API `license.spdx_id`, https://api.github.com/repos/pocket-id/pocket-id). |
| Source URL | https://github.com/pocket-id/pocket-id |
| Per-arch downloads | `https://github.com/pocket-id/pocket-id/releases/download/v2.19.3/pocket-id_linux_amd64` and `.../pocket-id_linux_arm64` (both confirmed as release assets). |
| Checksum source | `https://github.com/pocket-id/pocket-id/releases/download/v2.19.3/checksums.txt`. Confirmed lines: `9c70adaaa4e4490c8b4db882de724f8a0672573ca50ba59d5250d3b40ab72a6b  pocket-id_linux_amd64`, `83bc97832f5f52bb17a3e0dc7d2a54662f18ee4ca3b5c576ab00155a456ad512  pocket-id_linux_arm64`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/pocket-id/pocket-id/v2.19.3/docker/Dockerfile. Frontend stage (vite-plus), backend stage `golang:1.27.4-alpine` with `CGO_ENABLED=0` static build, final `alpine:3.24.3` with `su-exec`. `EXPOSE 1411`, `ENV APP_ENV=production`, `ENTRYPOINT ["sh","/app/docker/entrypoint.sh"]`, `CMD ["/app/pocket-id"]`. |
| Upstream entrypoint | https://api.github.com/repos/pocket-id/pocket-id/contents/scripts/docker/entrypoint.sh?ref=v2.19.3. Starts as root only if needed, `PUID`/`PGID` default 1000, chowns `/app/data`, then `su-exec`. Not used (rootless, `/config`). |
| Env vars (backend config) | https://api.github.com/repos/pocket-id/pocket-id/contents/backend/internal/common/env_config.go?ref=v2.19.3. Relevant: `APP_ENV`, `APP_URL` (lowercased, trailing slash trimmed), `ENCRYPTION_KEY` (file option), `DB_CONNECTION_STRING` (file option), `TRUST_PROXY`, `PROXY_PROTOCOL`, `TRUSTED_PLATFORM`, `PORT`, `HOST`, `UNIX_SOCKET`, `UPLOAD_PATH`, `FILE_BACKEND`, `LOG_LEVEL`, `LOG_JSON`, `ANALYTICS_DISABLED`, `VERSION_CHECK_DISABLED`, `UI_CONFIG_DISABLED`, `STATIC_API_KEY` (file option), `TLS_CERT`, `TLS_KEY`, `ICON_LIBRARY_URL`. |
| Default SQLite path | UNVERIFIED: not confirmed in this run. Set `DB_CONNECTION_STRING` explicitly to `/config/...` after checking the backend default. |
| Ports | 1411/tcp (`EXPOSE 1411`; `PORT` default is UNVERIFIED in this run). |
| Dependencies | None (embedded SQLite). |

## 2. Target layout

- `apps/pocket-id/Dockerfile`
- `apps/pocket-id/docker-bake.hcl`
- `apps/pocket-id/settings.yaml`
- `apps/pocket-id/container-test.yaml`
- `apps/pocket-id/start.sh`

No `defaults/`, `etc/`, `scripts/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. No runtime sibling is needed: the app is a single static Go binary with the frontend embedded (`CGO_ENABLED=0`), so the ubuntu base is enough. Closest sibling: `apps/adguardhome-sync` (prebuilt release binary on ubuntu).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Download the binary for the arch: `curl -fL -o /app/pocket-id "https://github.com/pocket-id/pocket-id/releases/download/v${VERSION}/pocket-id_linux_${TARGETARCH}"` (`TARGETARCH` gives `amd64` or `arm64`, matching the asset names).
3. Download `checksums.txt` for the same release and verify: `grep " pocket-id_linux_${TARGETARCH}$" checksums.txt | sha256sum -c -`. Fail the build on mismatch. Use `/tmp` for the scratch files and remove them.
4. `chmod 0755 /app/pocket-id && chown apps:apps /app/pocket-id`.
5. Install the license: download `LICENSE` from the tag (UNVERIFIED: file path in the repo; confirm before writing) to `/usr/share/licenses/pocket-id/LICENSE`.
6. `ENV APP_ENV=production HOME=/config PORT=1411 HOST=0.0.0.0`.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 1411`, `VOLUME /config`.

Keep the upstream `EXPOSE 1411` value. Do not use the upstream Alpine stage or `su-exec`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "pocket-id" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=pocket-id/pocket-id versioning=semver
  default = "2.19.3"
}
variable "LICENSE" { default = "BSD-2-Clause" }
variable "SOURCE" { default = "https://github.com/pocket-id/pocket-id" }
```

Four standard targets and the default group as in `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/pocket-id/pocket-id"
ports:
  - port: 1411
    protocol: tcp
    required: true
env:
  - name: APP_URL
    default: ""
    required: true
  - name: PORT
    default: "1411"
    required: false
  - name: HOST
    default: "0.0.0.0"
    required: false
  - name: TRUST_PROXY
    default: ""
    required: false
  - name: ENCRYPTION_KEY
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  []
```

`APP_URL` is required: passkeys need the public HTTPS origin (draft caveat). An empty default is a problem under the rule "required env needs a non-empty default or handling in `start.sh`": handle it in `start.sh` (see section 7). `ENCRYPTION_KEY` is set only if the user supplies it; check that the app generates one on first run before listing it (UNVERIFIED). `TRUST_PROXY` default: leave empty and confirm the accepted values (UNVERIFIED). Ports list matches `EXPOSE`.

## 7. start.sh

- `mkdir -p /config/data` (or the path chosen for `DB_CONNECTION_STRING`; confirm the default first, see section 1).
- If `APP_URL` is unset, print a clear warning and continue (the app can start without it; passkeys will not work). Do not invent a URL.
- Set `DB_CONNECTION_STRING` to a file under `/config` if not provided, so SQLite lands on the writable volume.
- Set `UPLOAD_PATH=/config/uploads` and `FILE_BACKEND` only after confirming the variable names are read (UNVERIFIED for upload path default).
- `cd /config` and `exec /app/pocket-id` so signals reach the binary. Do not run `su-exec` or `chown`; the process is already `apps`.
- Read env from `settings.yaml` only; no secrets in logs or process args (use `*_FILE` options where the app supports them).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '1411'
http:
- port: '1411'
  path: /
filePaths:
- /app/pocket-id
- /usr/share/licenses/pocket-id/LICENSE
```

Port 1411 has both a tcp and an http probe (coverage rule). The `http` path `/` may return a redirect on first run (initial setup); confirm the status code during the run and use the path that returns 200 (UNVERIFIED). Do not weaken to a tcp-only probe if the http path works.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data` (SQLite, uploads; chart PVC `/app/data`) | `/config` (SQLite under `/config/data` or the chosen path) |
| Upstream root-owned entrypoint chown | Not needed: binary owned by `apps`, data on `/config` |
| Go build caches | Not present in the image (prebuilt binary) |

Draft expectations reconciled: the chart runs as the image default user with `readOnlyRootFilesystem: true`. This image also runs as `apps` with `--read-only --tmpfs /tmp`. Not privileged. Existing users of the chart must move `/app/data` content to `/config`.

## 10. Risks, caveats and open questions

- Passkeys need HTTPS on a secure origin; `APP_URL` must be the public address behind a reverse proxy (draft caveat, confirmed by the env name in upstream config).
- Data move: existing chart data under `/app/data` must be copied to the new path before first start (data gotcha).
- SQLite default path and upload path: UNVERIFIED (section 1). Resolve before merge; do not guess.
- `APP_URL` required with no safe default (section 6); the app may refuse to start or run in a degraded mode without it. Confirm the behaviour in the run step.
- Upstream release binary was built with `CGO_ENABLED=0`; the binary is glibc-independent, so ubuntu works (expected, not run).
- arm64: asset present (`pocket-id_linux_arm64`), not built.

## 11. Build and test steps

```sh
cd apps/pocket-id
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pocket-id-probe --read-only --tmpfs /tmp \
  -e APP_URL=http://localhost:1411 \
  -v pocket-id-probe-config:/config pocket-id:2.19.3
docker logs -f pocket-id-probe
forgetool containers test --image pocket-id:2.19.3 --config ./apps/pocket-id/container-test.yaml
docker rm -f pocket-id-probe; docker volume rm pocket-id-probe-config
```

Expected readiness signal: the server starts and listens on 1411 (`Now listening` or equivalent; exact text UNVERIFIED until run). Restart with the same volume and confirm the database under `/config` is kept. The container test runs without `APP_URL`, so check that case separately (it should warn, not crash).

## 12. PR checklist

- Branch `feat/add-pocket-id`, commit `feat(pocket-id): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign it, and the `license/cla` check shows status.
- Say what was not tested: the build, the run on `--read-only`, the first-run setup, passkeys over HTTPS, arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
