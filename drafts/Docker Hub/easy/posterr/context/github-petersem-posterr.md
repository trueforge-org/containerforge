# github.com/petersem/posterr

Source URL(s) + fetch date:
- https://github.com/petersem/posterr (repo root, via raw README)
- https://raw.githubusercontent.com/petersem/posterr/master/README.md
- https://raw.githubusercontent.com/petersem/posterr/master/Dockerfile
- https://raw.githubusercontent.com/petersem/posterr/master/package.json
- https://github.com/petersem/posterr/releases (includes v1.15.0 release page)
- https://github.com/petersem/posterr/blob/4609d7e2ef2ce37bac78349b3978e61a706d0180/Dockerfile (draft's pinned blob; not refetched, master raw used)
- Fetched 2026-11-26

## What it is
- Media display software for Plex (mandatory), with optional Sonarr v3.0, Radarr v4.3, Readarr v0.1.3. Styled like cinema foyer screens. Node.js + Express. MIT license.
- Extras: sleep timer (API), trivia quiz, Awtrix LED matrix support, CEC control (Raspberry Pi scripts only, `/scripts/scriptdoco.md`).
- Resource use per README: 20-35 MB RAM, ~75 MB disk, CPU under 1%.

## Install/build steps and build deps (upstream Dockerfile, master)
- `FROM node:24.1.0-alpine`
- `RUN apk update`; `RUN apk add tzdata`; `RUN apk add net-tools`
- `ENV NODE_ENV=production`
- `WORKDIR /usr/src/app`
- `COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]`
- `RUN npm install --production --silent && mv node_modules ../`
- `COPY . .`
- No USER (runs as root), no VOLUME, no ENTRYPOINT.

## Runtime deps (package.json, version 1.21.18, license MIT, no `engines` field)
- Scripts: `start` = `node index.js`; `dev` = `nodemon index.js`; `test` is a stub that exits 1.
- Dependencies (ranges as written): @jaames/iro ^5.5.2, axios ^0.27.2, body-parser ^1.19.0, bootstrap ^5.0.2, cookie-parser ^1.4.5, cors ^2.8.5, ejs ^3.1.6, express ^4.17.1, express-hbs ^2.3.4, express-session ^1.17.1, express-validator ^6.10.0, font-awesome ^4.7.0, fs-extra ^9.1.0, image-size ^0.9.7, jquery ^3.6.0, memorystore ^1.6.6, ping ^0.4.1, plex-api ^5.3.1, sleep-promise ^9.1.0, yarn ^1.22.11.
- Dev: jsdoc ^4.0.0, nodemon ^2.0.22.
- External: Plex server (required); Sonarr/Radarr/Readarr optional.

## Binaries/entrypoint/CLI flags
- `CMD ["node", "index.js"]`.
- Binary builds for macOS, Linux, Windows also exist (separate from the Docker image).

## Env vars (table)
| Name | Default | Notes |
| --- | --- | --- |
| TZ | not set in image | Timezone database name, e.g. `Australia/Brisbane` (README example) |
| BASEPATH | "" (empty) | URL path prefix for reverse proxy; may be blank |

- Plex URL/token and library settings are entered in the web UI settings page, not env vars.

## Ports
- Container port 3000 (`EXPOSE 3000`). Compose/CLI examples map `9876:3000`.
- Settings page: `http://hostIP:9876/settings` (reached on first load, by clicking the title banner of a slide, or by clicking "no content" text).
- Binary executables default to 3000.

## Volumes/paths and persistent data
- `/usr/src/app/config`: saved Posterr settings (required per README).
- `/usr/src/app/public/custom`: custom pictures and future custom media (required per README).
- Dockerfile has no VOLUME instruction.

## User/UID & permissions
- No USER in the Dockerfile; runs as root. Run user not stated in docs.

## Config files and formats
- Config file names/format not stated. Settings written through the web UI into the config directory.
- Default settings-page password: `raidisnotabackup` (README says it should be changed after first login).

## Healthcheck/readiness endpoints
- Dockerfile: `HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=15s CMD node healthcheck.js > /dev/null || exit 1`.
- Healthcheck script `healthcheck.js` (per plan): GET 127.0.0.1:3000${BASEPATH}; 200/301/302 healthy.
- README: sleep API at `/api/sleep` (POST with headers `psw` and `sleep=true|false`; GET returns status). Checks Now Screening/Playing every 10 seconds.

## Version/release info and asset naming
- package.json version 1.21.18.
- GitHub releases page: latest label on `v1.15.0` (title "Binaries for Posterr", notes say binaries are broken by a packaging-tool breaking change). Older: v1.14.2, v1.14.1, v1.14.0, v1.13.0, v1.12.0, v1.11.0, 1.10.2, 1.10.1, 1.9.0. Releases carry binaries only, 3 assets each (6 for 1.9.0). Asset file names not shown on the page (draft's `poster-binaries.zip` not visible).
- Source tarball pattern: `https://github.com/petersem/posterr/archive/refs/tags/v${VERSION}.tar.gz` (tags are `v`-prefixed; the 1.21.18 tag is newer than any release).
- Docker Hub `latest` tag; no versioned tags shown.

## Arch support
- Compose example labelled "X86, ARM64". Docker Hub page confirms the labels; no explicit per-arch manifest list shown.

## Gotchas
- Watchtower (containrrr) can auto-update the container (README).
- Unraid template exists in Community Apps (being replaced by a new version, per README).
- Default password is visible on the settings page; change after first login.

## Contradictions with plan.md
- plan.md: Node major in the python-node base is unverified. Upstream image is `node:24.1.0-alpine`, which supports the plan's Node 24 expectation but does not confirm the base.
- plan.md: `poster-binaries.zip` is said to be not needed. Releases page shows the v1.15.0 release is "Latest" with binaries only; it does not confirm the zip name.
