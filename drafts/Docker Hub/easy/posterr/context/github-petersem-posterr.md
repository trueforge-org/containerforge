# petersem/posterr (GitHub)

Source URL(s) + fetch date:
- https://github.com/petersem/posterr (repo; README via https://raw.githubusercontent.com/petersem/posterr/master/README.md, main branch returned 404)
- https://raw.githubusercontent.com/petersem/posterr/4609d7e2ef2ce37bac78349b3978e61a706d0180/Dockerfile (the URL in draft/plan, fetched 2026-11-26)
- https://raw.githubusercontent.com/petersem/posterr/4609d7e2ef2ce37bac78349b3978e61a706d0180/package.json
- https://github.com/petersem/posterr/tags
- https://github.com/petersem/posterr/releases/tag/v1.15.0

## What it is
Digital poster / screensaver style display for Plex, with optional Sonarr, Radarr and Readarr integration. Node.js + Express web app, browser based. License MIT.

## Install/build steps and build deps
Upstream Dockerfile at commit 4609d7e (matches tag v1.21.18 per the tags page):
```
FROM node:24.1.0-alpine
RUN apk update
RUN apk add tzdata
RUN apk add net-tools
ENV NODE_ENV=production
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../
COPY . .
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=5s --retries=3 --start-period=15s CMD node healthcheck.js > /dev/null || exit 1
CMD ["node", "index.js"]
```
- No ARG, no USER (upstream runs as default root in alpine), no VOLUME, no ENTRYPOINT.
- Upstream installs tzdata and net-tools with apk. Upstream base is alpine; ContainerForge uses an Ubuntu based python-node image.

## Runtime deps
package.json (version 1.21.18, MIT, main index.js, start = `node index.js`, test is a stub):
- @jaames/iro ^5.5.2, axios ^0.27.2, body-parser ^1.19.0, bootstrap ^5.0.2, cookie-parser ^1.4.5, cors ^2.8.5, ejs ^3.1.6, express ^4.17.1, express-hbs ^2.3.4, express-session ^1.17.1, express-validator ^6.10.0, font-awesome ^4.7.0, fs-extra ^9.1.0, image-size ^0.9.7, jquery ^3.6.0, memorystore ^1.6.6, ping ^0.4.1, plex-api ^5.3.1, sleep-promise ^9.1.0, yarn ^1.22.11
- No `engines` field. Node version not stated in README.

## Binaries/entrypoint/CLI flags
- Entrypoint: `node index.js` (CMD). Healthcheck script: `node healthcheck.js`.
- Standalone native binaries are also offered by upstream for macOS, Linux and Windows (release asset `poster-binaries.zip`, see below). Not used by a container build.

## Env vars
| Name | Default | Purpose |
| --- | --- | --- |
| TZ | (example Australia/Brisbane) | Local timezone, TZ database name. Requires tzdata. |
| BASEPATH | empty | URL prefix for reverse proxy setups. Optional. |

No other env vars documented in README. (Plan.md lists `PORT`, default 3000, from index.js; not confirmed by the fetched README.)

## Ports
- Container listens on 3000 (EXPOSE 3000). Host example mapping 9876:3000.
- Setup UI: http://hostIP:9876/settings in examples (container path /settings).

## Volumes/paths and persistent data
- `/usr/src/app/config` - required, persists settings.
- `/usr/src/app/public/custom` - required, custom pictures and other custom media.
- Compose example host paths: ./docker/posterr/config and ./docker/posterr/custom (create first).

## User/UID and permissions
- Upstream Dockerfile sets no USER; runs as root by default.
- TrueCharts chart runs container as runAsUser 0 / runAsGroup 0 (see truecharts-posterr.md).

## Healthcheck/readiness
- Upstream HEALTHCHECK: `node healthcheck.js`, interval 10s, timeout 5s, retries 3, start-period 15s.
- README says the image includes a health check.

## Version/release info and asset naming
- Latest tag on tags page: v1.21.18 (Sep 5, 2026). Recent tags: v1.21.17, v1.21.15, v1.21.14, v1.21.13, v1.21.12, v1.21.11, v1.21.10 (Jan 29 2026), 1.21.8 (no v prefix, Jan 28 2026), v1.21.9. v1.21.16 not in list.
- Tags page shows no release assets, only auto-generated source zip and tar.gz.
- Source archive naming (not downloaded): `https://github.com/petersem/posterr/archive/refs/tags/v${VERSION}.tar.gz` (tag form v-prefixed for recent tags; the 1.21.8 tag has no v prefix).
- Release v1.15.0 (titled "Binaries for Posterr", marked Latest, released 2 Feb, commit 2b68a12): 3 assets, names not shown on the fetched page. Release notes say the binaries are broken due to a packaging tool breaking change. Not needed for the container build.
- Upstream does not publish checksums.

## Arch support
- Upstream Docker Hub page lists X86 and ARM64 for compose/CLI install. Standalone binaries for macOS, Linux, Windows. The CEC monitor control script is Raspberry Pi only.

## Gotchas
- Setup page default password is documented as "raidisnotabackup" (upstream README). Not an env var; do not hardcode in container.
- Settings and custom media go to `config` and `public/custom` directories. The app writes relative paths (`./config`, `./saved`, `./public/custom`) when run from cwd.
- Plex is mandatory; Sonarr v3.0+, Radarr v4.3+, Readarr v0.1.3+ optional.
- Sleep API: `/api/sleep` (POST with headers `psw` and `sleep`; GET returns status).
- Resource use per upstream: about 20-35 MB memory, about 75 MB disk.
- Upstream suggests watchtower for updates.
