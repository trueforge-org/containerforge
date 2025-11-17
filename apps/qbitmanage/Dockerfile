

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5
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
