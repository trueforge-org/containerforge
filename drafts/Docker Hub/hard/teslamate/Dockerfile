FROM elixir:1.20.4-otp-29 AS builder
# UNVERIFIED: pin the elixir:1.20.4-otp-29 digest at implementation time
ARG VERSION
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV HEX_HOME=/tmp/hex MIX_HOME=/tmp/mix npm_config_cache=/tmp/npm
USER root
# Source: upstream tag v${VERSION}, full repo so ../grafana, ../VERSION, ../LICENSE resolve as upstream expects
ADD https://github.com/teslamate-org/teslamate.git#v${VERSION} /opt/app
# Node 22 from NodeSource (upstream steps), UNVERIFIED: NodeSource key URL
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg brotli \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/app/elixir
ENV MIX_ENV=prod
RUN mix local.rebar --force && mix local.hex --force
RUN mix deps.get --only prod && mix deps.compile
RUN npm ci --prefix ./assets
RUN mix assets.deploy && mix compile
RUN mix release --path /opt/built \
    && mkdir -p /opt/legal \
    && cp /opt/app/NOTICE /opt/app/LICENSE /opt/legal/

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libodbc2 libsctp1 libssl3t64 libstdc++6 tini tzdata \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /opt/built/ /app/teslamate/
COPY --from=builder /opt/legal/ /usr/share/licenses/teslamate/
# The release is read-only at runtime
RUN chown -R apps:apps /app && chmod -R 755 /app
# HOME and caches in /config or /tmp; release temp dir in /tmp (read-only rootfs)
ENV LANG=C.UTF-8 HOME=/config SRTM_CACHE=/tmp/srtm_cache RELEASE_TMP=/tmp/release PORT=4000
EXPOSE 4000
VOLUME /config

# Copy configuration files into container
COPY --chmod=0755 . /

USER apps
