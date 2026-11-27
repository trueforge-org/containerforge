# GitHub: patrickstigler/quiz-game Dockerfile

Source URL(s):
- https://raw.githubusercontent.com/patrickstigler/quiz-game/master/Dockerfile
- https://github.com/ASKJR/quiz-game (HTML page fetched; no build facts, upstream repo shell only)
Fetched: 2026-11-27

## Build stage
| Item | Value |
| --- | --- |
| base | node:12.2.0-alpine AS build |
| WORKDIR | /app |
| steps | COPY package*.json; `npm install --silent`; COPY . /app; `npm run build` |

## Runtime stage
| Item | Value |
| --- | --- |
| base | nginx:1.16.0-alpine |
| packages | apk: curl, git, bash, nano, wget, ca-certificates |
| libssl | `apk upgrade libssl1.0` |
| static files | COPY --from=build /app/dist to /usr/share/nginx/html |
| nginx config | removes /etc/nginx/conf.d/default.conf; copies ./nginx.conf to /etc/nginx/conf.d |
| EXPOSE | 80 |
| CMD | `["nginx", "-g", "daemon off;"]` |
| USER | none (root) |

## Gotchas
- Pinned old bases (node 12.2.0, nginx 1.16.0); build needs nginx.conf in the repo root (not fetched).
- Build output is static (React/Vue-style `dist/`); no runtime env vars in Dockerfile.
- No VOLUME; /app in the chart is not a path used by the image.
