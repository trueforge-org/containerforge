

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:0859da470a5092cf1bdec06d87165ec6eebd7d490682b89035f450db869223fb
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
