# The system Python is used so that python3-gi and the GStreamer bindings from apt work in the venv.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG SRC_SHA256

USER root

# UNVERIFIED: package names on Ubuntu 26.04 and the exact GStreamer set.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        ffmpeg \
        gir1.2-gst-plugins-base-1.0 \
        gir1.2-gstreamer-1.0 \
        gstreamer1.0-libav \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-tools \
        libffi-dev \
        libjpeg-dev \
        libpng-dev \
        libsndfile1 \
        poppler-utils \
        python3 \
        python3-dev \
        python3-gi \
        python3-gst-1.0 \
        python3-venv \
        sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Upstream tag archive. Checksum pinned by hand, bump with VERSION.
RUN curl -fsSL -o /tmp/mediagoblin.tar.gz "https://git.sr.ht/~mediagoblin/mediagoblin/archive/v${VERSION}.tar.gz" && \
    echo "${SRC_SHA256}  /tmp/mediagoblin.tar.gz" | sha256sum -c - && \
    install -d /tmp/src && \
    tar xzf /tmp/mediagoblin.tar.gz -C /tmp/src --strip-components=1 && \
    rm -f /tmp/mediagoblin.tar.gz

# Venv with system site packages, so that python3-gi and GStreamer are visible.
RUN python3 -m venv --system-site-packages /app/venv && \
    PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install --no-cache-dir "/tmp/src[audio]"

# Defaults are taken from the upstream source tree, so no config text is invented here.
# UNVERIFIED: paste.ini is at the repo root. Its broadcast server binds 0.0.0.0:6543 upstream.
RUN install -d /app/mediagoblin-defaults && \
    cp /tmp/src/mediagoblin.example.ini /app/mediagoblin-defaults/mediagoblin.ini && \
    cp /tmp/src/paste.ini /app/mediagoblin-defaults/paste.ini && \
    install -d /usr/share/licenses/mediagoblin && \
    cp -r /tmp/src/licenses/. /usr/share/licenses/mediagoblin/ && \
    cp /tmp/src/COPYING /usr/share/licenses/mediagoblin/COPYING

# Drop the compiler and dev headers, then clean up. /config is the persistent data directory.
RUN apt-get purge -y --auto-remove build-essential python3-dev libffi-dev libjpeg-dev libpng-dev && \
    install -d -o 568 -g 568 /config && \
    rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache

ENV HOME=/config \
    PATH=/app/venv/bin:${PATH} \
    PYTHONDONTWRITEBYTECODE=1 \
    XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 6543

VOLUME /config

CMD ["/start.sh"]
