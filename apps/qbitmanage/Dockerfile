

FROM ghcr.io/trueforge-org/python:3.14.7@sha256:05a7bc16dd8486cbe36714903407947136771e66de31cf93d562200e8a665def
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/StuffAnThings/qbit_manage/archive/${VERSION}.tar.gz" | tar xzf - -C "/app" --strip-components=1 && \
    pip3 install --break-system-packages --no-cache-dir --upgrade "/app" && \
    chmod -R u=rwX,go=rX "/app" && \
    chown -R apps:apps "/app"


USER apps

COPY --chmod=0755 . /

WORKDIR /config
