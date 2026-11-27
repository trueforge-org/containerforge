# GitHub: DIYgod/RSSHub Dockerfile and release

Source URL(s): https://raw.githubusercontent.com/DIYgod/RSSHub/c566e920fd386c19935954e1969ac8d7d3c8b5c4/Dockerfile ; https://api.github.com/repos/DIYgod/RSSHub/releases/latest (fetched 2026-11-27)

## Release
- Latest release tag: `v2026.11.27-8768.gbfc93be` (html: github.com/DIYgod/RSSHub/releases/tag/v2026.11.27-8768.gbfc93be). Published by github-actions[bot].
- Release assets: none listed in API response (image is built from source by CI).
- Tag scheme: `vYYYY.MM.DD-<build>.<shortsha>`.

## Dockerfile (multi-stage, commit c566e92)
- Stage `dep-builder`: `FROM node:26-trixie`. corepack enable pnpm; `pnpm install --frozen-lockfile` and `pnpm rb` (PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true). Build args: `USE_CHINA_NPM_REGISTRY` (0/1, switches npm/pnpm registry to npmmirror).
- Stage `dep-version-parser`: `FROM debian:trixie-slim`. Greps versions of `patchright`, `@vercel/nft`, `fs-extra` from package.json to /ver/.
- Stage `docker-minifier`: `FROM node:26-trixie-slim`. Installs @vercel/nft + fs-extra; `pnpm build`; runs `scripts/docker/minify-docker.js` to create `/app-minimal`, moves node_modules into /app, deletes scripts/lib.
- Stage `chromium-downloader`: `FROM node:26-trixie-slim`. Build args `TARGETPLATFORM`, `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD` (default 1). On linux/amd64 with download=0 installs bundled Chromium via Patchright; otherwise apt installs `chromium` and writes `CHROMIUM_EXECUTABLE_PATH` to /app/.env. Verifies shared libs with ldd.
- Final stage: copies /app from docker-minifier; `ENV LD_PRELOAD=libjemalloc.so.2`; `EXPOSE 1200`; `ENTRYPOINT ["dumb-init", "--"]`; `CMD ["npm", "run", "start"]`.
- Final image has no explicit USER (runs as root unless overridden).

## Gotchas
- Default listening port in image is 1200. TrueCharts overrides PORT env to 10191.
- Chromium availability depends on build arg; `chromium-bundled*` tags ship bundled Chromium.
- Base images are node:26-trixie (build) and debian/node:26-trixie-slim (runtime stages).

## Final stage `app` (line ~118, full file grep)
- `FROM node:26-trixie-slim AS app`; ENV NODE_ENV=production, TZ=Asia/Shanghai, PLAYWRIGHT_BROWSERS_PATH=/app/node_modules/.cache/ms-playwright, LD_PRELOAD=libjemalloc.so.2.
- apt: `dumb-init git curl libjemalloc2` plus Chromium runtime libs (amd64 path) or `chromium` (other arches).
- No USER, no VOLUME. EXPOSE 1200. ENTRYPOINT dumb-init, CMD `npm run start`.
