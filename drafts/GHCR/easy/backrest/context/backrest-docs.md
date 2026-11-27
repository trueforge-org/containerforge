# Backrest docs (garethgeorge.github.io/backrest)

## Source URL(s) + date
- https://garethgeorge.github.io/backrest (home, fetched 2026-11-27)
- https://garethgeorge.github.io/backrest/introduction/getting-started (fetched 2026-11-27)

## What it is
- Web UI and orchestrator for restic; creates repos, browses snapshots, restores files, cron scheduling, command hooks, notifications.

## Install/build steps + deps
- Docs say: "Please refer to the GitHub README for platform-specific installation instructions." No install commands on the page.

## Ports
- Web UI at `http://localhost:9898` ("typically", configurable).

## Config files
- Linux/macOS: `~/.config/backrest/config.json`
- Windows: `%appdata%\backrest\config.json`
- Authentication: user/password set on first launch; to reset, delete the `users` key in config.json and restart.
- Auth can be disabled for local installs or behind an authenticating reverse proxy.

## Env vars (documented for storage backends, not for backrest itself)
- S3: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
- B2: B2_ACCOUNT_ID, B2_ACCOUNT_KEY
- Google Cloud: GOOGLE_PROJECT_ID, GOOGLE_APPLICATION_CREDENTIALS
- Backrest's own env vars (data/config dir) are NOT documented on this page.

## Runtime deps
- Storage: restic repo URIs (b2:, s3:, gs:, sftp:, local path, rclone:remote:path). Rclone needs its own config.
- SFTP key via restic option `-o sftp.args="-i /path/to/key"`.

## Gotchas
- Repo URI, name and encryption are set in the UI; repo name is immutable.
- Instance ID cannot be changed after initial setup.
- Restic cache must be kept out of the read-only root (no path documented here).
