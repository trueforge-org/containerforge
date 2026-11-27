# ErsatzTV docs (Introduction, Installation, Networking)

Source URL(s) (fetched 2026-11-27):
- https://ersatztv.org/docs (Introduction)
- https://ersatztv.org/docs/installation
- https://ersatztv.org/docs/networking

## What it is
ErsatzTV: configure and stream custom live channels from a media library.

## Important
- The site banner and nav say "ErsatzTV Legacy" and "Legacy Docs". Docs describe the Legacy line. The installation page points to the latest release page and to a separate "legacy-develop-builds" repo. Check which product line the image follows before relying on these docs.
- Installation page: Docker images plus pre-built binaries for Windows x64, macOS x64/arm64, Linux x64/arm64. Version naming example in docs: `v26.11.0-f8410286-develop` for a develop build after v26.10.0. Newer versions can change DB schema and config (not backwards compatible).

## Ports (Networking page)
| Env | Meaning |
| --- | --- |
| (default) | port 8409 for all requests (management and streaming) |
| ETV_UI_PORT | separate port for all requests, management and streaming |
| ETV_STREAMING_PORT | separate port for streaming only; blocks management requests |

- OIDC (e.g. Pocket ID, Keycloak, Authelia, Auth0) can secure the management interface (env vars on that page, not fully extracted).
- JWT can secure streaming requests; access token can be passed as `?access_token=` on e.g. `/iptv/channels.m3u`.

## Gotchas
- Default port 8409 is confirmed by docs (the Dockerfile does not EXPOSE it).
- Env names ETV_UI_PORT and ETV_STREAMING_PORT come from the networking docs only.
- Installation and Networking pages were the only follow-ups (2 of max 3); the Media/Advanced pages were not fetched.
