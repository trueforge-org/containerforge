# TasmoAdmin README (master)
Source URL: https://raw.githubusercontent.com/TasmoAdmin/TasmoAdmin/master/README.md (grep extract, fetched 2026-11-27)

- Standalone, container, or Home Assistant addon. PHP 8.2+ webserver; Docker image is Alpine with Nginx and PHP 8.5; amd64, arm, arm64.
- Image on GitHub packages: ghcr.io/tasmoadmin/tasmoadmin (README link)
- Env vars:
  - TASMO_DATADIR: data dir with trailing slash (default ./tasmoadmin/data/)
  - TASMO_BASEURL: base URL
  - TASMO_TMPDIR: sessions/cache (default ./tasmoadmin/tmp/)
  - TASMO_DEBUG: true displays PHP errors (default off; chart sets 1)
  - TASMO_DEVICE_PASSWORD_KEY: base64 32-byte key for device password encryption at rest
  - TASMO_ALLOW_CROSS_SITE_IFRAME: true to embed over HTTPS (SameSite=None; Secure for HTTPS only)
- Device password key resolution: `_DATADIR_/.device-password.key` first, then TASMO_DEVICE_PASSWORD_KEY; both must match if both exist; otherwise generated and persisted to .device-password.key
- Docs: GitHub wiki (not fetched). Dev: ddev, phpunit, pre-commit.
