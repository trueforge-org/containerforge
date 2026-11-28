
# Source: the upstream release has no binary assets, so the tag archive is fetched once and shared by both build stages.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS src
ARG VERSION
USER root
RUN echo "*** Fetching Hasty Paste source ***" && \
  curl -fL -o /tmp/hasty-paste.tar.gz \
    "https://github.com/enchant97/hasty-paste/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /src && \
  tar xzf /tmp/hasty-paste.tar.gz -C /src --strip-components=1 && \
  rm /tmp/hasty-paste.tar.gz

# Frontend build (upstream node-base + node-build stages).
# UNVERIFIED: exact Node major in python-node; confirm with `node -v`.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS web-build
USER root
ENV HOME=/tmp \
  PNPM_HOME=/tmp/pnpm \
  PATH=/tmp/pnpm:$PATH
COPY --from=src /src /src
WORKDIR /src/app
RUN npm install -g --force corepack@latest && \
  corepack enable && \
  corepack prepare pnpm --activate && \
  pnpm install --frozen-lockfile && \
  pnpm run build

# Go build (upstream go-build stage). Static binary, so the alpine build image is not shipped.
# UNVERIFIED: digest for golang:1.26-alpine not resolved; pin it once confirmed.
FROM golang:1.26-alpine@sha256:ecb67f987aa1a57794c91d19ade7ae0209f2f0f5496aaef9e6ae85ddf92d02ab AS go-build
ARG TARGETOS
ARG TARGETARCH
ENV GOCACHE=/tmp/go-cache \
  GOPATH=/tmp/go \
  GOMODCACHE=/tmp/go/pkg/mod
COPY --from=src /src /src
WORKDIR /src/app
RUN mkdir -p /out && \
  go tool sqlc generate && \
  go tool templ generate && \
  CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/hasty-paste .

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

ENV \
  BIND__HOST=0.0.0.0 \
  BIND__PORT=8080 \
  DB_URI=sqlite:///config/data/db.sqlite \
  ATTACHMENTS_PATH=/config/data/attachments \
  HOME=/config

COPY --from=go-build --chmod=0755 /out/hasty-paste /app/hasty-paste
# UNVERIFIED: how `serve` resolves dist/ (relative to the working dir or a fixed path); see plan section 10.
COPY --from=web-build /src/app/dist /app/dist
COPY --from=src --chmod=0644 /src/LICENSE.txt /usr/share/licenses/hasty-paste/LICENSE.txt

RUN chown -R apps:apps /app && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /app
