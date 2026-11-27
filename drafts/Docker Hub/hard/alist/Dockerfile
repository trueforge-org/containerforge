
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# alist and aria2 write nothing to $HOME by design; keep it off /app
ENV \
  HOME=/tmp

RUN echo "*** Installing aria2 (optional helper, enabled at runtime with ENABLE_ARIA2=true) ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    aria2 \
    ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# Only md5 is published upstream, so this checks for corruption, not tampering (see plan section 10)
RUN echo "*** Installing alist ${VERSION} ***" && \
  mkdir -p /app /usr/share/licenses/alist && \
  curl -fsSL -o /tmp/alist.tar.gz \
    "https://github.com/AlistGo/alist/releases/download/v${VERSION}/alist-linux-${TARGETARCH}.tar.gz" && \
  curl -fsSL -o /tmp/md5.txt \
    "https://github.com/AlistGo/alist/releases/download/v${VERSION}/md5.txt" && \
  (cd /tmp && grep " ./alist-linux-${TARGETARCH}.tar.gz$" md5.txt | sed 's#\./##' | md5sum -c -) && \
  tar xzf /tmp/alist.tar.gz -C /app alist && \
  curl -fsSL -o /usr/share/licenses/alist/LICENSE \
    "https://raw.githubusercontent.com/AlistGo/alist/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/alist.tar.gz /tmp/md5.txt

USER apps
COPY --chmod=0755 . /

# aria2 RPC (6800) is opt-in and not exposed by default
EXPOSE 5244

VOLUME /config
