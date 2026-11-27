FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS buildstage

ARG VERSION
ARG DNSTOOL_REF
ARG CACHE_DOMAINS_REF

USER root

ENV GOCACHE=/tmp/gocache \
    GOPATH=/tmp/go

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        golang-go && \
    rm -rf /var/lib/apt/lists/*

# dnstool is built without cgo so the binary runs in the final image unchanged.
# UNVERIFIED: golang-go version against the dnstool go.mod, and the main package location.
RUN git clone https://github.com/lancachenet/lancache-dns.git /src/lancache-dns && \
    git -C /src/lancache-dns checkout "${VERSION}" && \
    git clone https://github.com/lancachenet/dnstool.git /src/dnstool && \
    git -C /src/dnstool checkout "${DNSTOOL_REF}" && \
    git clone https://github.com/uklans/cache-domains.git /src/cache-domains && \
    git -C /src/cache-domains checkout "${CACHE_DOMAINS_REF}" && \
    cd /src/dnstool && \
    CGO_ENABLED=0 go build -trimpath -ldflags "-s -w" -o /out/dnstool . && \
    mkdir -p /out/licenses && \
    cp /src/lancache-dns/LICENSE /out/licenses/LICENSE && \
    cp /src/dnstool/LICENSE /out/licenses/dnstool-LICENSE && \
    cp /src/cache-domains/LICENSE /out/licenses/cache-domains-LICENSE && \
    rm -rf /src/cache-domains/.git /tmp/gocache /tmp/go

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

USER root

# UNVERIFIED: bind9 version is not pinned. Pin it once the Ubuntu 26.04 version is read (plan section 4).
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bind9 \
        dnsutils \
        libcap2-bin && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/named && \
    install -d -o apps -g apps /config && \
    apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=buildstage /out/dnstool /usr/local/bin/dnstool
COPY --from=buildstage /src/cache-domains /app/cache-domains
COPY --from=buildstage /out/licenses/ /usr/share/licenses/lancache-dns/

USER apps
COPY --chmod=0755 . /

EXPOSE 53/udp 53/tcp
VOLUME /config

CMD ["/start.sh"]
