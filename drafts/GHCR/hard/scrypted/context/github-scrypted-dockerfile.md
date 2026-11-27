# koush/scrypted install/docker/Dockerfile (main)

Source URL(s) + date:
- https://raw.githubusercontent.com/koush/scrypted/main/install/docker/Dockerfile (fetched 2026-11-27)
- https://github.com/koush/scrypted/releases/latest (redirect, fetched 2026-11-27) -> tag v0.147.0
- https://registry.npmjs.org/@scrypted/server/latest (fetched 2026-11-27) -> version 0.147.0, license ISC, bin scrypted-serve

## What it is
- Scrypted server image layered on a base image `ghcr.io/koush/scrypted-common:${BASE}`.

## Build steps
1. `ARG BASE="noble-full"`; `FROM ghcr.io/koush/scrypted-common:${BASE}`
2. WORKDIR /; cache-bust `ADD https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h skipcache`
3. `ARG SCRYPTED_INSTALL_VERSION="latest"`; `RUN test -n "$SCRYPTED_INSTALL_VERSION"`
4. `RUN npx -y scrypted@latest install-server ${SCRYPTED_INSTALL_VERSION}` (installs npm package into /server)
5. WORKDIR /server
6. ENV NODE_OPTIONS="--dns-result-order=ipv4first"
7. ENV SCRYPTED_BASE_VERSION="20250101" (must be bumped when base image changes, per comment)
8. CMD `["/bin/sh", "-c", "ulimit -c 0; exec npm --prefix /server exec scrypted-serve"]`

## Runtime deps
- Provided by scrypted-common base (not fetched). Node via npm; scrypted npm package 0.147.0.

## Entrypoint/flags
- `npm --prefix /server exec scrypted-serve` (bin: scrypted-serve -> bin/scrypted-serve)

## Ports
- Not declared in this Dockerfile. Chart uses 10611 (SCRYPTED_INSECURE_PORT).

## Config / env
- SCRYPTED_INSECURE_PORT (chart) ; SCRYPTED_WEBHOOK_UPDATE* (commented in chart)

## Version/asset naming
- Base tags used by chart: `v<ver>-jammy-full|lite|nvidia`; Dockerfile default BASE `noble-full`.
- Upstream release tag format: `v0.147.0`. Chart appVersion 0.123.58 is older than latest tag at fetch time.

## Gotchas
- Upstream Dockerfile default base is noble; chart image tags are jammy-based.
- `random.org` cache-bust URL makes the build non-reproducible (do not copy).
- `install-server latest` fetches whatever the npm latest is at build time.
- License of npm package: ISC (npm metadata).
