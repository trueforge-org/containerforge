## TODO pin version tag
FROM ghcr.io/trueforge-org/python:rolling AS buildstage

# set version label

RUN \
  echo "**** install packages ****" && \
  apk add  --no-cache \
    giflib \
    libgsf \
    nodejs \
    vips && \
  apk add  --no-cache --virtual=build-dependencies \
    build-base \
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
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.local \
    $HOME/.npm \
    /tmp/*

    ## TODO: pin to version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:56c028d92c9c7e5d29c1265fd0b615c9fbc4995cf5f6ef6007393c3030b4b749

ARG VERSION
ARG TARGETARCH
USER root

COPY --from=buildstage /build/server/ /app
COPY --from=buildstage /build/server/.env.sample /app/.env
COPY --from=buildstage /build/client/build /app/public/
COPY --from=buildstage /build/client/build/index.html /app/views/index.ejs

RUN \
  apk add  --no-cache \
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
