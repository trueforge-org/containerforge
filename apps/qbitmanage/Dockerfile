

FROM ghcr.io/trueforge-org/python:3.14.7@sha256:1b4e02f5ae67a789aaf0f3d0d059a6eee7da28a9998c7018070edff055aff72a
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
