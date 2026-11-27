FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

# set version label
ARG VERSION
USER root

# build stage only: npm and Angular build tooling stay out of the final image
ENV HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/.npm

# UNVERIFIED: the 2020 Angular and node-sass dependency set must build on the Node version in the base image
RUN set -eux; \
  mkdir -p /app/clarkson; \
  curl -fL "https://github.com/linuxserver/Clarkson/archive/refs/tags/v${VERSION}.tar.gz" | \
    tar xz -C /app/clarkson --strip-components=1; \
  cd /app/clarkson; \
  chmod +x ./flyway/flyway; \
  npm install; \
  ./node_modules/@angular/cli/bin/ng build --prod; \
  npm run prune-angular2; \
  npm prune --omit=dev; \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# flyway needs a Java runtime
# UNVERIFIED: package name and version on ubuntu 26.04, check with apt-cache policy
RUN apt-get update && \
  apt-get install -y --no-install-recommends openjdk-21-jre-headless && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /app/clarkson /app/clarkson
RUN mkdir -p /usr/share/licenses/clarkson && \
  cp /app/clarkson/LICENSE /usr/share/licenses/clarkson/LICENSE && \
  chown -R apps:apps /app/clarkson && \
  chmod -R 755 /app/clarkson

ENV NODE_ENV=production \
  HOME=/tmp \
  NPM_CONFIG_CACHE=/tmp/.npm

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
WORKDIR /app/clarkson
