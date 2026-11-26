# commento-plusplus — implementation plan
> Source: ./draft.md · Target: apps/commento-plusplus/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.8.7 (latest release, published 2022-04-07; https://api.github.com/repos/souramoo/commentoplusplus/releases/latest). Matches draft. No newer release exists, so the project is effectively unmaintained: `UNVERIFIED: whether the upstream default branch has newer commits`. |
| Renovate | `datasource=github-releases depName=souramoo/commentoplusplus versioning=semver` (proposed; not checked against renovate config) |
| License | MIT (https://api.github.com/repos/souramoo/commentoplusplus, `license.spdx_id`) |
| Source URL | https://github.com/souramoo/commentoplusplus |
| Download | Release asset `release.tar.gz`, 7976924 bytes: https://github.com/souramoo/commentoplusplus/releases/download/v1.8.7/release.tar.gz. `UNVERIFIED: the asset's contents (whether it holds api/, frontend/, templates/, db/ as in the git tree). Check after download.` |
| Checksum source | None on the release. `UNVERIFIED: no digest or checksum file was published`. Pin the tarball by its SHA-256 computed at build time against a value committed in the Dockerfile, or verify the git tag. |
| Per-arch binary | None published. Build from source for amd64 and arm64. |
| copy-from | no (draft and upstream image is alpine/musl; not usable on glibc ubuntu) |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/souramoo/commentoplusplus/v1.8.7/Dockerfile: stages `golang:1.15-alpine` (api, `make ${RELEASE}`), `node:12-alpine` (frontend, installs python2 and g++, `make ${RELEASE}`), `alpine:3.13` (templates and db, `make ${RELEASE}`), final `alpine:3.13` with ca-certificates. `ENTRYPOINT ["/commento/commento"]`, `WORKDIR /commento/`, `EXPOSE 8080`, `ENV COMMENTO_BIND_ADDRESS=0.0.0.0`, `ARG RELEASE` (default `prod`, build-time only). No `USER`, no `VOLUME`, no `CMD`. |
| Port | 8080/tcp (`EXPOSE 8080`, confirmed) |
| Env vars (real) | `COMMENTO_BIND_ADDRESS=0.0.0.0` (confirmed in upstream Dockerfile). Database, SMTP and origin settings: `UNVERIFIED: not listed in the Dockerfile; read the upstream config loader (api/ Go config package) and docs before listing any others.` |
| Data and config paths | `UNVERIFIED: not in the Dockerfile.` The app is stateless apart from PostgreSQL, so no write path is expected yet. |
| Dependency | PostgreSQL (`apps/postgresql` exists, marked ✅). Draft says it is a hard dependency. `UNVERIFIED: the exact connection env var names`. |
| Go and Node versions | Upstream uses Go 1.15 and Node 12, both end-of-life. `UNVERIFIED: whether v1.8.7 builds with a current Go and Node without source changes.` |

## 2. Target layout

- `apps/commento-plusplus/Dockerfile`
- `apps/commento-plusplus/docker-bake.hcl`
- `apps/commento-plusplus/settings.yaml`
- `apps/commento-plusplus/container-test.yaml`
- `apps/commento-plusplus/start.sh`

`defaults/` is not needed unless a default config file must be seeded into `/config` (decide once the config loader is read). `etc/`, `health/` and `root/` are not needed. Do not use `root/`. No `DOWNSTREAM_CHANGES.md`, because this image is not a `FROM` base.

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (the brief's pinned digest). Go API binary runs on ubuntu, as the draft says.
- Go build stage: `FROM golang:<ver>` with a `// renovate: datasource=docker depName=docker.io/library/golang` annotation. Pick the version the code needs, `UNVERIFIED`. Pin a digest, `UNVERIFIED: digest not looked up`.
- Node build stage: `FROM node:<lts>` with a renovate annotation, `UNVERIFIED: version and digest`. Use the frontend's required Node version, which needs confirming from `frontend/package.json`.
- Closest sibling: `apps/pwndrop` (build stage, then runtime stage) and `apps/postgresql` (ubuntu base with a database dependency).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Build stages first:
   - `FROM golang:<ver> AS api-build`: download `https://github.com/souramoo/commentoplusplus/releases/download/${VERSION}/release.tar.gz` (VERSION `v1.8.7`), verify its checksum, extract to `/src`, `cd /src/api && CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -o /out/commento ./...` (exact build target `UNVERIFIED`, mirror `make ${RELEASE}` from upstream `api/Makefile`). Set `GOCACHE=/tmp/go-build`.
   - `FROM node:<ver> AS frontend-build`: copy `/src/frontend`, `npm ci`, run the frontend build from upstream `frontend/Makefile`. Set npm cache to `/tmp`.
   - `FROM ubuntu AS templates-db-build` (or reuse the same stage): run the upstream templates and db `make` steps.
2. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`:
   - `USER root`, `apt-get install -y --no-install-recommends ca-certificates`, clean apt lists. Check whether ubuntu already has it (`apt-get` only if missing).
   - `COPY --from=api-build /out/commento /app/commento/commento`, `COPY --from=frontend-build` for the built assets, `COPY --from=templates-db-build` for templates and db output. Target layout under `/app/commento/`, `UNVERIFIED: exact paths the binary expects at runtime`.
   - `ENV COMMENTO_BIND_ADDRESS=0.0.0.0 HOME=/tmp` (keep caches out of `/config`).
   - `chown -R apps:apps /app/commento` is not needed if files are root-owned and read-only.
3. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/commento
```

No `CMD` or `ENTRYPOINT` in the Dockerfile; `start.sh` is the entrypoint through the base image, as siblings do. `UNVERIFIED: confirm how apps/ubuntu runs start.sh (entrypoint.sh in the base)`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "commento-plusplus" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=souramoo/commentoplusplus versioning=semver
  default = "v1.8.7"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/souramoo/commentoplusplus" }
```

Add `GO_VERSION` and `NODE_VERSION` variables, each with a renovate annotation, and pass them as `args` in the `image` target. Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print` (`UNVERIFIED: not run`).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/souramoo/commentoplusplus"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: COMMENTO_BIND_ADDRESS
    default: "0.0.0.0"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: false
dependencies:
  - name: postgresql
```

Database env vars and any SMTP vars are added only after they are confirmed from upstream (section 1). Do not invent names. `/config` is listed only if a seeded config file is needed; otherwise remove it. `dependencies: postgresql` is required.

## 7. start.sh

- Idempotent. If a seeded config is needed, write it to `/config` only when missing. No writes to `/app`.
- Read the DB connection values from env and apply them on every start.
- Export `COMMENTO_BIND_ADDRESS` (default `0.0.0.0`).
- Final line: `exec /app/commento/commento` (exact binary path `UNVERIFIED`, follow section 4).
- Wait-for-DB loop is optional. `UNVERIFIED: whether commento retries the DB connection itself`.

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
- /app/commento/commento
```

Add one `tcp` and `http` probe for port 8080 (coverage rule). Set the `http` path to one that returns 200 without a DB, `UNVERIFIED`.

Because the app hard-depends on PostgreSQL, the narrow exception of `build-test-protocol` applies only if all three criteria hold: a hard dependency (yes, draft), it will not start without the DB (`UNVERIFIED: confirm by running it without a DB`), and a sidecar DB cannot be wired into `container-test.yaml` with the available primitives (`UNVERIFIED`). If the exception applies, add the required comment near the narrowed assertions, e.g. `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`. Do not replace probes with always-true checks.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (no `USER`). ContainerForge runs as `apps` (UID 568).
- Port 8080 is above 1024, so no privileged bind is needed.
- Read-only rootfs: the binary, templates and assets are only read. Any write goes to `/config` or `/tmp`.
- Draft security expectations: non-root yes, read-only rootfs yes, privileged no, no extra persistence. These match the draft and are `UNVERIFIED` until a run confirms them. `UNVERIFIED: whether the app writes anywhere at runtime`.
- No extra persistence: PostgreSQL is external.

## 10. Risks, caveats and open questions

- Upstream is unmaintained (last release 2022) and uses EOL Go 1.15 and Node 12, plus alpine 3.13. Rebuilding on ubuntu with newer toolchains may need source fixes. Blocker if the code does not compile with a current Go.
- Draft caveat (confirmed): PostgreSQL must exist before the first start.
- Draft caveat (inferred): SMTP. Account confirmation and notification emails need an SMTP server. Not configured in this plan (UNVERIFIED env names).
- Draft `copy-from` is `no`, so the image is built from source. Build time is slow (Go and Node stages).
- No arm64 binary upstream. Build both arches from source; arm64 is `UNVERIFIED` until built.
- Blockers: none confirmed yet. Blocking if the frontend build needs a Node version that cannot be installed on the ubuntu-based stage.

## 11. Build and test steps

```sh
cd apps/commento-plusplus
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name commento-plusplus-probe --read-only --tmpfs /tmp \
  -v commento-plusplus-probe-config:/config ghcr.io/trueforge-org/commento-plusplus:v1.8.7
docker logs -f commento-plusplus-probe
forgetool containers test --image commento-plusplus:v1.8.7 --config ./apps/commento-plusplus/container-test.yaml
docker rm -f commento-plusplus-probe; docker volume rm commento-plusplus-probe-config
```

Use a fresh named volume per round for empty-`/config` startup. Expected readiness signal: `UNVERIFIED: the upstream startup log line`. Run once with a running PostgreSQL container (`apps/postgresql`) on the same network, to check the real startup path. Use `--network` for that run, not in `container-test.yaml`.

## 12. PR checklist

- Branch: `feat/add-commento-plusplus`. Commit: `feat(commento-plusplus): add new container`.
- PR title matches the commit. Use `.github/PULL_REQUEST_TEMPLATE.md` and keep its sections and checkboxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- Do not check "Built container locally" unless the build and run above were done. Say what was not tested (the untested list is every `UNVERIFIED` item above, plus arm64 if not built).
