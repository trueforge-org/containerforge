# Upstream Dockerfile: SiaFoundation/siad (commit 66e7fc6)

Source URL: https://raw.githubusercontent.com/SiaFoundation/siad/66e7fc6/Dockerfile (fetched 2026-11-27)

## Build stage
- `FROM golang:alpine AS build`; WORKDIR /app; `COPY . .`.
- apk: build-base git make ca-certificates; `update-ca-certificates`.
- `git status > /dev/null` (fixes GIT_DIRTY detection in Makefile), then `make static`.

## Runtime stage
- `FROM alpine:latest`.
- `COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt`.
- `COPY --from=build /app/release /` (binary `siad` lands at `/siad`).

## Ports / env / volume
- `EXPOSE 9981/tcp` (gateway), `EXPOSE 9982/tcp` (host RHP2), `EXPOSE 9983/tcp` (host RHP3).
- `ENV SIA_WALLET_PASSWORD=` (auto-unlocks wallet); `ENV SIA_API_PASSWORD=` (API auth).
- `VOLUME [ "/sia-data" ]`.
- No USER (root). No CMD.

## Entrypoint
- `ENTRYPOINT [ "/siad", "--disable-api-security", "-d", "/sia-data", "--api-addr", ":9980" ]`.
- Note: `--disable-api-security` makes the API unauthenticated, despite `SIA_API_PASSWORD` being set in ENV.
- API bound to `:9980` (not in EXPOSE).
