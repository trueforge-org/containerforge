# hadolint ignore=DL3007,DL3002
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION

USER root

# UNVERIFIED: package names on 26.04 (libsass-dev, libpcre3-dev) are taken from the upstream Alpine build (libsass-dev, pcre). Check with apt-cache.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xz-utils \
        libsass-dev \
        libpcre3-dev \
    && rm -rf /var/lib/apt/lists/*

# UNVERIFIED: Nim 2.2.6 toolchain. The upstream build image is Alpine-only and cannot be reused. Confirm the install method
# and add its checksum before merge. The URL below is a placeholder shape, not a checked download.
RUN curl -fsSL -o /tmp/nim.tar.xz "https://nim-lang.org/download/nim-2.2.6-linux_x64.tar.xz" \
    && mkdir -p /opt/nim \
    && tar -xJf /tmp/nim.tar.xz -C /opt/nim --strip-components=1 \
    && rm -f /tmp/nim.tar.xz
ENV PATH="/opt/nim/bin:/root/.nimble/bin:${PATH}"

# UNVERIFIED: the source archive has no published checksum. The commit SHA in VERSION is the pin.
RUN mkdir -p /tmp/src \
    && curl -fsSL -o /tmp/nitter.tar.gz "https://github.com/zedeus/nitter/archive/${VERSION}.tar.gz" \
    && tar -xzf /tmp/nitter.tar.gz -C /tmp/src --strip-components=1 \
    && rm -f /tmp/nitter.tar.gz

WORKDIR /tmp/src
RUN nimble install -y --depsOnly \
    && nimble build -d:danger -d:lto -d:strip --mm:refc \
    && nimble scss \
    && nimble md

# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

# UNVERIFIED: runtime PCRE package name on 26.04 (libpcre3 or libpcre2-8-0).
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpcre3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/src/nitter /app/nitter/nitter
COPY --from=build /tmp/src/public /app/nitter/public
COPY --from=build /tmp/src/nitter.example.conf /defaults/nitter.conf
# UNVERIFIED: LICENSE file name in the upstream repo root. Check before the build.
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/nitter/LICENSE
RUN chmod -R 755 /app/nitter /defaults

COPY --chmod=0755 start.sh /start.sh

ENV HOME=/config \
    TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config

CMD ["/start.sh"]
