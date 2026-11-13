# ---------- UI BUILD STAGE ----------
FROM ghcr.io/trueforge-org/node:26.13@sha256:9089d949e06c56f8eb6a948e0004bcd03a86094fe9c68b1d85c594518d45d517 AS ui

ARG VERSION

USER root
WORKDIR /build

# Fetch the wg-easy source and build the web UI
RUN curl -fsSL -o /tmp/wg-easy.tar.gz "https://github.com/wg-easy/wg-easy/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/wg-easy.tar.gz -C /build --strip-components=1 && \
    rm -f /tmp/wg-easy.tar.gz

WORKDIR /build/src
RUN npm install --global corepack@latest && \
    corepack enable pnpm && \
    pnpm install --frozen-lockfile && \
    pnpm build

# ---------- LIBSQL STAGE ----------
# libsql has to be installed next to the server (https://github.com/nitrojs/nitro/issues/3328)
FROM ghcr.io/trueforge-org/node:26.13@sha256:9089d949e06c56f8eb6a948e0004bcd03a86094fe9c68b1d85c594518d45d517 AS libsql

USER root
WORKDIR /build
RUN npm install --no-save --omit=dev libsql

# ---------- AMNEZIAWG STAGE ----------
FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:a91915f24d7593a9d485df9884eff50dde58df2f49d52da7fd800a6dacaacbfe AS awg

# renovate: datasource=github-releases depName=amnezia-vpn/amneziawg-tools
ARG AWGTOOLS_BRANCH=v3.1.20260812
# renovate: datasource=github-tags depName=amnezia-vpn/amneziawg-go
ARG AWGGO_BRANCH=v3.1.20260828

USER root
WORKDIR /build

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    git clone --depth 1 --branch "${AWGTOOLS_BRANCH}" https://github.com/amnezia-vpn/amneziawg-tools.git && \
    git clone --depth 1 --branch "${AWGGO_BRANCH}" https://github.com/amnezia-vpn/amneziawg-go && \
    export GOCACHE=/tmp/go-cache && \
    (cd amneziawg-go && unset GOPATH && make) && \
    (cd amneziawg-tools/src && make) && \
    sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' amneziawg-tools/src/wg-quick/linux.bash

# ---------- FINAL RUNTIME IMAGE ----------
FROM ghcr.io/trueforge-org/node:26.13@sha256:9089d949e06c56f8eb6a948e0004bcd03a86094fe9c68b1d85c594518d45d517

ARG VERSION

USER root

# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iproute2 \
        iptables \
        kmod \
        nftables \
        procps \
        wireguard-go \
        wireguard-tools && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy && \
    mkdir -p /app /etc/wireguard /etc/amnezia && \
    ln -s /etc/wireguard /etc/amnezia/amneziawg

WORKDIR /app

# Web UI build, migrations and libsql
COPY --from=ui /build/src/.output /app
COPY --from=ui /build/src/server/database/migrations /app/server/database/migrations
COPY --from=libsql /build/node_modules /app/server/node_modules

# cli
COPY --from=ui --chmod=0755 /build/src/cli/cli.sh /usr/local/bin/cli

# amneziawg-go and amneziawg-tools
COPY --from=awg --chmod=0755 /build/amneziawg-go/amneziawg-go /usr/bin/amneziawg-go
COPY --from=awg --chmod=0755 /build/amneziawg-tools/src/wg /usr/bin/awg
COPY --from=awg --chmod=0755 /build/amneziawg-tools/src/wg-quick/linux.bash /usr/bin/awg-quick

RUN chown -R apps:apps /app /etc/wireguard

ENV DEBUG=Server,WireGuard,Database,CMD,Firewall \
    PORT=51821 \
    HOST=0.0.0.0 \
    INSECURE=false \
    INIT_ENABLED=false \
    DISABLE_IPV6=false \
    NODE_ENV=production

USER apps
COPY --chmod=0755 . /

EXPOSE 51820/udp 51821/tcp

VOLUME /etc/wireguard

CMD ["node", "server/index.mjs"]
