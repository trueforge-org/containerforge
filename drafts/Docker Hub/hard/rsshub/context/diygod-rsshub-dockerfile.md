# DIYgod/RSSHub Dockerfile (master)

Source: https://raw.githubusercontent.com/DIYgod/RSSHub/master/Dockerfile , fetched 2026-11-26 (read as head and tail parts, covering the whole file).

## Stages
| Stage | Base | Work |
| --- | --- | --- |
| dep-builder | node:26-trixie | corepack enable pnpm; `pnpm install --frozen-lockfile` with PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true; `pnpm rb` |
| dep-version-parser | debian:trixie-slim | greps patchright, @vercel/nft, fs-extra versions from package.json to /ver/ |
| docker-minifier | node:26-trixie-slim | `pnpm add @vercel/nft fs-extra --save-prod`; `pnpm build`; `minify-docker.js` prunes node_modules to /app/app-minimal -> /app/node_modules |
| chromium-downloader | node:26-trixie-slim | if PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0 and amd64: `pnpm exec patchright install chromium`; otherwise creates empty ms-playwright cache dir |
| app | node:26-trixie-slim | final |

- Mirror: `USE_CHINA_NPM_REGISTRY=1` switches npm/pnpm to npmmirror.
- Final app stage: apt `dumb-init git curl libjemalloc2`; on amd64 with bundled browser, Chromium shared libs (libnss3, libgbm1, etc.); on arm/arm64 `apt install chromium` and writes `CHROMIUM_EXECUTABLE_PATH` to `/app/.env`.
- ARG TARGETPLATFORM; PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD default 1.
- `COPY --from=docker-minifier /app /app`.

## Runtime
- `ENTRYPOINT ["dumb-init", "--"]`; `CMD ["npm", "run", "start"]`.
- `EXPOSE 1200`.
- No USER directive (runs as root).
- LABEL org.opencontainers.image.authors=https://github.com/DIYgod/RSSHub.

## Env (final stage)
| Var | Value |
| --- | --- |
| NODE_ENV | production |
| TZ | Asia/Shanghai |
| PLAYWRIGHT_BROWSERS_PATH | /app/node_modules/.cache/ms-playwright |
| LD_PRELOAD | libjemalloc.so.2 (set later in file) |

## Arch
- amd64: Playwright/patchright bundled Chromium (libs from apt).
- arm/arm64: distro chromium from apt; path in /app/.env.

## Gotchas
- Build-time Chromium download only for amd64 and only when PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0.
- Upstream file has a commented-out ldd/apt-file recipe for missing libs.
- Node 26 base images (trixie).
