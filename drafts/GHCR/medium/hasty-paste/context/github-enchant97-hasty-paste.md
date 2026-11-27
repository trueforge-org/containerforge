# Upstream: enchant97/hasty-paste (app/Dockerfile at ad6a831, README)

## Source URL(s) + date
- https://raw.githubusercontent.com/enchant97/hasty-paste/ad6a831789716dfdfde3a68e22ff5bb2ef1b0851/app/Dockerfile (fetched 2026-11-27; same as the blob URL)
- https://raw.githubusercontent.com/enchant97/hasty-paste/main/README.md (fetched 2026-11-27)
- Docs site https://hastypaste.docs.enchantedcode.co.uk/ linked from README (not fetched).

## What it is
- Hasty Paste II: paste sharing (plain/markdown/code), private/unlisted/public visibility, assets, expiry, user accounts, OpenID/OAuth2 SSO.
- License: code AGPL-3.0-or-later (`LICENSE.txt`), docs FDL-1.3-or-later, icon all rights reserved (README).

## Build (app/Dockerfile)
| Stage | Base | Steps |
| --- | --- | --- |
| node-base | `node:24-slim` | `PNPM_HOME=/pnpm`, PATH; `npm install --global corepack@latest`; `corepack enable` |
| node-build | node-base | `WORKDIR /opt/hasty-paste`; `COPY . .`; `pnpm install --frozen-lockfile` (cache mount `/pnpm/store`); `pnpm run build` |
| go-build | `golang:1.26-alpine` | `WORKDIR /opt/hasty-paste`; `COPY . .`; `go tool sqlc generate`; `go tool templ generate`; `CGO_ENABLED=0 GOOS=linux go build -o ./hasty-paste` |
| final | `gcr.io/distroless/static-debian12` | `WORKDIR /opt/hasty-paste`; copy `dist` (node-build) and `hasty-paste` binary (go-build) with `--link` |

- Build uses `go tool sqlc` and `go tool templ` (Go tool directives), so codegen needs no separate install.

## Entrypoint/flags
- `ENTRYPOINT ["./hasty-paste"]`, `CMD ["serve"]`.
- HEALTHCHECK: `--interval=2m --timeout=5s --start-period=20s --start-interval=5s --retries=3 CMD ["./hasty-paste","health-check"]`.

## Env vars (Dockerfile ENV)
| Name | Default |
| --- | --- |
| BIND__HOST | 0.0.0.0 |
| BIND__PORT | 8080 |
| DB_URI | sqlite:///opt/hasty-paste/data/db.sqlite |
| ATTACHMENTS_PATH | /opt/hasty-paste/data/attachments |

## Ports
- `EXPOSE 8080`.

## Volumes/paths
- `VOLUME /opt/hasty-paste/data` (DB and attachments live under it).
- Dist: `/opt/hasty-paste/dist`. Binary: `/opt/hasty-paste/hasty-paste`.

## User/UID
- No USER directive in this Dockerfile. Base `gcr.io/distroless/static-debian12` user not checked here (the `:nonroot` variant is a different tag). Set user explicitly if needed.

## Healthcheck
- See above (`health-check` subcommand).

## Version/asset naming
- Release API (`/releases/latest`) returned 403. Alternative HTML page `https://github.com/enchant97/hasty-paste/releases/tag/v2.5.1` returned title "Release V2.5.1". No `releases/download/v2.5.1/` asset links found in that page (no binary assets).
- Tag form `v2.5.1` (plan).

## Arch
- Not stated in fetched sources; Go and Node build are arch-neutral. Base images are multi-arch.

## Gotchas
- Final image is distroless (no shell); HEALTHCHECK uses the binary's own `health-check` subcommand, not curl.
- `docs/install.md` linked from the plan does not exist on main (404) or master (404).
- Chart's BIND__PORT = 10601 overrides the image default 8080.
