FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

# build variables
ARG VERSION
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    golang-go && \
  rm -rf /var/lib/apt/lists/*

# VERSION is a commit SHA (upstream has no release tags); source is pinned by content.
RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /go/src/app && \
  curl -fL -o /tmp/nullserv-src.tar.gz \
    "https://github.com/bmrzycki/nullserv/archive/${VERSION}.tar.gz" && \
  tar xf /tmp/nullserv-src.tar.gz -C /go/src/app --strip-components=1 && \
  rm -f /tmp/nullserv-src.tar.gz

WORKDIR /go/src/app

# same flags as upstream's Dockerfile; mkbuildinfo.sh generates buildinfo.go first
RUN \
  echo "**** compile nullserv ****" && \
  sh ./mkbuildinfo.sh && \
  mkdir -p /app && \
  CGO_ENABLED=0 GOOS=linux GOCACHE=/tmp/go-cache \
    go build -a -trimpath -ldflags '-w -extldflags "-static"' -o /app/nullserv *.go

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

# add nullserv
COPY --from=buildstage /app/nullserv /app/nullserv
COPY --from=buildstage /go/src/app/LICENSE /usr/share/licenses/nullserv/LICENSE

RUN \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  mkdir -p /config && \
  chown -R apps:apps /config

# add local files
USER apps
COPY --chmod=0755 start.sh /start.sh
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080 8443

VOLUME /config
ENTRYPOINT ["/start.sh"]
