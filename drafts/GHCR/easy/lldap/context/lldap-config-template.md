# lldap_config.docker_template.toml (v0.6.3)

## Source URL(s) + date
- https://raw.githubusercontent.com/lldap/lldap/v0.6.3/lldap_config.docker_template.toml
- Fetched 2026-11-26

## What it is
Default config template for the Docker image. Every key can be overridden by an env var with prefix `LLDAP_` (nested via `__`).

## Config keys (defaults)
| Key | Default | Env override |
| --- | --- | --- |
| verbose | false | LLDAP_VERBOSE |
| ldap_host | 0.0.0.0 (commented) | LLDAP_LDAP_HOST |
| ldap_port | 3890 | LLDAP_LDAP_PORT |
| http_host | 0.0.0.0 (commented) | LLDAP_HTTP_HOST |
| http_port | 17170 | LLDAP_HTTP_PORT |
| http_url | http://localhost | LLDAP_HTTP_URL |
| assets_path | ./app (relative to workdir) | - |
| jwt_secret | REPLACE_WITH_RANDOM (commented) | LLDAP_JWT_SECRET or LLDAP_JWT_SECRET_FILE |
| ldap_base_dn | dc=example,dc=com | - |
| ldap_user_dn | admin | - |
| ldap_user_email | admin@example.com | - |
| ldap_user_pass | REPLACE_WITH_PASSWORD (commented; min 8 chars) | LLDAP_LDAP_USER_PASS or _FILE |
| force_ldap_user_pass_reset | false (commented; "always" allowed) | - |
| database_url | sqlite:///data/users.db?mode=rwc (ACTIVE default) | LLDAP_DATABASE_URL |
| key_file | /data/private_key (commented; auto-generated if missing) | LLDAP_KEY_FILE |
| key_seed | "RanD0m STR1ng" (ACTIVE, placeholder) | LLDAP_KEY_SEED |
| ignored_user_attributes / ignored_group_attributes | commented examples | - |
| [smtp_options] enable_password_reset | true | LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET |
| [smtp_options] server | smtp.gmail.com | LLDAP_SMTP_OPTIONS__SERVER |
| [smtp_options] port | 587 | LLDAP_SMTP_OPTIONS__PORT |
| [smtp_options] smtp_encryption | TLS (NONE, TLS, STARTTLS) | LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION |
| [smtp_options] user / password / from / reply_to | sender@gmail.com / password / "LLDAP Admin <sender@gmail.com>" / "Do not reply <noreply@localhost>" | LLDAP_SMTP_OPTIONS__USER / __PASSWORD / __FROM / __REPLY_TO |
| [ldaps_options] enabled | true | LLDAP_LDAPS_OPTIONS__ENABLED |
| [ldaps_options] port | 6360 | LLDAP_LDAPS_OPTIONS__PORT |
| [ldaps_options] cert_file / key_file | /data/cert.pem / /data/key.pem | - |
| [healthcheck_options] | http_host section (file truncated in fetch) | LLDAP_HEALTHCHECK_OPTIONS__HTTP_HOST |

## Ports
- 3890/tcp LDAP, 17170/tcp HTTP, 6360/tcp LDAPS (if enabled).

## Volumes/paths
- `/data` used for sqlite DB, private_key, LDAPS cert/key.

## Gotchas
- Template's active `key_seed` and `database_url` are the defaults; the image needs `LLDAP_KEY_SEED` / DB URL overrides for real use.
- LDAPS is enabled by default in the template (`enabled=true`, port 6360) while the TrueCharts chart does not expose it.
- Config file location and `assets_path` are relative to the working directory of the binary (`/app` in the image per chart command `/app/lldap`).
