FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS fetch

ARG VERSION
# UNVERIFIED: no upstream checksum is published for the dist zip. Pin the SHA-256
# of the release asset in docker-bake.hcl. An empty value makes the check fail,
# so the build stops until it is set.
ARG SHA256
USER root

# UNVERIFIED: whether the base already ships unzip. Remove this install if it does.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends unzip; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL -o /tmp/dist.zip "https://github.com/shlinkio/shlink-web-client/releases/download/v${VERSION}/shlink-web-client_${VERSION}_dist.zip"; \
    echo "${SHA256}  /tmp/dist.zip" | sha256sum -c -; \
    unzip -q /tmp/dist.zip -d /tmp/dist; \
    rm -f /tmp/dist.zip

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ENV TZ=Etc/UTC

# Static SPA files, read-only at runtime. The base image's CMD serves them with
# /config/nginx.conf, and the site from defaults/default.conf is seeded by
# docker-entrypoint.d/10-shlink.sh.
COPY --from=fetch --chown=568:568 /tmp/dist /app/www

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
