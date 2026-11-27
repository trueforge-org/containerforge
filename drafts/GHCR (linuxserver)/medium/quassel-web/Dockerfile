FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# commit SHA of magne4000/quassel-webserver master (no tags or releases match master)
ARG VERSION

ENV HOME=/tmp \
    NPM_CONFIG_CACHE=/tmp/npm-cache \
    NPM_CONFIG_UPDATE_NOTIFIER=false

USER root

# download the source at the pinned commit (no build step upstream; npm install only)
RUN mkdir -p /app/quassel-web \
 && curl -fsSL -o /tmp/quassel-web.tar.gz \
      "https://github.com/magne4000/quassel-webserver/archive/${VERSION}.tar.gz" \
 && tar xzf /tmp/quassel-web.tar.gz -C /app/quassel-web --strip-components=1 \
 && rm -f /tmp/quassel-web.tar.gz \
 && cd /app/quassel-web \
 && npm ci --omit=dev \
 \
 # license from the archive (MIT)
 && mkdir -p /usr/share/licenses/quassel-web \
 && cp /app/quassel-web/LICENSE-MIT /usr/share/licenses/quassel-web/LICENSE \
 \
 # permissions and cleanup
 && chown -R root:root /app/quassel-web \
 && chmod -R 755 /app/quassel-web \
 && rm -rf /tmp/npm-cache /tmp/*

# start.sh and the rest of the app folder come in with COPY . /
COPY --chmod=0755 . /

# run as 568
USER apps

WORKDIR /config
ENV TZ=Etc/UTC
EXPOSE 64080
VOLUME ["/config"]

CMD ["/start.sh"]
