# Source: sytone/obsidian-remote README (main)

Source URL(s) + date: https://raw.githubusercontent.com/sytone/obsidian-remote/main/README.md (fetched 2026-11-27, 13.6 KB)

## Run
- `docker run` examples: `-p 8080:8080`, `-v <host>/vaults:/vaults`, `-v <host>/config:/config`, image `ghcr.io/sytone/obsidian-remote:latest`.
- Access: http://localhost:8080/ ; README warns not to expose unsecured to the web.

## Ports
| Port | Purpose |
| --- | --- |
| 8080 | HTTP Obsidian Web Interface |

## Volumes
| Path | Purpose |
| --- | --- |
| /vaults | Obsidian vaults |
| /config | Obsidian configuration and ssh data for obsidian-git |

## Env vars (README table)
| Var | Default | Notes |
| --- | --- | --- |
| PUID | 911 | container user ID |
| PGID | 911 | container group ID |
| TZ | Etc/UTC | |
| DOCKER_MODS | (none) | linuxserver mods, e.g. universal-git |
| INSTALL_PACKAGES | (none) | needs universal-package-install mod |
| CUSTOM_PORT | 8080 | internal HTTP port |
| CUSTOM_USER | abc | HTTP Basic auth username |
| PASSWORD | abc | HTTP Basic auth password; README also says no auth if unset (conflict in README) |
| SUBFOLDER | (none) | reverse-proxy subfolder, slashes required |
| TITLE | "KasmVNC Client" | page title (README text; Dockerfile sets "Obsidian v<ver>") |
| FM_HOME | /config | file manager landing dir |

## Gotchas
- README TITLE default ("KasmVNC Client") conflicts with Dockerfile ENV TITLE ("Obsidian v0.15.9").
- README PASSWORD default "abc" vs "no auth if unset" text: conflict within README.
