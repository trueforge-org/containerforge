# Vikunja docs

Source URL(s) + fetch date: https://vikunja.io/docs/ · https://vikunja.io/docs/config-options · https://vikunja.io/docs/docker-walkthrough · fetched 2026-11-26

## What it is
- Task and project management app, self-hostable or hosted (Vikunja Cloud). Public API, CLI, webhooks, OpenID and LDAP auth.
- Install options: Docker (docker walkthrough, full docker example), build from sources (magefile), desktop packages, k8s hosting.

## Config options and defaults (config-options)
| Option | Default |
| --- | --- |
| service.interface | `:3456` |
| service.rootpath | working directory (falls back to the binary's directory) |
| service.publicurl | empty |
| service.secret | random per startup if unset (invalidates tokens on restart) |
| service.enableregistration | true |
| service.timezone | GMT |
| database.type | sqlite (also postgres, mysql/mariadb) |
| database.path | `./vikunja.db` |
| files.basepath | `./files` |
| log.enabled | true |
| log.path | `<rootpath>logs` |
| keyvalue.type | memory |
| redis.host | `localhost:6379` |

Env var naming: `VIKUNJA_` + uppercase path joined by underscores (`first.child` -> `VIKUNJA_FIRST_CHILD`). Env vars override the config file.

Config file search: rootpath, `/etc/vikunja`, `~/.config/vikunja`, cwd. `--config` pins one file.

## Docker walkthrough (compose example)
- Image `vikunja/vikunja`, published port `3456:3456`, volume `./files:/app/vikunja/files`, `restart: unless-stopped`.
- Env in the example: `VIKUNJA_SERVICE_PUBLICURL` (the public URL; include a non-standard port or account creation fails), `VIKUNJA_DATABASE_HOST` (db service name), `VIKUNJA_DATABASE_PASSWORD`, `VIKUNJA_DATABASE_TYPE=postgres`, `VIKUNJA_DATABASE_USER`, `VIKUNJA_DATABASE_DATABASE`, `VIKUNJA_SERVICE_SECRET` (must be a secure random value).
- Database example: `postgres:18`; volume `./db:/var/lib/postgresql`; healthcheck `pg_isready`.
- User: Vikunja runs as UID 1000 by default. The files directory must be writable by it. `PUID`/`PGID` have no effect; use Docker's `user:`.
- Image is `scratch`: no shell. `/tmp` must be writable for exports.

## Gotchas
- The example uses placeholder passwords and secrets. Replace them.
- The docs example `./db:/var/lib/postgresql` is a DB container detail, unrelated to the Vikunja image paths.
