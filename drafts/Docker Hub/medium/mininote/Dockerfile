FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# UNVERIFIED: the Node version in this base must be >= 22.12.0 (upstream README)
ARG VERSION
ARG TARGETARCH
ARG base_url=/
USER root

ENV HOME=/config \
    BASE_URL=${base_url} \
    COREPACK_HOME=/tmp/corepack \
    YARN_CACHE_FOLDER=/tmp/yarn

RUN echo "*** Installing mininote ***" && \
  mkdir -p /app/mininote && \
  curl -fL -o \
    /tmp/mininote.tar.gz \
    "https://github.com/muety/mininote/archive/${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/mininote.tar.gz -C \
    /app/mininote --strip-components=1 && \
  rm /tmp/mininote.tar.gz

# UNVERIFIED: build steps follow upstream Dockerfile (yarn in /app, then webapp build)
RUN echo "*** Building mininote ***" && \
  cd /app/mininote && \
  corepack enable && \
  yarn set version stable && \
  yarn && \
  cd webapp && \
  corepack enable && \
  yarn set version stable && \
  yarn && \
  yarn build:base && \
  rm -rf /tmp/yarn /tmp/corepack

# UNVERIFIED: upstream data path is /app/data (read-only at runtime); the native data location is not confirmed
RUN echo "*** Redirecting data to /config ***" && \
  mkdir -p /config/data && \
  ln -s /config/data /app/mininote/data

# UNVERIFIED: LICENSE file name in the source tarball
RUN mkdir -p /usr/share/licenses/mininote && \
  cp /app/mininote/LICENSE /usr/share/licenses/mininote/LICENSE && \
  chown -R apps:apps /app/mininote && \
  chmod -R 755 /app/mininote

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config

WORKDIR /app/mininote
