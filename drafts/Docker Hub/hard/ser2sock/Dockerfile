# ser2sock 1.5.5 (GPL-3.0-only), built from the upstream tag on the ContainerForge ubuntu base.
# Upstream: https://github.com/nutechsoftware/ser2sock (tags only, no published checksum; the tag is pinned by VERSION).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION

USER root
WORKDIR /tmp

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential autoconf automake libtool pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# UNVERIFIED: make DESTDIR=/out install places the binary under /usr/local/bin and the license under /out.
RUN curl -fsSL -o /tmp/ser2sock.tar.gz "https://github.com/nutechsoftware/ser2sock/archive/refs/tags/v${VERSION}.tar.gz" && \
    mkdir /tmp/src && \
    tar xzf /tmp/ser2sock.tar.gz -C /tmp/src --strip-components=1 && \
    rm /tmp/ser2sock.tar.gz && \
    cd /tmp/src && \
    autoreconf -f -i && \
    ./configure --prefix=/usr/local && \
    make && \
    make DESTDIR=/out install && \
    install -D -m 0644 /tmp/src/COPYING /out/usr/share/licenses/ser2sock/COPYING

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# socat is only used for the virtual serial pair in demo mode (start.sh). libssl is already in the base.
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends socat && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /out/usr/local/bin/ser2sock /usr/local/bin/ser2sock
COPY --from=build /out/usr/share/licenses/ser2sock /usr/share/licenses/ser2sock

ENV HOME=/config \
    LISTENER_PORT=10000 \
    BAUD_RATE=9600

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 10000

VOLUME /config

CMD ["/start.sh"]

USER apps
