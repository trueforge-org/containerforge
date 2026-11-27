# UNVERIFIED: base and digest taken from plan.md section 3 (ubuntu 26.04, same release as the rocker image).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config
ENV TMPDIR=/tmp
ENV XDG_CACHE_HOME=/tmp/.cache

# UNVERIFIED: r-base-core availability and version on ubuntu 26.04; it must match the R 4.6.2 the chart pins.
# The deb path uses the rocker remap (resolute -> jammy, from install_rstudio.sh), not the resolute codename.
# TODO: add a sha256 check after the first verified download (self-computed; posit publishes no checksum).
# TODO: ship the AGPL-3.0 COPYING under /usr/share/licenses/rstudio/ (source not fetched yet).
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    gdebi-core \
    r-base-core && \
  ARCH="$(dpkg --print-architecture)" && \
  curl -fsSL -o /tmp/rstudio-server.deb \
    "https://download2.rstudio.org/server/jammy/${ARCH}/rstudio-server-${VERSION}-${ARCH}.deb" && \
  gdebi -n /tmp/rstudio-server.deb && \
  rm -f /tmp/rstudio-server.deb && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

COPY --chmod=0755 . /

USER apps

EXPOSE 8787

VOLUME /config

WORKDIR /config
