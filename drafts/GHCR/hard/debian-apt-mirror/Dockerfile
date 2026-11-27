FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

ARG VERSION

ENV HOME=/config

USER root

# apt-mirror comes from the distro archive, and the package is architecture-independent.
# UNVERIFIED: the Ubuntu 26.04 package version. Pin it to the 0.5.4 release once checked with `apt-cache policy apt-mirror`.
# The Apache2 and cron packages of the upstream image are not installed: nginx (from the base) serves the mirror,
# and start.sh runs the sync loop.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends apt-mirror; \
    rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the copyright file of the package holds the GPL text. It is shipped as the license file.
RUN set -eux; \
    mkdir -p /usr/share/licenses/debian-apt-mirror; \
    cp /usr/share/doc/apt-mirror/copyright /usr/share/licenses/debian-apt-mirror/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config

ENTRYPOINT ["/start.sh"]
