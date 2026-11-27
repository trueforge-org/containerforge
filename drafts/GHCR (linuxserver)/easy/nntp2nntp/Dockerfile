# BLOCKED: upstream nntp2nntp is Python 2 only (print statement, setup.py classifiers 2.6 and 2.7).
# This image will not work on the Python 3 base until a Python 3 source is chosen (plan section 10).
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

# UNVERIFIED: GitHub archive directory name (nntp2nntp-<tag>) and the Python 3 compatibility of the dependencies
RUN set -eux; \
    mkdir -p /tmp/nntp2nntp /usr/share/licenses/nntp2nntp; \
    curl -fsSL -o /tmp/nntp2nntp/src.tar.gz "https://github.com/linuxserver/nntp2nntp/archive/${VERSION}.tar.gz"; \
    tar -xzf /tmp/nntp2nntp/src.tar.gz -C /tmp/nntp2nntp; \
    cp "/tmp/nntp2nntp/nntp2nntp-${VERSION}/LICENSE" /usr/share/licenses/nntp2nntp/; \
    /app/venv/bin/python -m pip install --no-cache-dir /tmp/nntp2nntp/src.tar.gz service_identity; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 1563

VOLUME /config

CMD [""]
