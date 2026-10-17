FROM ghcr.io/trueforge-org/golang:1.27.2@sha256:b220b4a2c6345a5845612ada9f218028681cf5ce7cf4d8f0b0ab3fd8ad680be5 as buildstage

# build variables
ARG VERSION
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    golang-go

RUN \
echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/pwndrop && \
  (curl -fL -o \
  /tmp/pwndrop-src.tar.gz \
    "https://github.com/kgretzky/pwndrop/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
  /tmp/pwndrop-src.tar.gz \
    "https://github.com/kgretzky/pwndrop/archive/refs/tags/v${VERSION}.tar.gz" || (PWDROP_RELEASE=$(curl -sX GET "https://api.github.com/repos/kgretzky/pwndrop/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]') && curl -fL -o \
  /tmp/pwndrop-src.tar.gz \
    "https://github.com/kgretzky/pwndrop/archive/refs/tags/${PWDROP_RELEASE}.tar.gz")) && \
  tar xf \
  /tmp/pwndrop-src.tar.gz -C \
    /tmp/pwndrop --strip-components=1 && \
  echo "**** compile pwndrop  ****" && \
  cd /tmp/pwndrop && \
  go build -ldflags="-s -w" \
    -o /app/pwndrop/pwndrop \
    -mod=vendor \
    main.go && \
  cp -r ./www /app/pwndrop/admin

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:fbb8b286bdadd3cda896e800061cc867ad228255b76c968de072f2bf16794598

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add pwndrop
COPY --from=buildstage /app/pwndrop/ /app/pwndrop/

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8080 4443

WORKDIR /config
VOLUME /config
