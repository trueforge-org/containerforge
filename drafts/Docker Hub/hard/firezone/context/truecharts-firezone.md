# TrueCharts chart: firezone

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/firezone (chart values via raw `values.yaml`, fetched 2026-11-26)

## Image

- `repository`: `docker.io/firezone/firezone`
- `tag`: `0.7.36@sha256:6e65ebab1ddbdc8dfe8c6aa10defda1ea9b2b48e0f2b54772338f3e735be8a6f`
- `pullPolicy`: `IfNotPresent`

## Security

- `runAsUser: 0`, `runAsGroup: 0`, `PUID: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`. `privileged` not specified.
- Capabilities add: `NET_ADMIN`, `SYS_MODULE`. Drop: not specified.

## Persistence

- `config` -> `/var/firezone`, enabled. No `type`.

## Ports

- main: http, port `13000`.
- wireguard service: udp, port `51820`.

## Probes

- None defined.

## Env (main container, verbatim keys)

- `PHOENIX_HTTP_PORT` (from service main port), `EXTERNAL_URL` (chart value), `PHOENIX_SECURE_COOKIES`, `PHOENIX_EXTERNAL_TRUSTED_PROXIES`, `PHOENIX_PRIVATE_CLIENTS`
- `DATABASE_HOST` from secret `<release>-postgresqlcreds` key `plainhost`; `DATABASE_PORT` `5432`; `DATABASE_NAME` and `DATABASE_USER` from `dependencies.postgresql.depconfig`; `DATABASE_PASSWORD` from the same secret key `postgresql-password`; `DATABASE_SSL_ENABLED` `false`
- `RESET_ADMIN_ON_BOOT`, `DEFAULT_ADMIN_EMAIL` (chart values); `DEFAULT_ADMIN_PASSWORD` from secret `env-secrets`
- Secret refs from `firezone-secrets` (key equals env name): `GUARDIAN_SECRET_KEY`, `DATABASE_ENCRYPTION_KEY`, `SECRET_KEY_BASE`, `LIVE_VIEW_SIGNING_SALT`, `COOKIE_SIGNING_SALT`, `COOKIE_ENCRYPTION_SALT`
- Device and client defaults: `ALLOW_UNPRIVILEGED_DEVICE_MANAGEMENT`, `ALLOW_UNPRIVILEGED_DEVICE_CONFIGURATION`, `VPN_SESSION_DURATION`, `DEFAULT_CLIENT_PERSISTENT_KEEPALIVE`, `DEFAULT_CLIENT_MTU`, `DEFAULT_CLIENT_ENDPOINT`, `DEFAULT_CLIENT_DNS`, `DEFAULT_CLIENT_ALLOWED_IPS`, `MAX_DEVICES_PER_USER`
- Auth: `LOCAL_AUTH_ENABLED`, `DISABLE_VPN_ON_OIDC_ERROR`
- WireGuard: `WIREGUARD_PORT`, `WIREGUARD_IPV4_ENABLED` `true`, `WIREGUARD_IPV4_MASQUERADE`, `WIREGUARD_IPV6_ENABLED` `false`, `WIREGUARD_IPV6_MASQUERADE` `false`
- `CONNECTIVITY_CHECKS_ENABLED`, `CONNECTIVITY_CHECKS_INTERVAL`, `TELEMETRY_ENABLED`
- Pool size, SSL, SAML, OIDC and outbound email: commented out.

## Dependencies

- `postgresql`: enabled; `postgresqlUsername` and `postgresqlDatabase` both `firezone`; operator `pgVersion` 16. Comment: migrations break on PostgreSQL 18 (primary key `id` not NOT NULL).

## Secrets

- `env-secrets`: `DEFAULT_ADMIN_PASSWORD` from `firezone.admin.default_password`.

## Gotchas

- Chart uses `WIREGUARD_IPV6_ENABLED=false`, while bootstrap defaults to `true`. Chart choice.
- Chart requires NET_ADMIN and SYS_MODULE; plan rejects SYS_MODULE.
