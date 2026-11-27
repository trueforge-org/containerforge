FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a as buildstage

# build variables
ARG VERSION
USER root

# UNVERIFIED: the apt golang-go on 26.04 must build go.mod (go 1.13); confirm with `go version` in the build log
RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    golang-go

# keep Go caches out of the image and out of /config
ENV GOCACHE=/tmp/go-cache \
    GOMODCACHE=/tmp/go-mod \
    GOPATH=/tmp/go

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/golinks && \
  curl -fL -o \
    /tmp/golinks-src.tar.gz \
    "https://git.mills.io/prologic/golinks/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/golinks-src.tar.gz -C \
    /tmp/golinks --strip-components=1

RUN \
  echo "**** compile golinks ****" && \
  cd /tmp/golinks && \
  go install github.com/GeertJohan/go.rice/rice@v1.0.2 && \
  /tmp/go/bin/rice embed-go && \
  mkdir -p \
    /app/golinks && \
  CGO_ENABLED=0 go build \
    -tags "netgo static_build" \
    -trimpath \
    -ldflags "-s -w" \
    -o /app/golinks/golinks \
    . && \
  mkdir -p \
    /usr/share/licenses/golinks && \
  cp /tmp/golinks/LICENSE /usr/share/licenses/golinks/LICENSE

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# build variables
ARG VERSION
USER root

# add golinks binary and its license
COPY --from=buildstage /app/golinks/ /app/golinks/
COPY --from=buildstage /usr/share/licenses/golinks/ /usr/share/licenses/golinks/

RUN \
  chown -R apps:apps /app/golinks && \
  chmod -R 755 /app/golinks

ENV HOME=/config \
    BIND=0.0.0.0:8000 \
    BASEURL=http://localhost:8000 \
    DBPATH=/config/search.db \
    TITLE=Search

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8000/tcp

WORKDIR /config
VOLUME /config
