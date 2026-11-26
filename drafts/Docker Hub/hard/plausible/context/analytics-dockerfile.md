# plausible/analytics Dockerfile (@ 0621fc0a77cc50add00baddbdd59f378324da483)

Source URL: https://github.com/plausible/analytics/blob/0621fc0a77cc50add00baddbdd59f378324da483/Dockerfile (fetched via raw.githubusercontent.com, pinned commit)

## Stages
1. buildcontainer: hexpm/elixir:1.14.3-erlang-25.2.3-alpine-3.18.0
2. final: alpine:3.18.0

## Build args (exported as env)
- ERL_FLAGS (no default; multi-platform qemu workaround)
- BUILD_METADATA (default {})

## Builder
- apk: git, nodejs, yarn, python3, npm, ca-certificates, wget, gnupg, make, gcc, libc-dev; then npm upgraded globally, webpack global
- ENV MIX_ENV=prod, NODE_ENV=production, NODE_OPTIONS=--openssl-legacy-provider, ERL_FLAGS
- WORKDIR /app; COPY mix.exs, mix.lock, config, assets/(package*.json, assets), tracker/(package*.json, tracker), priv, lib, rel
- mix local.hex/local.rebar --force; mix deps.get --only prod; mix deps.compile
- npm install + npm run deploy in ./assets and ./tracker
- mix phx.digest priv/static; mix download_country_database; mix sentry_recompile; mix release plausible

## Final
- apk: openssl, ncurses, libstdc++, libgcc, ca-certificates; apk upgrade --no-cache
- ENV BUILD_METADATA, LANG=C.UTF-8, LISTEN_IP=0.0.0.0
- WORKDIR /app; release from builder /app/_build/prod/rel/plausible -> /app
- rel/docker-entrypoint.sh -> /entrypoint.sh (chmod a+x)
- User plausibleuser UID 1000 (home /app, /bin/sh; no GID set); chown /app; USER plausibleuser
- EXPOSE 8000
- ENTRYPOINT ["/entrypoint.sh"]; CMD ["run"]
- No VOLUME, no HEALTHCHECK

## Gotchas
- Image is the app only; Postgres and ClickHouse are required external services.
- Pinned Elixir 1.14.3 / Erlang 25 / alpine 3.18.0 build stack.
