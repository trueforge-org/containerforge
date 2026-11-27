# soft-serve README (main)

## Source URL(s) + date
- https://raw.githubusercontent.com/charmbracelet/soft-serve/main/README.md (fetched via WebFetch summary)
- Fetched 2026-11-27

## Status
- SUNSET: "No further security updates will be applied"; forks encouraged. Code remains MIT.

## What it is
- Self-hosted Git server with SSH TUI; single binary `soft`. Clone over SSH, HTTP, Git. Git LFS over HTTP and SSH.

## Default ports
- SSH `:23231`, HTTP `:23232`, Git daemon `:9418`, Stats `:23233`

## Data / config
- `soft serve` creates a `data` dir (repos, SSH keys, DB). Override with `SOFT_SERVE_DATA_PATH`.
- Config `config.yaml` in data dir by default; `SOFT_SERVE_CONFIG_LOCATION` for custom path (file must exist, else default generated).
- DB: SQLite `soft-serve.db` (Postgres supported).
- Env prefix `SOFT_SERVE_` + uppercase key (e.g. `SOFT_SERVE_NAME`, `SOFT_SERVE_SSH_LISTEN_ADDR`, `SOFT_SERVE_SSH_KEY_PATH`, `SOFT_SERVE_HTTP_LISTEN_ADDR`, `SOFT_SERVE_HTTP_PUBLIC_URL`, `SOFT_SERVE_GIT_MAX_CONNECTIONS`, `SOFT_SERVE_ANON_ACCESS`, `SOFT_SERVE_ALLOW_KEYLESS`, `SOFT_SERVE_DEFAULT_REPO`).

## First run
- git must be installed.
- `SOFT_SERVE_INITIAL_ADMIN_KEYS` = SSH public key(s) → admin. An `admin` user is created.
- `SOFT_SERVE_DEFAULT_REPO` creates an empty public repo at boot.

## Access defaults
- `anon-access` default `read-only` (others: no-access, read-write, admin-access); `allow-keyless` default `true`.
- Dev-only: `SOFT_SERVE_ANON_ACCESS=admin-access` + `SOFT_SERVE_ALLOW_KEYLESS=true` = unauthenticated admin. Never on untrusted networks.

## Other defaults
- SSH idle timeout 120s; Git idle 3s; Git max connections 32; LFS on; SSH LFS transfer off; mirror pull `@every 10m`; SSH strict host key `accept-new`.
- Old SHA-1 RSA keys only; Ed25519 recommended.

## Docker
- Docker image exists; README links `docker.md` (not fetched).

## Install options
- Homebrew, Winget, pacman, Nix, apt, yum/dnf, release binaries, `go install`.
