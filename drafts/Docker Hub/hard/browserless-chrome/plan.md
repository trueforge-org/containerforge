# browserless-chrome — implementation plan
> Source: ./draft.md · Target: apps/browserless-chrome/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Latest upstream release v2.64.3 (2026-11-23) in `browserless/browserless`. The draft's `browserless/chrome:1.61.1` is the legacy v1 image of the old `browserless/chrome` repo; v2 is the maintained line and ships as `ghcr.io/browserless/chromium`. Recommend 2.64.3 and note the jump |
| Renovate | `datasource=github-releases depName=browserless/browserless versioning=semver` |
| License | UNVERIFIED (release page did not show it). v2 is believed to be SSPL-1.0 or commercial; v1 (`browserless/chrome`) was different. Check LICENSE in the repo before setting `LICENSE`, and confirm a public image is permitted |
| Source URL | https://github.com/browserless/browserless |
| Download | Source tarball `https://github.com/browserless/browserless/archive/refs/tags/v${VERSION}.tar.gz`; browsers installed via npm/playwright at build (UNVERIFIED exact script names). Chrome stable .deb exists for amd64 only; arm64 Chrome stable does not, so use the bundled Chromium |
| Checksum | None for the tarball; Chrome .deb has none published either |
| Upstream Dockerfile | Raw `Dockerfile` URL on main returned 404 (file lives in `docker/` subfolders); NOT reviewed. The draft links the v1 `docker/chrome/Dockerfile` |
| Env (search, docs.browserless.io open-source page) | `PORT` (3000), `HOST` (defaults to localhost; set 0.0.0.0), `TOKEN` (if unset all endpoints, including `/function`, are unauthenticated), `CONCURRENT` (10), `QUEUED`, `TIMEOUT` (ms, 30000). Official image runs as non-root `blessuser`; `--shm-size=2g` recommended |

## 2. Target layout

`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`. No `defaults/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` as the draft states (provides node/npm; required Node major for 2.64.3 UNVERIFIED, check `package.json` engines). If the Node version does not match, switch to `ghcr.io/trueforge-org/ubuntu` plus a Node install. Closest siblings: `apps/changedetection` (python-node plus playwright browsers), `apps/budge`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. apt (only packages not in base; check): `fonts-liberation`, `fonts-noto-color-emoji`, `libnss3`, `libgbm1`, `libasound2t64`, `libatk-bridge2.0-0t64`, `libgtk-3-0t64`, `libxss1`, `xvfb` (for headful, UNVERIFIED). Prefer `npx playwright install-deps chromium` as in changedetection if that is how the base handles it.
3. Download tarball to `/tmp`, extract to `/app` (strip 1), `npm ci` then the build script (UNVERIFIED: `npm run build`, `npm run install:browsers`), with `npm_config_cache=/tmp/npm`.
4. `ENV PLAYWRIGHT_BROWSERS_PATH=/app/browsers` so browsers are baked under read-only `/app`; remove dev dependencies after build.
5. License file to `/usr/share/licenses/browserless-chrome/`.
6. `ENV HOME=/config HOST=0.0.0.0 PORT=3000`, `XDG_CACHE_HOME=/tmp/.cache`.
7. `chown -R apps:apps /app`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `USER apps`.

## 5. docker-bake.hcl

APP `browserless-chrome`; VERSION `2.64.3` with `// renovate: datasource=github-releases depName=browserless/browserless versioning=semver`; LICENSE per verification (UNVERIFIED, likely `SSPL-1.0`); SOURCE `https://github.com/browserless/browserless`. Four standard targets, default `image-local`. `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/browserless/browserless"`. ports: 3000/tcp. env: `HOST` `0.0.0.0`, `PORT` `3000`, `TOKEN` default `""` (start.sh generates one if empty, see below), `CONCURRENT` `10`, `QUEUED` `10` (default UNVERIFIED), `TIMEOUT` `30000`, `TZ` `Etc/UTC`. volumes: `/config` (downloads) required true. dependencies: none.

## 7. start.sh

1. `mkdir -p /config/downloads /config/metrics /tmp/chrome-data`.
2. If `TOKEN` is empty, generate one with `openssl rand -hex 24`, persist to `/config/token`, export it, and log that a token was generated (not its value). This keeps the unauthenticated `/function` endpoint closed by default; document the deviation.
3. `cd /app && exec node build/index.js` (entrypoint UNVERIFIED; confirm in package.json `start`). Chrome flags: run as UID 568 with `--no-sandbox` only if the userns sandbox is unavailable; decide per runtime test, and pass via Browserless launch args (UNVERIFIED config).

## 8. container-test.yaml

Schema header, `timeoutSeconds: 180`. `tcp: - port: '3000'`; `http: - port: '3000' path: /docs` (UNVERIFIED path; use `/` if `/docs` is absent). `filePaths`: `/app/package.json`. A runner `ls /app/browsers` to confirm the browser was installed. The test runs without TOKEN, so the generated-token path is exercised by start.sh anyway; test the authenticated path manually.

## 9. Rootless and read-only-rootfs adaptations

- Chrome user data dir, crash dumps and cache go to `/tmp` (`--user-data-dir=/tmp/chrome-data`, `XDG_*` to `/tmp`).
- Draft `/downloads` and `/metrics` PVCs map to `/config/downloads` and `/config/metrics` (UNVERIFIED env names for the paths; browserless v2 uses `DOWNLOAD_DIR`-like options, check).
- `/dev/shm` must be at least 1 to 2 GiB (`--shm-size`/emptyDir Memory) or pass `--disable-dev-shm-usage` so Chrome uses `/tmp`.
- Sandbox: unprivileged user namespaces are blocked by the default seccomp profile; either allow them at deploy time or use `--no-sandbox` (reduced isolation). Not privileged; non-root UID 568.

## 10. Risks, caveats and open questions

- Licence of v2 (SSPL/commercial) may block redistribution as a public image: open question for maintainers.
- Version jump v1.61.1 to v2.x changes API/env semantics; TrueCharts chart may need updating.
- Upstream Dockerfile unreviewed; build scripts and entrypoint UNVERIFIED.
- Chrome stable .deb is amd64 only, so arm64 relies on the bundled Chromium build.
- Exposed API without token is dangerous; token is auto-generated by default.
- Large image; shm needs.

## 11. Build and test steps

```sh
cd apps/browserless-chrome
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create browserless-chrome-probe-config
docker run --rm -d --name browserless-chrome-probe --read-only --tmpfs /tmp --shm-size=2g -v browserless-chrome-probe-config:/config browserless-chrome:2.64.3
docker logs -f browserless-chrome-probe
forgetool containers test --image browserless-chrome:2.64.3 --config ./apps/browserless-chrome/container-test.yaml
docker rm -f browserless-chrome-probe; docker volume rm browserless-chrome-probe-config
```
Expected readiness: a log line that the HTTP server is listening on port 3000 (exact wording UNVERIFIED); a manual `curl localhost:3000/...` with the token must open a page and return output.

## 12. PR checklist

- Branch `feat/add-browserless-chrome`; commit and PR title `feat(browserless-chrome): add new container`; target `main`.
- Fill the PR template; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, browser launch under read-only rootfs, sandbox behaviour, arm64, licence check.
