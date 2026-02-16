
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG WIREGUARD_RELEASE

RUN \
  if [ -z ${WIREGUARD_RELEASE+x} ]; then \
  WIREGUARD_RELEASE=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APTINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:wireguard-tools$/,/V:/' /tmp/APTINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  echo "**** install dependencies ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    bc \
    coredns \
    iproute2 \
    iptables \
    iptables \
    iputils \
    kmod \
    libcap2-bin \
    libqrencode-tools \
    net-tools \
    nftables \
    openresolv \
    wireguard-tools==${WIREGUARD_RELEASE} && \
  echo "wireguard" >> /etc/modules && \
  sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] && [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] && cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick && \
  rm -rf /etc/wireguard && \
  ln -s /config/wg_confs /etc/wireguard && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 51820/udp

WORKDIR /config
VOLUME /config
