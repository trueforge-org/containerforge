# traggo.net docs (install, configuration, home)

**Source URL(s) + fetch date** (fetched 2026-11-26)
- https://traggo.net/install/ (parent page; sections below)
- https://traggo.net/config/ (followed from install page, section "Configuration")
- https://traggo.net/ (home page, section "Home")
- Not followed: https://traggo.net/dev/setup/ (developer setup, not relevant to install/config) and the Terminology, First Login, Reverse Proxy pages.

## Install (https://traggo.net/install/)

**Install methods:** Docker (multi-arch), prebuilt binary from GitHub releases, Arch Linux (AUR, page says "TODO"), source (build docs).

**Docker**
- Multi-arch: amd64, 386, ppc64le, s390x, arm64, arm v7 (Raspberry Pi).
- Run: `docker run -p 80:3030 -v /opt/traggo/data:/opt/traggo/data traggo/server:latest`
- Compose: image `traggo/server:latest`, ports `3030:3030`, volume `./traggodata:/opt/traggo/data`, env `TRAGGO_DEFAULT_USER_NAME` and `TRAGGO_DEFAULT_USER_PASS` to set the admin credentials.

**Binary (example v0.0.9, 64-bit Linux):** download zip from releases, unzip, `chmod +x`, run (example uses sudo). The example version is outdated.

**Configuration and login:** change the admin user's default password before starting the server. Credentials are overridden with the two env vars above. Database location is set with `TRAGGO_DATABASE_CONNECTION`.

**Data and port:** listens on 3030 by default. Docker example maps to host 80. SQLite is stored in `/opt/traggo/data` in the Docker setup.

## Configuration (https://traggo.net/config/)

**Precedence (first definition wins):** env vars, then `.env.local` and `.env` next to the binary, then `$HOME/.config/traggo/server.ini`, then `/etc/traggo/server.ini`.

| Variable | Default | Meaning |
|---|---|---|
| `TRAGGO_PORT` | `3030` | HTTP port |
| `TRAGGO_DEFAULT_USER_NAME` | `admin` | initial account name |
| `TRAGGO_DEFAULT_USER_PASS` | `admin` | initial account password |
| `TRAGGO_PASS_STRENGTH` | `10` | bcrypt strength |
| `TRAGGO_LOG_LEVEL` | `info` | debug, info, warn, error, fatal, panic |
| `TRAGGO_DATABASE_DIALECT` | `sqlite3` | only supported dialect listed |
| `TRAGGO_DATABASE_CONNECTION` | `data/traggo.db` | sqlite file path |

- Default login: `admin` / `admin`. Docs recommend changing both.
- File config options are shown commented out; they need uncommenting to take effect.

## Home (https://traggo.net/)

Traggo is a self-hosted, tag-based time tracking tool: record time spans and label them with tags instead of tasks. Dashboards with diagrams, list and calendar views, multiple UI themes, basic user management. Versioning follows SemVer. Top-level links: Install, Configuration, Development (dev setup, building from source, timezones), Terminology, First Login, Reverse Proxy.
