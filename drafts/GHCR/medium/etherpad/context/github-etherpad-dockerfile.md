# ether/etherpad Dockerfile (pinned commit)

Source URL(s): https://raw.githubusercontent.com/ether/etherpad/844729c6b9e68d593da9928141e6e2daced53ec9/Dockerfile (fetched 2026-11-27; blob URL is the same content)

## What it is
Multi-stage Node image for Etherpad. Upstream repo: https://github.com/ether/etherpad (Apache-2.0 per plan).

## Build args
| Arg | Default | Use |
| --- | --- | --- |
| BUILD_ENV | git | `git` (copy .git in) or `copy` (no git metadata, e.g. tarballs) |
| PnpmVersion | 12.4.2 | pnpm pinned via npm global install; must be redeclared per stage |
| TIMEZONE | empty | installs tzdata when set |
| SETTINGS | ./settings.json.docker | copied to `settings.json` |
| ETHERPAD_PLUGINS | empty | space-separated plugin names installed at build |
| ETHERPAD_LOCAL_PLUGINS | empty | local plugin paths |
| ETHERPAD_GITHUB_PLUGINS | empty | GitHub plugin names |
| INSTALL_SOFFICE | empty | any value installs libreoffice + openjdk8-jre |
| EP_HOME | empty | useradd home dir override |
| EP_UID | 5001 | etherpad user uid |
| EP_GID | 0 | etherpad group gid |
| EP_SHELL | empty | useradd shell |
| EP_DIR | /opt/etherpad-lite | app dir |
| http_proxy / https_proxy / no_proxy | empty | build proxies |

## Stages
- `adminbuild` (node:24-alpine): pnpm install, `pnpm run build:ui`.
- `build` (node:24-alpine): removes yarn, npm; installs pnpm, `ca-certificates git`, creates user `etherpad`; `USER etherpad`; WORKDIR `/opt/etherpad-lite`.
- `build_git` / `build_copy` selected by BUILD_ENV.
- `development`: runs `bin/installDeps.sh`, optional plugin install.
- `production` (final): `NODE_ENV=production`, `ETHERPAD_PRODUCTION=true`, `pnpm store prune`, copies `settings.json`.

## Runtime
- USER etherpad (non-root by default, uid 5001).
- EXPOSE 9001.
- HEALTHCHECK: `wget -qO- http://127.0.0.1:9001/health | grep -E "pass|ok|up"` every 5s.
- CMD: `sh -c "cd src && exec node --require tsx/cjs node/server.ts"` (bypasses pnpm at runtime on purpose).
- pnpm env `pnpm_config_pm_on_fail=ignore` set in build stage.

## Gotchas
- Each build stage that installs pnpm must redeclare `ARG PnpmVersion` or it installs latest.
- Docker-compose named volume over `src/plugin_packages`: dir must exist in image, owned by etherpad.
