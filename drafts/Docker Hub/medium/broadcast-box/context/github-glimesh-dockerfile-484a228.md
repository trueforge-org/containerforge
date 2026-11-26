# Glimesh/broadcast-box Dockerfile @ 484a228

Source: https://raw.githubusercontent.com/Glimesh/broadcast-box/484a22832dcea141ff3ac984f2f038cacf8aa678/Dockerfile (fetched 2026-11-26)

## Stage 1 `web-build`
- `FROM node` (no tag); WORKDIR /broadcast-box/web
- COPY `. /broadcast-box`; RUN `npm install && npm run build`

## Stage 2 `go-build`
- `FROM golang:alpine`; WORKDIR /broadcast-box; ENV GOPROXY=direct, GOSUMDB=off
- COPY `. /broadcast-box`; RUN `apk add git`; RUN `go build` (binary name `broadcast-box`)

## Stage 3 (final)
- `FROM golang:alpine`
- COPY --from=web-build /broadcast-box/web/build -> same path
- COPY --from=go-build /broadcast-box/broadcast-box and /broadcast-box/.env.production
- ENV APP_ENV=production, NETWORK_TEST_ON_START=true
- WORKDIR /broadcast-box; ENTRYPOINT ["/broadcast-box/broadcast-box"]

## Not present
- No ARG, EXPOSE, VOLUME, USER (root), CMD, package URLs
