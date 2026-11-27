
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION
ARG MKVDTS2AC3_VERSION
ARG MKVDTS2AC3_SHA256
ARG TARGETARCH
USER root

# Version guard: PACKAGE_VERSION carries an apt epoch (7:8.0.1-3ubuntu2), so strip it before comparing.
# hadolint ignore=DL3008,DL3015
RUN p="${PACKAGE_VERSION#*:}" && test "${p%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "ffmpeg=${PACKAGE_VERSION}" \
        mkvtoolnix \
        inotify-tools \
        rsync \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Only mkvdts2ac3.sh and its license are extracted from the archive, so the license ships alongside it.
RUN echo "*** Installing mkvdts2ac3 ***" && \
    mkdir -p /tmp/mkv /app /usr/share/licenses/ffmpeg-mkvdts2ac3 && \
    curl -fsSL -o /tmp/mkvdts2ac3.tar.gz \
        "https://github.com/JakeWharton/mkvdts2ac3/archive/refs/tags/${MKVDTS2AC3_VERSION}.tar.gz" && \
    echo "${MKVDTS2AC3_SHA256}  /tmp/mkvdts2ac3.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/mkvdts2ac3.tar.gz -C /tmp/mkv --strip-components=1 --wildcards '*/mkvdts2ac3.sh' '*/LICENSE.txt' && \
    install -m 0755 /tmp/mkv/mkvdts2ac3.sh /app/mkvdts2ac3.sh && \
    install -m 0644 /tmp/mkv/LICENSE.txt /usr/share/licenses/ffmpeg-mkvdts2ac3/mkvdts2ac3-LICENSE.txt && \
    chown -R apps:apps /app && \
    rm -rf /tmp/*

ENV HOME=/config \
    TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

VOLUME /config

WORKDIR /config
CMD ["/start.sh"]
