
# BLOCKED (see plan.md section 10): port, Node version and license must be settled before this is built
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

ENV NPM_CONFIG_CACHE=/tmp/npm-cache \
    NODE_ENV=production \
    LOG_LEVEL=INFO

USER root

# source build: client is built in place, server deps installed for production
# UNVERIFIED: whether the server reads its built client from /client/dist or another path (check server/)
# UNVERIFIED: sharp native build on this Node version and arm64
RUN echo "**** install fotosho ****" && \
  mkdir -p /app/fotosho && \
  curl -fL -o /tmp/fotosho.tar.gz \
    "https://github.com/advplyr/fotosho/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/fotosho.tar.gz -C /app/fotosho --strip-components=1 && \
  cd /app/fotosho/client && \
  npm install && \
  npm run generate && \
  cd /app/fotosho && \
  npm install --omit=dev && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf /tmp/* $HOME/.cache /var/lib/apt/lists/*

# run as 568
USER apps
COPY --chmod=0755 . /

# UNVERIFIED: port 80 cannot be bound by UID 568 without CAP_NET_BIND_SERVICE; the port decision is open
EXPOSE 80
VOLUME /config
