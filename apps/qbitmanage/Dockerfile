

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d5ee44265ccc73d87135ab858d4cf4e793603f0efe7180d8b44acfe3af54db42
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/StuffAnThings/qbit_manage/archive/v${VERSION}.tar.gz" | tar xzf - -C "/app" --strip-components=1 && \
    pip3 install --break-system-packages --no-cache-dir --upgrade "/app" && \
    chmod -R u=rwX,go=rX "/app" && \
    chown -R apps:apps "/app"


USER apps

COPY . /

WORKDIR /config
