# UNVERIFIED: base and digest taken from plan.md section 3 (ubuntu 26.04). Apache and the module come from apt.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# The module package is pinned to VERSION (1.4.1-6). UNVERIFIED: apache2 is not pinned; no version was read from the archive.
# UNVERIFIED: the module's a2enmod name (musicindex) and whether the package already enables it (a2enmod is idempotent).
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-musicindex="${VERSION}" && \
  a2enmod musicindex && \
  mkdir -p /usr/share/licenses/apache-musicindex && \
  cp /usr/share/doc/libapache2-mod-musicindex/copyright /usr/share/licenses/apache-musicindex/copyright && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# Overrides /etc/apache2/apache2.conf: listens on 8080, runtime files under /tmp (see etc/apache2/apache2.conf).
COPY --chmod=0755 . /

USER apps

EXPOSE 8080
