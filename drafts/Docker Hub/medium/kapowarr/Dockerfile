# Initial draft from plan.md. UNVERIFIED items are marked inline.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
ARG VERSION
USER root
WORKDIR /app

# The release zip is architecture-neutral, so one download serves amd64 and arm64.
# The checksum is the GitHub release asset digest; refresh it on each VERSION bump.
# Zip layout (where requirements.txt and Kapowarr.py sit) is UNVERIFIED; check with `python -m zipfile -l`.
# Python 3.15 wheels for cryptography >=46.0.5 are UNVERIFIED (3.14 fallback in plan section 3).
RUN set -eux; \
    echo "*** Installing Kapowarr ***"; \
    mkdir -p /app/kapowarr; \
    curl -fsSL -o /tmp/kapowarr.zip "https://github.com/Casvt/Kapowarr/releases/download/V${VERSION}/Kapowarr-release.zip"; \
    echo "b90ce35f767627ce609025f7eeb1fc31b3cab4e9e975ca9c7d79c84bbd32f05b  /tmp/kapowarr.zip" | sha256sum -c -; \
    /app/venv/bin/python -m zipfile -e /tmp/kapowarr.zip /app/kapowarr; \
    PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install -r /app/kapowarr/requirements.txt; \
    mkdir -p /usr/share/licenses/kapowarr; \
    curl -fsSL -o /usr/share/licenses/kapowarr/LICENSE "https://raw.githubusercontent.com/Casvt/Kapowarr/V${VERSION}/LICENSE"; \
    chown -R root:root /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5656
VOLUME /config
