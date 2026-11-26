# SoulRaven80/wdosg

Source URL(s) + fetch date: https://github.com/SoulRaven80/wdosg · https://raw.githubusercontent.com/SoulRaven80/wdosg/v1.3.9/README.md · https://raw.githubusercontent.com/SoulRaven80/wdosg/v1.3.9/Dockerfile · https://raw.githubusercontent.com/SoulRaven80/wdosg/v1.3.9/package.json · https://raw.githubusercontent.com/SoulRaven80/wdosg/v1.3.9/LICENSE · https://github.com/SoulRaven80/wdosg/tags · fetched 2026-11-26

## What it is
- "A simple web server to manage and run DOS based games on your browser." Central DOS game library. Metadata from IGDB (Twitch credentials), games run in the browser via js-dos. Local user auth with admin.
- Features (README): IGDB metadata and artwork, manuals and attachments, light/dark themes, device-local saves, server-side saves (v1.3.1+), list or grid library view and js-dos v8 support (v1.3.5+).

## Install/build steps and build deps
- Upstream v1.3.9 Dockerfile: `FROM node:23-alpine3.19`; `WORKDIR /app`; `COPY . .`; `RUN npm install`; `EXPOSE 3001`; `CMD [ "node", "index" ]`. No USER, no ENV, no VOLUME.
- Build deps: none beyond npm and what native modules need. See Dependencies.

## Runtime deps (v1.3.9 package.json, quoted from fetch)
- `"type": "module"`, `main` = `index.js`, `scripts.test` = echo error. No `engines` field.
- Dependencies: `adm-zip ^0.5.16`, `apicache ^1.6.3`, `axios ^1.8.4`, `bcryptjs ^3.0.2`, `cookie-parser ^1.4.7`, `cors ^2.8.5`, `express ^4.21.1`, `express-fileupload ^1.5.1`, `image-downloader ^4.3.0`, `jsonwebtoken ^9.0.2`, `nodemailer ^6.9.16`, `pino ^9.5.0`, `pino-http ^10.3.0`, `pino-pretty ^13.0.0`, `public-ip ^7.0.1`, `querystring ^0.2.1`, `short-uuid ^5.2.0`, `sqlite3 ^5.1.7` (native), `string-sanitizer ^2.0.2`.
- Dev deps (not needed at runtime): eslint and @eslint/js, @stylistic/eslint-plugin-js, globals.
- The package.json has no `better-sqlite3`, no `cheerio`. The earlier plan.md wording was corrected (see README.md).

## Binaries/entrypoint/CLI flags
- Entrypoint: `node index` (from CMD). No CLI flags documented.

## Env vars (README table, upstream defaults)
| Variable | Default | Notes |
| --- | --- | --- |
| `TWITCH_CLIENT_ID` | empty | Needed for IGDB metadata (not stated as mandatory) |
| `TWITCH_CLIENT_SECRET` | empty | Same |
| `LOG_LEVEL` | `info` | also debug, trace |
| `TOKEN_SECRET` | `secret` | Should be changed and kept secure |
| `GAMES_LIBRARY` | `/app/wdosglibrary` | "leave as-is in Docker" |
| `DB_PATH` | `/app/database/` | "leave as-is in Docker" |
| `EMAIL_SERVICE`, `EMAIL_USER`, `EMAIL_PASS` | empty | Invitation emails |
| `SERVER_FRIENDLY_URL` | empty | Redirect target for authentication |
| `PORT` | not documented in README | Code default 3001 (per plan.md) |
| `TWITCH_CLIENT_ID_FILE`, `TWITCH_CLIENT_SECRET_FILE`, `TOKEN_SECRET_FILE`, `EMAIL_PASS_FILE` | empty (TOKEN_SECRET_FILE lists `secret`) | Docker-secret variants (read as files) |

## Ports
- 3001 (README: open http://localhost:3001; EXPOSE 3001).

## Volumes/paths and persistent data
- `<library>:/app/wdosglibrary` (game library).
- `<db>:/app/database` (SQLite database).

## User/UID & permissions
- Upstream image runs as root (no USER).

## Config files and formats
- Game bundles are js-dos bundles: a `.zip` with the game, a js-dos config file and `dosbox.conf`.

## Healthcheck/readiness endpoints
- None documented.

## Default credentials (gotcha)
- README: default admin login `wdosg@wdosg.com` / `wdosg`. Not mentioned in plan.md. Must be changed on first run.

## Cautions (README, verbatim)
- "Make sure your instance is NOT exposed." The app requires authentication but was not designed for the open internet.
- "Starting from wDOSg v1.3.5, use of Twitch client token is removed in favor of client secret."

## Version/release info and asset naming
- Tags on GitHub: v1.3.9 (latest, dated Apr 25 2025), v1.3.8, v1.3.7, v1.3.6, v1.3.5, v1.3.4, v1.3.3, v1.3.2, v1.3.1, v1.3.0 (paginated; older tags exist). Each tag has a /releases/tag/<tag> page. v1.3.9 commit message references a failed dos.zone import (issue #46).
- No release assets listed. Source tarball pattern `https://github.com/SoulRaven80/wdosg/archive/refs/tags/v<version>.tar.gz` (not downloaded here).
- Tag commit SHA `5cc2cc88...` is in plan.md; not verified in this fetch.

## License
- LICENSE file at v1.3.9: GNU GPL version 3, 29 June 2007 (text only; no "only" or "or later" notice in the file).
- package.json says `"license": "ISC"` (package version `1.0.0`). Conflict flagged in plan.md; not resolved upstream.
- README does not state a license.

## Arch support
- Not stated. Native `sqlite3` module needs prebuilt or compile for each arch.

## Gotchas
- Docker Hub tags shown: only `latest` (not `v1.3.9`, as plan.md's Renovate note suggests). See README.md.
- Upstream Dockerfile uses node:23-alpine3.19 (musl). plan.md base is a ubuntu-based Node image.
