FROM ghcr.io/trueforge-org/java17:17.0.16@sha256:efdc903d9ce0436b6207bc5a4e732d24a27231851975c999770fd8709a8316b8

ARG VERSION
ARG TARGETARCH

ENV HOME=/config

USER root

# UNVERIFIED: the java17 base must ship every JRE module SongKong needs.
# The vendor publishes no per-arch Linux build, so image-all is amd64 only.
RUN echo "*** Installing SongKong ${VERSION} ***" && \
  mkdir -p /app /tmp/songkong-dl && \
  curl -fsSL -o /tmp/songkong-dl/songkong.tgz \
    "https://www.jthink.net/songkong/downloads/current/songkong-linux-headless-novm.tgz?val=82" && \
  # UNVERIFIED: no checksum is published and the URL is unversioned ("current").
  # TODO: verify the archive version against VERSION once the version file is located.
  tar xzf /tmp/songkong-dl/songkong.tgz -C /app --strip-components=1 && \
  echo "*** Recording license pointer ***" && \
  mkdir -p /usr/share/licenses/songkong && \
  find /app -maxdepth 2 -type f \( -iname 'license*' -o -iname 'eula*' -o -iname 'notice*' \) \
    -exec cp {} /usr/share/licenses/songkong/ \; && \
  echo "SongKong is proprietary software. Vendor page: https://www.jthink.net/songkong/" \
    > /usr/share/licenses/songkong/VENDOR-LICENSE-URL.txt && \
  # upstream data path /songkong resolves into the persistent /config volume
  ln -s /config /songkong && \
  chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/songkong-dl

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 4567
VOLUME /config
