# farmOS.org hosting docs (install, requirements, docker)

**Source URL(s) + date:** https://farmOS.org/hosting/install (main); followed: https://farmOS.org/hosting/requirements, https://farmOS.org/hosting/docker. Fetched 2026-11-26.

**What it is:** Official install/hosting guide. Lists Docker (recommended), Composer (custom builds), prebuilt packages.

**Install steps (main page):** 1. Deploy codebase and provision a DB server. 2. Open the hostname in a browser; web installer runs (optional modules). 3. Configure file uploads, cron, OAuth2 keys if needed.

## Requirements (/hosting/requirements)
- PHP: "PHP 8.4" (only version listed).
- Required PHP ext: BCMath, EXIF, GEOS, SimpleXML.
- Recommended PHP: `memory_limit=256M`, `max_execution_time=240`, `max_input_time=240`, `max_input_vars=5000`, `realpath_cache_size=4096K`, `realpath_cache_ttl=3600`.
- DB: PostgreSQL 16+ (recommended), MariaDB 10.6+, MySQL/Percona 8.0+, SQLite 3.45+.
- Web server: not specified (Drupal requirements apply). Nginx shown only as TLS reverse proxy (443 -> farmOS port 80).
- SSL optional (Geolocate button and sensor streams need it).
- Satellite map layers (Mapbox, Google) need API keys.
- No upload-size values, no Composer/Drush requirement, no OS requirement.

## Docker (/hosting/docker)
- Image: `farmos/farmos:x.y.z`. Docs advise against `latest` (manual update steps).
- Run: `docker run --rm -p 80:80 -v "${PWD}/sites:/opt/drupal/web/sites" farmos/farmos:x.y.z`.
- Ownership: `mkdir sites && sudo chown 33:33 sites` (33 = www-data).
- Compose: copy `docker/docker-compose.production.yml` from repo; example includes a PostgreSQL `db` service with default credentials (example only).
- Persistence: `/opt/drupal/web/sites` must persist (settings and uploads). Everything else replaced on image update.
- PHP override: `./php.ini:/usr/local/etc/php/conf.d/farmos.ini` with `upload_max_filesize = 50M`, `post_max_size = 50M`.
- Update: change version tag, `docker compose down` then `up`; run manual DB update steps from the "Updating" docs.
- No env vars described. Ports: 80.

## Filesystem and cron (from install docs, followed)
- Settings: `sites/default/settings.php`.
- Private files: `$settings['file_private_path'] = '/opt/drupal/web/sites/default/private/files';`; create `/opt/drupal/web/sites/default/private/`; owner/group www-data; mode 770.
- OAuth2 keys: `keys/public.key`, `keys/private.key` outside webroot (`../keys`), writable during generation, then protected. Module `farm_api_oauth`.
- Cron: `vendor/bin/drush cron` (weekly is enough), or secret URL `https://[base-url]/cron/[secret-key]` with wget. Automated Cron module not recommended.

**Version/asset naming:** not on these pages.
**Arch:** not stated.
**Gotchas**
- Docs PHP 8.4 requirement; plan targets PHP 8.5.
- Docker docs state `/opt/drupal/web/sites`, matching the upstream Dockerfile.
- Docs say the image "latest" tag needs manual steps; pin a version.
- Fetch failures: none.
