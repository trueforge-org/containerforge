# TasmoAdmin .docker/Dockerfile.alpine-tmpl at 81271a0 (template)
Source URL: https://raw.githubusercontent.com/TasmoAdmin/TasmoAdmin/81271a076cacecb1e8d4e8723af35e61510276de/.docker/Dockerfile.alpine-tmpl (fetched 2026-11-27)

## Args
- BUILD_FROM=amd64/alpine:3.23 (base; templated per arch)
- COMPOSER_VERSION=2.9.5 (composer stage); NODE_VERSION=22.22.1-slim (node stage)
- BUILD_REF=dev, BUILD_VERSION=dev, BUILD_DATE; S6_OVERLAY_VERSION=3.1.6.2; QEMU_ARCH=x86_64; BUILD_ARCH=amd64

## Stages
1. node-builder (node:${NODE_VERSION}): COPY tasmoadmin /tasmoadmin; `npm ci && npm run build && rm -rf node_modules/`
2. builder (composer:${COMPOSER_VERSION}): `composer install --optimize-autoloader --no-dev`
3. final (${BUILD_FROM}):
   - COPY .docker/_tmp/qemu-${QEMU_ARCH}-static /usr/bin/ (qemu for cross builds)
   - apk: nginx, bash, busybox, curl, ca-certificates, tzdata, libssl3, libcrypto3, musl; php85 + php85-fpm, php85-curl, php85-dom, php85-json, php85-session, php85-zip, php85-mbstring
   - s6-overlay 3.1.6.2: noarch, arch (x86_64 or arm for arm32v7), symlinks-noarch, symlinks-arch tarballs from github just-containers/s6-overlay
   - COPY .docker/rootfs /
   - COPY --from=builder /tasmoadmin -> /var/www/tasmoadmin; removes .htaccess and .empty files

## Runtime
- VOLUME ["/data"]; EXPOSE 80 443
- ENV BUILD_VERSION, BUILD_REF, SSL=false
- fastcgi_param BUILD_VERSION/BUILD_REF appended to /etc/nginx/fastcgi_params
- HEALTHCHECK: `curl --fail http://127.0.0.1 || curl --fail https://127.0.0.1`
- ENTRYPOINT ["/init"] (s6 init)
- License GPL-3.0; source https://github.com/TasmoAdmin/TasmoAdmin

## User
- No USER line: root (s6 init)

## Gotchas
- Template: BUILD_FROM and QEMU_ARCH/BUILD_ARCH are substituted per arch by the upstream pipeline
