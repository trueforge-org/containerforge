# shlink-web-client — implementation plan
> Source: ./draft.md · Target: apps/shlink-web-client/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 4.9.1 (`v4.9.1`, published 2026-11-21). The draft uses 4.9.0; the TrueCharts chart (17.0.0) uses 4.9.1; 4.9.1 is the latest release, so the plan pins it. Source: `gh api repos/shlinkio/shlink-web-client/releases/latest`. 4.9.1 changelog: dependency update and nginx base bump to `nginx/nginx-unprivileged:1.31-alpine` (security fix). |
| Renovate | `datasource=github-releases depName=shlinkio/shlink-web-client versioning=semver` |
| License | MIT (SPDX `MIT`). https://github.com/shlinkio/shlink-web-client/blob/develop/LICENSE |
| Source URL | https://github.com/shlinkio/shlink-web-client |
| Download (amd64 and arm64) | https://github.com/shlinkio/shlink-web-client/releases/download/v4.9.1/shlink-web-client_4.9.1_dist.zip . Architecture independent static content, one asset for both arches. |
| Checksum source | None published on the release (only the zip is an asset). UNVERIFIED: no upstream checksum. Plan: pin a SHA256 ARG for the zip and verify it, see section 4. |
| Upstream Dockerfile reviewed | https://github.com/shlinkio/shlink-web-client/blob/v4.9.1/Dockerfile. Build: `node:26.13-alpine`, `npm ci && node --run build`. Runtime: `nginx/nginx-unprivileged:1.31-alpine`, copies `config/docker/nginx.conf` to `/etc/nginx/conf.d/default.conf` and `scripts/docker/servers_from_env.sh` to `/docker-entrypoint.d/30-shlink-servers-json.sh`, serves `build` at `/usr/share/nginx/html`, writes `servers.json`. |
| Upstream nginx config | https://github.com/shlinkio/shlink-web-client/blob/v4.9.1/config/docker/nginx.conf. `listen 8080 default_server`, `root /usr/share/nginx/html`, SPA fallback `try_files $uri $uri/ /index.html$is_args$args`, `location = /servers.json { try_files /servers.json /conf.d/servers.json; }`, cache rules for css/js (1y), html/json (no cache). |
| Env vars (real) | From `scripts/docker/servers_from_env.sh` (v4.9.1): `SHLINK_SERVER_URL` and `SHLINK_SERVER_API_KEY` (both required to generate servers.json), `SHLINK_SERVER_NAME` (default `Shlink`), `SHLINK_SERVER_FORWARD_CREDENTIALS` (default `false`). |
| Data / write paths | Upstream writes only `servers.json`. Upstream writes it into the web root (`/usr/share/nginx/html`). |
| Ports | 8080/tcp |
| arm64 | Yes: the dist zip is arch independent; the nginx base is multi-arch. |
| copy-from | `no`: the image is a static SPA, not a binary source. |
| Dependencies | None. Needs an external Shlink server to be useful (not a container dependency). |

## 2. Target layout

- `apps/shlink-web-client/Dockerfile`
- `apps/shlink-web-client/docker-bake.hcl`
- `apps/shlink-web-client/settings.yaml`
- `apps/shlink-web-client/docker-entrypoint.d/10-shlink.sh` (same pattern as `apps/it-tools/docker-entrypoint.d/10-copyconfig.sh`; no separate `start.sh`, the nginx base's entrypoint runs these scripts and then its `CMD`)
- `apps/shlink-web-client/container-test.yaml`
- `apps/shlink-web-client/defaults/default.conf` (the site config; replaces the nginx base's `default.conf` exactly as `apps/it-tools` does, because the base's `default.conf` also has `listen 8080 default_server` and two default servers on one port make nginx fail). The base's `defaults/nginx.conf` is reused, not shipped again.

No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). No `root/`.

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`. The draft names nginx as the runtime image, and the nginx sibling already runs as `apps` with a `/config` seeded config and `/tmp` writable paths. Build stage (only for unzip and checksum): `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Closest sibling: `apps/nginx` (static server on nginx) and `apps/it-tools` (static SPA on nginx).

The nginx sibling's Dockerfile is the pattern: `USER root` for installs, `USER apps`, `COPY --chmod=0755 . /`. Its `CMD` reads `/config/nginx.conf`, which the base's `docker-entrypoint.d/03-copyconfig.sh` seeds (`cp -n`) together with `/config/sites/default.conf`.

## 4. Dockerfile

1. Stage `ubuntu AS fetch`: `ARG VERSION`, `ARG SHA256`, `USER root`, `apt-get install -y --no-install-recommends unzip` (UNVERIFIED whether the base already has unzip, check at build time; do not add it if present). Download the zip to `/tmp`, check `echo "${SHA256}  /tmp/dist.zip" | sha256sum -c -`, extract to `/tmp/dist`.
   - `SHA256` has no upstream source. Compute it once from the downloaded asset, pin it in the Dockerfile as an `ARG` with a comment saying where it came from (not in bake). Mark as a known gap in PR notes.
2. Final stage: `FROM nginx base`, `ARG VERSION`, `USER root`.
   - `COPY --from=fetch /tmp/dist /app/www` (read-only at runtime, owned by `apps:apps`, `chmod -R 755`).
   - `COPY --chmod=0755 defaults/ /defaults/` is handled by `COPY . /`; do not duplicate.
   - `ENV TZ=Etc/UTC`
3. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`. Keep the base's `CMD` (nginx with `/config/nginx.conf`); do not override it.

The upstream `servers.json` write into the web root is not copied: the web root is read-only (section 9).

## 5. docker-bake.hcl

- `APP = "shlink-web-client"`
- `VERSION` default `4.9.1`, preceded by `// renovate: datasource=github-releases depName=shlinkio/shlink-web-client versioning=semver`
- `LICENSE = "MIT"`, `SOURCE = "https://github.com/shlinkio/shlink-web-client"`
- Standard targets (`docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`). The SHA256 for the zip is passed as an `args` entry in `image` (`SHA256 = "<pinned>"`), next to `VERSION`, so bake keeps them in one place.
- Validate: `cd apps/shlink-web-client && docker buildx bake --print`.

## 6. settings.yaml

- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/shlinkio/shlink-web-client"`.
- `ports`: `8080`, `tcp`, `required: false`.
- `env`:
  - `SHLINK_SERVER_URL`, default empty, required false
  - `SHLINK_SERVER_API_KEY`, default empty, required false
  - `SHLINK_SERVER_NAME`, default `"Shlink"`, required false
  - `SHLINK_SERVER_FORWARD_CREDENTIALS`, default `"false"`, required false
  - `TZ`, default `"Etc/UTC"`, required false
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.

## 7. docker-entrypoint.d/10-shlink.sh

Idempotent, runs with empty `/config`, never writes to `/app`. The base's entrypoint runs it before nginx starts and then `exec`s the `CMD`, so no `start.sh` is needed (UNVERIFIED: confirm the ubuntu base entrypoint runs `/docker-entrypoint.d/*` as `apps` and execs the CMD; `apps/it-tools` relies on it).

1. `mkdir -p /config/sites`, then copy `/defaults/default.conf` to `/config/sites/default.conf` (overwrite, as `apps/it-tools` does, so the base's seeded default site is replaced; this script sorts after `03-copyconfig.sh`).
2. Generate `/config/servers.json` only when `SHLINK_SERVER_URL` and `SHLINK_SERVER_API_KEY` are both set, with `umask 077`, escaping each value (do not interpolate raw values into JSON; use `jq -n --arg` if available in the base, UNVERIFIED, otherwise a checked fallback). If they are not set and the file is missing, write `[]`. Never overwrite a `/config/servers.json` the user edited unless the env values are set.

The site (`defaults/default.conf`) has `listen 8080 default_server` (and the `[::]` form), `root /app/www`, the upstream SPA fallback `try_files $uri $uri/ /index.html$is_args$args`, and `location = /servers.json { alias /config/servers.json; }`. The `include /config/sites/*.conf;` comes from the nginx sibling's `nginx.conf`.

## 8. container-test.yaml

```
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 60

tcp:
- port: '8080'

http:
- port: '8080'
  path: /
```

The `http` probe checks `/` returns the SPA index. Optionally add `path: /servers.json` with status 200 (the default `[]` file), if forgetool supports a status field; check the schema.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root in the chart (`runAsUser 0`, `readOnlyRootFilesystem false`). Target is `USER apps` with read-only rootfs. The upstream image is already non-root (`ARG UID=101`), so the chart override is the only root source.
- Upstream writes `servers.json` into the web root. Target writes it to `/config/servers.json` and nginx aliases it, so `/app/www` stays read-only.
- nginx temp and cache paths are under `/tmp` (nginx sibling's `nginx.conf` already sets them).
- `pid /tmp/nginx.pid;` comes from the nginx sibling's `nginx.conf`.
- Draft security expectations (non-root no, read-only no) are reconciled: target is non-root and read-only compatible, which is stricter than the chart. Flag this for the user: the chart override is not needed.

## 10. Risks, caveats and open questions

- Version: draft says 4.9.0; plan pins 4.9.1. Chart upgrade is a user decision.
- No upstream checksum for the dist zip. The pinned SHA256 proves integrity against the value at pin time only. Document this in the PR.
- The SPA does nothing without a Shlink server. Caveat from the draft: servers are configured in the browser or via `servers.json`.
- Two `default_server` blocks on 8080 would break nginx; the plan replaces the base's `default.conf` with its own (as `apps/it-tools` does). Verify on the first run with an empty `/config`.
- Blockers: none. No musl, GPU, privileged or arm64 gaps.

## 11. Build and test steps

From `apps/shlink-web-client/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name shlink-probe --read-only --tmpfs /tmp -v shlink-probe-config:/config shlink-web-client:4.9.1`, then `docker logs -f shlink-probe`. Expected readiness signal: nginx `start worker process` lines and no `[emerg]`. Cleanup: `docker rm -f shlink-probe; docker volume rm shlink-probe-config`.
4. Repeat with `-e SHLINK_SERVER_URL=https://example.invalid -e SHLINK_SERVER_API_KEY=test` (test value only) to check servers.json generation and that `/servers.json` is served.
5. `forgetool containers test --image shlink-web-client:4.9.1 --config ./apps/shlink-web-client/container-test.yaml`. If forgetool is unavailable, probe 8080 by hand.

## 12. PR checklist

- Branch: `feat/add-shlink-web-client`
- Commit: `feat(shlink-web-client): add new container`
- PR title: `feat(shlink-web-client): add new container`
- Body: PR template at `.github/PULL_REQUEST_TEMPLATE.md`, with `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested (arm64 build, upstream checksum absence, real Shlink server).
- Do not tick "Built container locally" unless the build and run above were done.
