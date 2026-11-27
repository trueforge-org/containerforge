# Chevereto V4 docs (v4-docs.chevereto.com)

Source URL(s) + date: https://v4-docs.chevereto.com (main), /application/installing/installation.html, /application/stack/php.html (fetched 2026-11-27). Docs last updated 11/17/2026.

## Scope warning
- These docs describe **Chevereto V4**. The container builds `rodber/chevereto-free` **1.6.2** (a different, 2022 release line). Treat V4 facts as non-authoritative for 1.6.2.

## What it is
- Self-hosted media-sharing platform. Docker is listed as the recommended install path (multi-site chevereto/docker project, not this image).

## PHP (V4 docs)
| Chevereto V4 | PHP |
| --- | --- |
| 4.5 | 8.2, 8.3 |
| 4.4 | 8.1, 8.2 |
| 4.3 | 8.1, 8.2 |
| 4.2 | 8.1, 8.2 |
| 4.1 | 8.0, 8.1 |
| 4.0 | 8.0, 8.1 |

- Recommended ini: upload_max_filesize 64M, post_max_size 64M, max_execution_time 30, memory_limit 512M.
- Required extensions: curl exif fileinfo gd hash imagick json pdo pdo-mysql session xml; mysqlnd required.
- Image library: prefers Imagick, falls back to GD. `CHEVERETO_IMAGE_LIBRARY=gd` forces GD.
- Formats: PNG GIF JPG BMP WEBP. Docs example for restricting: `CHEVERETO_IMAGE_FORMATS_AVAILABLE = '["JPG","PNG","BMP","GIF"]'` (JSON array form).
- Filesystem: PHP user must own install dir with recursive read; rw on session path, temp, ./content, ./images, ./importing. Debian example: `chown -R www-data: /var/www/html`.
- Must not restrict `set_time_limit`.

## Install paths (V4 docs)
- Docker (recommended), VPS, Synology, release ZIP (`get.sh` installer), Setup via HTTP or CLI (creates DB tables and admin user on first run).

## Gotchas
- PHP 7.4 (used by 1.6.2 upstream) is not listed in any V4 row.
- Setup creates DB tables on first run (relevant to empty /config-style start behaviour: setup is a web/CLI step, not automatic).
