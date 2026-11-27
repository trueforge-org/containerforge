# Docker Hub: shenxn/protonmail-bridge

Source URL(s):
- https://hub.docker.com/v2/repositories/shenxn/protonmail-bridge/
- https://hub.docker.com/v2/repositories/shenxn/protonmail-bridge/tags?page_size=10
Fetched: 2026-11-27

## Repository
| Key | Value |
| --- | --- |
| pull_count | 2325258 |
| star_count | 23 |
| last_updated | 2025-04-02 |
| description | ProtonMail IMAP/SMTP Bridge Docker container (unofficial) |
| tag count | 92 |

## Tag types (from README in full_description)
- `deb`: built from the official .deb release, amd64 only. Tags: `latest`, `[version]`.
- `build`: built from source (proton-bridge repo), amd64, arm64, arm/v7 (riscv64 also present). Tags: `build`, `[version]-build`.
- ARMv7 note: builds newer than 1.4.5-build had an arm/v7 parser problem (old README text).

## Tags seen (page_size=10)
| Tag | Arch | Last pushed |
| --- | --- | --- |
| latest (OCI index, digest 3717b444...) | amd64 + others | 2025-04-02 |
| 3.19.0-build | multi-arch index | 2025-04-02 |
| build | multi-arch | 2025-04-02 |
| 3.19.0-1 | amd64 (digest in chart) | 2025-04-02 |
| 3.18.0-build, 3.18.0-1, 3.17.0-build, 3.17.0-1, 3.16.0-1, 3.12.0-1 | older | older |

## Run / init (README)
- Init: `docker run --rm -it -v protonmail:/root shenxn/protonmail-bridge init`, then CLI `login`, `info`, `exit`.
- Run: `docker run -d -v protonmail:/root -p 1025:25/tcp -p 1143:143/tcp shenxn/protonmail-bridge`.
- Local-only publish suggested: `-p 127.0.0.1:1025:25/tcp -p 127.0.0.1:1143:143/tcp`.
- Credentials are read from the bridge CLI `info` output, not env vars (README: env vars not used because of 2FA support).

## Gotchas
- Last image push 2025-04-02; upstream release is newer (see GitHub release file).
