# CorneliousJD/SUI-Startpage (upstream source)

**Source URL(s):** https://github.com/CorneliousJD/SUI-Startpage (README via raw.githubusercontent.com at commit fb4094a047d25cd21352c0849b5b623171e7974c; Dockerfile and start.sh at the same commit)
**Fetched:** 2026-11-26

## What it is
- SUI is a startpage for a server and/or a new-tab page: a static HTML/CSS/JS site.
- The repo is a fork made to trigger Docker Hub builds for an unRAID container template. Its maintainer has added small changes at user request.
- Pinned commit per plan.md: `fb4094a047d25cd21352c0849b5b623171e7974c` (2020-05-20). No releases or tags.

## Install/build steps and build deps
- No install step documented. Customisation is done by editing files directly.
- Site files: `index.html`, `apps.json`, `links.json`, `providers.json`, `favicon.ico`, `assets/` (JS and CSS). Also `LICENSE`, `License.md`, `README.md`, `Dockerfile`, `start.sh` (not served).
- Download as a tarball: `https://github.com/CorneliousJD/SUI-Startpage/archive/<full-sha>.tar.gz` (plan.md, HTTP 200 checked). Archive URLs are skipped as sources; the pattern is recorded here.

## Runtime deps
- Static site: no server-side runtime. The upstream Dockerfile uses `nginx:alpine`.
- Client-side CDNs (per plan.md): jQuery, Handlebars, Iconify, Google Font. The browser needs internet access.
- Icons are Material Design Icons (materialdesignicons.com). Screenshots are on imgur (not needed).

## Upstream Dockerfile (at fb4094a)
- `FROM nginx:alpine`
- `LABEL` maintainer (omitted here).
- `EXPOSE 80`
- `RUN mkdir -p /usr/share/holding`; `COPY . /usr/share/holding` (whole build context).
- `RUN chmod +x` on `/usr/share/holding/start.sh`.
- `ENTRYPOINT` runs `start.sh` from `/usr/share/holding` (exec form, relative path).
- No CMD, USER, WORKDIR, ENV or VOLUME.

## Upstream start.sh (at fb4094a, `#!/bin/sh`)
1. Copies from `/usr/share/holding/` to `/usr/share/nginx/html/` only if the target is missing: `index.html`, `apps.json`, `links.json`, `providers.json`, `favicon.ico`; `assets/` copied recursively if the folder is absent.
2. Deletes `License.md`, `README.md`, `start.sh` from `/usr/share/nginx/html/` if present.
3. `chmod -R 777 /usr/share/nginx/html` (no chown).
4. `nginx -g "daemon off;"`.
- The plan does not use this script: it bakes files at build time and relies on the nginx base entrypoint (see plan.md section 7). Do not copy the `chmod 777`.

## Env vars
None read by the app.

## Ports
Upstream Dockerfile declares 80. The ContainerForge nginx base serves on 8080.

## Volumes/paths and persistent data
- Served directory: `/usr/share/nginx/html` (upstream start.sh and TrueCharts persistence).
- No state. Users customise by replacing JSON files (bind mounts recommended over the chart PVC).

## Config files and formats
- `apps.json`: `apps` array; objects with `name`, `url`, `icon`. URLs must start with `http://` or `https://`. Icon names from Material Design Icons. No trailing comma after last entry.
- `links.json`: `bookmarks` array; objects with `category` and a `links` array; each link has `name` and `url` (http/https). No trailing comma after last link or category.
- `providers.json`: search providers listed for the web UI (contents not shown on the page).
- Search providers: edit `assets/js/search.js` around line 59 (`search(text)` switch on slash-prefixed trigger, e.g. `/z`, `/am`), and add the entry to `providers.json`.
- Color themes: `themer.js`; theme names must also be updated in the `themes` section of `index.html`. Themes are chosen with the options button at the bottom left.

## User/UID and permissions
Not specified upstream. Upstream chmod 777 is not needed in the plan.

## Healthcheck/readiness endpoints
None. `GET /` returning HTML is the only signal.

## Version/release info
- No releases or tags. Last commit 2020-05-20 ("Update README.md"), effectively dormant.
- Docker Hub `corneliousjd/sui-startpage` last updated over 6 years ago (see dockerhub summary).

## Arch support
Arch-neutral static files.

## Gotchas
- Upstream `start.sh` only copies defaults when missing, so bind-mounted JSON files are kept on restart.
- No license file text on the README. The `LICENSE` file begins with the Unlicense text (per plan.md); `License.md` is blank at this commit. GitHub reports `Unlicense`.
- The README gives no docker run example, port or volume.
