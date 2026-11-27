# UNVERIFIED: sibling apps (theme-park, it-tools) pin nginx 1.28.3 at digest 3a862278...; this plan uses 1e4f20bf.... Confirm the digest at build time.
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION

USER root

RUN echo "*** Installing TagSpaces web ***" && \
  file="tagspaces-web-${VERSION}.zip" && \
  curl -fsSL -o "/tmp/${file}" \
    "https://github.com/tagspaces/tagspaces/releases/download/v${VERSION}/${file}" && \
  curl -fsSL -o /tmp/SHA256SUMS.txt \
    "https://github.com/tagspaces/tagspaces/releases/download/v${VERSION}/SHA256SUMS.txt" && \
  (cd /tmp && grep " ${file}\$" SHA256SUMS.txt | sha256sum -c -) && \
  unzip -q "/tmp/${file}" -d /tmp/ts && \
  rm -rf /usr/share/nginx/html/* && \
  cp -r /tmp/ts/web/. /usr/share/nginx/html/ && \
  mkdir -p /usr/share/licenses/tagspaces && \
  cp /tmp/ts/web/LICENSE.txt /usr/share/licenses/tagspaces/LICENSE.txt && \
  chown -R 568:568 /usr/share/nginx/html && \
  rm -rf /tmp/ts /tmp/SHA256SUMS.txt "/tmp/${file}"

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /usr/share/nginx/html
