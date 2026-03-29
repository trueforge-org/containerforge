

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:1685c0f458568fddff62e0fe0f0804de9d13469bd9fc967bc8c7bde606166969
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ARG TARGETARCH=${TARGETARCH/arm64/arm64}
ARG TARGETARCH=${TARGETARCH/amd64/x64}


USER root
WORKDIR /app


VOLUME ["/cache","/logs"]

RUN mkdir -p "/var/lib/dbus" && ln -s "/config/machine-id" "/var/lib/dbus/machine-id" || :
RUN ln -s "/config/" "/app/.duplicacy-web"

RUN curl -fsSL "https://acrosync.com/duplicacy-web/duplicacy_web_linux_${TARGETARCH}_${VERSION}" > "/app/duplicacy_web" && \
    chmod 755 "/app/duplicacy_web" \
    && chown -R apps:apps /app


USER apps
COPY --chmod=0755 . /
VOLUME ["/cache","/logs"]
WORKDIR /config
EXPOSE 3875
