FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV BLOCKY_CONFIG_FILE=/config/config.yml

# Checksums from blocky_checksums.txt for v0.37.0. Update them together with VERSION.
RUN echo "*** Installing Blocky ***" && \
  case "${TARGETARCH}" in \
    amd64) blocky_arch="x86_64"; blocky_sha="784d0617cb39944ca80197a9fe7ac2d796bcf1154dafb36a598c776a6c18da0e" ;; \
    arm64) blocky_arch="arm64"; blocky_sha="7ebd9f112d847eb37f8bb60930822865a2909627a33f1f969ded1557da56a904" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  archive="blocky_v${VERSION}_Linux_${blocky_arch}.tar.gz" && \
  curl -fsSL -o "/tmp/${archive}" \
    "https://github.com/0xERR0R/blocky/releases/download/v${VERSION}/${archive}" && \
  echo "${blocky_sha}  /tmp/${archive}" | sha256sum -c - && \
  mkdir -p /tmp/blocky-src /app && \
  tar -xzf "/tmp/${archive}" -C /tmp/blocky-src && \
  install -m 0755 /tmp/blocky-src/blocky /app/blocky && \
  echo "*** Installing license (UNVERIFIED: tarball may not ship LICENSE, so fetch it from the tag) ***" && \
  mkdir -p /usr/share/licenses/blocky && \
  curl -fsSL -o /usr/share/licenses/blocky/LICENSE \
    "https://raw.githubusercontent.com/0xERR0R/blocky/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/blocky-src "/tmp/${archive}"

USER apps
COPY --chmod=0755 . /

EXPOSE 4000 5353/tcp 5353/udp

VOLUME /config

CMD ["/start.sh"]
