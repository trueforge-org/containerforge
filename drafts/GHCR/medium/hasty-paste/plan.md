# hasty-paste — implementation plan
> Source: ./draft.md · Target: apps/hasty-paste/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2.5.1`, published 2026-11-10 (latest stable). Matches the chart tag `2.5.1`. Source: https://api.github.com/repos/enchant97/hasty-paste/releases/latest |
| Renovate | `datasource=github-releases depName=enchant97/hasty-paste versioning=semver`. Tag form is `v2.5.1`, so the bake `VERSION` is `2.5.1` and the URL uses `v${VERSION}`. |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`). `LICENSE` in `docker-bake.hcl` = `AGPL-3.0`. |
| Source URL | https://github.com/enchant97/hasty-paste |
| Application binary | None. The release has zero assets (same API response). Build from source for both arches. |
| amd64 / arm64 | compile / compile (Go with `CGO_ENABLED=0`, so one static binary per `TARGETARCH`). |
| Checksum source | None published. Source archive is content-addressed by tag, and the build is from source. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/enchant97/hasty-paste/ad6a831789716dfdfde3a68e22ff5bb2ef1b0851/app/Dockerfile (draft pins this commit). |
| Upstream stages | `node-base` `FROM node:24-slim` (corepack); `node-build` runs `pnpm install --frozen-lockfile` then `pnpm run build` into `dist/`; `go-build` `FROM golang:1.26-alpine` runs `go tool sqlc generate`, `go tool templ generate`, `CGO_ENABLED=0 GOOS=linux go build -o ./hasty-paste`; final `FROM gcr.io/distroless/static-debian12` copies `dist/` and the binary. |
| Entrypoint / cmd | `ENTRYPOINT ["./hasty-paste"]`, `CMD ["serve"]`. |
| Port | `8080/tcp`, from `ENV BIND__PORT=8080` and `EXPOSE 8080`. The draft's `8000` is wrong and must not be used. |
| Env vars (real, upstream image) | `BIND__HOST=0.0.0.0`, `BIND__PORT=8080`, `DB_URI=sqlite:///opt/hasty-paste/data/db.sqlite`, `ATTACHMENTS_PATH=/opt/hasty-paste/data/attachments`. |
| Data paths | Upstream: `/opt/hasty-paste/data` (VOLUME). We remap to `/config/data`. |
| Health | Upstream HEALTHCHECK runs `./hasty-paste health-check` every 2 minutes. |
| Install docs | UNVERIFIED: `docs/install.md` returns 404 at the pinned commit, and `docs/` on main is a Hugo site. The draft's install link is stale; do not cite it. |
| apt | none needed (static Go binary, node build in a builder stage). |

## 2. Target layout

- `apps/hasty-paste/Dockerfile`
- `apps/hasty-paste/docker-bake.hcl`
- `apps/hasty-paste/settings.yaml`
- `apps/hasty-paste/container-test.yaml`
- `apps/hasty-paste/start.sh`

No `defaults/`, `etc/`, `health/` needed: the app creates its own database on first start (UNVERIFIED, see section 10). No `root/`. No `DOWNSTREAM_CHANGES.md` because nothing uses this image as a `FROM` base.

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The ubuntu base is the required final-stage base for a static Go binary plus a static web bundle; no language runtime is needed at runtime.
- Node build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, because it already ships Node (`apps/budge` uses it for a Node 24 build). Reuse the node base and avoid a second `node:24-slim` pull. pnpm is enabled via corepack, as `apps/it-tools` does (it installs corepack with npm first). UNVERIFIED: exact Node major in python-node; confirm with `node -v` in step 2.
- Go build stage: upstream uses `golang:1.26-alpine`. Go apps in `apps/` such as `apps/pwndrop` build on the ubuntu base with apt `golang-go`; this plan instead follows the go-runtime rule (`FROM golang:<ver> AS build`). Use `FROM golang:1.26-alpine@<digest>` (digest UNVERIFIED: resolve it in step 2 and pin it). The binary is static (`CGO_ENABLED=0`), so alpine as a build image is fine; it is not shipped.
- Closest siblings: `apps/it-tools` (node build stage, copy output into nginx final stage) and `apps/adguardhome-sync` (prebuilt binary in ubuntu with `ARG VERSION` and `TARGETARCH`).

## 4. Dockerfile

Build context: the upstream Dockerfile lives in `app/`, so the source tarball must be unpacked so that `app/` paths resolve (confirm in step 2).

1. Stage `web-build` from the python-node digest above:
   - `ARG VERSION`, `USER root`.
   - Fetch the tag source: `curl -fL https://github.com/enchant97/hasty-paste/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /src --strip-components=1` (URL form is standard GitHub; confirm it resolves in step 2).
   - `ENV PNPM_HOME=/tmp/pnpm PATH=/tmp/pnpm:$PATH`, `corepack enable`, `corepack prepare pnpm --activate`.
   - In the app folder: `pnpm install --frozen-lockfile && pnpm run build`. Output: `dist/`.
2. Stage `go-build` from the golang digest:
   - `ARG VERSION`, `ARG TARGETOS`, `ARG TARGETARCH`.
   - `GOCACHE=/tmp/go-cache`, `GOPATH=/tmp/go`, `GOMODCACHE=/tmp/go/pkg/mod` (never `/config`, never `/app`).
   - `go tool sqlc generate && go tool templ generate`, then `CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/hasty-paste .` run in the app folder (upstream uses `go build -o ./hasty-paste`; do not use `./...` with `-o`).
3. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@...`:
   - `USER root`.
   - `COPY --from=go-build --chmod=0755 /out/hasty-paste /app/hasty-paste`.
   - `COPY --from=web-build /src/app/dist /app/dist` (the server serves `dist/` from its working directory; UNVERIFIED how the path is resolved, see section 10).
   - `chown -R apps:apps /app && chmod -R 755 /app`.
   - `ENV BIND__HOST=0.0.0.0 BIND__PORT=8080 DB_URI=sqlite:///config/data/db.sqlite ATTACHMENTS_PATH=/config/data/attachments HOME=/config`.
   - `USER apps`, then `COPY --chmod=0755 . /` (so `start.sh` reaches the image).
   - `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /app`.
   - License file: upstream `LICENSE.txt` (AGPL) to `/usr/share/licenses/hasty-paste/` (confirm the file path in step 2).

The Dockerfile must have no `RUN` steps as `apps` (the stages stay root-owned until the final COPY).

## 5. docker-bake.hcl

- `APP` = `hasty-paste`.
- `VERSION` = `2.5.1` with `// renovate: datasource=github-releases depName=enchant97/hasty-paste versioning=semver`.
- `LICENSE` = `AGPL-3.0`.
- `SOURCE` = `https://github.com/enchant97/hasty-paste`.
- Standard targets: `docker-metadata-action`, `image` (args `VERSION`, labels source and licenses), `image-local` (`output = ["type=docker"]`, tags `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate with `docker buildx bake --print` in `apps/hasty-paste/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/enchant97/hasty-paste"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: BIND__HOST
    default: "0.0.0.0"
    required: false
  - name: BIND__PORT
    default: "8080"
    required: false
  - name: DB_URI
    default: "sqlite:///config/data/db.sqlite"
    required: false
  - name: ATTACHMENTS_PATH
    default: "/config/data/attachments"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Defaults must match `start.sh` and the image `ENV`. Do not add env names the app does not read. `dependencies: []` (no database service; SQLite is embedded).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu
mkdir -p /config/data/attachments
cd /app
exec ./hasty-paste serve
```

- Idempotent: `mkdir -p` only, no overwrite of existing data.
- Never writes to `/app`. The SQLite file and attachments go under `/config/data`.
- `exec` for signal handover.
- Caches: none written at runtime (Go and pnpm caches stay in build stages under `/tmp`).
- The app reads its config from the env names in section 6. No seed file is needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
```

- One `tcp` probe for port `8080` (the only port in `settings.yaml`).
- An `http` probe on `/` is not added yet: the response code on an empty `/config` is UNVERIFIED. Add one only after step 3 shows the path returns 200 (it must not be guessed).
- `timeoutSeconds`: use the value from `apps/it-tools` or `apps/adguardhome-sync` for Go-based servers (check which the sibling uses in its test file).
- No `filePaths` needed unless the build step shows the server writes files at startup.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Adapted |
| --- | --- |
| Distroless final, default user | `USER apps` on ubuntu base. |
| `/opt/hasty-paste/data` (VOLUME) | `/config/data` (`DB_URI` and `ATTACHMENTS_PATH` remapped). |
| Writable `/opt` | `/app` read-only at runtime. Nothing is written there. |
| Go build cache | `/tmp` (build stage only). |
| `HEALTHCHECK ./hasty-paste health-check` | Not carried over; the test uses the `tcp` probe. Can be added as a container healthcheck later. |

Run check: `docker run --read-only --tmpfs /tmp -v hasty-paste-probe-config:/config <image>`. The DB must be created under `/config/data` only.

## 10. Risks, caveats and open questions

- Source-only: no release binary and no checksum published. The build is reproducible only if the tag archive is pinned, which the tag gives but does not guarantee. Note this in the PR.
- Static-frontend path: UNVERIFIED how `serve` locates `dist/` (relative to the working dir or fixed path). Confirm in step 2 by reading the upstream Go code or a `./hasty-paste serve` log line; set `WORKDIR` and the `dist` target to match.
- Migrations: UNVERIFIED that `serve` runs DB migrations on start (`migrations/` exists in the source). If it does not, `start.sh` needs a `migrate` step; check before writing `start.sh`.
- Access control: creating pastes may be possible without login by default (draft inference, UNVERIFIED). Document in the PR and in `settings.yaml` description, do not change defaults.
- Unbounded data growth: paste data and attachments grow with no retention limit (draft inference, UNVERIFIED for this version).
- arm64: compiled from source for `TARGETARCH`. Go cross-compiles without CGO, so arm64 should not need extra work; not yet tested.
- Build-time cost: node install plus Go modules; both stages use `/tmp` caches.
- Blockers: none known.

## 11. Build and test steps

1. `cd apps/hasty-paste && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Probe run: `docker run --rm -d --name hasty-paste-probe --read-only --tmpfs /tmp -v hasty-paste-probe-config:/config hasty-paste:2.5.1`, then `docker logs -f hasty-paste-probe`. Expected readiness signal: a log line with the bind address `0.0.0.0:8080` (or the server's "listening" line, UNVERIFIED wording). No fatal error, container still running.
4. Test: `forgetool containers test --image hasty-paste:2.5.1 --config ./apps/hasty-paste/container-test.yaml`.
5. Cleanup: `docker rm -f hasty-paste-probe; docker volume rm hasty-paste-probe-config`.
6. arm64 only if the amd64 build fails on arch-specific code.

## 12. PR checklist

- Branch `feat/add-hasty-paste` from `main`.
- Commit and PR title: `feat(hasty-paste): add new container` (Conventional Commits, app as scope, target `main`).
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; keep its sections and checkboxes, check only what applies.
- Notes section must contain `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it.
- Honest "not tested" list: anything not built or run in this session (for example arm64, the probe run, forgetool test) must not be checked off.
