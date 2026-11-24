# firezone — implementation plan

> Source: ./draft.md · Target: apps/firezone/ · Difficulty: hard (Elixir release, WireGuard, needs NET_ADMIN) · Role: main · Verified on 2026-11-23
>
> **Recommendation: BLOCKED for a rootless, read-only port.** The image in the draft (0.7.36) is the legacy omnibus Firezone, whose start script creates a kernel WireGuard interface and nftables rules. See section 10 before spending build effort.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 0.7.36 (git tag `0.7.36`, commit `dc71329fa007942ed32c69bd820f66b94cf5a5cc`, a lightweight tag, so it is not a GitHub "release" object). It is the newest `0.7.x` tag found (0.7.36, 0.7.35, 0.7.34, ...). The draft's tag matches |
| Newer upstream | Firezone 1.x (releases `1.0.0` to `1.0.5` in April/May 2024, then component-wise tags such as `gateway-1.6.5`, `gui-client-1.5.21`, `headless-client-1.5.16`, `relay`) is a different architecture: separate portal (api, web, domain), relay and gateway services, no kernel WireGuard in the portal. No release of the old omnibus line after 0.7.36 exists; it is end of life |
| Renovate | `datasource=github-tags depName=firezone/firezone versioning=loose` would pick up 1.x/`gateway-*` tags and break the pin. Needs `allowedVersions=/^0\.7\./` in the renovate comment or the dependency should be left unmanaged (UNVERIFIED how renovate parses mixed tags). Recommend `renovate: ... allowedVersions=/^0\.7\.\d+$/` |
| License | At the 0.7.36 ref the root `LICENSE` is Apache License 2.0 (verified by fetching the file at that commit). Bake `Apache-2.0`. Current `master` has Elastic License 2.0 for the Elixir portal, which does NOT apply to 0.7.36 (verified root LICENSE only; sub-directory licenses UNVERIFIED) |
| Source URL | https://github.com/firezone/firezone (tarball `https://github.com/firezone/firezone/archive/refs/tags/${VERSION}.tar.gz`; tag has no `v` prefix) |
| Per-arch downloads | None (no prebuilt artifacts). Compile on amd64 and arm64 (draft: compile for both) |
| Checksum source | None for source tags; pin by tag/commit only |
| Upstream Dockerfile reviewed | `Dockerfile.prod` at the commit above. Builder `firezone/elixir:1.14.3-otp-25.2.1` (alpine 3.16.3 based), `apk add nodejs yarn build-base git python3`, `MIX_ENV=prod`, `mix deps.get --only prod`, `mix deps.compile`, `yarn install --frozen-lockfile && yarn deploy` in `apps/fz_http/assets`, `mix phx.digest`, `mix compile`, `mix release`. Runner `alpine:3.16.3` with `apk add -u --no-cache nftables libstdc++ ncurses-libs openssl`, `COPY --from=builder /app/_build/prod/rel/firezone ./`, `CMD ["/app/bin/server"]`. Runs as root. `.tool-versions`: nodejs 18.16.0, elixir 1.14.3-otp-25, erlang 25.2.1 |
| Entry script | `rel/overlays/bin/server`: `source bootstrap`, `./firezone eval FzHttp.Release.migrate`, optional `FzHttp.Release.create_admin_user` when `RESET_ADMIN_ON_BOOT=true`, `exec ./firezone start`. `bootstrap` creates the WireGuard interface (`ip link add wg-firezone type wireguard`, assigns addresses/routes, `set mtu`), generates a SAML self-signed cert and telemetry id in `/var/firezone` |
| Defaults in bootstrap | `WIREGUARD_INTERFACE_NAME=wg-firezone`, `WIREGUARD_IPV4_ADDRESS=10.3.2.1`, `WIREGUARD_IPV4_ENABLED=true`, `WIREGUARD_IPV4_NETWORK=10.3.2.0/24`, `WIREGUARD_IPV6_ADDRESS=fd00::3:2:1`, `WIREGUARD_IPV6_ENABLED=true`, `WIREGUARD_IPV6_NETWORK=fd00::3:2:0/120`, `WIREGUARD_MTU=1280` |
| Config keys (`apps/fz_http/lib/fz_http/config/definitions.ex`) | `external_url`, `phoenix_http_port` (compose default 13000), `phoenix_listen_address` (default `0.0.0.0`), `database_host` (default `postgres`), `database_port` (5432), `database_name` (`firezone`), `database_user` (`postgres`), `database_password`, `database_ssl_enabled`, `default_admin_email`, `default_admin_password`, `guardian_secret_key`, `database_encryption_key`, `secret_key_base`, `live_view_signing_salt`, `cookie_signing_salt`, `cookie_encryption_salt`, `wireguard_port` (compose default 51820), `wireguard_private_key_path`, `wireguard_interface_name`, `reset_admin_on_boot`, `telemetry_enabled`. The runtime env var name is the upper-cased key (UNVERIFIED; the Firezone env-var docs were not fetched) |
| Ports | portal HTTP `13000/tcp` (compose `PHOENIX_PORT:-13000`, behind Caddy on 80/443; the container itself does not terminate TLS), WireGuard `51820/udp`. The draft's 80/443 guess is wrong for the container |
| Data | `/var/firezone` (WireGuard private key `private_key`, `saml.key`/`saml.crt`, `.tid`) |
| Capabilities | Upstream compose adds `NET_ADMIN` (and `SYS_MODULE` per draft) plus `sysctls` for forwarding (UNVERIFIED which) |

## 2. Target layout

```
apps/firezone/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh          replaces upstream bin/server + bootstrap with rootless-safe logic
```

No `defaults/` needed unless secrets seeding templates are wanted (not needed). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Runtime stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (the draft's base; no Elixir base exists). Build stage: an Elixir 1.14.3 / OTP 25.2.1 image on Debian/Ubuntu glibc, for example `hexpm/elixir:1.14.3-erlang-25.2.1-ubuntu-jammy-<date>` (exact tag UNVERIFIED; check Docker Hub `hexpm/elixir`). A release built on glibc 2.35 (jammy) runs on 26.04 because glibc is backward compatible. Closest sibling for multi-stage compile-and-copy: `apps/kasmvnc`; no Elixir sibling exists.

## 4. Dockerfile

1. Build stage `FROM <hexpm/elixir 1.14.3 / OTP 25.2.1 glibc image> AS builder`; `ARG VERSION`; `apt-get install -y --no-install-recommends build-essential git python3 curl ca-certificates nodejs npm` then `npm install -g yarn`; Node must be 18.x (`.tool-versions` says 18.16.0; Ubuntu apt Node may differ, so use the base's node or `n`; UNVERIFIED).
2. `curl -fL https://github.com/firezone/firezone/archive/refs/tags/${VERSION}.tar.gz | tar xz --strip-components=1 -C /src`. `ENV MIX_ENV=prod HEX_HOME=/tmp/hex MIX_HOME=/tmp/mix VERSION=${VERSION}`.
3. Follow upstream Dockerfile.prod verbatim: `mix local.hex --force && mix local.rebar --force`, copy `mix.exs mix.lock` and the three umbrella apps (`fz_http`, `fz_vpn`, `fz_wall`), `mix deps.get --only prod`, `mix deps.compile`, `cd apps/fz_http/assets && yarn install --frozen-lockfile && yarn deploy && cd .. && mix phx.digest`, `mix compile`, `mix release`. The `fz_vpn` app may compile native code, so arm64 needs a check (UNVERIFIED).
4. Final stage (ubuntu line), `ARG VERSION`, `USER root`: `apt-get install -y --no-install-recommends iproute2 nftables libstdc++6 libncurses6 openssl libtinfo6 ca-certificates` (package list derived from upstream's apk list `nftables libstdc++ ncurses-libs openssl` plus `ip` used by bootstrap; names UNVERIFIED on 26.04; do not reinstall `curl`/`ca-certificates` already in base).
5. `COPY --from=builder /src/_build/prod/rel/firezone /app` (the release must be relocatable; set `RELEASE_TMP=/tmp/release` so Erlang does not write into `/app`), licenses to `/usr/share/licenses/firezone/` (`/src/LICENSE`).
6. `ENV HOME=/config RELEASE_TMP=/tmp/release RELEASE_DISTRIBUTION=none ERL_CRASH_DUMP=/tmp/erl_crash.dump PHOENIX_PORT=13000` (`RELEASE_DISTRIBUTION=none` is a standard Mix release switch to avoid epmd; UNVERIFIED that Firezone 0.7 tolerates it, it uses clustering only in 1.x).
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 13000 51820/udp`, `VOLUME /config` (move `/var/firezone` to `/config`), `WORKDIR /app`. Do not add `setcap` unless the capability decision in section 10 is taken (then `setcap cap_net_admin+ep` on `ip` and `nft` plus Docker `cap_add` is still insufficient for non-root without ambient caps, so this path is likely a dead end).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "firezone" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=firezone/firezone versioning=loose allowedVersions=/^0\.7\.\d+$/
  default = "0.7.36"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/firezone/firezone" }
```

Standard `group "default"`, `image` (arg `VERSION`, OCI labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64). Also pass builder tool versions as args (`ELIXIR_VERSION=1.14.3`, `OTP_VERSION=25.2.1`) so Dockerfile and bake stay aligned. `docker buildx bake --print`.

## 6. settings.yaml

- `upstream_env_url: "https://github.com/firezone/firezone"`.
- ports: `13000` tcp `required: false` (portal; Caddy/ingress in front), `51820` udp `required: false`.
- env (only names backed by `definitions.ex`/`bootstrap`; mark as UNVERIFIED that the upper-cased names are read): `EXTERNAL_URL` (default `""`, required true: handled by start.sh which falls back to `http://localhost:13000`, so set `required: false` unless start.sh refuses to start), `DATABASE_HOST` (`""`), `DATABASE_PORT` (`5432`), `DATABASE_NAME` (`firezone`), `DATABASE_USER` (`postgres`), `DATABASE_PASSWORD` (`""`), `DEFAULT_ADMIN_EMAIL` (`""`), `DEFAULT_ADMIN_PASSWORD` (`""`), `SECRET_KEY_BASE`, `GUARDIAN_SECRET_KEY`, `DATABASE_ENCRYPTION_KEY`, `LIVE_VIEW_SIGNING_SALT`, `COOKIE_SIGNING_SALT`, `COOKIE_ENCRYPTION_SALT` (all default `""`; start.sh generates and persists them under `/config`), `WIREGUARD_PORT` (`51820`), `WIREGUARD_INTERFACE_NAME` (`wg-firezone`), `TELEMETRY_ENABLED` (`false`, deviation: upstream default is true), `TZ`.
- volumes: `/config` required.
- dependencies: `postgresql` ✅ (apps/postgresql exists).

## 7. start.sh

1. `mkdir -p /config/firezone /tmp/release`. Persist generated secrets (`SECRET_KEY_BASE`, `GUARDIAN_SECRET_KEY`, `DATABASE_ENCRYPTION_KEY`, the three salts) in `/config/firezone/secrets.env` created once with `umask 077` and sourced on every start; user-provided env wins. Never log them or put them on the command line.
2. Default `EXTERNAL_URL=http://localhost:13000`, `PHOENIX_HTTP_PORT=13000` (the name of the port variable is UNVERIFIED), `DATABASE_HOST` unchanged (upstream default `postgres`).
3. WireGuard private key path: set `WIREGUARD_PRIVATE_KEY_PATH=/config/firezone/private_key` (config key `wireguard_private_key_path`); the rootless-safe replacement for `/var/firezone`.
4. Wait up to 30 s for PostgreSQL with `nc -z` when `DATABASE_HOST` resolves; log and continue (retry loop), never `exit` on failure.
5. Skip the upstream `bootstrap` interface creation unless the process has `CAP_NET_ADMIN` (`ip link add` test); log `WireGuard interface setup skipped: missing NET_ADMIN`. SAML cert generation writes to `/config/firezone/saml.{key,crt}` only if missing (paths in `saml_keyfile_path`/`saml_certfile_path`).
6. `/app/bin/firezone eval FzHttp.Release.migrate` (applied every start, idempotent), then if `DEFAULT_ADMIN_EMAIL` and `DEFAULT_ADMIN_PASSWORD` are set and `RESET_ADMIN_ON_BOOT=true`: `eval FzHttp.Release.create_admin_user`.
7. `exec /app/bin/firezone start`.

Bind: Phoenix listens on `0.0.0.0` by default (`phoenix_listen_address`). Passwords stay in the environment.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql; full functional test not feasible in single-container suite
timeoutSeconds: 240
tcp:
- port: '13000'
filePaths:
- /app/bin/firezone
- /app/bin/server
```

The DB-dependency narrowing is allowed only if all three protocol criteria hold. (1) hard dependency on postgresql: yes (`dependencies:`), (2) will not start/fail health without it: Firezone runs `migrate` before `start`, so it will exit without a database, which makes the TCP probe fail; this is true only if start.sh does not tolerate a missing DB, (3) not feasible to wire a sidecar: unknown. If start.sh keeps retrying instead of exiting (as planned in section 7), the port is never opened and the TCP probe cannot pass either, so the realistic test is `filePaths` plus a runner such as `/app/bin/firezone version`. Decide after the first run, and keep the required comment above the narrowed assertions. UDP 51820 has no `tcp` probe type; list it in settings.yaml and document that no probe can cover it (UNVERIFIED whether forgetool supports UDP probes).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/firezone` (private key, saml cert/key, `.tid` telemetry id) | `/config/firezone/` |
| Erlang release tmp (`RELEASE_TMP`, `releases/*/`), crash dump | `/tmp/release`, `/tmp` |
| Kernel interface `wg-firezone`, routes, nftables rules (needs root + NET_ADMIN) | NOT remappable. Without the capability the VPN data plane cannot work |
| Hex/Mix caches at build | `/tmp` |

Draft expectations: chart runs UID 0 / PUID 0, `readOnlyRootFilesystem: false`, caps `NET_ADMIN` and `SYS_MODULE`, persistence `/var/firezone`. Reconciliation: UID 568 and read-only rootfs are feasible for the portal (Phoenix/Ecto) only; WireGuard and nftables require capabilities that a non-root user does not inherit in Docker/Kubernetes (no ambient capabilities), so a full port needs either `USER root` for that part (violates the repo rule `USER apps`) or a split into a portal-only image plus the separate gateway. `SYS_MODULE` should not be granted.

## 10. Risks, caveats and open questions

- **Blocker: root and capabilities.** `bin/server` sources `bootstrap`, which runs `ip link add ... type wireguard` and manages nftables; `set -e` makes a failure fatal. Non-root + NET_ADMIN does not work without ambient capabilities. A rootless port must disable that path (this plan skips it), leaving a portal that cannot terminate tunnels. Ask the maintainers whether a portal-only legacy image is useful.
- **End-of-life software.** 0.7.x is a legacy release line, superseded by 1.x with a different architecture; renovate will have nothing to update. Consider porting current 1.x components (gateway, relay, api, web) as separate apps instead; their image build and license (Elastic License 2.0 for the Elixir portal at master) need a separate plan.
- Env var names are inferred from config keys (UNVERIFIED mapping), and the HTTP port variable name is not confirmed; docs were not fetched.
- Elixir 1.14.3/OTP 25.2.1 builder image tag UNVERIFIED; building old OTP on arm64 may be slow or fail; `fz_vpn` native bits unknown.
- PostgreSQL is a hard dependency; no first-boot admin without `DEFAULT_ADMIN_EMAIL`/`DEFAULT_ADMIN_PASSWORD` (manual setup draft caveat).
- WireGuard needs host kernel support and the UDP port forwarded (draft caveat).
- The draft's ports 80/443 do not exist in the container; Caddy is separate.

## 11. Build and test steps

```sh
cd apps/firezone
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker network create firezone-probe-net
docker run -d --rm --name firezone-probe-db --network firezone-probe-net -e POSTGRES_PASSWORD=probe -e POSTGRES_USER=postgres -e POSTGRES_DB=firezone postgresql:<version>
docker run --rm -d --name firezone-probe --network firezone-probe-net --read-only --tmpfs /tmp \
  -e DATABASE_HOST=firezone-probe-db -e DATABASE_PASSWORD=probe \
  -v firezone-probe-config:/config firezone:0.7.36
docker logs -f firezone-probe
forgetool containers test --image firezone:0.7.36 --config ./apps/firezone/container-test.yaml
docker rm -f firezone-probe firezone-probe-db; docker volume rm firezone-probe-config; docker network rm firezone-probe-net
```

Also run once with an empty `/config` and no env (the container-test condition) and confirm it stays alive, logging a database wait. Readiness: migration finished, Phoenix log line for the endpoint listening on `0.0.0.0:13000`, no fatal crash dump. Cap at 10 rounds; if the missing-capability path is the only failure, record the app as `unfixable` for the data plane rather than weakening tests.

## 12. PR checklist

- Do not open the PR until the maintainers confirm the legacy 0.7.36 image should be ported; otherwise skip this app.
- Branch `feat/add-firezone`; commit `feat(firezone): add new container`; same PR title; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- State clearly what is untested: the WireGuard/nftables path (not supported rootless), arm64 build, env var name mapping, builder image tag, and any narrowed tests.
- Pre-completion: bake `--print` ok, Dockerfile/bake aligned (`VERSION`, `ELIXIR_VERSION`, `OTP_VERSION`), read-only rootfs and empty `/config` verified, no downstream consumers.
