

FROM ghcr.io/trueforge-org/python:3.14.8@sha256:c298a5e065ea46d0280a6f0e4b696c549d169a280e63ee6b49791865753112ca
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
