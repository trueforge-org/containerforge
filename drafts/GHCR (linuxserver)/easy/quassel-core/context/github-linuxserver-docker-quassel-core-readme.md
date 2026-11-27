# linuxserver/docker-quassel-core README (master)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-quassel-core/master/README.md (fetched 2026-11-27)

## DEPRECATION
- "This image is deprecated. We will not offer support for this image and it will not be updated."

## What it is
- Quassel-core: IRC core daemon. Requires a desktop client to configure. Always on, keeps identity; backlog downloaded by client.

## Environment variables
| Var | Usage |
| --- | --- |
| PUID / PGID | UserID / GroupID (example 1000) |
| TZ | timezone |
| UMASK | optional umask override |
| RUN_OPTS | set `--config-from-environment` for stateless config |
| DB_BACKEND | `SQLite` (default example) or `PostgreSQL` |
| DB_PGSQL_USERNAME / DB_PGSQL_PASSWORD / DB_PGSQL_HOSTNAME / DB_PGSQL_PORT | PostgreSQL connection |
| AUTH_AUTHENTICATOR | `Database` or `LDAP` |
| AUTH_LDAP_HOSTNAME / AUTH_LDAP_PORT / AUTH_LDAP_BIND_DN / AUTH_LDAP_BIND_PASSWORD / AUTH_LDAP_FILTER / AUTH_LDAP_UID_ATTRIBUTE | LDAP auth |
| FILE__<VAR> | read var from file (Docker secrets) |

## Run options (via RUN_OPTS)
- `--strict-ident`, `--ident-daemon` (bool)
- `--ident-port "10113"`, `--ident-listen "::,0.0.0.0"`
- `--ssl-cert /config/keys/cert.crt`, `--ssl-key /config/keys/cert.key`, `--require-ssl` (bool)

## Ports
- `4242` core port (default; "default: 4242").
- `10113` optional ident port (`113:10113` in examples).

## Volumes/paths
- `/config`: database and core config storage. Settings persist here.

## User/UID
- PUID/PGID mapping (example 1000:1000).

## Healthcheck
- Not documented.

## Gotchas
- First connection: quassel client creates admin user and picks SQLite (Quassel limitation for the README setup flow).
- Example run uses `-e RUN_OPTS='--config-from-environment'` and `-e DB_BACKEND=SQLite` in minimal example.
