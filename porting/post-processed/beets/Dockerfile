
FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libcairo2-dev \
    cargo \
    cmake \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    pkg-config \
    libfftw3-dev \
    libgirepository1.0-dev \
    libjpeg-dev \
    libpng-dev \
    libmpg123-dev \
    libopenjp2-7-dev \
    libsqlite3-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    libchromaprint1 \
    libexpat1 \
    ffmpeg \
    libfftw3-3 \
    flac \
    libgdbm6 \
    gobject-introspection \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-base \
    gstreamer1.0-tools \
    imagemagick \
    libjpeg-turbo8 \
    lame \
    libffi8 \
    libpng16-16 \
    mpg123 \
    libopenjp2-7 \
    libsqlite3-0 && \
  echo "**** compile mp3gain ****" && \
  mkdir -p /tmp/mp3gain-src && \
  curl -o /tmp/mp3gain-src/mp3gain.zip -sL https://sourceforge.net/projects/mp3gain/files/mp3gain/1.6.2/mp3gain-1_6_2-src.zip && \
  cd /tmp/mp3gain-src && \
  unzip -qq /tmp/mp3gain-src/mp3gain.zip && \
  sed -i "s#/usr/local/bin#/usr/bin#g" /tmp/mp3gain-src/Makefile && \
  make && \
  make install && \
  echo "**** compile mp3val ****" && \
  mkdir -p /tmp/mp3val-src && \
  curl -o /tmp/mp3val-src/mp3val.tar.gz -sL https://downloads.sourceforge.net/mp3val/mp3val-0.1.8-src.tar.gz && \
  cd /tmp/mp3val-src && \
  tar xzf /tmp/mp3val-src/mp3val.tar.gz --strip 1 && \
  make -f Makefile.linux && \
  cp -p mp3val /usr/bin && \
  echo "**** install pip packages ****" && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir pip wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    beautifulsoup4 \
    beets==${VERSION} \
    beets-extrafiles \
    beetcamp \
    python3-discogs-client \
    flask \
    PyGObject \
    pyacoustid \
    pylast \
    requests \
    requests_oauthlib \
    typing-extensions \
    unidecode && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential libcairo2-dev cargo cmake libavcodec-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev pkg-config libfftw3-dev libgirepository1.0-dev libjpeg-dev libpng-dev libmpg123-dev libopenjp2-7-dev libsqlite3-dev python3-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /tmp/* $HOME/.cache $HOME/.cargo /var/lib/apt/lists/*

# environment settings
ENV BEETSDIR="/config" \
EDITOR="nano" \
HOME="/config"

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8337
VOLUME /config

WORKDIR /config
