# Upstream README: bastienwirtz/homer @ b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2

Source URL(s): https://raw.githubusercontent.com/bastienwirtz/homer/b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2/README.md (fetched 2026-11-27)

## What it is
Homer: static HTML/JS dashboard driven by a YAML config (`assets/config.yml`). Apache-2.0. Must be served over HTTP (not file://).

## Install
- Docker: `b4bz/homer:latest`, bind mount config dir to `/www/assets`, port 8080, `--user :` to override uid.
- Release tarball: `https://github.com/homer-dashboard/homer/releases/latest/download/homer.zip` (asset name `homer.zip`); extract; `cp assets/config.yml.dist assets/config.yml`; serve with any web server.
- Manual build: `pnpm install && pnpm build`, output in `/dist`.

## Env vars
| var | default | note |
| --- | --- | --- |
| INIT_ASSETS | 1 | install example config and assets; needs writable config dir |
| SUBFOLDER | null | host under sub-path, e.g. `/homer` |
| PORT | 8080 | internal port |
| IPV6_DISABLE | 0 | 1 disables IPv6 listen |

## Gotchas
- Container runs as uid/gid 1000 by default.
- Release page for v26.11.4 was not parsed (see README.md failures).
