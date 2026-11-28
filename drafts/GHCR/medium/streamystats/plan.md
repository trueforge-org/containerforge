# streamystats — implementation plan
> Source: ./draft.md · Target: apps/streamystats/ (row 1, web) and apps/streamystats-job-server/ (row 2) · Difficulty: medium · Role: main (row 1), sidecar (row 2) · Verified on 2026-11-25

The draft has two rows. Each row is a separate container, and this repo is one app per folder, so the plan covers **two apps**, one PR each. Row 2 must land first or in the same PR window, because row 1 reads its API.

Status: **blocked on items marked UNVERIFIED in sections 1, 6 and 10.** The ghcr digests, the license, and the env var names are not confirmed.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2.22.3`, published 2026-11-13 (https://github.com/fredrikburmester/streamystats/releases/tag/v2.22.3, gh API). The release has no assets; build from the tag source. |
| Renovate | `datasource=github-releases depName=fredrikburmester/streamystats versioning=semver` (release tags are `vX.Y.Z`). Proposed, consistent with `apps/nzbhydra2`. |
| License | UNVERIFIED for the repository. The repo API reports license null and there is no root `LICENSE` file (gh contents). `apps/nextjs-app/package.json` or `apps/job-server/package.json` declares `"license": "MIT"` (gh; which one was not confirmed). |
| Source URL | https://github.com/fredrikburmester/streamystats |
| Download | Source tarball `https://github.com/fredrikburmester/streamystats/archive/refs/tags/v2.22.3.tar.gz` (standard GitHub tag archive, same pattern as `apps/pwndrop`; UNVERIFIED that this exact URL works, check at build). |
| Checksum source | None published. Pin by tag; the tarball is content-addressed by tag only. |
| Upstream Dockerfile reviewed (row 1) | https://raw.githubusercontent.com/fredrikburmester/streamystats/4049ac60351575c68639fcf8db76a4f477df8ab2/apps/nextjs-app/Dockerfile: stages `oven/bun:1.4.2-alpine` (deps) and `node:26-alpine` (runner). `bun install --frozen-lockfile`; `bun run build` in `packages/database`; `bun --bun next build --experimental-build-mode compile` in `apps/nextjs-app`. Runner copies `.next/standalone` to `./`, `.next/static` and `public`. `ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 HOSTNAME=0.0.0.0 PORT=3000`. `EXPOSE 3000`. `USER nextjs` (UID 1001). `CMD ["node","server.js"]`. HEALTHCHECK `curl -f http://127.0.0.1:3000/api/health`. |
| Upstream Dockerfile reviewed (row 2) | https://raw.githubusercontent.com/fredrikburmester/streamystats/4049ac60351575c68639fcf8db76a4f477df8ab2/apps/job-server/Dockerfile: stages `oven/bun:1.4.2` (builder), `debian:bookworm-20260824-slim` (runner). `bun build ./src/migrate-entrypoint.ts --compile --minify --outfile migrate-bin` in `packages/database`; `bun add geoip-lite@2.0.3`; `bun build ./src/index.ts --compile --minify --outfile server` in `apps/job-server`. Runner copies `migrate-bin`, `drizzle/`, `server`, and geoip data. `ENV NODE_ENV=production PORT=3005 HOST=0.0.0.0`. `EXPOSE 3005`. `CMD ["sh","-c","./migrate-bin && exec ./server"]`. No USER (runs as root upstream). |
| Port | Row 1: 3000/tcp (upstream EXPOSE and `PORT`). Row 2: 3005/tcp (upstream EXPOSE and `PORT`). The draft's 3001 for the job server is wrong per the upstream Dockerfile. |
| Env vars (real) | Row 1: `NODE_ENV`, `NEXT_TELEMETRY_DISABLED`, `HOSTNAME`, `PORT` (from Dockerfile). Row 2: `NODE_ENV`, `PORT`, `HOST`. Database and Jellyfin/Emby connection variables are UNVERIFIED: not read from the fetched Dockerfiles (they belong to the app code). |
| Image tags (draft) | `ghcr.io/fredrikburmester/streamystats-nextjs:v2.22.3` and `ghcr.io/fredrikburmester/streamystats-job-server:v2.22.3`. UNVERIFIED: digests and arm64 manifests (no ghcr API access). |
| arm64 | UNVERIFIED. `oven/bun` and `node` base images are multi-arch upstream, but no arm64 test evidence. |
| Dependencies | Postgres (required). `apps/postgresql` exists (✅). Row 2 is the `streamystats-job-server` chart sidecar (❌ not in ContainerForge: this plan creates it). |

## 2. Target layout

Row 1 (`apps/streamystats/`):
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.

Row 2 (`apps/streamystats-job-server/`):
- `Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`.

No `defaults/` (no seeded config is needed). No `root/`. No `DOWNSTREAM_CHANGES.md` (neither image is a `FROM` base).

## 3. Base image

- Row 1 final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, with Node added in the build stage (see section 4). The draft suggested `python-node`, but it adds Python, which Next.js does not need. Use `ubuntu` plus Node only if the node version can be pinned to the upstream `node:26` line. UNVERIFIED: the exact Node version available from the ubuntu archive or a pinned tarball.
- Row 2 final stage: the same ubuntu digest. The compiled binary is glibc-linked, so it runs on Ubuntu. The base already has `curl` and `ca-certificates`.
- Build stage (both rows): ubuntu digest plus a pinned Bun. Bun is not in the ubuntu archive; obtain it from the pinned `oven/bun:1.4.2` image (`COPY --from=oven/bun:1.4.2@sha256:<digest>`, digest UNVERIFIED) or from an official Bun release tarball (checksum UNVERIFIED). Do not use an unpinned `curl | bash`.
- Closest sibling: `apps/pwndrop` (build stage then runtime stage), `apps/bazarr` (Python), `apps/changedetection` (node-based app layout).

## 4. Dockerfile

Row 1 (`streamystats`):
1. `FROM <ubuntu digest> AS buildstage`, `ARG VERSION`, `USER root`.
2. Install Node (version pinned to upstream line 26; UNVERIFIED availability) and Bun 1.4.2 (pinned as in section 3).
3. Fetch the tag tarball and extract to `/tmp/src` (`--strip-components=1`).
4. `bun install --frozen-lockfile` at repo root; `bun run build` in `packages/database`; `bun --bun next build --experimental-build-mode compile` in `apps/nextjs-app`.
5. Final stage: `FROM <ubuntu digest>`, `USER root`, copy `.next/standalone` to `/app/streamystats/`, `.next/static` to `/app/streamystats/apps/nextjs-app/.next/static`, and `public` to `/app/streamystats/apps/nextjs-app/public` (layout from the upstream runner).
6. `ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 HOSTNAME=0.0.0.0 PORT=3000 HOME=/config`.
7. `USER apps`, `COPY --chmod=0755 . /`.

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app/streamystats/apps/nextjs-app
VOLUME ["/config"]
```

Row 2 (`streamystats-job-server`):
1. Build stage: ubuntu digest plus Bun 1.4.2 (pinned). Fetch the same tag tarball.
2. `bun install --frozen-lockfile`; `bun run build` in `packages/database`; `bun build ./src/migrate-entrypoint.ts --compile --minify --outfile migrate-bin`; `bun add geoip-lite@2.0.3` in `apps/job-server`; `bun build ./src/index.ts --compile --minify --outfile server`.
3. Final stage: ubuntu digest. Copy `migrate-bin`, `drizzle/`, `server`, and the geoip data to `/app/streamystats-job-server/`. Install `curl` only if the base lacks it (it has it, so skip).
4. `ENV NODE_ENV=production PORT=3005 HOST=0.0.0.0 HOME=/config`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3005`, `WORKDIR /app/streamystats-job-server`, `VOLUME ["/config"]`.

## 5. docker-bake.hcl

Both apps use the same shape as `apps/nzbhydra2/docker-bake.hcl`:

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "streamystats" }   // or "streamystats-job-server"

variable "VERSION" {
  // renovate: datasource=github-releases depName=fredrikburmester/streamystats versioning=semver
  default = "v2.22.3"
}

variable "LICENSE" { default = "UNVERIFIED" }   // resolve from repo license
variable "SOURCE" { default = "https://github.com/fredrikburmester/streamystats" }
```

Four standard targets and the default group. Validate with `docker buildx bake --print` in each app folder. `VERSION` (`v2.22.3`) is passed through to the Dockerfile `ARG VERSION`, and the tarball path uses it as-is.

## 6. settings.yaml

Row 1:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/fredrikburmester/streamystats"
ports:
  - port: 3000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  # UNVERIFIED: database connection variables (read by app code) to be confirmed from source
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```

Row 2:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/fredrikburmester/streamystats"
ports:
  - port: 3005
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```

Row 1 also depends on row 2, but `apps/streamystats-job-server` does not exist yet (this plan creates it), so do not list it under `dependencies:` until it lands; the job-server URL variable is UNVERIFIED, do not invent it. Do not list `NODE_ENV`, `PORT`, `HOST` unless `start.sh` reads them from `settings.yaml` (they are image-level, not user config).

## 7. start.sh

Row 1:
- `mkdir -p /config`; no seeding.
- `cd /app/streamystats/apps/nextjs-app` and `exec node server.js`.
- Bind `HOSTNAME=0.0.0.0` (already set in the image).

Row 2:
- `mkdir -p /config`; run `./migrate-bin` and then `exec ./server` (upstream CMD `sh -c './migrate-bin && exec ./server'`). Keep `exec` so signals reach the server.
- Migrations require the database. Fail with a clear message if `migrate-bin` exits non-zero (no silent retry loop).
- Never write to `/app`. Caches go to `/tmp`.

## 8. container-test.yaml

Row 1 (narrowed, database dependency): timeout and probes only.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '3000'   # narrowed: requires external postgresql; full functional test not feasible in single-container suite
filePaths:
- /app/streamystats/apps/nextjs-app/server.js
```

Row 2 (narrowed, database dependency):

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '3005'   # narrowed: requires external postgresql; full functional test not feasible in single-container suite
filePaths:
- /app/streamystats-job-server/server
- /app/streamystats-job-server/migrate-bin
```

The DB-dependency exception applies (hard `dependencies` on postgresql, fails without the DB, not feasible as a sidecar in the test primitives). Narrowed assertions are real (port open, files present), not no-ops. Row 2 has no HTTP probe in the test because `/health` needs the DB; if the health endpoint answers without the DB, add an `http` probe on `/health`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Upstream root user (job-server) | Runs as `apps` (568). Upstream chart runs as root with `runAsUser: 0` (draft expectation, not kept). |
| Row 1 Next.js `.next/cache` (build only) | Build stage; not present at runtime. |
| Row 1 `/app/streamystats/...` runtime writes | None expected (Next.js reads its own build). UNVERIFIED that Next.js writes nothing at runtime under `--read-only`; check the logs. |
| Row 2 `migrate-bin` / `server` working files | Run from `/app`, read-only. Any writes go to `/tmp`. |
| Chart's `/var/www/html/data` (draft) | UNVERIFIED for this image: the draft's data path belongs to the chart's nginx layout, not these images. Confirm before mapping to `/config`. |
| Chart init container `chown -R 568:568` (draft) | Not needed: the image runs as `apps` (568) and writes only to `/config`. |

Draft expectations reconciled: the chart's `readOnlyRootFilesystem` (main: false) and root user are not carried over. The init container and nginx `/run`, `/var/lib/nginx`, `/var/log` mounts from the draft are not part of these upstream images and are not needed.

## 10. Risks, caveats and open questions

- Two apps from one draft; the PR for row 2 should land before row 1 is tested end-to-end.
- Bun-compiled binaries and the Next.js compile mode (`--experimental-build-mode compile`) are upstream-specific and may change between releases; pin `bun` 1.4.2 and the release tag.
- UNVERIFIED: ghcr digests for `streamystats-nextjs:v2.22.3` and `streamystats-job-server:v2.22.3`. The draft's `copy-from` option (job-server image) is a Debian-slim glibc image and could be copied with `COPY --from`, but tag and arch availability are unverified; do not use it without that check.
- UNVERIFIED env names for the database connection and the job-server URL; must come from upstream source, not guessed.
- License unknown for the whole repo (no root `LICENSE`).
- Migrations run at container start (`migrate-bin`), so the first start needs Postgres.
- arm64 unverified.
- Blockers: missing license; unverified env var names; node version availability in ubuntu 26.04; ghcr digests.

## 11. Build and test steps

Row 2 first, then row 1. Per app:

```sh
cd apps/streamystats-job-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name ss-job-probe --read-only --tmpfs /tmp \
  -v ss-job-probe-config:/config streamystats-job-server:<VERSION>
docker logs -f ss-job-probe
forgetool containers test --image streamystats-job-server:<VERSION> --config ./apps/streamystats-job-server/container-test.yaml
docker rm -f ss-job-probe; docker volume rm ss-job-probe-config
```

Repeat for `apps/streamystats` (`ss-web-probe`). Readiness signal for row 2: `migrate-bin` exits 0 with a Postgres connection, then the server logs a listening line (UNVERIFIED wording). Readiness for row 1: `node server.js` listens on 3000 and `/api/health` returns 200. The probe run needs a reachable Postgres (`dependencies: postgresql`), so run it with a `postgresql` container on the same network; without one, record the result as "database-dependent, narrowed test only".

## 12. PR checklist

- Branch `feat/add-streamystats-job-server` (row 2) and `feat/add-streamystats` (row 1); commit and PR titles `feat(streamystats-job-server): add new container` and `feat(streamystats): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; keep sections; check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested, to state honestly: the Bun compile on both rows, the Next.js compile mode, runtime against a real Postgres, arm64, the ghcr digests, and the license.
- Before the PR: `docker buildx bake --print` passes in each app; `VERSION` equals Dockerfile `ARG VERSION`; narrowed DB tests are annotated; no assertion weakened.
