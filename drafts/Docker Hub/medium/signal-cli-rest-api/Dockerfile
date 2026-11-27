# Build stage: compile the REST server from the upstream tag (no release binary is published)
# UNVERIFIED: digest for golang:1.26-trixie not pinned; add it after lookup.
FROM golang:1.26-trixie AS build

ARG VERSION
ARG SIGNAL_CLI_VERSION

RUN apt-get update && \
  apt-get install -y --no-install-recommends git ca-certificates wget unzip zip file build-essential libz-dev zlib1g-dev binutils && \
  rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${VERSION}" https://github.com/bbernhard/signal-cli-rest-api /src

WORKDIR /src
# UNVERIFIED: upstream fetches libsignal_jni.so per arch from bbernhard/libsignal-client-builds (v0.102.1), plus swag docs.
# The exact asset URLs and checksums are not in the plan. This is the blocking step; do not ship without it.
RUN go install github.com/swaggo/swag/cmd/swag@v1.16.4 && \
  mkdir -p /out && \
  go build -o /out/signal-cli-rest-api .

# Final stage: JRE for the signal-cli JVM child process
FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3db5983d5bd504865ac842efb282bcbdbd286adbc116fc18645ec3c433eba44a

ARG VERSION
ARG SIGNAL_CLI_VERSION
ARG TARGETARCH
USER root

# Upstream state dir /home/.local/share/signal-cli is remapped to /config/signal-cli
ENV PORT=8080 \
  GIN_MODE=release \
  SIGNAL_CLI_CONFIG_DIR=/config/signal-cli \
  SIGNAL_CLI_REST_API_PLUGIN_SHARED_OBJ_DIR=/usr/bin/ \
  HOME=/config

COPY --from=build /out/signal-cli-rest-api /app/signal-cli-rest-api

# signal-cli JVM tarball (arch-independent). Upstream 0.101 pins 0.14.8; kept for parity.
RUN curl -fL -o /tmp/signal-cli.tgz \
    "https://github.com/AsamK/signal-cli/releases/download/v${SIGNAL_CLI_VERSION}/signal-cli-${SIGNAL_CLI_VERSION}.tar.gz" && \
  tar xzf /tmp/signal-cli.tgz -C /app && \
  mkdir -p /app/bin && \
  ln -s "/app/signal-cli-${SIGNAL_CLI_VERSION}/bin/signal-cli" /app/bin/signal-cli && \
  # UNVERIFIED: LICENSE path inside the signal-cli tarball
  install -D "/app/signal-cli-${SIGNAL_CLI_VERSION}/LICENSE" /usr/share/licenses/signal-cli-rest-api/signal-cli-LICENSE && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

COPY --from=build --chown=root:root /src/LICENSE /usr/share/licenses/signal-cli-rest-api/LICENSE

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8080
VOLUME /config
