FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION
USER root

# Prebuilt web bundle (arch-neutral). The archive layout is UNVERIFIED: run `tar tzf` on it in the build step and
# fix the -C target if the files are nested under build/web.
RUN set -eux; \
  mkdir -p /usr/share/nginx/html/kitchenowl; \
  curl -fsSL -o /tmp/kitchenowl_web.tar.gz \
    "https://github.com/TomBursch/kitchenowl/releases/download/v${VERSION}/kitchenowl_Web.tar.gz"; \
  tar xzf /tmp/kitchenowl_web.tar.gz -C /usr/share/nginx/html/kitchenowl; \
  chmod -R 755 /usr/share/nginx/html; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
