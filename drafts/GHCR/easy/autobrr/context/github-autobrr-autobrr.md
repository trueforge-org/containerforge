# autobrr/autobrr (upstream Dockerfile at abad209, release and license metadata)
Source URL(s): https://raw.githubusercontent.com/autobrr/autobrr/abad209f1e6a7041f27eadccc27a5468d1c555fc/Dockerfile (fetched; blob variant same), https://api.github.com/repos/autobrr/autobrr (fetched 200), https://api.github.com/repos/autobrr/autobrr/releases/latest (fetched 200), https://github.com/autobrr/autobrr (repo)

## Release (api releases/latest)
- tag `v1.91.1`, published 2026-11-20T20:37:41Z
- Assets include desktop installers (e.g. autobrr-desktop_1.91.1_windows_x86_64.msi); linux tar.gz names not listed in the fetched portion (plan lists autobrr_1.91.1_linux_x86_64.tar.gz / _arm64.tar.gz)

## License
- GitHub API: GPL-2.0 (spdx_id GPL-2.0)

## Build (Dockerfile at abad209)
- Web: `node:24.19.0-alpine3.24` builder, corepack + pnpm install --frozen-lockfile, `pnpm run build`, outputs /web/dist and build.go
- App: `golang:1.27-alpine3.24`, `apk add git build-base tzdata`, `ENV SERVICE=autobrr`, `CGO_ENABLED=0`
- Builds `bin/autobrr` from cmd/autobrr/main.go and `bin/autobrrctl` from cmd/autobrrctl/main.go
- ldflags: -s -w -X main.version -X main.commit -X main.date (ARGs VERSION=dev, REVISION=dev, BUILDTIME)
- Runner: `alpine:3.24`, `apk --no-cache add ca-certificates curl tzdata jq`
- Runner ENV: HOME=/config, XDG_CONFIG_HOME=/config, XDG_DATA_HOME=/config
- LABEL org.opencontainers.image.source https://github.com/autobrr/autobrr
- WORKDIR /app, `VOLUME /config`, binaries to /usr/local/bin/

## Entrypoint / ports
- `ENTRYPOINT ["/usr/local/bin/autobrr", "--config", "/config"]`
- EXPOSE 7474
- No HEALTHCHECK, no USER directive

## Volumes / paths
- /config (VOLUME); reads /config/config.toml

## Runtime deps
- ca-certificates, curl, tzdata, jq (Alpine runner)
