# Upstream: Dictionarry-Hub/profilarr (README, LICENSE, latest release)

Source URL(s) + date:
- https://github.com/Dictionarry-Hub/profilarr (not fetched directly; README used)
- https://raw.githubusercontent.com/Dictionarry-Hub/profilarr/0583ee157985e8d69cb05f6047a3c4dda9f03b33/README.md (2026-11-27)
- https://raw.githubusercontent.com/Dictionarry-Hub/profilarr/0583ee157985e8d69cb05f6047a3c4dda9f03b33/LICENSE (2026-11-27)
- https://api.github.com/repos/Dictionarry-Hub/profilarr/releases/latest: 403. Alternative https://github.com/Dictionarry-Hub/profilarr/releases/latest (HTML) -> "Release v2.3.1"
- https://github.com/Dictionarry-Hub/profilarr/releases/tag/v2.3.1: covered by the alternative above

What it is: configuration management for Radarr and Sonarr. Syncs custom formats and quality profiles from git-based PCD repos.

License: AGPL-3.0 (LICENSE: GNU AFFERO GENERAL PUBLIC LICENSE Version 3).

Platforms: Docker linux/amd64 and linux/arm64. Sonarr v4 and v5 (v5 experimental), Radarr v5 and v6.

Env vars (README table):
| Name | Default | Purpose |
| --- | --- | --- |
| PUID | 1000 | user ID for file permissions |
| PGID | 1000 | group ID for file permissions |
| UMASK | 022 | file creation mask |
| PORT | 6868 | web UI port |
| AUTH | on | login on or off (oidc is deprecated alias for on) |
| OIDC_CLIENT_ID / OIDC_CLIENT_SECRET / OIDC_DISCOVERY_URL | - | SSO; all three must be set |
| ORIGIN | - | public URL behind reverse proxy; required for OIDC (callback `{ORIGIN}/auth/oidc/callback`) |
| PROFILARR_API_KEY | - | plaintext runtime secret for `X-Api-Key` auth |

Compose example from README: port `6868:6868`, volume `./config:/config`, env PUID/PGID.

Gotchas: ORIGIN must be set for OIDC. Chart sets AUTH and ORIGIN.
