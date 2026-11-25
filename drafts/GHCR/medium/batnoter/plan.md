# batnoter — implementation plan
> Source: ./draft.md · Target: apps/batnoter/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.0.0, published 2022-06-13 (https://api.github.com/repos/batnoter/batnoter/releases/latest). The repo was last pushed 2022-10-01, so it is stale. The draft's chart tag is `latest`, which is not a pinned version. Pin `1.0.0`. |
| Renovate | `datasource=github-releases depName=batnoter/batnoter versioning=semver` (convention choice, UNVERIFIED upstream). |
| License | MIT (GitHub repo metadata, https://api.github.com/repos/batnoter/batnoter). |
| Source URL | https://github.com/batnoter/batnoter |
| Binary | No release assets on v1.0.0. Build the UI from source. |
| Per-arch download | Source tarball `https://github.com/batnoter/batnoter/archive/refs/tags/v${VERSION}.tar.gz` (UNVERIFIED: not fetched). |
| Checksum source | None on the release. Pin the tag. |
| Upstream Dockerfile reviewed | Commit 8722c3af2b81233f158ca17e4818b9251c8cc1d3 (the draft traced repo HEAD, not the tag; https://raw.githubusercontent.com/batnoter/batnoter/8722c3af2b81233f158ca17e4818b9251c8cc1d3/Dockerfile). Re-check the Dockerfile at the v1.0.0 tag (UNVERIFIED). |
| Upstream stages | Stage 1: `node:16-alpine`, `WORKDIR /app`, `COPY . .`, `RUN npm i`, `RUN npm run build`. Stage 2: `nginx:stable-alpine`, copies `/app/build` to `/usr/share/nginx/html` and `/app/nginx/default.conf` to `/etc/nginx/conf.d/default.conf`. |
| ENTRYPOINT / CMD | None. The image inherits the nginx base. |
| USER | None (base default). |
| EXPOSE | `EXPOSE 3000`. This does not prove the listen port: the nginx `listen` directive in `default.conf` is not shown (UNVERIFIED). The draft's 8080 is inferred and not confirmed. |
| ENV | None in the Dockerfile. |
| Arch | No conditionals. `node:16-alpine` and `nginx:stable-alpine` are Alpine/musl; the build does not depend on arch. |
| copy-from | No. The upstream image is Alpine (musl) and contains only the static UI, so it does not run on glibc ubuntu. |
| Dependencies | None confirmed. The draft says a backend service is probably needed (UNVERIFIED: not in the fetched Dockerfile). |

## 2. Target layout

- `apps/batnoter/Dockerfile`
- `apps/batnoter/docker-bake.hcl`
- `apps/batnoter/settings.yaml`
- `apps/batnoter/container-test.yaml`
- `apps/batnoter/start.sh`
- `apps/batnoter/etc/nginx/conf.d/default.conf` (our own nginx config; `etc/` is on the dockerignore allow-list)

Never use `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f`

Reason: the static UI is served by nginx, and `apps/nginx` is the matching ContainerForge runtime. Use `apps/nginx` as the closest sibling; read its Dockerfile, `settings.yaml` and `container-test.yaml` before writing ours.

Build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the React build. The build needs Node. Node 16 (upstream) is end of life, so the plan uses the base's Node version and records the change. Confirm `node --version` in the build (UNVERIFIED) and check that `npm run build` works on it.

## 4. Dockerfile

1. Build stage `FROM <python-node> AS build` with `ARG VERSION`, `USER root`.
2. Source: `curl -fL "https://github.com/batnoter/batnoter/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`. The tag is `v1.0.0`; `VERSION` is `1.0.0`.
3. Install and build in the app folder: `cd /tmp/src && npm ci` (the lockfile, if it exists, must be present at the tag; otherwise `npm install`, UNVERIFIED), then `npm run build`.
4. Final stage `FROM <nginx>` with `USER root` only if a copy needs it (no apt needed).
5. Copy the UI and our nginx config:
   - `COPY --from=build /tmp/src/build /app/batnoter/html` (the build output path; keep `/app` read-only at runtime).
   - Nginx serves from `/app/batnoter/html`. Our `etc/nginx/conf.d/default.conf` listens on the chosen port and sets `root /app/batnoter/html`. Avoid writes under `/usr/share/nginx/html`.
   - License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/batnoter/LICENSE`.
6. Writable paths for nginx: `client_body_temp_path`, `proxy_temp_path`, `fastcgi_temp_path`, `uwsgi_temp_path`, `scgi_temp_path`, `pid` set to `/tmp/...` in our `default.conf` (or the global `nginx.conf` of the sibling). Set `/var/cache/nginx` aside, it is not writable at runtime.
7. ENV: `HOME=/config`, `XDG_CACHE_HOME=/tmp`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE <port>
VOLUME /config
WORKDIR /app/batnoter
```

`VOLUME /config` is listed in the chart as `/config`. The UI has no state, so `/config` can stay empty. Keep it because the sibling pattern and the `settings.yaml` schema expect `/config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "batnoter" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=batnoter/batnoter versioning=semver
  default = "1.0.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/batnoter/batnoter" }
```

Four standard targets and the default group copied from `apps/nginx/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/batnoter/batnoter"
ports:
  - port: <chosen port>
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Use the sibling `apps/nginx` env pattern (`NGINX_PORT`) only if our config reads it. The port must match `default.conf`.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
```

- Idempotent. Seeds nothing; the UI is stateless.
- Writes only to `/config` (empty) and `/tmp`.
- Use the start command of the sibling `apps/nginx`, not this one, if it differs.
- `exec` keeps nginx as PID 1 under tini.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '<chosen port>'
http:
- port: '<chosen port>'
  path: /
filePaths:
- /app/batnoter/html/index.html
- /etc/nginx/conf.d/default.conf
- /usr/share/licenses/batnoter/LICENSE
```

- Every port in `settings.yaml` has a `tcp` probe.
- `timeoutSeconds: 60` is the nginx sibling's value (check `apps/nginx/container-test.yaml`).
- The test runs with no env vars, which is the normal start path for this image.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| nginx temp and pid paths (`/var/cache/nginx`, `/var/run`) | `/tmp` in our `default.conf` and in the global nginx config. |
| `/usr/share/nginx/html` | Not used. The UI is served from `/app/batnoter/html`. |
| `/config` | Empty, reserved for future state. |

- Port: nginx on `USER apps` cannot bind below 1024. Use a port above 1024. The sibling `apps/nginx` uses 8080, so use 8080 unless a reason is found (UNVERIFIED convention choice). The draft's 8080 is therefore kept, but it is inferred, not upstream-confirmed. Note this in the PR.
- Read-only rootfs: `--read-only --tmpfs /tmp` must work. Confirm nginx starts with no writes outside `/tmp` and `/config`.
- The draft's "chart sets runAsUser 0" is replaced by `USER apps`. Non-root is possible once the port and temp paths are fixed, which this plan does.
- No privileged setting and no extra persistence.

## 10. Risks, caveats and open questions

- Draft caveat confirmed: the image is only the static UI. Without the backend, the app cannot work end to end. Whether a backend is needed is UNVERIFIED because the fetched Dockerfile does not show backend code. Check the repo's `README` or source at the tag before the PR. If a backend is needed, this app is blocked on a second container, so stop and report.
- Draft caveat confirmed: the trace used repo HEAD (8722c3a), not the v1.0.0 tag. The plan builds the tag, so the built code may differ from the draft trace. Re-check the Dockerfile at the tag.
- Upstream nginx `listen` port is UNVERIFIED (`default.conf` was not fetched). Our config replaces it, so this does not block the build, but the port in `settings.yaml` is our choice.
- Maintenance risk: the repo was last pushed 2022-10-01, and upstream Node 16 is end of life. The build may fail on the base's Node version. Record the fallback if it does.
- Copy-from: no. The upstream image is musl and does not run on glibc ubuntu.
- arm64: no arch conditionals upstream. Published arm64 is UNVERIFIED. Build amd64 first.
- Blocker candidate: a missing backend. See the first bullet.

## 11. Build and test steps

From `apps/batnoter/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run with a fresh empty `/config` volume:

```sh
docker volume create batnoter-probe-config
docker run --rm -d --name batnoter-probe --read-only --tmpfs /tmp \
  -v batnoter-probe-config:/config batnoter:1.0.0
docker logs -f batnoter-probe
```

   Expected readiness signal: nginx's `start worker process` line, or a clean `Configuration complete; ready for start up` line (exact text UNVERIFIED for the chosen image; take it from the first run). The container must still be running, with no `[emerg]` or `[crit]` lines.
4. `forgetool containers test --image batnoter:1.0.0 --config ./container-test.yaml`, or the manual checks if forgetool is unavailable.
5. Clean up: `docker rm -f batnoter-probe; docker volume rm batnoter-probe-config`.

Not tested here: arm64, the backend path (if any), and the Node 16 to base-Node change in the build.

## 12. PR checklist

- Branch: `feat/add-batnoter`.
- Commit: `feat(batnoter): add new container`.
- PR title: `feat(batnoter): add new container`.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Say what was not tested: arm64, the backend (if any), and the full app behaviour, which the UI-only image cannot show.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows the status).
- Conventional commit scope `batnoter` for every commit.
