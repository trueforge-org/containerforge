# Ubuntu base as used by apps/pwndrop (Go built in a build stage, copied into the runtime stage).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
# UNVERIFIED: sha256 of https://git.mills.io/prologic/shorturl/archive/v0.1.0.tar.gz. Not computed yet; the build fails until it is set in docker-bake.hcl.
ARG CHECKSUM

USER root

# UNVERIFIED: golang-go from the Ubuntu 26.04 archive may not build a 2017 source tree. See plan.md section 10 (R2).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      golang-go \
 && rm -rf /var/lib/apt/lists/*

# GOPATH layout, as the upstream build stage uses. Caches go to /tmp.
ENV GOPATH=/tmp/go \
    GOCACHE=/tmp/go-build \
    GO111MODULE=auto

RUN set -eux; \
    mkdir -p /tmp/go/src/github.com/prologic/shorturl /tmp/dl; \
    curl -fsSL -o /tmp/dl/shorturl.tar.gz \
      "https://git.mills.io/prologic/shorturl/archive/${VERSION}.tar.gz"; \
    echo "${CHECKSUM}  /tmp/dl/shorturl.tar.gz" | sha256sum -c -; \
    tar -xzf /tmp/dl/shorturl.tar.gz -C /tmp/go/src/github.com/prologic/shorturl --strip-components=1; \
    cd /tmp/go/src/github.com/prologic/shorturl; \
    make TAG="${VERSION}" BUILD=dev build; \
    mkdir -p /app/shorturl /usr/share/licenses/shorturl; \
    cp shorturl /app/shorturl/shorturl; \
    cp LICENSE /usr/share/licenses/shorturl/LICENSE; \
    rm -rf /tmp/dl /tmp/go

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

COPY --from=build /app/shorturl /app/shorturl
COPY --from=build /usr/share/licenses/shorturl /usr/share/licenses/shorturl
RUN chown -R root:root /app/shorturl /usr/share/licenses/shorturl \
 && chmod -R 755 /app/shorturl /usr/share/licenses/shorturl

USER apps
COPY --chmod=0755 . /

ENV HOME=/config

EXPOSE 8000
VOLUME /config
WORKDIR /config
