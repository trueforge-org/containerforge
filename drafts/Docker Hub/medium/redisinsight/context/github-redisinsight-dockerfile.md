# GitHub: RedisInsight/RedisInsight Dockerfile and docker-entry.sh

Source URL(s):
- https://raw.githubusercontent.com/RedisInsight/RedisInsight/ecd3e7452cac2438bf1a69df8b4e38fc973383dd/Dockerfile
- https://raw.githubusercontent.com/RedisInsight/RedisInsight/ecd3e7452cac2438bf1a69df8b4e38fc973383dd/docker-entry.sh
- https://api.github.com/repos/redis/RedisInsight/releases/latest
Fetched: 2026-11-27

## Build stage: node:24.22.2-alpine
| Step | Detail |
| --- | --- |
| apk | python3, py3-setuptools, make, git, g++, gcompat (virtual .gyp) |
| npm | `COPY package.json package-lock.json .npmrc`; patches; `npm ci --ignore-scripts && npx patch-package` (.npmrc: legacy-peer-deps=true) |
| backend | `npm ci --prefix redisinsight/api` |
| build | `npm run build:ui`, `npm run build:statics`, `npm run build:api` |
| prune | `npm ci --prefix redisinsight/api --omit=dev` |

## Runtime stage: node:24.22.2-alpine
| Item | Value |
| --- | --- |
| ARG | NODE_ENV=production; RI_SEGMENT_WRITE_KEY |
| ENV | RI_SERVE_STATICS=true, RI_BUILD_TYPE=DOCKER_ON_PREMISE, RI_APP_FOLDER_ABSOLUTE_PATH=/data, NODE_ENV |
| apk | `apk upgrade --no-cache libcrypto3 libssl3` (CVE-2023-5363) |
| copied | redisinsight/api/dist, redisinsight/api/node_modules, redisinsight/ui/dist |
| dirs | /data created, owned by node |
| entry | docker-entry.sh (chmod +x) |
| EXPOSE | 5540 |
| USER | node |
| ENTRYPOINT | `["./docker-entry.sh", "node", "redisinsight/api/dist/src/main"]` |
| CMD | none |

## docker-entry.sh
- `set -e`; echoes banner; `exec "$@"` (so args run as PID 1 with signal handling).

## Gotchas
- Dockerfile comment: RedisInsight is hard-coded to port 5540 (chart sets RI_APP_PORT, effect not verified here).
- Runs as node (uid 1000) by default.
- Requires `.npmrc`, `patches/`, `configs/`, `scripts/` in the build context.

## Release (redis/RedisInsight releases/latest)
| Key | Value |
| --- | --- |
| tag_name | 3.10.2 |
| published_at | 2026-11-24 |
| assets | Redis-Insight-linux-amd64.deb, -x86_64.rpm, -arm64.AppImage, -aarch64.rpm, -linux-amd64.snap, mac dmg, win installer.exe |
- Asset naming: `Redis-Insight-linux-<arch>.<ext>`.
