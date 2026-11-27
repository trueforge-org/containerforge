# UNVERIFIED (draft): the upstream image is Alpine/musl. This draft rebuilds on ubuntu (plan sections 3 and 10).
# Open blockers, not solved here: DNS on port 53 needs a capability or a remap (section 10);
# the FTL link type (glibc or musl) is not checked (section 11, step 0); PIHOLE_CORE_REF is not set.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG FTL_VERSION
ARG PIHOLE_CORE_REF=""
ARG TARGETARCH
USER root

ENV DNSMASQ_USER=pihole \
  FTL_CMD=no-daemon \
  HOME=/config

# UNVERIFIED: package list is inferred from the draft, not checked against upstream (plan section 4, step 3).
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    lighttpd \
    php-cgi \
    php-sqlite3 \
    php-xml \
    sqlite3 \
    cron \
    curl \
    dnsutils \
    ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# SHA-1 is the only checksum upstream publishes for FTL (plan section 1).
RUN case "${TARGETARCH}" in \
    amd64) ftl_arch=amd64; ftl_sha1=a438611acfee876d08cb6241b2288e3bae9026a1 ;; \
    arm64) ftl_arch=arm64; ftl_sha1=66eba44204c46b3adf03d204edbc663af81266f9 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /usr/local/bin/pihole-FTL \
    "https://github.com/pi-hole/FTL/releases/download/${FTL_VERSION}/pihole-FTL-${ftl_arch}" && \
  echo "${ftl_sha1}  /usr/local/bin/pihole-FTL" | sha1sum -c - && \
  chmod 0755 /usr/local/bin/pihole-FTL

# UNVERIFIED: the pi-hole core ref for image 2026.11.0 is not confirmed (plan section 4, step 5). Fail the build until it is set.
RUN [ -n "${PIHOLE_CORE_REF}" ] || { echo "PIHOLE_CORE_REF is not set" >&2; exit 1; }

RUN mkdir -p /opt/pihole && \
  curl -fsSL "https://github.com/pi-hole/pi-hole/archive/${PIHOLE_CORE_REF}.tar.gz" | tar xz -C /opt/pihole --strip-components=1 && \
  install -D /opt/pihole/LICENSE /usr/share/licenses/pihole/LICENSE && \
  chmod -R 755 /opt/pihole
# UNVERIFIED: the FTL licence is not read, and the web UI source (pi-hole/web) is not addressed (plan section 4).

# Pi-hole config lives on the /config volume. The upstream paths point there.
RUN ln -sfn /config/pihole /etc/pihole && \
  ln -sfn /config/dnsmasq.d /etc/dnsmasq.d

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: the web port (8080) is not set by an env var here, and DNS 53 needs a runtime decision (plan section 10).
EXPOSE 53/tcp 53/udp 8080
VOLUME /config
