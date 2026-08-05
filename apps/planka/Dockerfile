FROM ghcr.io/trueforge-org/python-node:3.14.6@sha256:0dabaaf8e37a81dc74e25fc5dec5863df789c95250518ea57e33d6c432cc3133 AS buildstage

# set version label
ARG VERSION
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libgif7 \
    libgsf-1-114 \
    libvips42 && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-setuptools && \
  echo "**** install planka ****" && \
  mkdir -p /build && \
  (curl -fL -o \
    /tmp/planka.tar.gz \
    "https://github.com/plankanban/planka/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
    /tmp/planka.tar.gz \
    "https://github.com/plankanban/planka/archive/refs/tags/${VERSION}.tar.gz" || (PLANKA_RELEASE=$(curl -sX GET "https://api.github.com/repos/plankanban/planka/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && curl -fL -o \
    /tmp/planka.tar.gz \
    "https://github.com/plankanban/planka/archive/refs/tags/${PLANKA_RELEASE}.tar.gz")) && \
  tar xf \
    /tmp/planka.tar.gz -C \
    /build --strip-components=1 && \
  cd /build/server && \
  npm install pnpm@9 --global && \
  pnpm import && \
  pnpm install --prod && \
  cd /build/client && \
  pnpm import && \
  sed -i '/"node-sass"/d' package.json && \
  pnpm add sass --save-dev && \
  pnpm install --prod && \
  DISABLE_ESLINT_PLUGIN=true npm run build && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    $HOME/.local \
    $HOME/.npm \
    /tmp/*

FROM ghcr.io/trueforge-org/node:24.19.0@sha256:225eb6fc544ed2a7e052fc90395181505b118b0a0c5547b18e1b0207937843ba

ARG VERSION
ARG TARGETARCH
USER root

COPY --from=buildstage /build/server/ /app
COPY --from=buildstage /build/server/.env.sample /app/.env
COPY --from=buildstage /build/client/dist /app/public/
COPY --from=buildstage /build/client/dist/index.html /app/views/index.ejs

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client && \
    echo "**** create symlinks ****" && \
    rm -rf /app/data && \
    ln -s /config/data /app/data

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 1337

VOLUME /config

WORKDIR /config
