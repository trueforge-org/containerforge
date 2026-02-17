

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:0c2ff68fa63566e2fcbe025b58c229a612b4eba0377a0dc77b4b820a7d0c2ffd
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
