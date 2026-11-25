# strapi — implementation plan
> Source: ./draft.md · Target: apps/strapi/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `5.63.0` (latest stable GitHub release `v5.63.0`, 2026-11-18; npm `@strapi/strapi@5.63.0` is `dist-tags.latest`). The chart pins a third-party image `vshadbolt/strapi:5.57.0-alpine`, which is older. Build from the official npm package, not the third-party image. |
| Renovate | `datasource=npm depName=@strapi/strapi versioning=semver` |
| License | Community Edition: MIT Expat. Code under `ee/` directories is under the Enterprise Edition license. GitHub reports `NOASSERTION` and npm reports `SEE LICENSE IN LICENSE`. Sources: https://raw.githubusercontent.com/strapi/strapi/develop/LICENSE and `npm view @strapi/strapi license`. |
| Source URL | https://github.com/strapi/strapi |
| Download | `npm:@strapi/strapi@5.63.0`, installed with npm (the upstream third-party Dockerfile uses `yarn global add`). No prebuilt binary. Interpreted JavaScript. |
| Checksum source | npm registry integrity (`dist.integrity`) for the package, checked by npm on install. |
| Engines | `node >=22.0.0 <=26.x.x`, `npm >=6.0.0` (`npm view @strapi/strapi engines`). Docs: Docker examples use `node:22-alpine`. Source: https://docs.strapi.io/cms/installation/docker |
| Upstream Dockerfile reviewed | Third-party `naskio/docker-strapi` at `96fd6e7`, `images/strapi-alpine/Dockerfile`: `ARG NODE_VERSION=18`, `ARG STRAPI_VERSION=latest`, `RUN yarn global add @strapi/strapi@${STRAPI_VERSION}`, `WORKDIR /srv/app`, `EXPOSE 1337`, `VOLUME /srv/app`, no `USER`, entrypoint `docker-entrypoint.sh`. Source: https://raw.githubusercontent.com/naskio/docker-strapi/96fd6e7/images/strapi-alpine/Dockerfile. Note: its Node 18 default is below the 22 minimum. |
| Port | `1337` (`PORT` in the docs example; `HOST=0.0.0.0` in the example `.env`). Chart: `1337`. |
| Required env vars | `NODE_ENV`, `DATABASE_CLIENT`, `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `JWT_SECRET`, `ADMIN_JWT_SECRET`, `APP_KEYS`, `API_TOKEN_SALT`, `TRANSFER_TOKEN_SALT`, `ENCRYPTION_KEY`. Source: https://docs.strapi.io/cms/installation/docker |
| Database | Docs show `DATABASE_CLIENT=postgres` (5432) or `mysql` (3306). The default project config uses SQLite when no DB env is set (UNVERIFIED for 5.63; check `config/database.*` of the scaffolded project). Chart: PostgreSQL via `DATABASE_*`. |
| Data and writes | Project directory is `/srv/app` in the chart. Uploads: `public/uploads`. Docs also mention `/opt/app/public/uploads` (dev layout). Cache and build output locations for 5.63 are UNVERIFIED. |
| Dependencies | `postgresql` (exists as `apps/postgresql`). Optional, not required: SQLite works without it. |
| UNVERIFIED | (a) the `create-strapi` (or `strapi new`) flags for a non-interactive scaffold with no network DB; (b) which paths Strapi writes at runtime (`.strapi`, `.cache`, `dist`, `public/uploads`); (c) whether the package ships `ee/` code that changes the LICENSE field; (d) the Node major of the `python-node` base (section 3). |

## 2. Target layout

- `apps/strapi/Dockerfile`
- `apps/strapi/docker-bake.hcl`
- `apps/strapi/settings.yaml`
- `apps/strapi/container-test.yaml`
- `apps/strapi/start.sh`

No `defaults/` needed if the project is scaffolded at build time. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (the build and final stage). It provides node and npm, as `budge` does. Strapi 5.63 needs Node 22 to 26, so the Node major of this base must be checked first: `docker run --rm <base> node -v`. If it is below 22, the base is not usable and the plan is blocked (section 10). Closest sibling: `apps/budge` (a Node app built in the image, `/config` as writable state).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install the native build tools that Strapi's dependencies may need (`build-essential python3`), as `budge` does, and purge them at the end.
3. Scaffold and build the project at image build time, not at first start, so the admin UI is built once: `npx create-strapi@${VERSION} /app/strapi --skip-cloud --no-run --use-npm` (flags UNVERIFIED; confirm the non-interactive set against the 5.63 CLI). Then `cd /app/strapi && npm run build`.
4. Remove network-only CLI state: `npm cache clean --force`.
5. License: copy the `LICENSE` from the installed `@strapi/strapi` package to `/usr/share/licenses/strapi/LICENSE`. The Enterprise (`ee/`) terms apply to those files; record this in section 10.
6. Ownership: `chown -R apps:apps /app/strapi`, `chmod -R 755 /app/strapi`.
7. Keep the scaffold as a template under `/app` (read-only at runtime). `start.sh` copies it to `/config/app` on first start (section 7), so the running project is writable and persistent.
8. Tail:

```dockerfile
ENV NODE_ENV=production HOST=0.0.0.0 PORT=1337 HOME=/config \
    npm_config_cache=/tmp/npm-cache

USER apps
COPY --chmod=0755 . /

EXPOSE 1337
VOLUME /config
WORKDIR /config
```

`npm_config_cache=/tmp/...` keeps the npm cache out of `/config` (rule: caches go to `/tmp`).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "strapi" }
variable "VERSION" {
  // renovate: datasource=npm depName=@strapi/strapi versioning=semver
  default = "5.63.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/strapi/strapi" }
```

`LICENSE` is `MIT` for the Community Edition, which is what the image is built from. The `ee/` caveat is recorded in section 10; it is not a reason to change the value without the user's decision. Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/strapi/strapi"
ports:
  - port: 1337
    protocol: tcp
    required: false
env:
  - name: NODE_ENV
    default: "production"
    required: false
  - name: HOST
    default: "0.0.0.0"
    required: false
  - name: PORT
    default: "1337"
    required: false
  - name: DATABASE_CLIENT
    default: "sqlite"
    required: false
  - name: DATABASE_HOST
    default: ""
    required: false
  - name: DATABASE_PORT
    default: "5432"
    required: false
  - name: DATABASE_NAME
    default: "strapi"
    required: false
  - name: DATABASE_USERNAME
    default: "strapi"
    required: false
  - name: DATABASE_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - name: postgresql
```

Secrets (`APP_KEYS`, `JWT_SECRET`, `ADMIN_JWT_SECRET`, `API_TOKEN_SALT`, `TRANSFER_TOKEN_SALT`, `ENCRYPTION_KEY`) are generated by `start.sh` on first run when missing, so they are not `required: true` (a `required` var must have a default or be handled on first run). Listing them as `env` entries with no default is allowed only if the schema accepts it (UNVERIFIED). `opt_dependencies` key name is UNVERIFIED against the schema; if the schema only has `dependencies`, mark postgresql there as optional in a comment.

## 7. start.sh

```bash
#!/usr/bin/env bash

set -e
app=/config/app

if [[ ! -f "${app}/package.json" ]]; then
  mkdir -p "${app}"
  cp -a /app/strapi/. "${app}/"
fi

env_file="${app}/.env"
if [[ ! -f "${env_file}" ]]; then
  {
    echo "APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32)"
    echo "API_TOKEN_SALT=$(openssl rand -base64 16)"
    echo "ADMIN_JWT_SECRET=$(openssl rand -base64 16)"
    echo "TRANSFER_TOKEN_SALT=$(openssl rand -base64 16)"
    echo "JWT_SECRET=$(openssl rand -base64 16)"
    echo "ENCRYPTION_KEY=$(openssl rand -base64 16)"
  } > "${env_file}"
fi

cd "${app}"
export HOST="${HOST:-0.0.0.0}" PORT="${PORT:-1337}" NODE_ENV="${NODE_ENV:-production}"
exec npm run start
```

- Seeds `/config/app` only when missing; never overwrites user state.
- Generated secrets are written once, into `/config/app/.env` (a persistent file). Environment values are read on every start, so DB passwords from the env apply each start (rule for DB apps).
- Writes nothing under `/app`. Runtime caches (`.cache`, `.strapi`) need checking (UNVERIFIED); if they write into the project, they stay in `/config/app` (persistent), which the caches rule does not allow, so a symlink to `/tmp` may be needed (section 10).
- `exec` for signal handling. `npm run start` is the upstream script (confirm in the scaffold's `package.json`).
- `openssl` availability in the base is UNVERIFIED; check it before relying on it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '1337'
http:
- port: '1337'
  path: /admin
filePaths:
- /app/strapi/package.json
- /usr/share/licenses/strapi/LICENSE
```

The test runs with no env vars and no DB, so the SQLite default must start. That makes a full test possible: no `narrowed` DB exception is needed. Every settings.yaml port has a probe. `timeoutSeconds: 300` is a guess to cover first-start migration (UNVERIFIED against sibling values). The `http` path `/admin` is UNVERIFIED for the first-run state; use the path that returns 200.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Project dir `/srv/app` (chart) | `/config/app`, seeded from the read-only template in `/app/strapi` |
| `public/uploads` | `/config/app/public/uploads` (persistent) |
| npm cache | `/tmp/npm-cache` via `npm_config_cache` |
| Strapi runtime cache (`.cache`, `.strapi`, `dist`) | UNVERIFIED; if written in the project, move via symlink to `/tmp` (section 10) |

Draft expectations reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image runs as `apps` and writes only under `/config` and `/tmp`, so it is compatible with `--read-only --tmpfs /tmp`. The chart's extra persistence `/srv/app` maps to `/config/app` here, so migrating users must move their data there.

## 10. Risks, caveats and open questions

- Node 22 to 26 is required (`engines`). The `python-node` base major is UNVERIFIED. If it is below 22, the base cannot be used; the fallback (an ubuntu base with a pinned Node 22 install) is a larger decision that needs the user's approval.
- The admin build runs at image build time (section 4). The draft said so, but the third-party upstream Dockerfile does not show a build step (UNVERIFIED for 5.63).
- Image size and build time: the admin build is slow and the image is large.
- PostgreSQL is optional; SQLite is the default. The chart enables PostgreSQL, so DB-backed config is a separate test case and not covered by this suite.
- LICENSE: `MIT` for Community Edition; the `ee/` directories are under the Enterprise license. Confirm with the user before publishing the bake `LICENSE`.
- The third-party `vshadbolt/strapi` image is not used; this plan builds from the npm package.
- Blockers: none confirmed beyond the Node 22 base check and the runtime cache paths.

## 11. Build and test steps

```sh
cd apps/strapi
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name strapi-probe --read-only --tmpfs /tmp \
  -v strapi-probe-config:/config strapi:5.63.0
docker logs -f strapi-probe
forgetool containers test --image strapi:5.63.0 --config ./apps/strapi/container-test.yaml
docker rm -f strapi-probe; docker volume rm strapi-probe-config
```

Readiness: the process stays up and the log shows the Strapi listen line on port 1337 (exact text UNVERIFIED until a run). Check `/config/app/.env` exists after start, and that a restart keeps the same secrets.

## 12. PR checklist

- Branch `feat/add-strapi`, commit and PR title `feat(strapi): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the Node 22 base, the scaffold flags, the admin build time, the `--read-only` run, the probe paths, the PostgreSQL path, and arm64.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
