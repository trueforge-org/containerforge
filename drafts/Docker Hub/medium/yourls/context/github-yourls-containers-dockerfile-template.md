# GitHub: YOURLS/containers images/yourls/Dockerfile.template

## Source URL(s) + date
- https://raw.githubusercontent.com/YOURLS/containers/ab773d7d9e7408f66b532736ceea60324b9f3e3f/images/yourls/Dockerfile.template (2026-11-27)
- Blob URL in urls.txt (github.com/.../blob/...) is the same file; raw variant fetched.

## What it is
Template the upstream `yourls` official image is generated from. Placeholders: `%%VARIANT%%`, `%%VARIANT_EXTRAS%%`, `%%VARIANT_FILES%%`, `%%SHA256%%`, `%%CMD%%`.

## Build steps
- Base: `FROM php:8.5-%%VARIANT%%` (apache / fpm / fpm-alpine).
- PHP exts via `docker-php-ext-install -j "$(nproc)"`: bcmath, pdo_mysql, mysqli.
- opcache ini written to `$PHP_INI_DIR/conf.d/opcache-recommended.ini` (memory_consumption=128, interned_strings_buffer=8, max_accelerated_files=4000, revalidate_freq=2, fast_shutdown=1).
- Renovate: `# renovate: datasource=github-releases depName=YOURLS/YOURLS versioning=composer`
- `ARG YOURLS_VERSION="1.10.6"`, `ARG YOURLS_SHA256="%%SHA256%%"`; both exported as ENV.
- Download: `curl -fsSL https://github.com/YOURLS/YOURLS/archive/${YOURLS_VERSION}.tar.gz`, verified with `sha256sum -c`.
- Extract to `/usr/src/`, rename `YOURLS-<ver>` to `/usr/src/yourls`, `chown -R www-data:www-data`.
- `COPY --chown=www-data:www-data config-container.php /usr/src/yourls/user/`
- `COPY container-entrypoint.sh /usr/local/bin/`
- `ENTRYPOINT ["container-entrypoint.sh"]`, `CMD ["%%CMD%%"]` (per variant).
- checkov skips: CKV_DOCKER_2, CKV_DOCKER_3.

## Gotchas
- Variant-specific files and extras are injected at `%%VARIANT_EXTRAS%%` / `%%VARIANT_FILES%%`; not in this template.
- Version + SHA256 must be updated together (renovate-managed `ARG`).
