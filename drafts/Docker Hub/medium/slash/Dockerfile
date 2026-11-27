# build stage: UI (Node 22). UNVERIFIED: pin node:22-alpine by digest once fetched.
FROM node:22-alpine AS frontend

ARG VERSION
WORKDIR /frontend-build

RUN \
  apk add --no-cache curl && \
  curl -fL -o \
    /tmp/slash.tar.gz \
    "https://github.com/yourselfhosted/slash/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/slash.tar.gz -C \
    /frontend-build --strip-components=1 && \
  rm -f /tmp/slash.tar.gz

WORKDIR /frontend-build/frontend/web
RUN corepack enable && pnpm i --frozen-lockfile && pnpm build

# build stage: backend (Go). UNVERIFIED: pin golang:1.23-alpine by digest; confirm go.mod Go version.
FROM golang:1.23-alpine AS backend

ARG VERSION
ARG TARGETARCH
WORKDIR /backend-build

RUN \
  apk add --no-cache curl && \
  curl -fL -o \
    /tmp/slash.tar.gz \
    "https://github.com/yourselfhosted/slash/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/slash.tar.gz -C \
    /backend-build --strip-components=1 && \
  rm -f /tmp/slash.tar.gz

COPY --from=frontend /frontend-build/frontend/web/dist /backend-build/server/route/frontend/dist

ENV GOCACHE=/tmp/go-cache

RUN \
  mkdir -p /out && \
  CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
    go build -trimpath -ldflags="-s -w" -o /out/slash ./bin/slash/main.go

# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

COPY --from=backend /out/slash /app/slash/slash
COPY --from=backend /backend-build/LICENSE /usr/share/licenses/slash/LICENSE

RUN \
  echo "**** prepare paths ****" && \
  chmod 0755 /app/slash/slash && \
  mkdir -p /var/opt && \
  ln -s /config/slash /var/opt/slash

# copy local files
USER apps
COPY --chmod=0755 . /

ENV TZ=UTC \
    SLASH_MODE=prod \
    SLASH_PORT=5231

# ports and volumes
EXPOSE 5231
VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
