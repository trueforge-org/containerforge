# Upstream app bundle comes from the last published image. Keep the tag and digest in step.
# UNVERIFIED: the digest was read from the registry API and is not re-checked here.
ARG VERSION=4.0.1
FROM mongoclient/mongoclient:${VERSION}@sha256:885dd82b3db780258d1204850058453e0db7f7010b8a75033fac066062318f04 AS src

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION=4.0.1
ARG NODE_VERSION=12.16.1
ARG NODE_SHA256=b826753f14df9771609ffb8e7d2cc4cb395247cb704cf0cea0f04132d9cf3505
ARG TARGETARCH

USER root

# The upstream bundle is amd64 only, so fail clearly on any other architecture.
RUN if [ "${TARGETARCH}" != "amd64" ]; then echo "nosqlclient: amd64 only, no arm64 build exists" >&2; exit 1; fi

# UNVERIFIED: xz-utils and curl are not in the base image; pin them if they are added.
RUN apt-get update && \
    apt-get install -y --no-install-recommends xz-utils curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Node 12 runs the upstream Meteor bundle. It is EOL and kept outside /app.
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz && \
    echo "${NODE_SHA256}  /tmp/node.tar.xz" | sha256sum -c - && \
    mkdir -p /usr/local/lib/node12 && \
    tar -xJf /tmp/node.tar.xz -C /usr/local/lib/node12 --strip-components=1 && \
    ln -s /usr/local/lib/node12/bin/node /usr/local/bin/node12 && \
    mkdir -p /usr/share/licenses/nosqlclient && \
    cp /usr/local/lib/node12/LICENSE /usr/share/licenses/nosqlclient/LICENSE-node && \
    rm -f /tmp/node.tar.xz

COPY --from=src /opt/meteor/dist/bundle /app

# UNVERIFIED: the LICENSE path on the tag exists. The bundle may ship its own copy.
RUN rm -f /app/entrypoint.sh && \
    curl -fsSL "https://raw.githubusercontent.com/nosqlclient/nosqlclient/${VERSION}/LICENSE" \
      -o /usr/share/licenses/nosqlclient/LICENSE && \
    chown -R root:root /app && \
    chmod -R a+rX /app

ENV HOME=/tmp/home \
    PORT=3000 \
    ROOT_URL=http://localhost \
    NODE_ENV=production

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
WORKDIR /app

CMD ["/start.sh"]
