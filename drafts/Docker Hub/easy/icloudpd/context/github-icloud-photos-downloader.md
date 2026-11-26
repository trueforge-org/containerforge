# GitHub: icloud-photos-downloader/icloud_photos_downloader (upstream application)

Source URL(s) + fetch date: https://github.com/icloud-photos-downloader/icloud_photos_downloader ; README and docs read from raw at tag v1.34.0 (`main` branch raw returned 404 for README.md and docs/authentication.md); release metadata from https://api.github.com/repos/icloud-photos-downloader/icloud_photos_downloader/releases/tags/v1.34.0 ; release page https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/latest · fetched 2026-11-26

## What it is
Command-line tool to download iCloud photos to local storage. Runs on Linux, Windows, macOS, laptops, desktops and NAS. Volunteer maintained; project asks for a maintainer (issue #1305). MIT license.

## Install/build steps and build deps
- Install routes: GitHub release executable, PyPI, AUR, npm, Docker, or build from source.
- No build deps needed for the release binary (PyInstaller-style single file, per plan.md; not verified by this fetch).

## Runtime deps
- Release binaries: none beyond the platform libc. musl variants exist for Alpine.
- iCloud prerequisite: "Access iCloud Data on the Web" must be enabled on the Apple device, or Apple returns ACCESS_DENIED. Advanced Data Protection must be off, or on with `--adp-web-access`.

## Binaries/entrypoint/CLI flags
- Executable name is `icloudpd` (not `icloud`; `icloud` is a separate helper tool).
- Examples:
  - `icloudpd --directory /data --username my@email.address --watch-with-interval 3600`
  - `icloudpd --username my@email.address --auth-only`
  - `icloudpd --directory /data/shared --username ... --library 'SharedSync-...' --prune-orphans`
- Modes: copy (default), `--auto-delete` (sync), `--keep-icloud-recent-days` (move). Other: `--until-found`, `--recent`, `--set-exif-datetime`, `--dry-run`, `--help` lists all.
- Auth flags: `--password-provider` (parameter, keyring, console, webui; repeatable, order = check order; console and webui must be last), `--mfa-provider` (console default, or webui), `--cookie-directory`, `--domain` (`cn` for China), `--adp-web-access`.
- Notifications: `--smtp-username`, `--smtp-password`, `--notification-email`.

## Env vars (table)
- None documented by upstream (no env interface; all settings are CLI flags). Plan.md uses ICLOUDPD_* wrapper names in start.sh.

## Ports
- Not stated in README or authentication.md. Plan.md says the web UI is fixed on 8080 and listens on all interfaces; not confirmed by these pages (the auth page lists no port or host option). Treat as unverified.

## Volumes/paths and persistent data
- Session cookies: `--cookie-directory`, else `~/.pyicloud` (in Docker `/root/.pyicloud`).
- Keyring fallback (headless): `~/.local/share/python_keyring/keyring_pass.cfg` (in Docker `/root/.local/share/python_keyring/keyring_pass.cfg`). The docs say this file's password "is not encrypted". Plan.md's `XDG_DATA_HOME` expectation is not mentioned in these docs.
- Downloads: `--directory` (plan: `/data`).

## User/UID & permissions
- No user or USER guidance in these pages.

## Config files and formats
- Keyring file `keyring_pass.cfg` (plain text). Session files per account in the cookie directory.

## Version/release info and asset naming
- Latest release: v1.34.0, published 2026-11-20T19:37:18Z (tag `v1.34.0`).
- Relevant assets (name, bytes, sha256 digest from the release API):
  - `icloudpd-1.34.0-linux-amd64` 39024920 `c1ae40027cea92eeb5ee24338a25fb79d564ae0f06c42d322b41282bbd2d3b02`
  - `icloudpd-1.34.0-linux-arm64` 38246672 `a5d59bd72145d7f00530cc02c15ccc463db05bb11a5068ac6a8656faa4cf8e6e`
  - `icloudpd-1.34.0-linux-arm32v7` 36481856 `10594f511bc4e8d7b0f7bbbb951cf00396826f3bb8ac5f098c39d2052ecfa470`
  - musl variants: `icloudpd-1.34.0-linux-musl-amd64` / `-musl-arm64` / `-musl-arm32v7`
  - `icloudpd-1.34.0-oci.tar`, `icloudpd-1.34.0-py3-none-any.whl` (97476 bytes, pure Python wheel), platform wheels, macOS and Windows builds.
- Naming pattern: `icloudpd-<version>-linux-<arch>` (glibc); `icloud-<version>-linux-<arch>` is a different tool (the draft's `icloud-1.33.1-...` links were wrong).
- Plan.md's digests (amd64 `c1ae4002...`, arm64 `a5d59bd7...`) match the API values.
- The release page reported 34 assets; the API listing above captured 32 (its digests are used here).

## Arch support
- linux amd64, arm64, arm32v7 (glibc and musl), macOS, Windows.

## Healthcheck/readiness endpoints
- None documented.

## Gotchas
- Contradiction with the draft: draft links `icloud-1.33.1-linux-*` (wrong tool) and version 1.33.1 with 1.32.x in text. Latest is 1.34.0.
- Web UI: `--password-provider webui` and `--mfa-provider webui` are supported. The auth doc says the webui MFA provider cannot send SMS and does not support FIDO security keys (matches plan.md).
- Keyring password saved unencrypted (matches plan.md).
- Session expiry about two months (matches plan.md).
- Upstream docs say the password-provider order rule: console and webui must be last (matches plan.md).
- Not fetched: the numbered docs sub-pages (install.html, webui.html, reference.html, etc.).
