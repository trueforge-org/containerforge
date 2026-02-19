

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:8b4bc444de4cf6adfc309c1d748674d60f2c849924b456cbdc93650f8566bca7
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
COPY container-test.yaml /container-test.yaml

COPY . /

WORKDIR /config
