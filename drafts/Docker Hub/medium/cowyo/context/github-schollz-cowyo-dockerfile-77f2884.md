# schollz/cowyo Dockerfile @ 77f28842

Source: https://raw.githubusercontent.com/schollz/cowyo/77f28842c4e9d55c50bcf7aed180be5e9ed9a41c/Dockerfile (fetched 2026-11-26)

## Stage 1 `frontend`
- `FROM node:24-alpine`; WORKDIR /src/web
- COPY web/package.json web/package-lock.json; `npm ci`
- COPY web/index.html web/vite.config.js; web/public -> ./public; web/src -> ./src; `npm run build`

## Stage 2 `backend`
- `FROM golang:1.26.5-alpine`; WORKDIR /src
- COPY go.mod go.sum; `go mod download`; COPY . .
- COPY --from=frontend /src/internal/site/build -> ./internal/site/build
- `CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/cowyo ./cmd/cowyo`

## Stage 3 final
- `FROM alpine:3.23`; `apk add --no-cache ca-certificates`; system group+user `cowyo`; mkdir /data; chown cowyo:cowyo /data
- COPY --from=backend /out/cowyo -> /usr/local/bin/cowyo
- ENV SQLITE_PATH=/data/cowyo2.sqlite3
- USER cowyo; EXPOSE 8001; CMD ["/usr/local/bin/cowyo"]
- No ARG, VOLUME, ENTRYPOINT; no download URLs

## Gotchas
- Layout here (web/, ./cmd/cowyo, internal/site/build) differs from plan's description of main (cowyo2); see main-branch file
