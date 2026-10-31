# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:205c6561352214872c61edea4909f29afe9be1eee6c61430ce627ca757c137ed

ARG VERSION
ARG TARGETARCH
ARG GRPCURL_VERSION
ARG FORTIO_VERSION
ARG CALICOCTL_VERSION

USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2-utils \
        bind9-dnsutils \
        bird2 \
        bridge-utils \
        ca-certificates \
        conntrack \
        curl \
        dhcping \
        ethtool \
        file \
        fping \
        git \
        httpie \
        iftop \
        iperf \
        iperf3 \
        iproute2 \
        ipset \
        iptables \
        iptraf-ng \
        iputils-ping \
        iputils-tracepath \
        ipvsadm \
        jq \
        ldnsutils \
        ltrace \
        mtr-tiny \
        netcat-openbsd \
        nftables \
        ngrep \
        nmap \
        openssh-client \
        openssl \
        oping \
        python3-scapy \
        snmp \
        socat \
        speedtest-cli \
        strace \
        swaks \
        tcpdump \
        tcptraceroute \
        termshark \
        traceroute \
        trippy \
        tshark \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/* /var/tmp/*

# Tools that Ubuntu does not package
RUN set -eu; \
    cd /tmp; \
    grpcurl_arch="${TARGETARCH}"; \
    if [ "${grpcurl_arch}" = "amd64" ]; then grpcurl_arch="x86_64"; fi; \
    grpcurl_file="grpcurl_${GRPCURL_VERSION}_linux_${grpcurl_arch}.tar.gz"; \
    curl -fsSLO "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/${grpcurl_file}"; \
    curl -fsSL "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_checksums.txt" | grep " ${grpcurl_file}$" | sha256sum -c -; \
    tar -xzf "${grpcurl_file}" -C /usr/local/bin grpcurl; \
    curl -fsSL "https://github.com/fortio/fortio/releases/download/v${FORTIO_VERSION}/fortio-linux_${TARGETARCH}-${FORTIO_VERSION}.tgz" | tar -xz -C / usr/bin/fortio; \
    calicoctl_file="calicoctl-linux-${TARGETARCH}"; \
    curl -fsSLO "https://github.com/projectcalico/calico/releases/download/${CALICOCTL_VERSION}/${calicoctl_file}"; \
    curl -fsSL "https://github.com/projectcalico/calico/releases/download/${CALICOCTL_VERSION}/SHA256SUMS" | grep " ${calicoctl_file}$" | sha256sum -c -; \
    install -m 0755 "${calicoctl_file}" /usr/local/bin/calicoctl; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

CMD ["sleep", "infinity"]
