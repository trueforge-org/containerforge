# UNVERIFIED: base digest carried over from plan.md; re-pin before merge.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# SHA256 of the amd64 tarball from the OpenTTD release page for VERSION.
ARG OPENTTD_SHA256_AMD64="f49eb25d61b00f8f4d332fee02b530ad75552d1efb8f2bb01e7ca5e6540fe059"
USER root

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  XDG_CACHE_HOME=/tmp

# UNVERIFIED: no arm64 tarball on the release page; the apt openttd route (version must match VERSION) is not implemented, so arm64 fails on purpose.
# xz-utils and curl are expected in the base image (UNVERIFIED), so no apt-get install here.
RUN echo "*** Installing OpenTTD ${VERSION} ***" && \
  if [ "$TARGETARCH" = "amd64" ]; then \
    curl -fL -o /tmp/openttd.tar.xz \
      "https://cdn.openttd.org/openttd-releases/${VERSION}/openttd-${VERSION}-linux-generic-amd64.tar.xz" && \
    echo "${OPENTTD_SHA256_AMD64}  /tmp/openttd.tar.xz" | sha256sum -c - && \
    mkdir -p /app/openttd && \
    tar -xJf /tmp/openttd.tar.xz -C /app/openttd --strip-components=1 && \
    rm /tmp/openttd.tar.xz && \
    echo "*** Installing license ***" && \
    install -D -m0644 /app/openttd/COPYING /usr/share/licenses/openttd/COPYING ; \
  else \
    echo "arm64 build not implemented yet" && exit 1 ; \
  fi

USER apps
COPY --chmod=0755 . /

EXPOSE 3979/tcp
EXPOSE 3979/udp

VOLUME /config
