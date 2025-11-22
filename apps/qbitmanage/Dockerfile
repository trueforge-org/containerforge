

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:7f3a002d8125a23f160f8f78ce367051200d136d2424bb028b5b55d2cfc5b6a3
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
