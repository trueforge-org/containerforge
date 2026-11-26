# TimWolla/docker-adminer: upstream Dockerfile (6.x standalone)

**Source URL(s):** https://github.com/TimWolla/docker-adminer/blob/6d83dde54e9e8a76c9e003eb494e296808a2a627/6/Dockerfile (fetched via raw.githubusercontent.com/TimWolla/docker-adminer/6d83dde54e9e8a76c9e003eb494e296808a2a627/6/Dockerfile)
**Fetched:** 2026-11-26

## What it is
The Docker Official Image build for Adminer 6.x. The file at this commit builds Adminer **6.3.0** (ADMINER_VERSION=6.3.0), not 6.3.1.

## Base and build deps
- `FROM php:8.4-alpine`.
- Build-only apk packages (group `.build-deps`, removed after build): `postgresql-dev`, `sqlite-dev`, `unixodbc-dev`, `freetds-dev`.
- Compiled PHP extensions via docker-php-ext-install: `mysqli`, `pdo_pgsql`, `pdo_sqlite`, `pdo_odbc` (configured `--with-pdo-odbc=unixODBC,/usr`), `pdo_dblib`.
- Runtime deps found by scanning compiled extensions with `scanelf` and installed as virtual group `.phpexts-rundeps`.

## Downloads and checksums (upstream publishes these for 6.3.0)
- `ADMINER_VERSION=6.3.0`
- `ADMINER_DOWNLOAD_SHA256=641e1a31e8cc333a309e202ef9446e1fd38c2069ed5f9ee509b80d70089d0503` (checksum of `adminer-6.3.0.php`)
- `ADMINER_SRC_DOWNLOAD_SHA256=651353bc14d125b548c429cc3ffaa30b97c8b0f86b1b1692138a35a2047fba3a` (checksum of the source tarball)
- Downloads `adminer-$ADMINER_VERSION.php` from the vrana/adminer release and saves it as `adminer.php`, verifying the SHA256.
- Downloads the source tarball for the tag, verifies its SHA256, extracts only `designs/` and `plugins/` (strips top folder), deletes the archive.
- Note: this is a checksum the image build uses for 6.3.0 only. The upstream release page itself publishes none (plan.md). A 6.3.1 value would need to be computed.

## PHP ini (written to /usr/local/etc/php/conf.d/0-upload_large_dumps.ini)
upload_max_filesize=128M, post_max_size=128M, memory_limit=1G, max_execution_time=600, max_input_vars=5000.

## Files and copy
- `COPY *.php /var/www/html/`
- `COPY entrypoint.sh /usr/local/bin/`
- `WORKDIR /var/www/html`; `/var/www/html` and `/var/www/html/plugins-enabled` created, owned by `adminer` recursively.

## User
- System group and user both named `adminer`. `USER adminer`.

## Entrypoint/CMD
- `ENTRYPOINT ["entrypoint.sh", "docker-php-entrypoint"]`
- `CMD ["php", "-S", "[::]:8080", "-t", "/var/www/html"]`
- `EXPOSE 8080`, `STOPSIGNAL SIGINT`. No ARG instructions.

## Ports
8080 (standalone). The entrypoint script is not fetched in this summary.

## Gotchas
- The upstream image runs the built-in PHP server on `[::]:8080` (all interfaces).
- Plugin and design features depend on the entrypoint wrapper (`plugin-loader.php`, `plugins-enabled`), which a read-only rootfs build would not provide unless ported.
