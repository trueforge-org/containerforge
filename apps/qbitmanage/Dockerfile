

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:8ba5cf93d8f36593fc5dcc55bdccc40f581008ab4732dca1f7c520daae9f145b
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

COPY --chmod=0755 . /

WORKDIR /config
