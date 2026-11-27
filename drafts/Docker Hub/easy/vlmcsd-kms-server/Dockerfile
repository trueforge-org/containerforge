FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root

# Upstream ships no linux/arm64 binary, so vlmcsd is built from the tagged source on every platform.
# No checksum is published for the source archive; the pinned tag is the integrity anchor.
RUN echo "*** Building vlmcsd ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends build-essential && \
  rm -rf /var/lib/apt/lists/* && \
  curl -fsSL -o /tmp/vlmcsd.tar.gz \
    "https://github.com/Wind4/vlmcsd/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/vlmcsd.tar.gz -C /tmp && \
  cd "/tmp/vlmcsd-${VERSION}" && \
  make -j"$(nproc)" && \
  mkdir -p /out && \
  cp bin/vlmcsd bin/vlmcs /out/ && \
  cp man/vlmcsd.8 /out/vlmcsd.8 && \
  cp etc/vlmcsd.ini /out/vlmcsd.ini.sample && \
  rm -rf /tmp/vlmcsd.tar.gz "/tmp/vlmcsd-${VERSION}"

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

ENV \
  HOME=/config

COPY --from=build /out/vlmcsd /app/vlmcsd
COPY --from=build /out/vlmcs /app/vlmcs
COPY --from=build /out/vlmcsd.8 /usr/share/doc/vlmcsd/vlmcsd.8
COPY --from=build /out/vlmcsd.ini.sample /usr/share/doc/vlmcsd/vlmcsd.ini.sample

# UNVERIFIED: upstream publishes no license file at this tag. Replace this notice with the real license text once decided.
RUN echo "*** Finalising vlmcsd ***" && \
  mkdir -p /usr/share/licenses/vlmcsd && \
  echo "vlmcsd ${VERSION} from https://github.com/Wind4/vlmcsd. No license file is published upstream at this tag." > /usr/share/licenses/vlmcsd/README && \
  chown -R apps:apps /app && chmod 0755 /app/vlmcsd /app/vlmcs

USER apps
COPY --chmod=0755 . /

EXPOSE 1688

VOLUME /config
