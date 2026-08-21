FROM ghcr.io/trueforge-org/python-node:3.14.7@sha256:aeb8262cb9284c7d0ebee44c3b7f1e40e77a061fd0ddfc093b2452cf27ed454d AS buildstage

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

FROM ghcr.io/trueforge-org/node:24.19.0@sha256:9bb5ae18e1e9db98eb0722f353a0f3591dc54c4b3c9d9d90a9720df0ceda0255

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
