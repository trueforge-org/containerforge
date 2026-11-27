# linuxserver/docker-fleet readme-vars.yml

Source URL (fetched 2026-11-27, pinned commit):
- https://raw.githubusercontent.com/linuxserver/docker-fleet/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/readme-vars.yml

## What it is
- Project: fleet. Upstream: https://github.com/linuxserver/fleet.
- Web UI that lists maintained images from one or more owned repos.
- Category: Docker. Base: baseimage-alpine 3.21.
- Init services: `svc-cron`, `svc-fleet`.

## Deprecation
- Deprecated, changelog entry 03.06.25: container and app retired (cannot sustain development).

## Arch
| Arch | Tag |
| --- | --- |
| x86_64 | amd64-latest |
| arm64 | arm64v8-latest |

## Env vars
| Name | Default / example | Required | Notes |
| --- | --- | --- | --- |
| `fleet_admin_authentication_type` | `DATABASE` | yes | `DATABASE` or `PROPERTIES` |
| `fleet_database_url` | `jdbc:mariadb://<url>:3306/fleet` | yes | full JDBC URL |
| `fleet_database_username` | `fleet_user` | yes | needs GRANT permissions |
| `fleet_database_password` | `dbuserpassword` | yes | |
| `fleet_admin_secret` | `randomstring` | no | password key derivation |

## Volumes / ports
- `/config`: main config file plus rolling logs.
- Port 8080 HTTP.

## Other
- Read-only rootfs: supported. Non-root: supported.
- Setup: `http://<ip>:8080`. With DATABASE auth, create first user at `/setup` (page disappears; restart advised), log in at `/login`.

## Changelog (recent)
- 03.06.25 deprecated; 24.12.24 Alpine 3.21; 04.06.24 Alpine 3.20; 20.03.24 Alpine 3.19; 01.04.19 initial.
