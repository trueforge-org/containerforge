

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:cdc35c1e179c9ebb98d18ad2f3c3b5ff340fbda5e75ccbd4f022ef7da5885760
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
