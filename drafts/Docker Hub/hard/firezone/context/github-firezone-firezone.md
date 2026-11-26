# firezone/firezone

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/firezone/firezone/dc71329fa007942ed32c69bd820f66b94cf5a5cc/Dockerfile.prod (fetched 2026-11-26)
- https://raw.githubusercontent.com/firezone/firezone/dc71329fa007942ed32c69bd820f66b94cf5a5cc/rel/overlays/bin/server (fetched 2026-11-26)
- https://raw.githubusercontent.com/firezone/firezone/dc71329fa007942ed32c69bd820f66b94cf5a5cc/rel/overlays/bin/bootstrap (fetched 2026-11-26; summary returned by the tool, see note)
- https://raw.githubusercontent.com/firezone/firezone/dc71329fa007942ed32c69bd820f66b94cf5a5cc/LICENSE (fetched 2026-11-26)
- https://github.com/firezone/firezone (repo root, fetched 2026-11-26; current master, not the pinned commit)
- Tarball (not downloaded, binary archive): https://github.com/firezone/firezone/archive/refs/tags/${VERSION}.tar.gz

## What it is

Firezone: WireGuard-based remote access / ZTNA platform. The pinned commit `dc71329` is the legacy 0.7.36 omnibus release: an Elixir/Phoenix portal (`apps/fz_http`) plus WireGuard and nftables control in `fz_vpn`/`fz_wall`.

Current master (repo root) is a different architecture: monorepo with Elixir portal (`elixir/`, Elastic License 2.0), Rust data plane, Swift/Kotlin/Rust clients. "Production self-hosting is not officially supported" (README).

## Install/build steps (Dockerfile.prod at dc71329, verbatim structure)

Args: `ELIXIR_VERSION=1.14.3`, `OTP_VERSION=25.2.1`, `ALPINE_VERSION=3.16.3`, `BUILDER_IMAGE="firezone/elixir:${ELIXIR_VERSION}-otp-${OTP_VERSION}"`, `RUNNER_IMAGE="alpine:${ALPINE_VERSION}"`.

Builder (`${BUILDER_IMAGE}`):
- `apk add nodejs yarn build-base git python3`
- `WORKDIR /app`; `mix local.hex --force && mix local.rebar --force`; `ENV MIX_ENV="prod"`
- `COPY mix.exs mix.lock ./`; copies `apps/fz_http/mix.exs`, `apps/fz_vpn/mix.exs`, `apps/fz_wall/mix.exs`; `mix deps.get --only $MIX_ENV`; `mkdir config`; `COPY config/config.exs config/${MIX_ENV}.exs config/`; `mix deps.compile`
- `COPY priv priv`, `COPY apps apps`; `ARG VERSION=0.0.0-docker`, `ENV VERSION=$VERSION`
- Assets: `cd apps/fz_http/assets && yarn install --frozen-lockfile && yarn deploy && cd .. && mix phx.digest`
- `mix compile`; `COPY config/runtime.exs config/`; `COPY rel rel`; `mix release`

Runner (`${RUNNER_IMAGE}`):
- `apk add -u --no-cache nftables libstdc++ ncurses-libs openssl`
- `WORKDIR /app`, `ENV MIX_ENV="prod"`, `COPY --from=builder /app/_build/${MIX_ENV}/rel/firezone ./`
- `CMD ["/app/bin/server"]`. No USER, EXPOSE, VOLUME, ENTRYPOINT, HEALTHCHECK. Runs as root.

## Entry scripts

`rel/overlays/bin/server` (verbatim):
```sh
#!/bin/sh
set -e
source "$(dirname -- "$0")/bootstrap"

./firezone eval FzHttp.Release.migrate

if [ "$RESET_ADMIN_ON_BOOT" = "true" ]; then
  ./firezone eval FzHttp.Release.create_admin_user
fi

exec ./firezone start
```

`rel/overlays/bin/bootstrap` (summary of the script):
- Defaults: `WIREGUARD_INTERFACE_NAME=wg-firezone`, `WIREGUARD_IPV4_ADDRESS=10.3.2.1`, `WIREGUARD_IPV4_ENABLED=true`, `WIREGUARD_IPV4_NETWORK=10.3.2.0/24`, `WIREGUARD_IPV6_ADDRESS=fd00::3:2:1`, `WIREGUARD_IPV6_ENABLED=true`, `WIREGUARD_IPV6_NETWORK=fd00::3:2:0/120`, `WIREGUARD_MTU=1280`.
- `setup_interface`: `ip link add <iface> type wireguard` if missing; `ip address replace` (IPv4) and `ip -6 address replace` (IPv6); `ip link set mtu <MTU> up`.
- `add_routes`: `ip route add <network> dev <iface>` (IPv4/IPv6) if missing.
- `setup_telemetry`: `/var/firezone/.tid` created from `/proc/sys/kernel/random/uuid` if missing; exports `TELEMETRY_ID`.
- `setup_saml`: `openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /var/firezone/saml.key -out /var/firezone/saml.crt -subj "/C=US/ST=Denial/L=Firezone/O=Dis/CN=www.example.com"` if key or cert missing.
- Ends with `cd -P -- "$(dirname -- "$0")"`.
- Needs root or NET_ADMIN for `ip link` / `ip route`; `set -e` in `server` makes a failure fatal.

## Runtime deps

- Erlang/OTP 25.2.1, Elixir 1.14.3 (builder). Runtime: `nftables libstdc++ ncurses-libs openssl` (Alpine). `ip` (iproute2) used by bootstrap.
- Node 18 (`.tool-versions` per plan; not fetched) and yarn for assets.

## Env vars (from chart and bootstrap; see truecharts file)

Runtime env names are the upper-cased config keys (confirmed by the TrueCharts chart: `PHOENIX_HTTP_PORT`, `EXTERNAL_URL`, `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD`, `DATABASE_SSL_ENABLED`, `RESET_ADMIN_ON_BOOT`, `DEFAULT_ADMIN_EMAIL`, `DEFAULT_ADMIN_PASSWORD`, `GUARDIAN_SECRET_KEY`, `DATABASE_ENCRYPTION_KEY`, `SECRET_KEY_BASE`, `LIVE_VIEW_SIGNING_SALT`, `COOKIE_SIGNING_SALT`, `COOKIE_ENCRYPTION_SALT`, `WIREGUARD_PORT`, `WIREGUARD_IPV4_ENABLED`, `WIREGUARD_IPV4_MASQUERADE`, `WIREGUARD_IPV6_ENABLED`, `TELEMETRY_ENABLED`, and others). Bootstrap env: the `WIREGUARD_*` list above.

## Ports

- Phoenix HTTP 13000/tcp (`PHOENIX_HTTP_PORT`, chart main port). Container does not terminate TLS (per plan; upstream compose puts Caddy in front).
- WireGuard 51820/udp (`WIREGUARD_PORT`, chart wireguard service).

## Volumes/paths and persistent data

- `/var/firezone`: `.tid` (telemetry id), `saml.key`, `saml.crt`, WireGuard private key (`private_key`, per plan).
- Chart persistence: `/var/firezone`.

## User/UID & permissions

- Runs as root (no USER). Chart sets runAsUser 0, PUID 0.
- WireGuard and nftables need root or NET_ADMIN. Chart adds capabilities `NET_ADMIN` and `SYS_MODULE`.

## Healthcheck/readiness endpoints

- None in Dockerfile.prod. Chart defines no probes.

## Version/release info

- Tag `0.7.36` (lightweight tag; commit `dc71329fa007942ed32c69bd820f66b94cf5a5cc`). Docker Hub `firezone/firezone:0.7.36`, digest `sha256:6e65ebab...` (Hub and chart agree).
- Hub page: 0.7 is past support; maintainers said updates only through 2024-01-31; users pointed to a FAQ on moving to 1.0.

## Arch support

- Not stated in Dockerfile.prod (alpine multi-arch base). Hub page lists no architectures.

## License

- LICENSE at dc71329: Apache License 2.0 (January 2004 text). Plan bake `Apache-2.0` is consistent.
- Current repo: Apache-2.0 overall; `elixir/` directory is Elastic License 2.0 (per repo root summary).

## Gotchas

- Upstream runs as root, needs NET_ADMIN and nftables; the rootless and read-only plan (plan BLOCKED recommendation) is consistent with this.
- Current repo says production self-hosting is not officially supported.
- Plan's `PHOENIX_PORT` name conflicts with the chart's `PHOENIX_HTTP_PORT` (corrected in plan.md).

## Contradictions with plan.md

- plan.md section 4 step 6 ENV `PHOENIX_PORT=13000`: chart uses `PHOENIX_HTTP_PORT`. Corrected in plan.md.
- plan.md section 7 step 2 said the port variable name is UNVERIFIED: chart confirms `PHOENIX_HTTP_PORT`. Corrected in plan.md.
- plan.md section 3 suggests `hexpm/elixir` builder; upstream uses `firezone/elixir:${ELIXIR_VERSION}-otp-${OTP_VERSION}`. Not changed (plan's choice; the upstream image is not verified as available for glibc).
