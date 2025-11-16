
FROM ghcr.io/trueforge-org/ubuntu:24.4AS buildstage

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
    py3-setuptools \
    python3-dev && \
  echo "**** install planka ****" && \
  if [ -z ${VERSION+x} ]; then \
  VERSION=$(curl -s https://api.github.com/repos/plankanban/planka/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
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

FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION

COPY --from=buildstage /build/server/ /app
COPY --from=buildstage /build/server/.env.sample /app/.env
COPY --from=buildstage /build/client/build /app/public/
COPY --from=buildstage /build/client/build/index.html /app/views/index.ejs

RUN \
  apk add  --no-cache \
    nodejs \
    postgresql16-client && \
    echo "**** create symlinks ****" && \
    /bin/bash -c \
    'dst=(user-avatars project-background-images attachments logs); \
    src=(public/user-avatars public/project-background-images private/attachments logs); \
    for i in "${!src[@]}"; do rm -rf /app/"${src[i]}" && ln -s /config/"${dst[i]}" /app/"${src[i]}"; done'

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 1337

VOLUME /config
