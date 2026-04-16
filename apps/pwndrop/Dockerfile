FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:48b8c4f16a22d675e504971c7a18b5384346a081b4c2f031923eb23f16c7d68d as buildstage

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
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:b91efc25164fbe723a41eca66f239d8f6c008fd7d10ceda9d5ba0975104d0432

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
