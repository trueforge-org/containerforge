# invidious — implementation plan
> Source: ./draft.md · Target: apps/invidious/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.20261114.0 (latest release, published 2026-11-14). Upstream release has no assets; it is a source tag. Source: https://api.github.com/repos/iv-org/invidious/releases/latest |
| Draft tag | Draft uses `quay.io/invidious/invidious:latest`, pinned by the chart. Quay tags/digests not verified (Quay API requires auth): UNVERIFIED |
| Renovate | `datasource=github-releases depName=iv-org/invidious versioning=loose` (tags are `v2.YYYYMMDD.N`, not strict semver) |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`). Use `AGPL-3.0-or-later` only if the repo's license header says so: UNVERIFIED |
| Source URL | https://github.com/iv-org/invidious |
| Download | Source tarball `https://github.com/iv-org/invidious/archive/refs/tags/${VERSION}.tar.gz`, compiled in the image. No prebuilt binary. |
| Checksum source | None published for the release. Pin by tag and record the commit SHA in the plan. |
| Upstream Dockerfile reviewed | `docker/Dockerfile` on master (https://raw.githubusercontent.com/iv-org/invidious/master/docker/Dockerfile). The draft pins commit `4e9d20dd…` for the same file; master was reviewed, the pinned commit is UNVERIFIED. |
| Upstream base and build | Build stage `84codes/crystal:1.22.3-alpine`. OpenSSL built from source (`OPENSSL_VERSION`, `OPENSSL_SHA256` build args, sha256 checked). `shards install --production`, then `crystal build ./src/invidious.cr --static` with `-lxml2 -llzma`. Final stage `alpine:3.24`. |
| Upstream runtime | `USER invidious` (UID/GID 1000), `WORKDIR /invidious`, `EXPOSE 3000`, `ENTRYPOINT ["/sbin/tini","--"]`, `CMD ["/invidious/invidious"]`, no `VOLUME`, no `ENV`. Copies `assets`, `config`, `locales` and the binary. Runs `sed` to change `host: 127.0.0.1` to `host: invidious-db` in `config/config.yml`. |
| Draft premise | **Contradicted.** The draft says it is a glibc build on the ubuntu base with the upstream Crystal linux tarball. Upstream builds a fully static musl binary on Alpine. See section 10. |
| Ports | 3000/tcp (EXPOSE, confirmed) |
| Env vars | Upstream sets none in the Dockerfile. Config comes from `config/config.yml` (keys such as `db`, `host`, `port`, `domain`, `hmac_key`). Env override names are UNVERIFIED: do not add them to `settings.yaml` until checked against `src/invidious/config.cr` on master. |
| Dependency | `postgresql` (apps/postgresql exists, so mark ✅). |
| arm64 | Upstream Dockerfile uses `84codes/crystal` which has an arm64 variant (UNVERIFIED for this tag). Not checked. |
| Asset packages | `rsvg-convert`, `ttf-opensans`, `tini`, `tzdata` are Alpine packages. Ubuntu equivalents: `librsvg2-bin`, `fonts-open-sans`, `tini`, `tzdata` (names UNVERIFIED on Ubuntu 26.04). |

## 2. Target layout

Files under `apps/invidious/` (allow-list rules in `include/.dockerignore`):

- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`
- `defaults/config.yml` (copied to `/defaults`, seeded into `/config` only when missing)

Not needed: `etc/`, `scripts/`, `health/`, `app/`. `root/` must not be touched.

`DOWNSTREAM_CHANGES.md`: not needed, the app is not a `FROM` base.

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (same as `apps/pwndrop` and `apps/postgresql`).
- Build stage: the upstream build (Crystal, OpenSSL) is alpine-based. Two options:
  - **A (recommended, if the static binary runs on glibc):** build stage is `84codes/crystal:1.22.3-alpine@<digest>` (digest UNVERIFIED, must be pinned from the registry at build time), copy `/invidious` out with `COPY --from=`. The result is a static musl binary, which needs no musl at runtime, and it runs on the ubuntu final stage.
  - **B:** build Crystal on ubuntu from the upstream linux tarball (URL and checksum UNVERIFIED). Glibc binary, more work, arm64 UNVERIFIED.
- Closest siblings: `apps/pwndrop` (build stage plus ubuntu final stage), `apps/postgresql`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Default in bake: `v2.20261114.0`.
2. Stage `build` (`FROM 84codes/crystal:1.22.3-alpine@<digest>`): `apk add --no-cache sqlite-static yaml-static`; copy source via `curl -fL` from the tag tarball into `/tmp/invidious`; `shards install --production`; `crystal build ./src/invidious.cr --static --release --link-flags "-lxml2 -llzma -no-pie"` into `/tmp/invidious-bin`.
   - OpenSSL: upstream builds OpenSSL statically because Alpine has no static libssl usable here. Keep the same pattern: `OPENSSL_VERSION` and `OPENSSL_SHA256` as ARGs, `sha256sum -c` before extract. Versions UNVERIFIED: copy from `docker/Dockerfile` in the pinned commit.
   - Build packages (`apk`): `curl perl linux-headers`, `libxml2-static`/`xz-static` for `-lxml2 -llzma` (UNVERIFIED package names).
3. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:…`:
   - `USER root`, `apt-get install --no-install-recommends librsvg2-bin fonts-open-sans tini tzdata` (package names UNVERIFIED on 26.04). Skip any already in the base; check with `dpkg -l` in a local build.
   - Copy `assets`, `config`, `locales` from the source tree to `/app/invidious/`, and the binary to `/app/invidious/invidious`. Keep `/app` read-only at runtime.
   - `COPY --from=build /tmp/invidious-bin /app/invidious/invidious`.
   - `chown -R apps:apps /app` is not needed if files are only read. Use `chmod -R 755` as in `apps/adguardhome-sync` if the bake sets ownership.
   - `ENV HOME=/config`.
   - `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`.
   - Licence file: copy `LICENSE` from the source to `/usr/share/licenses/invidious/LICENSE`.
   - The base image already sets `ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]` (`apps/ubuntu/Dockerfile`), so do not install `tini` or set an ENTRYPOINT; UNVERIFIED how `/entrypoint.sh` hands over to `/start.sh`, check before writing the Dockerfile.

## 5. docker-bake.hcl

- `APP = "invidious"`, `VERSION = "v2.20261114.0"` with renovate comment `// renovate: datasource=github-releases depName=iv-org/invidious versioning=loose`.
- `LICENSE = "AGPL-3.0"`, `SOURCE = "https://github.com/iv-org/invidious"`.
- Four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`.
- Validate with `docker buildx bake --print` in `apps/invidious/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/iv-org/invidious"
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
  - postgresql
```

- `env` lists only `TZ` until the upstream env names are verified. Do not invent names.
- Database: the config's `db` section must point at the PostgreSQL service. `start.sh` writes the DB host from an env var it sets itself, using the `sed` idea from upstream but targeting `/config/config.yml`, not `/app`. Exact names are an open question (section 10).

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- Seed: `[ -f /config/config.yml ] || cp /defaults/config.yml /config/config.yml`. Never overwrite existing user state.
- Config path: the binary reads `config/config.yml` relative to its working directory or a config env var (UNVERIFIED). Verify in `src/invidious/config.cr`. Until verified, `cd /app/invidious` and link nothing into `/app`; use the env var if it exists.
- DB password: apply from env on every start (the protocol requires this for database apps). Keep it out of the process list and out of files other than `/config/config.yml`.
- Always `exec /app/invidious/invidious` so signals reach the process.
- Bind `0.0.0.0` on port 3000 through the config (`host`/`port` keys, verify names).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3000'
```

- `timeoutSeconds`: copy from a sibling Crystal/Go web app of the same weight; start from 120 (UNVERIFIED sibling value).
- The app needs PostgreSQL to serve, so this is a database-dependent app. The protocol's narrow exception applies only if all three criteria hold (hard dependency on a DB, fails without it, not feasible to wire a sidecar in `container-test.yaml`). They do. Add a comment:
  `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`
- The narrowed assertion is the TCP probe on 3000 plus the `Listening` or startup log line, which must be confirmed in the run.

## 9. Rootless and read-only-rootfs adaptations

- Write paths upstream: none in the image. The app writes logs and any runtime data to the working directory or `/tmp` (UNVERIFIED). Redirect any writes to `/tmp` (scratch) or `/config` (persistent). Nothing under `/app`.
- Upstream runs as `invidious` UID 1000. ContainerForge runs as `apps`. Confirm the `apps` UID is 1000 in the base; if not, note it.
- Draft expects `runAsUser 0` in the chart. ContainerForge runs `USER apps`, so the chart's root setting is dropped on purpose.
- `readOnlyRootFilesystem`: draft says false in the chart. Target is true: the app writes only to `/tmp` and `/config`.
- `privileged`: false. No extra persistence beyond `/config`.

## 10. Risks, caveats and open questions

- **Draft premise is wrong.** Upstream is Alpine/musl static (`alpine:3.24`, `crystal build --static`). The draft says "glibc build on ubuntu" and "copy-from no because musl". A static binary does not need musl at runtime, so `COPY --from` of the upstream image is possible in principle. Decide option A or B in section 3 before writing the Dockerfile. Recommend option A and verify with `ldd` (expect "not a dynamic executable") during the build.
- Crystal and OpenSSL versions and checksums must be copied from the pinned commit, not master: UNVERIFIED.
- Env var names for the DB host and password are UNVERIFIED (section 6, 7).
- arm64: UNVERIFIED for the Crystal image and for the static build.
- YouTube rate limits and API changes (draft caveat, inferred): expect upstream breakage. Outbound access is required.
- Blockers: none confirmed. Possible blocker: the DB password handling depends on the config key names.

## 11. Build and test steps

From `apps/invidious/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run and log check (empty `/config`, read-only):
   ```sh
   docker run --rm -d --name invidious-probe --read-only --tmpfs /tmp \
     -v invidious-probe-config:/config invidious:v2.20261114.0
   docker logs -f invidious-probe
   ```
   Expected readiness signal: the Invidious startup line that reports listening on port 3000 (exact text UNVERIFIED). Without a reachable PostgreSQL the process may exit. Record the log; per protocol the DB wait message counts only if the process stays alive.
   Clean up: `docker rm -f invidious-probe; docker volume rm invidious-probe-config`.
4. `forgetool containers test --image invidious:v2.20261114.0 --config ./apps/invidious/container-test.yaml`
5. Run with a PostgreSQL sidecar only for a manual functional check (not in the suite).

## 12. PR checklist

- Branch: `feat/add-invidious`
- Commit: `feat(invidious): add new container`
- PR title: `feat(invidious): add new container`
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Say what was not tested: arm64, the PostgreSQL functional path (narrowed test), the Crystal build if not run locally.
- Do not check "Built container locally" unless the build was run.
