# gitea — implementation plan
> Source: ./draft.md · Target: apps/gitea/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `28.4.0` (GitHub release `v28.4.0`, published 2026-11-15T19:39:47Z; it is the latest release per the releases/latest API). Matches the chart image `ghcr.io/go-gitea/gitea:28.4.0-rootless`. |
| Renovate | `// renovate: datasource=github-releases depName=go-gitea/gitea versioning=semver` (tag has `v` prefix; semver strips it). The repo's own renovate config was not fetched, so the annotation is the standard form, not copied from a sibling. |
| License | MIT (GitHub API `license.spdx_id`: `MIT`). |
| Source URL | https://github.com/go-gitea/gitea |
| Download (amd64) | https://github.com/go-gitea/gitea/releases/download/v28.4.0/gitea-28.4.0-linux-amd64 (HTTP 200 confirmed) |
| Download (arm64) | https://github.com/go-gitea/gitea/releases/download/v28.4.0/gitea-28.4.0-linux-arm64 (HTTP 200 confirmed) |
| Checksum source | Per-asset `.sha256` files on the same release: `gitea-28.4.0-linux-amd64.sha256` = `154e775bd6bb589fc14cd93a689d8fbc64090aaa3ec537f0e3af298b13c6d386`, `gitea-28.4.0-linux-arm64.sha256` = `5f8aad6a9fdb115170afc6691cb7dcb5f492dea82c5224385622cff093f66dbb`. Each `.sha256` is `<hash>  <asset name>`, so `sha256sum -c` works once the file is saved under its asset name. GPG `.asc` and sigstore bundles are also published (not verified by this plan). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/go-gitea/gitea/v28.4.0/Dockerfile.rootless: builds on `golang:1.27-alpine3.24` (frontend via pnpm, backend `make backend` with `TAGS="bindata timetzdata"`), final stage `alpine:3.24`, `USER 1000:1000`, `EXPOSE 2222 3000`, `VOLUME ["/var/lib/gitea", "/etc/gitea"]`, binary at `/app/gitea/gitea`, `ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/bin/docker-entrypoint.sh"]`. |
| Upstream env (set by the image) | `GITEA_WORK_DIR=/var/lib/gitea`, `GITEA_CUSTOM=/var/lib/gitea/custom`, `GITEA_TEMP=/tmp/gitea`, `TMPDIR=/tmp/gitea`, `GITEA_APP_INI=/etc/gitea/app.ini`, `HOME=/var/lib/gitea/git`. Source: the same Dockerfile. |
| Entrypoint command | `exec /usr/local/bin/gitea -c "${GITEA_APP_INI}" web` (https://raw.githubusercontent.com/go-gitea/gitea/v28.4.0/docker/rootless/usr/local/bin/docker-entrypoint.sh, line 16). |
| Ports | 3000/tcp (web UI, HTTP), 2222/tcp (built-in SSH, optional). Source: `EXPOSE` in the Dockerfile. |
| Binary arch | amd64 and arm64 release binaries exist, so `TARGETARCH` maps directly to the asset name (no mapping table needed). |
| Static linking | UNVERIFIED: whether the release binary is static (not checked with `file` or `ldd`). The ubuntu base is glibc, and the upstream runtime used alpine (musl). Confirm during step 2 of the protocol. |
| Config key names | UNVERIFIED: the `GITEA__section__KEY` override form and the database keys were not checked on the configuration cheat sheet. Plan avoids relying on them. |

Differences from the draft:
- The draft says "Go release binary with embedded assets": confirmed by the upstream build (`bindata` tag).
- The draft expects `/config`. Upstream uses `/var/lib/gitea` and `/etc/gitea`, so the paths must be remapped (section 9).
- The draft lists `git (inferred)` as an apt package. `apps/ubuntu/Dockerfile` already installs `git`, `curl` and `ca-certificates` (apt list around lines 43-50), so no apt step is needed. Re-check the base if the base changes.

## 2. Target layout

Files under `apps/gitea/`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required: creates `/config/gitea` and `/tmp/gitea`, then execs gitea)

Not needed: `defaults/` (gitea writes its own `app.ini` through the install wizard, so no seeded config is required; see section 7), `etc/`, `scripts/`, `health/`, `app/`. Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`
- Why it fits: a Go release binary has no runtime requirement beyond glibc (confirm, see section 1), and git, curl and CA certificates are already in the base. Upstream's alpine final stage is not needed.
- Closest sibling: none for gitea. For a single-binary web app on ubuntu with a binary download and `/config` state, use `apps/adguardhome-sync` (same base digest, `curl` + `tar`, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

Step list:

1. `FROM` the ubuntu base digest above. `ARG VERSION`, `ARG TARGETARCH`. `USER root` for the install step only.
2. Download the binary and its checksum, verify, install to `/app/gitea/gitea`:
   ```dockerfile
   RUN set -eux; \
       asset="gitea-${VERSION}-linux-${TARGETARCH}"; \
       base="https://github.com/go-gitea/gitea/releases/download/v${VERSION}"; \
       curl -fsSL -o "/tmp/${asset}" "${base}/${asset}"; \
       curl -fsSL -o "/tmp/${asset}.sha256" "${base}/${asset}.sha256"; \
       (cd /tmp && sha256sum -c "${asset}.sha256"); \
       mkdir -p /app/gitea; \
       install -m 0755 "/tmp/${asset}" /app/gitea/gitea; \
       rm -f "/tmp/${asset}" "/tmp/${asset}.sha256"; \
       chown -R apps:apps /app/gitea
   ```
   `TARGETARCH` values `amd64` and `arm64` match the asset names exactly. Other arches are not in scope (the draft lists only amd64 and arm64).
3. No apt step. Do not add `git`, `curl` or `ca-certificates`: the base has them.
4. Environment (moves all writes off `/app`):
   ```dockerfile
   ENV HOME=/config \
       GITEA_WORK_DIR=/config/gitea \
       GITEA_CUSTOM=/config/gitea/custom \
       GITEA_APP_INI=/config/gitea/app.ini \
       GITEA_TEMP=/tmp/gitea \
       TMPDIR=/tmp/gitea
   ```
5. `USER apps` is set after the install (the final stage must end with `USER apps`).
6. `COPY --chmod=0755 . /` after `USER apps`, as in siblings.
7. `EXPOSE 3000 2222` and `VOLUME /config`.
8. Do not add `HEALTHCHECK` (the upstream Dockerfile says not to, and ContainerForge uses the test suite).

No `CMD` is needed: `start.sh` is the entrypoint, following `apps/valkey` (`CMD ["/start.sh"]`). Set `CMD ["/start.sh"]` explicitly.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "gitea"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=go-gitea/gitea versioning=semver
  default = "28.4.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/go-gitea/gitea"
}
```

Then the standard `group "default"`, `image`, `image-local` (`${APP}:${VERSION}`), and `image-all` (linux/amd64, linux/arm64) targets, copied from `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` must equal the `ARG VERSION` consumed by the Dockerfile (no `v` prefix). Validate with `cd apps/gitea && docker buildx bake --print`.

## 6. settings.yaml

- Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json` and `schema_version: 1`.
- `upstream_env_url: "https://github.com/go-gitea/gitea"`.
- `ports`:
  - `port: 3000`, `protocol: tcp`, `required: false` (web UI; the draft's main port).
  - `port: 2222`, `protocol: tcp`, `required: false` (SSH; only used if the user enables built-in SSH).
- `env` (only variables the start script or the binary reads; defaults match `start.sh`):
  - `GITEA_APP_INI` default `/config/gitea/app.ini`, `required: false`
  - `GITEA_WORK_DIR` default `/config/gitea`, `required: false`
  - `GITEA_CUSTOM` default `/config/gitea/custom`, `required: false`
  - `TZ` default `Etc/UTC`, `required: false` (sibling convention)
  - The `GITEA_*` variables are set by the upstream image. The binary reading them is UNVERIFIED on a fetched page, so confirm against the config cheat sheet before merging.
- `volumes`: `- path: /config`, `required: true`.
- `opt_dependencies` (the draft marks both as optional; the protocol's `dependencies:` is for hard dependencies):
  - `- name: postgresql`, `required: false` (apps/postgresql exists: ✅; `opt_dependencies` is used this way in `apps/babybuddy/settings.yaml`)
  - `- name: memcache`, `required: false` (apps/memcache exists: ✅; the draft's "memcached" maps to this app)

## 7. start.sh

Requirements: idempotent, empty `/config` works, no writes to `/app`, `exec` at the end.

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/gitea/custom /config/gitea/data /config/gitea/log /tmp/gitea

export GITEA_APP_INI="${GITEA_APP_INI:-/config/gitea/app.ini}"

exec /app/gitea/gitea -c "${GITEA_APP_INI}" web
```

Points to decide and confirm:
- With an empty `/config`, there is no `app.ini`. Gitea should then show the install wizard on port 3000 (UNVERIFIED on a fetched page; check in step 3). Do not seed an `app.ini`: the wizard writes it, and seeding would skip the wizard.
- Do not overwrite an existing `app.ini`. The script never writes to it.
- Upstream's `docker-entrypoint.sh` also runs `chown`/`chmod` checks. Skip them: the `apps` user owns `/config`.
- Bind address: gitea defaults `HTTP_ADDR` to `0.0.0.0` on port 3000. UNVERIFIED; if the wizard's `app.ini` sets `127.0.0.1`, the TCP test fails. Confirm in step 3.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'

filePaths:
- /app/gitea/gitea
```

- `tcp` probe for port 3000 (required by the coverage minimum). Port 2222 is optional and not published by default; add a probe only if the port is made required.
- `timeoutSeconds` is a top-level key (not per probe) and 180 is the most common sibling value (20 of 29 files that set it).
- Test runs with no environment variables, so the first-run wizard path is what gets tested. The database-backed path (postgresql) is not tested here; no narrowing is needed because SQLite is the default and the database is optional.
- Add an `http` probe for `/` only if the forgetool schema accepts it for this app (check the schema before adding).

## 9. Rootless and read-only-rootfs adaptations

Upstream writes and remaps:

| Upstream path | Use | ContainerForge path |
| --- | --- | --- |
| `/var/lib/gitea` (work dir, custom, data, repositories) | `GITEA_WORK_DIR` | `/config/gitea` |
| `/var/lib/gitea/custom` | `GITEA_CUSTOM` | `/config/gitea/custom` |
| `/etc/gitea/app.ini` | `GITEA_APP_INI` | `/config/gitea/app.ini` |
| `/tmp/gitea` (TMPDIR) | temp | `/tmp/gitea` (tmpfs under `--read-only --tmpfs /tmp`) |
| `HOME=/var/lib/gitea/git` | home | `HOME=/config` |

Reconciling the draft's security expectations:
- UID: the chart runs `runAsUser 1000`. ContainerForge runs as `apps` (uid 568, from `apps/ubuntu/Dockerfile`). Existing data from the chart's `/data` PVC (uid 1000) needs a `chown` on migration. Document this for users, do not add a root init container.
- `readOnlyRootFilesystem`: compatible, because every write goes to `/config` or `/tmp`.
- `privileged`: no. No capabilities are needed. Port 2222 is above 1024, so no `NET_BIND_SERVICE`.
- Draft's `/data` and `/var/lib/gitea` extra persistence: replaced by `/config/gitea`; `/data` from the chart has no equivalent.
- Init container (root): not needed. Ownership of `/config` is the host's job; the image does not chown user data at runtime.

## 10. Risks, caveats and open questions

- Install wizard: first start needs a manual setup in the browser. Expected; the draft already flags it.
- Database: SQLite works without an external DB (default), so this app is not a hard database dependency. If PostgreSQL is used, the user configures it in the wizard.
- SSH (2222): built-in SSH uses host keys written under `/config/gitea` (UNVERIFIED path). Disabled by default in this plan (`required: false`).
- Data path: the draft says `/config`. The remap in section 9 is an inference from the env vars; the binary's exact write locations are UNVERIFIED until step 3.
- Binary static linking: UNVERIFIED (section 1). If the binary needs a glibc version newer than the base, stop and record as a blocker.
- Checksums: the plan uses upstream `.sha256` files. These come from the same host as the binary, so they protect against corruption, not against a compromised release. The `.asc` / sigstore files are an optional stronger check not included here.
- arm64: the release asset exists, but the arm64 build has not been run (step 2 is amd64 only).
- No blockers found for the binary itself.

## 11. Build and test steps

```sh
cd apps/gitea
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker rm -f gitea-probe 2>/dev/null; docker volume rm gitea-probe-config 2>/dev/null
docker run --rm -d --name gitea-probe --read-only --tmpfs /tmp \
  -v gitea-probe-config:/config gitea:28.4.0
docker logs -f gitea-probe            # until idle
docker exec gitea-probe sh -c 'curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:3000/'
docker rm -f gitea-probe; docker volume rm gitea-probe-config

forgetool containers test --image gitea:28.4.0 --config ./apps/gitea/container-test.yaml
```

Expected readiness signal: the process is still running, port 3000 accepts connections, and the log contains a gitea "Starting" or "Listen" line (exact text UNVERIFIED; take it from the first run's log). The HTTP check should return the install page (`200` or a redirect to `/install`).

Also run once with an existing `app.ini` on a second start to check the restart path (not covered by the test suite).

## 12. PR checklist

- Branch: `feat/add-gitea`
- Commit: `feat(gitea): add new container`
- PR title: `feat(gitea): add new container`
- PR description: from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Only check boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user the PR needs a signed Contributor License Agreement at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- State what was not tested: this plan was written without building or running the image. Bake, build, run and test are all still to do.
- Version alignment: `VERSION` in `docker-bake.hcl` = `ARG VERSION` in the Dockerfile = `28.4.0`.
- Not a `FROM` base: no `DOWNSTREAM_CHANGES.md`.
