# Upstream Dockerfile: agregarr/agregarr

**Source URL(s):** https://raw.githubusercontent.com/agregarr/agregarr/4a101503a89ebfbb3d8ba63445f87053b11b991a/Dockerfile (blob URL in urls.txt is the same file; fetched 2026-11-27)

## Build stage (`build_image`)
- `FROM node:20.19.5-alpine`, `WORKDIR /app`, `ARG TARGETPLATFORM` (default linux/amd64).
- apk: `python3 make g++ gcc libc6-compat bash build-base cairo-dev pango-dev jpeg-dev giflib-dev pixman-dev`.
- `yarn global add node-gyp`.
- `COPY package.json yarn.lock`; `CYPRESS_INSTALL_BINARY=0 yarn install --frozen-lockfile --network-timeout 1000000`.
- `COPY . ./`; `ARG COMMIT_TAG` -> env; `yarn build`.
- `yarn install --production --ignore-scripts --prefer-offline`.
- `rm -rf src server .next/cache`; `mkdir -p config && touch config/DOCKER`.
- Writes `committag.json` = `{"commitTag": "${COMMIT_TAG}"}`.

## Final stage
- `FROM node:20.19.5-alpine`, `WORKDIR /app`.
- apk: `tzdata tini fontconfig ttf-dejavu font-noto-emoji cairo pango jpeg giflib pixman ffmpeg python3`.
- Fonts: wget ~30 Google Fonts TTFs (raw.githubusercontent google/fonts ofl/*) to `/usr/share/fonts/truetype/poster-fonts`; FiraCode v6.2 zip from github releases (`FiraCode-Bold.ttf`); `fc-cache -fv`.
- fontconfig file `/etc/fonts/conf.d/99-agregarr-custom-fonts.conf` with `<dir>/app/config/fonts</dir>`.
- Deno: `deno@edge` from Alpine edge repos (added to /etc/apk/repositories).
- Chromium + nss freetype harfbuzz ca-certificates ttf-freefont (apk).
- yt-dlp: `https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp` -> `/usr/local/bin/yt-dlp` (unpinned).
- `COPY --from=build_image /app ./`.
- `ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`, `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium`.
- `ENTRYPOINT ["/sbin/tini", "--"]`, `CMD ["yarn", "start"]`, `EXPOSE 7171`.
- No `USER` directive (runs as root).

## Env vars (set in Dockerfile)
| Var | Value |
| --- | --- |
| COMMIT_TAG | build arg |
| PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD | 1 |
| PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH | /usr/bin/chromium |

## Ports
- 7171 (EXPOSE)

## Volumes/paths
- `/app/config` (created as `config/DOCKER` in build stage; not declared VOLUME upstream)
- `/app/config/fonts` custom fontconfig dir

## User/UID
- None (root).

## Arch
- Node Alpine (musl). Chromium and Deno from Alpine repos.

## Gotchas
- yt-dlp fetched unpinned (`latest`).
- Requires Deno (yt-dlp JS runtime, per Dockerfile comment).
