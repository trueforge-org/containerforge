# send — implementation plan
> Source: ./draft.md · Target: apps/send/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | UNVERIFIED. The GitLab releases API returns an empty list for `timvisee/send` (https://gitlab.com/api/v4/projects/timvisee%2Fsend/releases). The draft's container is `registry.gitlab.com/timvisee/send:latest` (rolling). Default branch `master`, last activity 2026-11-02. No version can be pinned from the fetched data; a commit SHA on `master` is the only option and must be chosen and recorded at build time. |
| Renovate | UNVERIFIED: depends on the pinned ref. If a commit SHA is pinned, use `datasource=git-refs depName=https://gitlab.com/timvisee/send currentValue=master` (same pattern as `apps/fenrus`). |
| License | UNVERIFIED. The GitLab project API `license` field is null. Read `LICENSE` in the pinned source before writing `LICENSE` in `docker-bake.hcl`. Do not guess. |
| Source URL | https://gitlab.com/timvisee/send |
| Per-arch download | None published. Build from the source archive per arch. UNVERIFIED archive URL; the GitLab archive form is `https://gitlab.com/timvisee/send/-/archive/<ref>/send-<ref>.tar.gz`, not fetched. |
| Checksum source | UNVERIFIED: none fetched. Pin a commit SHA and record the tarball checksum at build time. |
| Upstream Dockerfile reviewed | https://gitlab.com/api/v4/projects/timvisee%2Fsend/repository/files/Dockerfile/raw?ref=master. Two stages, both `node:26.12.1-alpine`. Builder: remaps the node user, creates `app` (uid 1000), `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm ci && npm run build`. Final: `app` user, copies `package*.json`, `app`, `common`, `public/locales`, `server`, and `/app/dist` from the builder; `npm ci --omit=dev && npm cache clean --force`; `USER app`; `ENV PORT=1443`; `EXPOSE ${PORT}`; `CMD ["node", "server/bin/prod.js"]`; no `VOLUME`; creates `/app/.config/configstore`. |
| Port | 1443 (`ENV PORT=1443` in the upstream Dockerfile). Matches the draft. |
| Env vars | Only `PORT` is confirmed. UNVERIFIED: the rest of the app config (README and config files were not fetched). |
| Data / upload paths | UNVERIFIED. Upstream creates `/app/.config/configstore`. The draft expects uploads under `/config`; the chart uses `/uploads` (chart PVC). The real upload path was not confirmed. |
| Dependencies | Valkey or Redis. The draft contradicts itself: Overview says hard dependency (valkey), Reason says optional. UNVERIFIED which is right; `apps/valkey` exists in ContainerForge. The chart enables a Redis dependency; the exact connection env vars are UNVERIFIED. |

## 2. Target layout

- `apps/send/Dockerfile`
- `apps/send/docker-bake.hcl`
- `apps/send/settings.yaml`
- `apps/send/container-test.yaml`
- `apps/send/start.sh`

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base; the writer should grep `apps/*/Dockerfile` for `send` to confirm).

## 3. Base image

- `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the build stage and the final stage. The Node version inside the base is UNVERIFIED; the upstream build uses Node 26.12.1, so confirm the base Node version is compatible before relying on it. If the build fails on the Node version, stop and report it, do not pin a different Node silently.
- Closest sibling: `apps/budge` (python-node, Node build of a web app, `USER apps`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV npm_config_cache=/tmp/npm-cache` (npm cache in `/tmp`, never `/config`).
3. Fetch the source at the pinned ref: `curl -fL -o /tmp/send.tar.gz https://gitlab.com/timvisee/send/-/archive/${VERSION}/send-${VERSION}.tar.gz` (UNVERIFIED URL form), verify the checksum (UNVERIFIED source), extract to `/tmp/src` with `--strip-components=1`.
4. Build as upstream does: `cd /tmp/src && PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm ci && npm run build`. Then `npm prune --omit=dev` in `/tmp/src`.
5. License: copy the pinned `LICENSE` into `/usr/share/licenses/send/LICENSE` (path and content UNVERIFIED until the source is read).
6. Cleanup: `rm -rf /tmp/* $HOME/.cache`.
7. Final stage: `FROM <python-node>`, `USER root`, `mkdir -p /app/send`, `COPY --from=build /tmp/src/package*.json /app/send/`, one `COPY --from=build` per directory so the layout is kept (`/tmp/src/app` to `/app/send/app/`, `/tmp/src/common` to `/app/send/common/`, `/tmp/src/server` to `/app/send/server/`; a multi-source COPY into `/app/send/` would flatten them), `COPY --from=build /tmp/src/public/locales /app/send/public/locales`, `COPY --from=build /tmp/src/dist /app/send/dist`, `COPY --from=build /tmp/src/node_modules /app/send/node_modules`. Add `COPY --from=build /usr/share/licenses/send /usr/share/licenses/send`. Keep only the paths the server needs; confirm against the upstream `COPY` list above.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV PORT=1443 \
    NODE_ENV=production
EXPOSE 1443
VOLUME /config
WORKDIR /app/send
```

- Do not run `npm ci` in the final stage; copy `node_modules` from the build stage. Upstream runs `npm ci --omit=dev` in the final stage; that is a choice to make against the sibling pattern, not a requirement. Prefer the copy to keep the final image write-free.
- `NODE_ENV=production` is an assumption. UNVERIFIED that the upstream reads it; remove it if not confirmed.
- Uploads: `/config` is the intended persistent path (draft). Do NOT write uploads into `/app`. The app's upload path must be set to `/config/uploads` through the env var the source reads. UNVERIFIED until the config is read.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "send"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://gitlab.com/timvisee/send currentValue=master
  default = "UNVERIFIED-COMMIT-SHA"
}
```

`VERSION` must be a pinned commit SHA recorded at build time, not a branch name. Replace the placeholder with the real SHA the writer or the builder selects, and record why in the PR. `LICENSE` is UNVERIFIED until read from the source. `SOURCE` = `https://gitlab.com/timvisee/send`. The remaining targets (`image`, `image-local`, `image-all`, `default` group) are copied from `apps/valkey/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://gitlab.com/timvisee/send"
ports:
  - port: 1443
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "1443"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - valkey
```

- Env: only `PORT` is confirmed. Do not add more until the config is read (see section 1). Redis or Valkey connection vars are UNVERIFIED; add them only after the source shows the app reads them.
- `dependencies: [valkey]` is optional per the draft; list it only if the server requires it at startup. UNVERIFIED. If optional, use `opt_dependencies` instead.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/uploads
export PORT="${PORT:-1443}"

cd /app/send
exec node server/bin/prod.js
```

- Idempotent. Creates `/config/uploads` only when missing (mkdir -p). Does not overwrite user state.
- No writes to `/app`. Caches stay in `/tmp`.
- `exec` so signals reach Node. The command is the upstream `CMD ["node", "server/bin/prod.js"]`.
- The upload directory name and the env var that sets it are UNVERIFIED; adjust `mkdir` to the real path once read.
- Bind address: confirm the server listens on `0.0.0.0` (or all interfaces) for `PORT`. UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '1443'
http:
- port: '1443'
  path: /
filePaths:
- /app/send/server/bin/prod.js
- /usr/share/licenses/send/LICENSE
```

- The test runs with no env vars, so `PORT` defaults to 1443. Valkey is optional per the draft, so the server should start without it; confirm during the run. If the server requires Valkey at startup, apply the DB-dependent exception (section 9 of the protocol): narrow only if all three criteria hold, and annotate with the required comment.
- The `/` path status is UNVERIFIED; use the status the probe sees (do not loosen to always-true).
- `timeoutSeconds: 60` is an estimate; check the sibling `apps/budge` value.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/.config/configstore` (created by upstream `mkdir`) | Not created in the final image; if the app writes there, remap to `/tmp` via `XDG_CONFIG_HOME=/tmp` (UNVERIFIED). |
| Uploads (chart: `/uploads` PVC) | `/config/uploads` (draft intent). Set through the env var the source reads (UNVERIFIED). |
| npm cache (build) | `/tmp/npm-cache`. |

Draft expectations reconciled: the chart runs as UID 0 (`runAsUser 0`), this image runs as `apps` (uid 568); `USER apps` applies. Read-only rootfs: the chart sets `false`, but the image must run with `--read-only --tmpfs /tmp`; the remaps above are needed for that. Not privileged. The draft's uploads-under-`/config` expectation conflicts with the chart's `/uploads` PVC; the image uses `/config/uploads` and existing chart users must move their data.

## 10. Risks, caveats and open questions

- No pinned version: the upstream has no releases, the `latest` tag is rolling, and the image must pin a commit SHA. Renovate would track the branch (noisy).
- License is UNVERIFIED. Do not write a `LICENSE` value until the source is read.
- Upload size limits and disk fill: configure limits through the app's settings (UNVERIFIED names).
- Valkey/Redis is a dependency only if the server requires it; to be confirmed.
- Node 26 build vs the base's Node version: UNVERIFIED compatibility (section 3).
- Blockers: none confirmed (no musl-only issue found in the Dockerfile, since the build uses Alpine only for the upstream image and this plan builds on the glibc base). The Node version and license are the open gates.

## 11. Build and test steps

```sh
cd apps/send
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name send-probe --read-only --tmpfs /tmp \
  -v send-probe-config:/config send:<pinned-sha>
docker logs -f send-probe
forgetool containers test --image send:<pinned-sha> --config ./apps/send/container-test.yaml
docker rm -f send-probe; docker volume rm send-probe-config
```

Readiness signal: UNVERIFIED until the first run; the upstream server log line was not read. Confirm the process stays up and port 1443 is open.

## 12. PR checklist

- Branch `feat/add-send`, commit and PR title `feat(send): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, only check applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: the build (amd64 only by default), the pinned commit's license, the upload path, the Valkey wiring, and the live server behaviour.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
