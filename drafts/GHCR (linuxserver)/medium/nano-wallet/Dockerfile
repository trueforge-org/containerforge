# build stage: Vue CLI build of the wallet
# UNVERIFIED: Vue CLI 4 / node-sass 4 may need an older Node or NODE_OPTIONS=--openssl-legacy-provider; check on the first build.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION

ENV HOME=/tmp \
    NPM_CONFIG_CACHE=/tmp/npm-cache \
    NPM_CONFIG_UPDATE_NOTIFIER=false

RUN curl -fsSL -o /tmp/nano-wallet.tar.gz \
      "https://github.com/linuxserver/nano-wallet/archive/refs/tags/${VERSION}.tar.gz" \
 && mkdir -p /tmp/src \
 && tar xzf /tmp/nano-wallet.tar.gz -C /tmp/src --strip-components=1 \
 && rm -f /tmp/nano-wallet.tar.gz

WORKDIR /tmp/src
RUN npm ci \
 && npm run build

# runtime stage: static files served by nginx
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

USER root

RUN mkdir -p /app/nano-wallet /usr/share/licenses/nano-wallet

COPY --from=build /tmp/src/dist/ /app/nano-wallet/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/nano-wallet/LICENSE

RUN chown -R root:root /app/nano-wallet /usr/share/licenses/nano-wallet \
 && chmod -R 755 /app/nano-wallet /usr/share/licenses/nano-wallet

# run as 568
USER apps
COPY --chmod=0755 . /

ENV HOME=/tmp
EXPOSE 8080
STOPSIGNAL SIGQUIT

CMD ["/start.sh"]
