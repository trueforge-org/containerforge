# Bitnami WordPress Dockerfile (debian-12 variant, commit 9da42441)

Source URL(s): https://raw.githubusercontent.com/bitnami/containers/9da424411c57f30d7bdc8409eabcce6e5709c9f3/bitnami/wordpress/7/debian-12/Dockerfile (fetched 2026-11-27; blob URL same file)

## Base
- `FROM docker.io/bitnami/minideb:bookworm`. Copyright Broadcom. SPDX APACHE-2.0.
- ARGs: `DOWNLOADS_URL=https://downloads.bitnami.com/files/stacksmith`, `TARGETARCH`.
- ENV: `HOME=/`, `OS_ARCH=${TARGETARCH:-amd64}`, `OS_FLAVOUR=debian-12`, `OS_NAME=linux`.
- LABEL version `7.1.5`, created 2026-11-19T22:23:38Z.

## Build
- `COPY prebuildfs /`; installs a long list of runtime libs with `install_packages` (incl. libmagickcore/wand 6, libicu72, libsqlite3-0, libssl3, procps, openssl, zlib1g).
- Downloads Stacksmith components (`${DOWNLOADS_URL}/<component>.tar.gz`) and verifies each with `sha256sum -c` against `/opt/bitnami/checksums/`:
  - render-template 1.0.10-7
  - php 8.4.28-0
  - apache 2.4.71-0
  - mysql-client 13.1.1-0
  - postgresql-lib 18.7.0-0
  - libphp 8.4.28-0
  - wordpress 7.1.5-1
- Extracts into `/opt/bitnami` (`--strip-components=2`).
- `apt-get update && apt-get upgrade -y`, clears apt lists; `chmod g+rwX /opt/bitnami`; strips setuid/setgid bits; uninstalls curl.
- `COPY rootfs /` then runs `/opt/bitnami/scripts/{mysql-client,apache,php,apache-modphp,wordpress}/postunpack.sh`.

## Runtime
- `ENV APACHE_HTTP_PORT_NUMBER=""`, `APACHE_HTTPS_PORT_NUMBER=""`, `APP_VERSION=7.1.5`, `BITNAMI_APP_NAME=wordpress`, `IMAGE_REVISION=1`, `LD_LIBRARY_PATH=/opt/bitnami/postgresql/lib`, PATH adds `/opt/bitnami/{wp-cli,common,php,apache,mysql}/bin`.
- `EXPOSE 8080 8443`
- `USER 1001`
- `ENTRYPOINT ["/opt/bitnami/scripts/wordpress/entrypoint.sh"]`
- `CMD ["/opt/bitnami/scripts/apache/run.sh"]`
- No VOLUME.

## Gotchas
- Bitnami scripts drive configuration (WORDPRESS_* env names), which are not in this file.
- Base uses `minideb:bookworm` (Debian 12) and Stacksmith tarballs from downloads.bitnami.com.
