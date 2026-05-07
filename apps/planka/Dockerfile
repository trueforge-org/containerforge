FROM ghcr.io/trueforge-org/python-node:3.14.4@sha256:f9fa725921ad7e5e85fee84f66a2e02f821501a5c66684e2cc9848be51e2048c AS buildstage

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

FROM ghcr.io/trueforge-org/node:24.15.0@sha256:4bca93d03032d86c7fe416b234838df556eb5d945e1d716dfc98b8fff38470ad

ARG VERSION
ARG TARGETARCH
USER root

COPY --from=buildstage /build/server/ /app
COPY --from=buildstage /build/server/.env.sample /app/.env
COPY --from=buildstage /build/client/build /app/public/
COPY --from=buildstage /build/client/build/index.html /app/views/index.ejs

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client && \
    echo "**** create symlinks ****" && \
    /bin/bash -c \
    'dst=(user-avatars project-background-images attachments logs); \
    src=(public/user-avatars public/project-background-images private/attachments logs); \
    for i in "${!src[@]}"; do rm -rf /app/"${src[i]}" && ln -s /config/"${dst[i]}" /app/"${src[i]}"; done'

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 1337

VOLUME /config

WORKDIR /config
