# tracearr — implementation plan
> Source: ./draft.md · Target: apps/tracearr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream release **v3.2.1**, published 2026-11-18: https://github.com/connorgallopo/Tracearr/releases/tag/v3.2.1 . The release has no binary, only `openapi-v1.json`, `openapi-v2.json`, `release-notes.json`. The app is built from the tagged source. The draft's chart image tag `ghcr.io/connorgallopo/tracearr:3.2.1` matches. |
| Upstream Dockerfile | Pinned commit: https://raw.githubusercontent.com/connorgallopo/Tracearr/a0037ccf60ceb3d26c9e0efbb2605fec47471322/docker/Dockerfile (WebFetch summary, not verbatim). |
| Renovate | `datasource=github-releases depName=connorgallopo/Tracearr versioning=semver` (tags carry a `v` prefix; semver handles it). |
| License | AGPL-3.0 (LABEL in the upstream Dockerfile). The repo API `license` field is `null`; a root `LICENSE` file exists at the repo root (gh contents listing); its text was not read, so the SPDX suffix is UNVERIFIED. |
| Source URL | https://github.com/connorgallopo/Tracearr |
| Download | No prebuilt binary. Source at the tag, built with pnpm and turbo in a build stage. |
| Checksum source | Git tag (source). Release assets carry GitHub API digests (`openapi-v1.json` `sha256:98fa22d6…`, not an app binary). |
| Upstream build | Builder `node:26-alpine3.23` (digest pinned): `pnpm@12.20.0` (matches `packageManager` in package.json, Renovate-managed), `pnpm install --frozen-lockfile`, `pnpm turbo run build` for `@tracearr/shared`, `@tracearr/server`, `@tracearr/web`. |
| Upstream runner | Same Alpine (musl) base. Installs `postgresql-client`, static Tailscale `1.104.7` (`/usr/bin/tailscale`, `/usr/sbin/tailscaled`), user `tracearr` UID/GID 1001, `IMAGE_CACHE_DIR=/data/tracearr/image-cache`, `NODE_ENV=production`, GeoLite2 City and ASN databases copied in, `/entrypoint.sh`, `USER tracearr`, `EXPOSE 3000`, `HEALTHCHECK` `wget http://127.0.0.1:3000/health` every 30s, `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["node", "apps/server/dist/index.js"]`. No VOLUME. |
| Ports | 3000/tcp (web UI, API, `/health`). |
| Dependencies | PostgreSQL (`apps/postgresql` ✅) and Valkey (`apps/valkey` ✅), both hard. |
| arm64 | UNVERIFIED (the upstream multi-arch manifest was not fetched). |
| copy-from | `no`: upstream is musl (Alpine). Confirmed by the base image in the upstream Dockerfile. |

## 2. Target layout

- `apps/tracearr/Dockerfile`
- `apps/tracearr/docker-bake.hcl`
- `apps/tracearr/settings.yaml`
- `apps/tracearr/container-test.yaml`
- `apps/tracearr/start.sh` (replaces upstream `entrypoint.sh`; fetch the upstream `docker/entrypoint.sh` first, it was not retrieved)

No `defaults/` or `etc/` unless the entrypoint's config seeding needs them (reason: decide after reading the upstream entrypoint). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, the Node sibling used by `apps/budge`. The draft calls it the runtime image. Build stage: the same base (it has Node and npm). `apps/budge` is the closest sibling (python-node, node build inside the image, `USER apps`, `VOLUME /config`).

Node version: the python-node base's Node version is UNVERIFIED. The upstream builder uses Node 26. If the base Node is older than the upstream `engines` requirement (package.json not fetched, UNVERIFIED), stop and ask whether to rebase on a Node 26 base, rather than shipping an unsupported Node.

## 4. Dockerfile

Two stages, both from the python-node base, digest pinned.

Build stage:
1. `FROM <python-node> AS build`, `ARG VERSION`, `ARG PNPM_VERSION=12.20.0`, `USER root`.
2. `npm install -g pnpm@${PNPM_VERSION}` (matches upstream `packageManager`).
3. `curl -fL https://github.com/connorgallopo/Tracearr/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`. The tag has a `v` prefix; the bake `VERSION` is `3.2.1`.
4. `cd /tmp/src && pnpm install --frozen-lockfile && pnpm turbo run build --filter @tracearr/shared --filter @tracearr/server --filter @tracearr/web` (turbo filter syntax as used upstream; UNVERIFIED exact flags).
5. Build the runtime tree in `/tmp/out`: upstream `dist` outputs of server, shared, web, emails, `migrations`, `assets/logo.png`, and the server and shared `package.json` files. Then `pnpm install --prod --frozen-lockfile --ignore-scripts --filter @tracearr/server...` in that tree (mirrors upstream runner step 7).

Final stage:
6. `FROM <python-node>`, `USER root`.
7. `apt-get install -y --no-install-recommends postgresql-client` (not in base; version pin UNVERIFIED against `VERSION`, check the base first). Clean `/var/lib/apt/lists/*`.
8. `COPY --from=build /tmp/out/ /app/tracearr/` and `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/tracearr/LICENSE` (license file UNVERIFIED; see section 10).
9. `ENV NODE_ENV=production IMAGE_CACHE_DIR=/config/tracearr/image-cache HOME=/config` (cache and backup dirs under `/config` per ContainerForge rules; `/tmp` for scratch).
10. `chown -R apps:apps /app/tracearr && chmod -R 755 /app/tracearr`.
11. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /app/tracearr`, `CMD ["/start.sh"]`.

Tailscale: the upstream runner installs Tailscale `1.104.7` for optional remote access. Not installed here unless the TrueCharts chart enables it (UNVERIFIED). Record the omission in the PR.

GeoLite2: the upstream image copies GeoLite2 City and ASN databases into the image. Do not copy them into the image without a verified source and licence check (MaxMind terms are not fetched; UNVERIFIED). Alternative: the app downloads them at runtime to `/config` (UNVERIFIED that the app supports this).

Version alignment: `ARG VERSION` equals the bake `VERSION` (`3.2.1`). Use the same value in `APP_VERSION` / `.build-info.json` if the app reads it (UNVERIFIED).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "tracearr" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=connorgallopo/Tracearr versioning=semver
  default = "3.2.1"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/connorgallopo/Tracearr" }
```

Use `AGPL-3.0-only` only if the upstream LICENSE file says "only"; upstream LABEL says `AGPL-3.0` (UNVERIFIED which suffix applies). Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/connorgallopo/Tracearr"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
  - name: valkey
```

The `env` list must name every variable the app reads. The Tracearr env names (database URL, Redis/Valkey URL, auth secrets, encryption key, base URL) are NOT confirmed: the upstream `.env.example` / config schema was not fetched. List them only after reading the source (UNVERIFIED). Do not invent names. The `dependencies` entries are the existing apps `postgresql` and `valkey`.

## 7. start.sh

- Fetch the upstream `docker/entrypoint.sh` at the pinned commit before writing this. The migration step, secret generation and any DB wait logic are in that file (not fetched, UNVERIFIED).
- Create `/config/tracearr/image-cache` and the backup directory only when missing.
- Wait for PostgreSQL and Valkey with a bounded retry loop that logs each attempt. A retry log counts as a readiness signal only when the process stays alive (protocol exception).
- Run migrations from `/app/tracearr/migrations` if the upstream entrypoint runs them (UNVERIFIED how).
- Generate any missing secrets once and store them in `/config` (UNVERIFIED which secrets are needed).
- Never write to `/app/tracearr`. Caches in `/tmp`.
- `exec node apps/server/dist/index.js` from `/app/tracearr`, so the process is PID 1 and gets signals.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '3000'
http:
- port: '3000'
  path: /health
filePaths:
- /app/tracearr/apps/server/dist/index.js
- /app/tracearr/apps/web/dist
- /usr/share/licenses/tracearr/LICENSE
```

- Hard dependencies (postgresql and valkey) are not in the test. Without them the server cannot start. Per the build-test protocol's database-dependent exception: all three criteria hold (hard `dependencies:` on a DB, fails without it, not feasible to wire a sidecar with the current primitives). So the test is narrowed: process-alive checks, port and file assertions. Add the comment `# narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite`.
- If the server exits without a DB (not confirmed), the test cannot pass. The fix is in `start.sh` (keep retrying while the process lives) or in the protocol exception, not by removing the assertions. Confirm in the first run.
- The `/health` path returns 200 only when the server is up; with no DB it does not, so the `http` probe may fail in this narrowed test. Keep it only if the health route answers without a DB (UNVERIFIED); otherwise drop it and note the reason in the test comment.
- `timeoutSeconds` 120 is a starting estimate; check a sibling Node app for its value.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path / behaviour | ContainerForge remap |
| --- | --- |
| `/data/tracearr/image-cache` (`IMAGE_CACHE_DIR`) | `/config/tracearr/image-cache` |
| Backup directory under `/data` (path UNVERIFIED) | `/config/backups` |
| Upstream runs `USER tracearr` UID/GID 1001 | `USER apps` (ContainerForge UID) |
| `/entrypoint.sh` (upstream, copied in) | `start.sh` (ContainerForge), after reading the upstream entrypoint |
| Tailscale and `tailscaled` in `/usr/sbin` | Not installed (see section 4) |
| `apk upgrade` on Alpine | Not applicable (ubuntu/python-node base, pinned by digest) |
| GeoLite2 DBs baked into the image | Not baked in; runtime download to `/config` or omit (section 4) |

Draft security expectations reconciled: the chart runs non-root with the default 568 (matches the draft). `readOnlyRootFilesystem: false` in the chart; this image is read-only-rootfs compatible if every write goes to `/config` or `/tmp`. Chart `privileged: false`. No `hostNetwork`.

## 10. Risks, caveats and open questions

- **Musl vs glibc**: upstream builds and runs on Alpine. The ContainerForge build must reproduce the build on the glibc python-node base. Native modules (if any) are UNVERIFIED. `copy-from` is `no` (draft agrees).
- **Node version**: the upstream needs Node 26 (builder `node:26-alpine3.23`). The python-node base's Node version is UNVERIFIED; this could block the build (section 3).
- **pnpm version**: `PNPM_VERSION=12.20.0` must match `packageManager` in the repo's package.json (UNVERIFIED that it matches).
- **Migrations**: upstream does not run them in the Dockerfile; the entrypoint does (presumed). Confirm from the upstream entrypoint.
- **External services**: PostgreSQL and Valkey must exist and be reachable. Media server access (draft caveat) is needed for function, not for start.
- **GeoLite2 licence**: do not bundle without a verified licence path (section 4).
- **Tailscale**: optional upstream feature, omitted; confirm the chart does not require it.
- **LICENSE file**: the repo API reports no license; the AGPL-3.0 label comes from the Dockerfile. Confirm the LICENSE file in the tag before writing `LICENSE`.
- arm64: UNVERIFIED.
- Blockers: the Node-version match (section 3) and the entrypoint reading (section 7) must be settled before the Dockerfile is finished.

## 11. Build and test steps

```sh
cd apps/tracearr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tracearr-probe --read-only --tmpfs /tmp \
  -v tracearr-probe-config:/config tracearr:3.2.1
docker logs -f tracearr-probe
forgetool containers test --image tracearr:3.2.1 --config ./apps/tracearr/container-test.yaml
docker rm -f tracearr-probe; docker volume rm tracearr-probe-config
```

- Expected readiness: the server log line for listening on 3000 (exact line UNVERIFIED; read it from the source). Without PostgreSQL and Valkey the probe run shows retry lines; the container must stay alive.
- For a full functional check, run the probe beside a `postgresql` and a `valkey` container on a shared network (manual run, not the forgetool suite). Record it in the PR.
- Empty `/config` start must create the cache directory and not fail.

## 12. PR checklist

- Branch `feat/add-tracearr`, commit and PR title `feat(tracearr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows status.
- Untested to state honestly: the build, the pnpm build on glibc, the Node version match, the narrowed test, the DB-backed run, arm64, and the GeoLite2 and Tailscale omissions.
- Confirm `docker buildx bake --print` passes and `VERSION` equals the Dockerfile `ARG VERSION`.
