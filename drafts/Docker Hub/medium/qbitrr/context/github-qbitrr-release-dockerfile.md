# GitHub: Feramance/qBitrr Dockerfile, release, docs

Source URL(s):
- https://raw.githubusercontent.com/Feramance/qBitrr/master/Dockerfile
- https://api.github.com/repos/Feramance/qBitrr/releases/latest
- https://feramance.github.io/qBitrr (docs home; JS-rendered, only nav and intro captured)
Fetched: 2026-11-27

## Dockerfile
### Stage webui-build: node:26-bookworm
- `npm ci` in webui/, `npm run build` (output into qBitrr/static).

### Stage runtime: python:3.14-slim
| Item | Value |
| --- | --- |
| ARG | VERSION="5.14.9-4"; QBITRR_SOURCE_BUILD=0 (1 disables auto-update for source builds) |
| LABEL | Name, Maintainer, Version, org.opencontainers.image.source |
| apt | tini (PID 1), gosu, curl |
| ENV | QBITRR_DOCKER_RUNNING=69420, QBITRR_SOURCE_BUILD, PYTHONDONTWRITEBYTECODE=1, PYTHONUNBUFFERED=1, PYTHONOPTIMIZE=1 |
| install | `pip install ".[fast]"` from /app (copy of repo, plus static UI from webui stage) |
| user | groupadd -r qbitrr; useradd -r -g qbitrr -d /config -s /sbin/nologin qbitrr; /config and /app chowned to qbitrr |
| entrypoint | COPY docker-entrypoint.sh to /docker-entrypoint.sh (not fetched); `ENTRYPOINT ["/docker-entrypoint.sh"]` |
| WORKDIR | /config |
| EXPOSE | 6969 |
| CMD | `["python", "-m", "qBitrr.main"]` |

## Release (latest)
| Key | Value |
| --- | --- |
| tag_name | v5.14.9-4 |
| published_at | 2026-11-23 |
| prerelease | false |
| assets | qBitrr-5.14.9-4-macOS-latest-arm64.tar.gz (and other platform archives) |

## Docs (feramance.github.io/qBitrr)
- Sections: Getting Started (pip, Docker, native), Configuration, Features, Web UI (/ui), Advanced, Troubleshooting, Development. Sub-pages not fetched (budget/JS-rendered).

## Gotchas
- Dockerfile runs as root in entrypoint, drops to user qbitrr via gosu (per Dockerfile comment; entrypoint not verified).
- Upstream latest v5.14.9-4 is newer than chart pin v5.12.12.
- Config template is downloaded by the chart initContainer from master (unpinned).
