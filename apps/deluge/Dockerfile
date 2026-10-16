

# stay on python 3.14 until Ubuntu ships python3-libtorrent for 3.15 (no PyPI wheels)
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
ARG VERSION

ENV DELUGE_BIN="deluged" \
    XDG_CONFIG_HOME="/config" \
    PYTHON_EGG_CACHE="/config/plugins/.python-eggs"

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        geoip-database \
        p7zip-full \
        python3-libtorrent \
    # PyPI has no libtorrent wheels for Python 3.14; expose Ubuntu's build to the image python
    && ln -s "$(python3 -c 'import sys; import importlib.util as u; sys.path.insert(0, "/usr/lib/python3/dist-packages"); print(u.find_spec("libtorrent").origin)')" \
        "$(python3 -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')/" \
    # Deluge currently imports pkg_resources (removed in setuptools 81+) and
    # OpenSSL.crypto.X509Req (removed in pyOpenSSL 26.3).
    && pip3 install --break-system-packages geoip2 "setuptools<81" "pyOpenSSL<26.3" "deluge==${VERSION}" \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:48c0ce2609bb3c35764956bbd9395e95b177421e3c74b3628c3676029f24f2e0 /usr/bin/unrar-ubuntu /usr/bin/unrar

# Switch to non-root user
USER apps
COPY --chmod=0755 . /

WORKDIR /config
