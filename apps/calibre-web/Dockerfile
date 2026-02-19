


FROM ghcr.io/trueforge-org/python:3.13.12@sha256:8b4bc444de4cf6adfc309c1d748674d60f2c849924b456cbdc93650f8566bca7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV \
  QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libldap2-dev \
    libsasl2-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    imagemagick \
    ghostscript \
    libasound2t64 \
    libldap2 \
    libmagic1t64 \
    libsasl2-2 \
    libxi6 \
    libxslt1.1 \
    libxfixes3 \
    sqlite3 \
    xdg-utils && \
  echo "**** install calibre-web ****" && \
  curl -o \
    /tmp/calibre-web.tar.gz -L \
    https://github.com/janeczku/calibre-web/archive/${VERSION}.tar.gz && \
  mkdir -p \
    /app/calibre-web && \
  tar xf \
    /tmp/calibre-web.tar.gz -C \
    /app/calibre-web --strip-components=1 && \
  cd /app/calibre-web && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r \
    requirements.txt -r \
    optional-requirements.txt && \
  echo "***install kepubify" && \
  if [ -z ${KEPUBIFY_RELEASE+x} ]; then \
    KEPUBIFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/pgaskin/kepubify/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /usr/bin/kepubify -L \
    https://github.com/pgaskin/kepubify/releases/download/${KEPUBIFY_RELEASE}/kepubify-linux-64bit && \
  rm -rf /etc/ImageMagick-6/policy.xml && \
  ln -s /defaults/policy.xml /etc/ImageMagick-6/policy.xml && \
  echo "**** cleanup ****" && \
  apt-get -y purge \
    build-essential \
    libldap2-dev \
    libsasl2-dev && \
  apt-get -y autoremove && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /root/.cache

# add local files
USER apps
COPY container-test.yaml /container-test.yaml
COPY . /
COPY ./root /




# ports and volumes
EXPOSE 8083
VOLUME /config
