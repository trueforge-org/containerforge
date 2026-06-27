
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:feedc096668b059bd1db605e99996089a746f34cb565f4ab067124d3425d9cf8 AS buildstage
############## build stage ##############
ARG VERSION
USER root

# package version

ENV MAKEFLAGS="-j4"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libargon2-dev \
    autoconf \
    automake \
    libboost-dev\
    libboost-locale-dev \
    build-essential \
    libc-ares-dev \
    libsasl2-dev \
    gettext \
    libicu-dev \
    libperl-dev \
    pax-utils \
    libssl-dev \
    perl \
    python3-dev \
    swig \
    tcl-dev && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir pip setuptools && \
  pip install -U --no-cache-dir cmake

RUN \
  echo "**** compile znc ****" && \
  mkdir -p \
    /tmp/znc && \
  git clone --branch "${VERSION}" --depth 1 \
    --recurse-submodules \
    https://github.com/znc/znc.git \
    /tmp/znc && \
  curl -o \
    /tmp/playback.tar.gz -L \
    https://github.com/jpnurmi/znc-playback/archive/master.tar.gz && \
  tar xf \
    /tmp/playback.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  curl -o \
    /tmp/znc-push.tar.gz -L \
    https://github.com/jreese/znc-push/archive/master.tar.gz && \
  tar xf \
    /tmp/znc-push.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  curl -o \
    /tmp/znc-clientbuffer.tar.gz -L \
    https://github.com/CyberShadow/znc-clientbuffer/archive/master.tar.gz && \
  tar xf \
    /tmp/znc-clientbuffer.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  curl -o \
    /tmp/znc-palaver.tar.gz -L \
    https://github.com/cocodelabs/znc-palaver/archive/master.tar.gz && \
  tar xf \
    /tmp/znc-palaver.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  cd /tmp/znc && \
  mkdir -p build && \
  cd build && \
  cmake .. \
    -DWANT_PYTHON=yes \
    -DWANT_PERL=yes \
    -DWANT_TCL=yes && \
  make && \
  make DESTDIR=/tmp/znc install

RUN \
  echo "**** determine runtime packages ****" && \
  (scanelf --needed --nobanner /tmp/znc/usr/local/bin/znc \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u \
    | xargs -r apt-get info --installed \
    | sort -u || true) \
    >> /tmp/znc/packages
############## runtime stage ##############

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:e566b6c11ab30372ddb0ee460a2f65699fd50ad2eb148ddac0d7800074159f19

# set version label
ARG VERSION
ARG TARGETARCH

# copy files from build stage
COPY --from=buildstage /tmp/znc/usr/ /usr/
COPY --from=buildstage /tmp/znc/packages /packages

USER root


RUN \
  echo "**** install runtime packages ****" && \
  RUNTIME_PACKAGES=$(echo $(cat /packages)) && \
  apt-get update && \
  if [ -n "${RUNTIME_PACKAGES}" ]; then apt-get install -y --no-install-recommends ${RUNTIME_PACKAGES}; fi

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 6501

VOLUME /config

WORKDIR /config
