# wifi-card Dockerfile at commit 7a990dd2

Source URL(s): https://raw.githubusercontent.com/bndw/wifi-card/7a990dd2411f6c8758ad696bf737b509f9672953/Dockerfile (fetched 2026-11-27; blob URL is the same file)

## Stages
1. `FROM node:24-alpine AS builder`, `WORKDIR /app`, `COPY . .`
   - `RUN corepack enable`
   - `RUN yarn install --immutable`
   - `RUN yarn prettier --check ./src`
   - `RUN yarn build` (output `/app/dist`)
2. `FROM nginx:stable-alpine`
   - `COPY --from=builder /app/dist /usr/share/nginx/html`

## Runtime
- No `EXPOSE`, `USER`, `VOLUME`, `ENV`, `ENTRYPOINT`, `CMD`, or nginx config in the file. Nginx base image defaults apply (port 80).

## Gotchas
- Static SPA: build output only. No server-side code.
- Build stage is Alpine/musl (node:24-alpine). Alpine base is the upstream choice.
- Package manager is Yarn via corepack (`--immutable` lockfile install).
