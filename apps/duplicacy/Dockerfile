

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:01cc09f895d289305f12087ced3d9b01ad74ec5e958384d3274a7caa87a94c37
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
