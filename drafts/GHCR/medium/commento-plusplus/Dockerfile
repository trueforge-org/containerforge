
# Source build. Go, Node and yarn come from the ubuntu base (go 1.27.4, node 26.13.1, yarn 1.22.22).
# UNVERIFIED: upstream v1.8.7 pins Go 1.15 and Node 12. Confirm the code builds on the base toolchains.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
USER root

ENV \
  HOME=/tmp \
  GOPATH=/tmp/go \
  GOCACHE=/tmp/go-build \
  GOMODCACHE=/tmp/go/pkg/mod \
  NPM_CONFIG_CACHE=/tmp/npm \
  YARN_CACHE_FOLDER=/tmp/yarn

RUN echo "*** Fetching commento++ ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential && \
  rm -rf /var/lib/apt/lists/* && \
  curl -fL -o /tmp/commento.tar.gz \
    "https://github.com/souramoo/commentoplusplus/archive/refs/tags/${VERSION}.tar.gz" && \
  mkdir -p /build/commento && \
  tar xzf /tmp/commento.tar.gz -C /build/commento --strip-components=1 && \
  rm /tmp/commento.tar.gz

WORKDIR /build/commento

# UNVERIFIED: the upstream Dockerfile runs `make ${RELEASE}` per folder (api, frontend, templates, db).
# The README says the root `make prod` produces build/prod/commento. The output layout is not confirmed.
RUN echo "*** Building commento++ ${VERSION} ***" && \
  make prod

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV \
  COMMENTO_BIND_ADDRESS=0.0.0.0

# UNVERIFIED: upstream final stage copies commento, js, css, images, fonts, i18n, *.html, templates/ and db/
COPY --from=builder /build/commento/build/prod /app/commento
COPY --from=builder /build/commento/LICENSE /usr/share/licenses/commento-plusplus/LICENSE

RUN chown -R apps:apps /app/commento && \
  chmod -R 755 /app/commento

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
