
# Base digest taken from apps/nginx and apps/it-tools (repo pin). The plan named 1e4f20bf..., which no app uses.
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION
USER root

# VERSION is a commit SHA: upstream has no releases and no checksum file.
RUN set -eux; \
    mkdir -p /tmp/src /usr/share/licenses/newyearcountdownclock; \
    curl -fsSL "https://github.com/modem7/Docker-NewYearCountdown/archive/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /tmp/src; \
    rm -rf /usr/share/nginx/html/*; \
    cp -r /tmp/src/src/. /usr/share/nginx/html/; \
    cp /tmp/src/LICENSE /usr/share/licenses/newyearcountdownclock/; \
    chown -R 568:568 /usr/share/nginx/html; \
    chmod -R 755 /usr/share/nginx/html; \
    rm -rf /tmp/src

USER apps
# defaults/default.conf is seeded to /config/sites by the nginx base (03-copyconfig.sh, cp -n)
COPY --chmod=0755 . /

WORKDIR /usr/share/nginx/html

EXPOSE 8080

VOLUME /config
