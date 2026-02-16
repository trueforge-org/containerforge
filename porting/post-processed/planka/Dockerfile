FROM ghcr.io/trueforge-org/python:rolling@sha256:ee0d6169d1276e97acbc5d2d7717702d211f7433c00bd3e4e16f1d8c80fe1103 AS buildstage

# set version label

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    giflib \
    libgsf \
    nodejs \
    vips && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    npm \
    py3-setuptools && \
  echo "**** install planka ****" && \
  mkdir -p /build && \
  curl -o \
    /tmp/planka.tar.gz -L \
    "https://github.com/plankanban/planka/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/planka.tar.gz -C \
    /build --strip-components=1 && \
  cd /build/server && \
  npm install pnpm@9 --global && \
  pnpm import && \
  pnpm install --prod && \
  cd /build/client && \
  pnpm import && \
  pnpm install --prod && \
  DISABLE_ESLINT_PLUGIN=true npm run build && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    $HOME/.local \
    $HOME/.npm \
    /tmp/*

FROM ghcr.io/trueforge-org/node:rolling@sha256:70adf71e6e9d204219ace16d177a96c7b06cc3d881c413eaaa312ed27d13479a

ARG VERSION
ARG TARGETARCH
USER root

COPY --from=buildstage /build/server/ /app
COPY --from=buildstage /build/server/.env.sample /app/.env
COPY --from=buildstage /build/client/build /app/public/
COPY --from=buildstage /build/client/build/index.html /app/views/index.ejs

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    postgresql16-client && \
    echo "**** create symlinks ****" && \
    /bin/bash -c \
    'dst=(user-avatars project-background-images attachments logs); \
    src=(public/user-avatars public/project-background-images private/attachments logs); \
    for i in "${!src[@]}"; do rm -rf /app/"${src[i]}" && ln -s /config/"${dst[i]}" /app/"${src[i]}"; done'

# copy local files
USER apps
COPY . /


# ports and volumes
EXPOSE 1337

VOLUME /config

WORKDIR /config
