

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:00750811fb5c6481942d0f9903fa012e5c221ebb8ddd261024fb72fecf456429
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
