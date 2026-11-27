# GitHub yourselfhosted/slash (Dockerfile at 489efa67, repo metadata)

Source URL(s) + date:
- https://raw.githubusercontent.com/yourselfhosted/slash/489efa67f3752e0d55e3487f820394d973322a2f/Dockerfile
- https://api.github.com/repos/yourselfhosted/slash
- Fetched 2026-11-27

## Repo metadata (GitHub API)
- full_name `yourselfhosted/slash`, license SPDX `AGPL-3.0`, default branch `main`, pushed 2026-08-24

## Dockerfile (489efa67)
Stages:
1. `FROM node:22-alpine AS frontend` (WORKDIR `/frontend-build`, `COPY . .`, WORKDIR `/frontend-build/frontend/web`)
   - `RUN corepack enable && pnpm i --frozen-lockfile`
   - `RUN pnpm build`
2. `FROM golang:1.23-alpine AS backend` (WORKDIR `/backend-build`, `COPY . .`)
   - `COPY --from=frontend /frontend-build/frontend/web/dist /backend-build/server/route/frontend/dist`
   - `RUN CGO_ENABLED=0 go build -o slash ./bin/slash/main.go`
3. `FROM alpine:latest AS monolithic` (WORKDIR `/usr/local/slash`)
   - `RUN apk add --no-cache tzdata`
   - `ENV TZ="UTC"`
   - `COPY --from=backend /backend-build/slash /usr/local/slash/`
   - `EXPOSE 5231`
   - `RUN mkdir -p /var/opt/slash`, `VOLUME /var/opt/slash`
   - `ENV SLASH_MODE="prod"`, `ENV SLASH_PORT="5231"`
   - `ENTRYPOINT ["./slash"]`

No USER directive (runs as root). No HEALTHCHECK. No CMD.

## Version/asset naming
- Build is from source (Go binary built in stage 2); no prebuilt binary download in the Dockerfile.
