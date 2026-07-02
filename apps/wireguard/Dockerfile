
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d

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
