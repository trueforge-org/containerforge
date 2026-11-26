# browserless/chrome Dockerfile (pinned commit 2ebe1345)

Source: https://github.com/browserless/chrome/blob/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile (raw, pinned), fetched 2026-11-26. Full file read.

## Build
- `ARG VERSION=latest`.
- Builder: `FROM ghcr.io/browserless/base:$VERSION`; `COPY src src/`; `npm run build`, `npm run build:function`, `npm run install:debugger`.
- Runtime: `FROM ghcr.io/browserless/base:$VERSION`; `npm prune --omit=dev`; `bash ./scripts/install-chrome.sh` (installs Google's deb for native arch; playwright install chrome fails on arm64); apt clean.
- Copies from builder: $APP_DIR/build, static, extensions.
- `RUN chown -R blessuser:blessuser $APP_DIR`.

## Runtime
- `USER blessuser`.
- `CMD ["./scripts/start.sh"]`.
- No EXPOSE in this file (default debugger port 3000 per README).

## Gotchas
- Depends on ghcr.io/browserless/base image (not in this file).
- Pinned commit is an older layout; current README on master describes a different product line (see browserless-chrome-readme.md).
