
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# Static Go binary, so no runtime packages are needed.
# SUM.sha512 lists every platform, so only the line for this archive is checked.
# UNVERIFIED: exact SUM.sha512 line format (plan says "<hash>  ./<file>").
RUN echo "*** Installing sshwifty ***" && \
  base="https://github.com/nirui/sshwifty/releases/download/${VERSION}-prebuild" && \
  file="sshwifty_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSL -o "/tmp/${file}" "${base}/${file}" && \
  curl -fsSL -o /tmp/SUM.sha512 "${base}/SUM.sha512" && \
  (cd /tmp && grep "${file}\$" SUM.sha512 | sha512sum -c -) && \
  mkdir -p /tmp/x /usr/share/licenses/sshwifty /usr/share/doc/sshwifty && \
  tar xzf "/tmp/${file}" -C /tmp/x && \
  install -m 0755 "/tmp/x/sshwifty_linux_${TARGETARCH}" /app/sshwifty && \
  cp /tmp/x/LICENSE.md /tmp/x/DEPENDENCIES.md /usr/share/licenses/sshwifty/ && \
  cp /tmp/x/sshwifty.conf.example.json /tmp/x/preset.example.json /usr/share/doc/sshwifty/ && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8182

VOLUME /config
WORKDIR /config
