FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS src

ARG VERSION=5.44.3

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /tmp/pocketmine \
 && curl -fsSL -o /tmp/pocketmine.tar.gz \
      "https://github.com/pmmp/PocketMine-MP/archive/refs/tags/${VERSION}.tar.gz" \
 && tar xzf /tmp/pocketmine.tar.gz -C /tmp/pocketmine --strip-components=1 \
 && rm -f /tmp/pocketmine.tar.gz \
 # UNVERIFIED: no sha256 recorded yet. The release API gives a digest for this asset; add sha256sum -c before shipping.
 && curl -fsSL -o /tmp/pocketmine/PocketMine-MP.phar \
      "https://github.com/pmmp/PocketMine-MP/releases/download/${VERSION}/PocketMine-MP.phar"


# PHP is compiled from the source tree with the upstream script (build/php/compile.sh -t linux64).
# The amd64 prebuilt PHP tarball URL was not located, so both arches compile the same way.
# Built on the same ubuntu 26.04 base as the runtime, not the upstream 22.04.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build-php

USER root

# UNVERIFIED: build dependency list, taken from the upstream note "build-essential, bison, re2c, cmake, etc.".
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      autoconf \
      bison \
      re2c \
      cmake \
      pkg-config \
      git \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=src /tmp/pocketmine /tmp/pocketmine

# Long compile. Record the time in the PR.
# UNVERIFIED: compile.sh output directory. Upstream copies its output to /opt/pocketmine/bin.
RUN cd /tmp/pocketmine/build/php \
 && ./compile.sh -t linux64 -j "$(nproc)" -f -g -P5 \
 && mkdir -p /opt/pocketmine \
 && cp -r bin /opt/pocketmine/bin


FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION=5.44.3

ENV TERM=xterm \
    HOME=/config \
    TMPDIR=/tmp

USER root

COPY --from=build-php /opt/pocketmine/bin /opt/pocketmine/bin
COPY --from=src /tmp/pocketmine/PocketMine-MP.phar /opt/pocketmine/PocketMine-MP.phar
COPY --from=src /tmp/pocketmine/LICENSE /usr/share/licenses/pocketmine-mp/LICENSE

# UNVERIFIED: php binary path inside the compiled output (upstream: bin/php7/bin/php).
RUN ln -s /opt/pocketmine/bin/php7/bin/php /usr/local/bin/php \
 && chmod -R 755 /opt/pocketmine /usr/share/licenses/pocketmine-mp

# UNVERIFIED: ship the PHP licence files from the compiled source as well.

WORKDIR /config
VOLUME ["/config"]
EXPOSE 19132/udp

COPY --chmod=0755 . /

USER apps
