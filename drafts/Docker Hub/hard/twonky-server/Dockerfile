FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG TWONKY_SHA256

USER root

ENV HOME=/config \
    TMPDIR=/tmp

# The vendor binary is x86-64 glibc only.
RUN test "${TARGETARCH}" = "amd64" || { echo "twonky-server: amd64 only" >&2; exit 1; }

# ffmpeg from apt replaces the static build the upstream image copied in. cgi-bin/ffmpeg.location points at /usr/bin/ffmpeg.
# The vendor serves the zip over plain http, so the pinned sha256 is the integrity check.
# UNVERIFIED: Twonky 8.5.2 is the only Linux build checked. The 8.5.3 Linux zip returned 403.
# The Terms PDFs ship in the zip. twonky.license is not copied, because it may be a purchased license key (UNVERIFIED).
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    mkdir -p /app/twonky /usr/share/licenses/twonky-server && \
    curl -fsSL -o /tmp/twonky.zip "http://download.twonky.com/${VERSION}/twonky-x86-64-glibc-2.22-${VERSION}.zip" && \
    echo "${TWONKY_SHA256}  /tmp/twonky.zip" | sha256sum -c - && \
    unzip -q /tmp/twonky.zip -d /app/twonky && \
    cp /app/twonky/NOTICES-Server.txt /usr/share/licenses/twonky-server/ && \
    cp /app/twonky/*.pdf /usr/share/licenses/twonky-server/ && \
    chmod 0755 /app/twonky/twonkyserver /app/twonky/twonkystarter && \
    chown -R root:root /app && chmod -R a+rX /app && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9000/tcp 1900/udp
VOLUME /config
WORKDIR /config
CMD ["/start.sh"]
