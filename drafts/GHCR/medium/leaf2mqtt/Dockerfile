# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: Dart 2.x SDK. The pubspec requires sdk <3.0.0. Version and sha256 are not confirmed; supply them through docker-bake.hcl.
ARG DART_SDK_VERSION
ARG DART_SDK_SHA256
# UNVERIFIED: sha256 of the v0.6 source tarball. Not published upstream; compute once and pin.
ARG LEAF2MQTT_SHA256

USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates curl unzip && \
    rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the Dart archive URL and arch names for 2.x releases.
RUN case "${TARGETARCH}" in \
        amd64) DART_ARCH=x64 ;; \
        arm64) DART_ARCH=arm64 ;; \
        *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fL -o /tmp/dartsdk.zip \
        "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_SDK_VERSION}/sdk/dartsdk-linux-${DART_ARCH}-release.zip" \
    && echo "${DART_SDK_SHA256}  /tmp/dartsdk.zip" | sha256sum -c - \
    && unzip -q /tmp/dartsdk.zip -d /usr/local \
    && rm -f /tmp/dartsdk.zip

ENV PATH=/usr/local/dart-sdk/bin:${PATH} \
    PUB_CACHE=/tmp/pub-cache \
    HOME=/tmp

RUN curl -fL -o /tmp/src.tar.gz "https://github.com/mitsumaui/leaf2mqtt/archive/refs/tags/${VERSION}.tar.gz" \
    && echo "${LEAF2MQTT_SHA256}  /tmp/src.tar.gz" | sha256sum -c - \
    && mkdir -p /build/leaf2mqtt \
    && tar -xzf /tmp/src.tar.gz -C /build/leaf2mqtt --strip-components=1 \
    && rm -f /tmp/src.tar.gz

WORKDIR /build/leaf2mqtt
# Dependencies include three git repos (gitlab.com and github.com). They may have moved since the archived v0.6 (UNVERIFIED).
RUN dart pub get \
    && mkdir -p /out \
    && dart compile exe src/leaf_2_mqtt.dart -o /out/leaf_2_mqtt

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# Runtime libraries for the AOT binary are UNVERIFIED. Check with ldd in the builder and add packages only if missing.
COPY --from=builder --chmod=0755 /out/leaf_2_mqtt /app/bin/leaf_2_mqtt
COPY --from=builder /build/leaf2mqtt/LICENSE /usr/share/licenses/leaf2mqtt/LICENSE

ENV HOME=/tmp

USER apps
COPY --chmod=0755 . /

VOLUME /config

CMD ["/start.sh"]
