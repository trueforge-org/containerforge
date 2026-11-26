# mongo-express — implementation plan
> Source: ./draft.md · Target: apps/mongo-express/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.1.0-rc-4. npm `latest` tag and the only GitHub release (`v1.1.0-rc-4`, prerelease: false, published 2026-02-23). Sources: https://registry.npmjs.org/mongo-express/latest, https://api.github.com/repos/mongo-express/mongo-express/releases/tags/v1.1.0-rc-4. Draft tag `v1.1.0-rc-4` matches. The draft's `public.ecr.aws/docker/library/mongo-express:latest` is a rolling tag; do not use it. |
| Renovate | `datasource=github-releases depName=mongo-express/mongo-express versioning=loose` (the `-rc-4` suffix is not strict semver). Renovate config itself UNVERIFIED. |
| License | MIT (npm `license` field and GitHub license API). |
| Source URL | https://github.com/mongo-express/mongo-express |
| Per-arch download | Arch-independent npm tarball: `https://registry.npmjs.org/mongo-express/-/mongo-express-1.1.0-rc-4.tgz`. No native binary. The release has no assets (GitHub API `assets: []`). |
| Checksum source | npm `dist.integrity` `sha512-GRn/eQmLplUfiq8AmwU2eqBhquAymIvEWhbQMALrbeb70/e8c5/pVisAr14FiPlBmhTTbUl0uqUSD1cx7d1aZg==` and `dist.shasum` `36c7c3cd2f5eb61e236f27fb386440272e06b40c`. Verify the tarball against `dist.integrity`. |
| Node requirement | `engines.node >= 18.18` (npm metadata). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/mongo-express/mongo-express/v1.1.0-rc-4/Dockerfile. Build stage `node:18-alpine3.16`, `yarn install && yarn build`; final stage `node:18-alpine3.16` with `apk add bash tini`, `yarn workspaces focus --production`; `CMD ["/sbin/tini", "--", "yarn", "start"]`; no `USER` (default user); `EXPOSE 8081`; ENV `ME_CONFIG_MONGODB_URL="mongodb://mongo:27017"`, `ME_CONFIG_MONGODB_ENABLE_ADMIN="true"`, `VCAP_APP_HOST="0.0.0.0"`; no `VOLUME`. |
| Port | 8081 web UI (`EXPOSE 8081`; config.default.js line 117 `port: process.env.PORT || 8081`). |
| Env vars (README table, https://raw.githubusercontent.com/mongo-express/mongo-express/v1.1.0-rc-4/README.md) | `ME_CONFIG_BASICAUTH_ENABLED` (default false), `ME_CONFIG_BASICAUTH_USERNAME` (default `admin`), `ME_CONFIG_BASICAUTH_PASSWORD` (default `pass`), each with a `_FILE` variant; `ME_CONFIG_OPTIONS_READONLY` (false); `ME_CONFIG_OPTIONS_FULLWIDTH_LAYOUT` (false); `ME_CONFIG_MONGODB_URL` (set by the upstream Dockerfile). |
| Host bind | `VCAP_APP_HOST` is set by the upstream Dockerfile. UNVERIFIED that the app reads it for the bind address; app.js calls `server.listen(config.site.port, config.site.host)`. Set and verify the bind host in `config.default.js` before relying on it. |
| Data / config write paths | None required by the app. UNVERIFIED that nothing writes at runtime. |
| Dependencies | MongoDB, reachable at `ME_CONFIG_MONGODB_URL`. `apps/mongodb` exists in ContainerForge. |

## 2. Target layout

- `apps/mongo-express/Dockerfile`
- `apps/mongo-express/docker-bake.hcl`
- `apps/mongo-express/settings.yaml`
- `apps/mongo-express/container-test.yaml`
- `apps/mongo-express/start.sh`

No `defaults/`, `etc/`, `health/` needed (the app takes its config from env). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base; the writer should grep `apps/*/Dockerfile` for `mongo-express` to confirm).

## 3. Base image

- Build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` (the python-node runtime, which ships Node). Node version inside this base is UNVERIFIED; the app needs Node >= 18.18.
- Final stage: same base, same digest. Closest sibling: `apps/budge` (python-node, Node build of a web app, `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE`, `VOLUME /config`).
- Why not ubuntu: the app is Node; python-node is the established Node runtime in this repo. The draft's `ghcr.io/trueforge-org/python-node` runtime choice matches.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `USER root`.
2. Set `ENV npm_config_cache=/tmp/npm-cache` (npm cache must be in `/tmp`, never `/config`).
3. Fetch and verify the npm tarball: `curl -fL -o /tmp/mongo-express.tgz https://registry.npmjs.org/mongo-express/-/mongo-express-${VERSION}.tgz`, verify with `sha512` against `dist.integrity` (see section 1), then `mkdir -p /app/mongo-express && tar xzf /tmp/mongo-express.tgz -C /app/mongo-express --strip-components=1`. The tarball is pure JS, so one fetch serves both arches.
4. `cd /app/mongo-express && npm ci --omit=dev && npm cache clean --force` (only if the tarball ships a lockfile; otherwise `npm install --omit=dev`). UNVERIFIED: whether the npm tarball includes `package-lock.json`. Check the `files` list before choosing.
5. License: `install -Dm0644 /app/mongo-express/LICENSE /usr/share/licenses/mongo-express/LICENSE`.
6. Cleanup: `rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*` (only what was created).
7. Final stage: `FROM <python-node>`, `USER root`, `COPY --from=build /app/mongo-express /app/mongo-express`, `COPY --from=build /usr/share/licenses/mongo-express /usr/share/licenses/mongo-express`, then `chown -R apps:apps /app/mongo-express` is NOT needed because `/app` is read-only at runtime and is not written to.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV PORT=8081 \
    VCAP_APP_HOST=0.0.0.0
EXPOSE 8081
VOLUME /config
WORKDIR /app/mongo-express
```

- `VCAP_APP_HOST` is set here to match upstream; its effect is UNVERIFIED (see section 1), so keep it only if the source reads it, otherwise bind explicitly in `start.sh`.
- Do not set `ME_CONFIG_MONGODB_URL` in the image; the default `mongodb://mongo:27017` is an upstream example, and the real value comes from `settings.yaml` / the user.
- `VOLUME /config` is required by the settings schema even though the app writes nothing there; `start.sh` creates it, so the empty-`/config` start works.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mongo-express"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mongo-express/mongo-express versioning=loose
  default = "1.1.0-rc-4"
}
```

Then `LICENSE` = `MIT`, `SOURCE` = `https://github.com/mongo-express/mongo-express`, the `default` group, `target "image"` with `args.VERSION` and OCI `source`/`licenses` labels, `target "image-local"` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), and `target "image-all"` (`linux/amd64`, `linux/arm64`), copied from `apps/valkey/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mongo-express/mongo-express"
ports:
  - port: 8081
    protocol: tcp
    required: false
env:
  - name: ME_CONFIG_BASICAUTH_ENABLED
    default: "true"
    required: false
  - name: ME_CONFIG_BASICAUTH_USERNAME
    default: "admin"
    required: false
  - name: ME_CONFIG_BASICAUTH_PASSWORD
    required: false
  - name: ME_CONFIG_MONGODB_URL
    default: "mongodb://mongodb:27017"
    required: true
  - name: ME_CONFIG_OPTIONS_READONLY
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mongodb
```

- Only names confirmed in the README are listed. `ME_CONFIG_MONGODB_URL` is `required: true` with a default that points at the sibling `mongodb` service name; the default must match what the sibling mongodb app exposes (`apps/mongodb/settings.yaml` exposes port 27017; the `mongodb` host name is a Docker/Kubernetes service-name choice, UNVERIFIED).
- Basic auth is enabled by default because the UI has no login otherwise (draft caveat). No default password is baked in: `start.sh` exits with an error when basic auth is enabled and `ME_CONFIG_BASICAUTH_PASSWORD` is empty. The container test must therefore set `ME_CONFIG_BASICAUTH_ENABLED=false` or pass a throwaway password (UNVERIFIED how container-test.yaml passes env; check `container-test.instructions.md`).
- `dependencies: [mongodb]` (mongodb exists in ContainerForge).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
export ME_CONFIG_MONGODB_URL="${ME_CONFIG_MONGODB_URL:-mongodb://mongodb:27017}"
export ME_CONFIG_BASICAUTH_ENABLED="${ME_CONFIG_BASICAUTH_ENABLED:-true}"
export ME_CONFIG_BASICAUTH_USERNAME="${ME_CONFIG_BASICAUTH_USERNAME:-admin}"
if [ "${ME_CONFIG_BASICAUTH_ENABLED}" = "true" ] && [ -z "${ME_CONFIG_BASICAUTH_PASSWORD:-}" ] && [ -z "${ME_CONFIG_BASICAUTH_PASSWORD_FILE:-}" ]; then
  echo "ME_CONFIG_BASICAUTH_PASSWORD is required when basic auth is enabled" >&2
  exit 1
fi
export PORT="${PORT:-8081}"

cd /app/mongo-express
exec node app.js
```

- Idempotent. Nothing is seeded into `/config` (the app writes no state there). No writes to `/app`.
- Caches stay in `/tmp` (`npm_config_cache` is set in the Dockerfile and the runtime does not install anything).
- Passwords are read from env on every start, so changing them also works after a restart (`ME_CONFIG_BASICAUTH_PASSWORD` is not written to disk).
- `exec` so signals reach Node directly. The upstream CMD runs `yarn start` under tini; `start.sh` replaces that with direct `node`. UNVERIFIED: that `app.js` is the right entrypoint for the package (check `package.json` `bin`/`main`; the npm metadata `bin` is `mongo-express: app.js`).
- The bind host: confirm `config.site.host` defaults to all interfaces (`0.0.0.0`) when `VCAP_APP_HOST` is set, or export the host explicitly. UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8081'
http:
- port: '8081'
  path: /
filePaths:
- /app/mongo-express/app.js
- /usr/share/licenses/mongo-express/LICENSE
```

- The test runs with no env vars, so the app starts with the default `ME_CONFIG_MONGODB_URL`. Mongo is not reachable in the test, so the app may log connection retries. Per the protocol this is a dependency case; narrow only if all three criteria of the DB-dependent exception hold (hard dependency on `mongodb`, will not start without it, and not feasible to wire a sidecar with the available primitives). The image should still serve its web UI without a DB, so verify this during the run before narrowing anything; if it does serve, keep the full http probe with no narrowing.
- If narrowing is needed, add the required comment near the narrowed assertions: `# narrowed: requires external mongodb; full functional test not feasible in single-container suite`.
- The `/` path returns the basic-auth prompt (401) when auth is enabled by default. UNVERIFIED expected status. If the probe sees 401, the assertion must be written to the real status code, not loosened to an always-true check. Confirm during the first run.
- `timeoutSeconds: 60` is an estimate; check the sibling `apps/budge` value.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| npm cache (`~/.npm`, during the build) | `npm_config_cache=/tmp/npm-cache` in the build stage. |
| Runtime writes | None found; UNVERIFIED that the app writes nothing at runtime. Run with `--read-only --tmpfs /tmp` to confirm. |

Draft expectations reconciled: upstream runs as the default user, this image runs as `apps` (uid 568), so `USER apps` applies. Read-only rootfs: the draft said `no` from the chart, but the image is designed to run with `--read-only --tmpfs /tmp` (no runtime writes found). The chart's `readOnlyRootFilesystem: false` is a chart choice, not an image constraint; the image should pass the read-only test. Not privileged.

## 10. Risks, caveats and open questions

- Requires a reachable MongoDB at `ME_CONFIG_MONGODB_URL` (manual setup; the chart's `mongodb` dependency is the intended wiring).
- Basic auth off by default upstream; this plan enables it by default. The user must supply the password; none is baked in.
- Upstream tag is `rc` (`1.1.0-rc-4`), the only release. No stable 1.x exists in the fetched data.
- The chart uses `latest`, a rolling tag; the image pins `1.1.0-rc-4`. This is a deliberate difference to note in the PR.
- UNVERIFIED: npm tarball lockfile presence (section 4), the health/401 status on `/` (section 8), the `VCAP_APP_HOST` bind behaviour (sections 1 and 7).
- Blockers: none (pure JavaScript, arch-independent, MIT, runs rootless).

## 11. Build and test steps

```sh
cd apps/mongo-express
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name mongo-express-probe --read-only --tmpfs /tmp \
  -v mongo-express-probe-config:/config mongo-express:1.1.0-rc-4
docker logs -f mongo-express-probe
forgetool containers test --image mongo-express:1.1.0-rc-4 --config ./apps/mongo-express/container-test.yaml
docker rm -f mongo-express-probe; docker volume rm mongo-express-probe-config
```

Readiness signal from upstream source: `Mongo Express server listening at ...` (app.js line 64). Mongo connection errors are expected without a DB (see section 8). Confirm the process stays up and port 8081 is open before trusting the test.

## 12. PR checklist

- Branch `feat/add-mongo-express`, commit and PR title `feat(mongo-express): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, only check applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: the build on both arches (only amd64 is the default test), the 401/200 probe status, the live MongoDB wiring, and the `VCAP_APP_HOST` effect.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
