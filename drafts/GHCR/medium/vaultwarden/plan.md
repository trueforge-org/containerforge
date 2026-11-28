# vaultwarden — implementation plan
> Source: ./draft.md · Target: apps/vaultwarden/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Scope: this plan covers Row 1 only (main image `ghcr.io/dani-garcia/vaultwarden`). Row 2 (the timshel SSO fork, a beta sidecar) is a different code base; it is listed in section 10 as an open question and is not part of this app.

## 1. Verified upstream facts

| Item | Value | Source |
|---|---|---|
| Latest stable version | 1.37.5, published 2026-11-01 | `gh api repos/dani-garcia/vaultwarden/releases/latest` |
| Renovate | `datasource=github-releases depName=dani-garcia/vaultwarden versioning=semver` (the release tag is `1.37.5`, no `v` prefix). Confirm the tag format is strict semver before writing the bake file. | GitHub release API |
| License (SPDX) | AGPL-3.0 | `gh api repos/dani-garcia/vaultwarden` |
| Source | https://github.com/dani-garcia/vaultwarden | draft.md |
| Per-arch binary | None: the release has no assets. Compile on amd64 and arm64. | release API (`assets: []`) |
| Copy-from image | `ghcr.io/dani-garcia/vaultwarden:1.37.5` is published, but it is a glibc debian build from upstream; using it would be a COPY --from of a binary we did not build. Prefer our own build, as the draft plans. | draft.md |
| Checksum source | None for the source tarball; source is pinned by git tag. The web vault is pinned by image digest in the upstream Dockerfile. | upstream Dockerfile |
| Upstream Dockerfile (docker/Dockerfile.debian @6ed6921) | Stages: `vault` from `docker.io/vaultwarden/web-vault@sha256:7baaa7d...eb52` (full digest UNVERIFIED; the fetched page shows it truncated); `xx` from `docker.io/tonistiigi/xx@sha256:40fe21f...8264a6`; `build` from `docker.io/library/rust:1.99.1-slim-trixie`; final `docker.io/library/debian:trixie-slim`. Build: `xx-cargo build --features ${DB} --profile ${CARGO_PROFILE}` with `CARGO_PROFILE=release`, `DB=sqlite,mysql,postgresql`, run twice (deps, then source). Web vault v2026.10.1 per the upstream comment. Runtime apt: `ca-certificates curl libmariadb3 libpq5 openssl`. `ENV ROCKET_PROFILE=release ROCKET_ADDRESS=0.0.0.0 ROCKET_PORT=80`. `WORKDIR /`. `COPY --from=vault /web-vault ./web-vault`. `EXPOSE 80`. `VOLUME /data`. `CMD ["/start.sh"]`. `HEALTHCHECK` via `/healthcheck.sh` every 60s. No USER in the final stage. | https://raw.githubusercontent.com/dani-garcia/vaultwarden/6ed6921cc2b0e03b4d74189574d2a5e71c512e97/docker/Dockerfile.debian |
| Ports | 80 in upstream (`ROCKET_PORT=80`), 80/http per EXPOSE. Changed in our build; see section 9. | upstream Dockerfile |
| Env vars | `ROCKET_PROFILE`, `ROCKET_ADDRESS`, `ROCKET_PORT` (confirmed). `DATA_FOLDER`: not set in upstream; the vaultwarden default is a relative `data` folder (UNVERIFIED against the 1.37.5 docs). `ADMIN_TOKEN`, `DOMAIN`, `DATABASE_URL`: UNVERIFIED names and defaults for 1.37.5. | upstream Dockerfile; vaultwarden docs not fetched |
| Write paths | `/data` (VOLUME in upstream). Our target: `/config`. | upstream Dockerfile |
| Dependencies | PostgreSQL optional (chart uses external PostgreSQL via cnpg, draft). SQLite is the default with no DB needed. `apps/postgresql` exists in this repo. | draft.md, `apps/postgresql` |

## 2. Target layout

Files in `apps/vaultwarden/`:
- `Dockerfile` (required; two stages: rust build, ubuntu final)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: seed config defaults, `exec` vaultwarden)

Not needed: `defaults/` (unless a default config file is seeded; then include it, else omit), `etc/`, `health/` (only if a healthcheck script is shipped), `app/` (not used). Never use `root/`.

`DOWNSTREAM_CHANGES.md` is not needed: vaultwarden is not a `FROM` base for other apps.

## 3. Base image

Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.

Build stage: `docker.io/library/rust:1.99.1-slim-trixie` (copied from the upstream Dockerfile). Note: the build stage's glibc must be no newer than the final stage's glibc. Trixie (glibc 2.41) is older than Ubuntu 26.04 (verify the glibc version in the built image with `ldd --version`), so the binary runs on the final image. If Ubuntu 26.04 glibc is older than trixie's, use a rust image built on an Ubuntu tag instead (UNVERIFIED, to check at build time).

Closest sibling for layout: `apps/bookstack` (PHP) is not Rust; use `apps/adguardhome-sync` for the ubuntu final stage and `USER apps` pattern. Check for an existing Rust app in `apps/` (none found in the repo listing at planning time).

## 4. Dockerfile

Stages:
1. `FROM --platform=$BUILDPLATFORM docker.io/library/rust:1.99.1-slim-trixie AS build`
2. Copy the cross-compile helper `xx` from the pinned digest, as upstream does (`tonistiigi/xx@sha256:...`, full digest must be resolved). Keep the upstream digests unless they are no longer published.
3. `ARG VERSION` (must equal bake `VERSION`), `ARG CARGO_PROFILE=release`, `ARG DB=sqlite,mysql,postgresql`.
4. Fetch the source at tag `${VERSION}` from GitHub (`git clone --depth 1 --branch ${VERSION}` or an archive). Pin the commit SHA in bake if an archive checksum is not published (UNVERIFIED: no tarball checksum found).
5. Dependency layer: run `xx-cargo build --features ${DB} --profile ${CARGO_PROFILE}` once on a stub so dependencies cache, then once on the source. Use `PKG_CONFIG` as in upstream.
6. Build with `CARGO_HOME` and `CARGO_TARGET_DIR` under `/tmp` or the build stage (not in the final image).
7. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...`.
8. `USER root` only for the apt step: `apt-get install --no-install-recommends ca-certificates curl libmariadb3 libpq5 openssl`, skipping packages the base already has. Pin the versions if they come from apt, per the Dockerfile rules (`libmariadb3` and `libpq5` package names on Ubuntu 26.04 are UNVERIFIED). Clean `/var/lib/apt/lists/*`.
9. `COPY --from=build /app/target/release/vaultwarden /app/vaultwarden`. Path depends on the build target (UNVERIFIED).
10. `COPY --from=vault /web-vault /app/web-vault` (the web vault digest pinned to the same version as upstream; full digest UNVERIFIED). Ship its license.
11. `ARG VERSION`, `ARG TARGETARCH`. Use `ENV` for `ROCKET_PROFILE=release`, `ROCKET_ADDRESS=0.0.0.0`, `ROCKET_PORT=8080`, `DATA_FOLDER=/config` (UNVERIFIED name for 1.37.5). `HOME=/config`.
12. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `CMD ["/start.sh"]`.
13. Do not build Rust in the final stage; do not write to `/app`.

Bake sets `VERSION` and passes the rust image as a build arg if it is parameterised.

## 5. docker-bake.hcl

- `target "docker-metadata-action" {}`
- `variable "APP" { default = "vaultwarden" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=dani-garcia/vaultwarden versioning=semver  default = "1.37.5" }`
- `variable "LICENSE" { default = "AGPL-3.0-only" }`. The GitHub API returned `AGPL-3.0`; the SPDX form for the bake value is `AGPL-3.0-only` or `AGPL-3.0-or-later`. Use the license text in the repo to choose (UNVERIFIED: confirm the license file). Do not guess.
- `variable "SOURCE" { default = "https://github.com/dani-garcia/vaultwarden" }`
- Standard targets: `image` (args VERSION, labels source, licenses), `image-local` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `image-all` (linux/amd64, linux/arm64), `group "default" { targets = ["image-local"] }`.
- Build time is long on both arches. The PR should say this.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/dani-garcia/vaultwarden"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: DATA_FOLDER
    default: "/config"
    required: false
  - name: ROCKET_PORT
    default: "8080"
    required: false
  - name: ROCKET_ADDRESS
    default: "0.0.0.0"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
    required: false
```

- Port 8080 (not 80): non-root `apps` cannot bind ports below 1024. Document the change in the PR.
- Only list env vars that start.sh or vaultwarden reads (`DATA_FOLDER` is UNVERIFIED until checked). Add `DOMAIN` and `ADMIN_TOKEN` only after their names are confirmed, and add a required-or-generated rule for the admin token (see section 7).
- The `dependencies` shape above follows the sibling `settings.yaml` schema; confirm the key name in a sibling that declares an optional dependency (for example one that lists `postgresql`).
- Check the field name for optional dependencies in a sibling before writing; the draft says PostgreSQL is external (cnpg) and not required.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Seed nothing unless a default config is shipped. Do not overwrite existing `/config` data.
- Create `/config` subdirectories only when missing (e.g. `attachments`, `icon_cache` if vaultwarden needs them at startup; UNVERIFIED).
- If `ADMIN_TOKEN` is set, pass it through the environment (do not write it to a file). If not set, the admin page stays disabled (UNVERIFIED behaviour in 1.37.5).
- If `DATABASE_URL` is set, pass it through; if not, the default SQLite file lives in `DATA_FOLDER` (`/config`).
- `cd /app` (web-vault is resolved relative to cwd, as upstream WORKDIR is `/`, so confirm `WEB_VAULT_FOLDER` if needed; UNVERIFIED).
- `exec /app/vaultwarden`.
- Never write into `/app`. Temp files go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 300
filePaths:
- /app/vaultwarden
- /app/web-vault
tcp:
- port: '8080'
```

- Every port in settings.yaml has a tcp probe (8080).
- The test runs with no env. vaultwarden starts with SQLite in `/config`, so the default path is tested. Required-env code (DATABASE_URL, ADMIN_TOKEN) is not tested; add its files to `filePaths` only if they exist.
- Add an http probe on `/` (expected 200 for the web vault, UNVERIFIED) only after a local run confirms it.
- `timeoutSeconds: 300`: vaultwarden starts quickly, but a first start with the SQLite migration is slower; check the sibling value during the build.

## 9. Rootless and read-only-rootfs adaptations

Upstream remaps:
- Port 80 → 8080 (non-root cannot bind 80). `ROCKET_PORT` changes in settings.yaml and Dockerfile.
- `/data` (upstream VOLUME) → `/config` through `DATA_FOLDER`.
- `/start.sh` (upstream CMD) → our `start.sh` (same path).
- `HEALTHCHECK` from upstream (`/healthcheck.sh`) is not shipped; it is replaced by the container-test probes. If a healthcheck is needed, add `health/` with a script and reference it in the sibling style. Not in this plan.
- Upstream runs as root (no USER). Target runs as `apps`.

Security expectations reconciliation (draft: non-root yes, read-only yes, privileged no):
- Matches the target: `USER apps`, read-only rootfs compatible, not privileged. The draft's expectations are consistent with the ContainerForge rules.
- Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- Long Rust compile on both arches; amd64 and arm64 builds are slow. arm64 needs a cross-compile helper (xx) and may not be validated in the PR.
- Full sha256 digests for `vaultwarden/web-vault` and `tonistiigi/xx` are truncated in the fetched page. Resolve the full digests from the upstream Dockerfile before writing the Dockerfile (UNVERIFIED).
- The build stage (trixie) vs final stage (Ubuntu 26.04) glibc compatibility: check with `ldd --version` (section 3).
- Config variable names for 1.37.5 (`DATA_FOLDER`, `DOMAIN`, `ADMIN_TOKEN`, `DATABASE_URL`) are UNVERIFIED; only the ROCKET_* names are confirmed.
- Bitwarden clients require HTTPS, so a TLS reverse proxy in front is needed for normal use (inferred from the draft).
- The admin panel needs `ADMIN_TOKEN` (inferred from the draft, UNVERIFIED name).
- Row 2 (`ghcr.io/timshel/vaultwarden:1.30.5-9`, SSO fork) is a different code base. Not in this app. If a second app is wanted, it needs its own folder and plan (open question for the user).
- Licence SPDX value for the bake file: UNVERIFIED (`AGPL-3.0` from the API; choose the `-only` or `-or-later` form from the license text).
- Blocker check: no privileged need, no GPU; the only blocker is build time.

## 11. Build and test steps

From `apps/vaultwarden`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local` (long; allow the build to finish)
3. Clean run with an empty volume:
   ```sh
   docker volume create vaultwarden-probe-config
   docker run --rm -d --name vaultwarden-probe --read-only --tmpfs /tmp \
     -v vaultwarden-probe-config:/config ${APP}:${VERSION}
   docker logs -f vaultwarden-probe
   ```
   Pass: the container stays up, the logs show a Rocket listening line on port 8080 (text UNVERIFIED for 1.37.5; the port check is the fallback), and there are no fatal errors.
4. Cleanup: `docker rm -f vaultwarden-probe; docker volume rm vaultwarden-probe-config`.
5. `forgetool containers test --image vaultwarden:<version> --config ./apps/vaultwarden/container-test.yaml`. If forgetool is not available, run step 3 and check port 8080 and the file paths by hand.
6. Repeat step 3 with the populated volume to confirm the restart path (SQLite file in `/config`).
7. arm64: `docker buildx bake --set image-local.platform=linux/arm64 image-local` only after amd64 passes; state in the PR if it is not run.

No docker build was run during planning.

## 12. PR checklist

- Branch: `feat/add-vaultwarden`
- Commit: `feat(vaultwarden): add new container`
- PR title: `feat(vaultwarden): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Say what was not tested: arm64, the long build time, the admin panel, the PostgreSQL path, and the reverse-proxy TLS setup unless they were run. Say that Row 2 (the SSO fork) is not included.
- Not applicable: DOWNSTREAM_CHANGES.md (not a base image).
