FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# glibc release tarball, not the upstream alpine build; checksum comes from the upstream release
RUN echo "*** Installing SheetAble ***" && \
  base="https://github.com/SheetAble/SheetAble/releases/download/v${VERSION}" && \
  file="SheetAble_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSL -o "/tmp/${file}" "${base}/${file}" && \
  curl -fsSL -o /tmp/checksums.txt "${base}/SheetAble_${VERSION}_checksums.txt" && \
  (cd /tmp && grep " ${file}\$" checksums.txt | sha256sum -c -) && \
  tar xzf "/tmp/${file}" -C /app sheetable && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/sheetable && \
  curl -fsSL -o /usr/share/licenses/sheetable/LICENSE \
    "https://raw.githubusercontent.com/SheetAble/SheetAble/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
