FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

# UNVERIFIED: s3cmd works without libmagic1 (python-magic is only a dependency); add apt libmagic1 if the run fails.
# UNVERIFIED: curl is in the base and the LICENSE path on the tag v${VERSION} exists.
RUN /app/venv/bin/pip install --no-cache-dir "s3cmd==${VERSION}" && \
    /app/venv/bin/s3cmd --version && \
    mkdir -p /usr/share/licenses/s3cmd /data && \
    curl -fsSL "https://raw.githubusercontent.com/s3tools/s3cmd/v${VERSION}/LICENSE" \
      -o /usr/share/licenses/s3cmd/LICENSE && \
    chown -R root:root /app/venv

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
