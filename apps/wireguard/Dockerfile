
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a1011d7c17be3f647e02872e2cdfe59154fb145297e1b5ceaba30341fcda262e

# set version label
ARG VERSION
ARG TARGETARCH
USER root
RUN \
  echo "**** install dependencies ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    bc \
    iproute2 \
    iptables \
    iputils-ping \
    kmod \
    libcap2-bin \
    qrencode \
    net-tools \
    nftables \
    wireguard-tools && \
  echo "wireguard" >> /etc/modules && \
  sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] && [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] && cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick && \
  rm -rf /etc/wireguard && \
  ln -s /config/wg_confs /etc/wireguard && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 51820/udp

WORKDIR /config
VOLUME /config
