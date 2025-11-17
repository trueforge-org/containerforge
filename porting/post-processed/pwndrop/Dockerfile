## TODO pin version tag
FROM ghcr.io/trueforge-org/go:rolling as buildstage

# build variables

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    build-base \
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
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

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
