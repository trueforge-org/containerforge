# GitHub yourselfhosted/slash (install docs, data path)

Source URL(s) + date:
- https://raw.githubusercontent.com/yourselfhosted/slash/main/docs/install.md
- https://raw.githubusercontent.com/yourselfhosted/slash/main/server/profile/profile.go
- Fetched 2026-11-27

## Install (docs/install.md)
- docker run: `docker run -d --name slash --publish 5231:5231 --volume ~/.slash/:/var/opt/slash yourselfhosted/slash:latest`
- Docker compose: upstream `docker-compose.yml` (data in volume `slash_slash`)
- Upgrade: back up `slash_prod.db`, `docker pull`, rerun

## Database
- Drivers: `sqlite` (default), `postgres`
- CLI flags: `--driver postgres --dsn 'postgresql://postgres:PASSWORD@localhost:5432/slash'`
- Env: `SLASH_DRIVER=postgres`, `SLASH_DSN=postgresql://...` (add `?sslmode=disable` if server has no SSL)

## Env / config (docs + profile.go)
| var | default / behaviour |
| --- | --- |
| SLASH_MODE | `prod` or `dev`; any other value becomes `dev` (profile.go). Image sets `prod`. |
| SLASH_PORT | 5231 |
| SLASH_DRIVER | `sqlite` default |
| SLASH_DSN | PostgreSQL DSN (secret) |
| Data dir | in `prod` mode with empty data, defaults to `/var/opt/slash` |

## Data path / SQLite (profile.go)
- In `prod`, if Data is empty: uses `/var/opt/slash` (Windows: `%ProgramData%\slash`).
- The data dir must already exist: `checkDataDir` does `os.Stat` and fails if missing.
- Relative data paths resolve against the binary's directory (`filepath.Dir(os.Args[0])`).
- SQLite DB file: `<data>/slash_<mode>.db` (e.g. `slash_prod.db`).

## Ports
- 5231 (docs and image default)

## Gotchas
- Pre-create the data directory before start (profile.go stat check).
- Relative data dirs are relative to the executable, not the CWD.
