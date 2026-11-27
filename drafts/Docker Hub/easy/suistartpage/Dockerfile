FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# Full commit SHA of the upstream repo. The repo publishes no checksums and has been dormant since 2020, so the pinned SHA is the integrity anchor.
ARG VERSION
USER root

RUN set -eux; \
  curl -fsSL "https://github.com/CorneliousJD/SUI-Startpage/archive/${VERSION}.tar.gz" -o /tmp/sui.tar.gz; \
  mkdir -p /tmp/sui; \
  tar xzf /tmp/sui.tar.gz -C /tmp/sui --strip-components=1; \
  rm -rf /usr/share/nginx/html/*; \
  cp -r /tmp/sui/assets /tmp/sui/index.html /tmp/sui/apps.json /tmp/sui/links.json /tmp/sui/providers.json /tmp/sui/favicon.ico /usr/share/nginx/html/; \
  mkdir -p /usr/share/licenses/suistartpage; \
  cp /tmp/sui/LICENSE /usr/share/licenses/suistartpage/; \
  chown -R 568:568 /usr/share/nginx/html; \
  chmod -R u=rwX,go=rX /usr/share/nginx/html; \
  rm -rf /tmp/sui /tmp/sui.tar.gz

USER apps
COPY --chmod=0755 . /

WORKDIR /usr/share/nginx/html

VOLUME /config
