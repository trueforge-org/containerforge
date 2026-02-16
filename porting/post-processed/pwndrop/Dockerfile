FROM ghcr.io/trueforge-org/golang:1.26.0 as buildstage

# build variables

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    go

RUN \
echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/pwndrop && \
  curl -o \
  /tmp/pwndrop-src.tar.gz -L \
    "https://github.com/kgretzky/pwndrop/archive/${VERSION}.tar.gz" && \
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
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add pwndrop
COPY --from=buildstage /app/pwndrop/ /app/pwndrop/

RUN \
# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 8080 4443

WORKDIR /config
VOLUME /config
