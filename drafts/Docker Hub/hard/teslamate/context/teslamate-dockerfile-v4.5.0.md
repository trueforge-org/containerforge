# teslamate-org/teslamate Dockerfile (v4.5.0)

Source URL: https://raw.githubusercontent.com/teslamate-org/teslamate/v4.5.0/Dockerfile (fetched 2026-11-26)
Blob URL: https://github.com/teslamate-org/teslamate/blob/v4.5.0/Dockerfile

## Stage 1: builder
- `FROM elixir:1.20.4-otp-29 AS builder`
- SHELL `["/bin/bash", "-o", "pipefail", "-c"]`
- apt: ca-certificates, curl, gnupg, brotli; NodeSource key `/etc/apt/keyrings/nodesource.gpg`; `NODE_MAJOR=22`; installs nodejs.
- `mix local.rebar --force && mix local.hex --force`
- `ENV MIX_ENV=prod`; `WORKDIR /opt/app/elixir`
- Copies: `elixir/mix.exs`, `mix.lock`, `config/$MIX_ENV.exs`, `config/config.exs`, `assets/package*.json`, `assets/`, `priv/static`, `lib`, `priv/repo/migrations`, `priv/gettext`; `grafana/dashboards` -> `../grafana/dashboards`; `VERSION` -> `../VERSION`; `NOTICE LICENSE` -> `../`; `config/runtime.exs`.
- `mix deps.get --only $MIX_ENV`, `mix deps.compile`, `npm ci --prefix ./assets`, `mix assets.deploy`, `mix compile`
- `mix release --path /opt/built`
- `COPY --chmod=444 NOTICE LICENSE /opt/legal/`

## Stage 2: app
- `FROM debian:trixie-slim AS app`
- `ENV LANG=C.UTF-8 SRTM_CACHE=/opt/app/.srtm_cache HOME=/opt/app`
- `WORKDIR $HOME`
- apt (--no-install-recommends): ca-certificates, libodbc2, libsctp1, libssl3t64, libstdc++6, tini, tzdata. Cleans lists.
- User: group `nonroot` gid 10001; user `nonroot` uid 10000, home `/home/nonroot`, shell `/sbin/nologin`.
- `chown -R nonroot:nonroot .`
- `COPY --from=builder /opt/legal/ /usr/share/doc/teslamate/`
- `USER nonroot:nonroot`
- `COPY --chown=nonroot:nonroot --chmod=555 entrypoint.sh /`
- `COPY --from=builder --chown=nonroot:nonroot --chmod=555 /opt/built .`
- `RUN mkdir $SRTM_CACHE`

## Entrypoint / ports
- `EXPOSE 4000`
- `ENTRYPOINT ["tini", "--", "/bin/dash", "/entrypoint.sh"]`
- `CMD ["bin/teslamate", "start"]`
- No ARG, VOLUME, HEALTHCHECK.

## Gotchas
- Runtime is non-root uid 10000 (nonroot), USER set in Dockerfile.
- `SRTM_CACHE` dir is created at build time under `/opt/app`.
