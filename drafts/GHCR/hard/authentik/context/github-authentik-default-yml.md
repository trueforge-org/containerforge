# authentik default config (authentik/lib/default.yml)

Source URL(s) + date: https://raw.githubusercontent.com/goauthentik/authentik/98ec4a7684fcb0cccfe78888a12df1df1ad938be/authentik/lib/default.yml (fetched 2026-11-27)

## Listen ports (defaults)
| Key | Value |
| --- | --- |
| listen.http | [::]:9000 |
| listen.https | [::]:9443 |
| listen.ldap | [::]:3389 |
| listen.ldaps | [::]:6636 |
| listen.radius | [::]:1812 |
| listen.metrics | [::]:9300 |
| listen.debug | 0.0.0.0:9900 |
| listen.debug_py | 0.0.0.0:9901 |

## Key defaults
| Key | Default |
| --- | --- |
| postgresql.host | localhost |
| postgresql.name / user | authentik / authentik |
| postgresql.port | 5432 |
| postgresql.password | `env://POSTGRES_PASSWORD` (indirection via env) |
| postgresql.sslmode | disable |
| log_level | info |
| web.workers / web.threads | 2 / 4 |
| web.path / base_url | / / "" |
| email.host / port | localhost / 25 |
| email.from | authentik@localhost |
| error_reporting.enabled | false |
| disable_update_check | false |
| disable_startup_analytics | false |
| outposts.container_image_base | ghcr.io/goauthentik/%(type)s:%(version)s |
| events.context_processors.geoip | /geoip/GeoLite2-City.mmdb |
| events.context_processors.asn | /geoip/GeoLite2-ASN.mmdb |
| cert_discovery_dir | /certs |
| blueprints_dir | /blueprints |
| email.template_dir | /templates |
| compliance.fips.enabled | false |
| tenants.enabled | false |

## Gotchas
- Default Postgres host is localhost; the container needs postgresql config set (env or config file).
- Defaults point GeoIP to /geoip, matching the upstream image's /geoip copy.
- Env override convention for these keys was not read in this file.
