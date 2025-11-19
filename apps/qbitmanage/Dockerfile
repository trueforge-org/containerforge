

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:6119b5ecab933bfd4ceb9c7e56b8c93379b830d6a5af0aa9cb7b014e1078be8f
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/StuffAnThings/qbit_manage/archive/v${VERSION}.tar.gz" | tar xzf - -C "/app" --strip-components=1 && \
    pip3 install --break-system-packages --no-cache-dir --upgrade "/app" && \
    chmod -R u=rwX,go=rX "/app" && \
    chown -R apps:apps "/app"


USER apps:apps

COPY . /

WORKDIR /config
