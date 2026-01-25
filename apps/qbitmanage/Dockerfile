

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:28879e692c9ef5264f2bc23dc0cb2ff1402c276b2126309e00eb097ee5ebc1a1
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
