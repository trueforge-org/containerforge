
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV \
    HOME=/config \
    PASTEY_DATA_DIRECTORY=/config/data

# Upstream release 0.5.1 (2022) pins Python 3.8 era deps. The patches below are UNVERIFIED on
# Python 3.15 and are asserted with grep so the build fails loudly if a patch misses.
RUN set -eux; \
    echo "*** Installing pastey ***"; \
    mkdir -p /app/pastey /usr/share/licenses/pastey; \
    curl -fsSL -o /tmp/pastey.tar.gz "https://github.com/Cesura/pastey/archive/refs/tags/${VERSION}.tar.gz"; \
    tar xzf /tmp/pastey.tar.gz -C /app/pastey --strip-components=1; \
    rm -f /tmp/pastey.tar.gz; \
    cd /app/pastey; \
    echo "*** Removing TensorFlow / guesslang (slim variant) ***"; \
    ./patch_no_tensorflow.sh; \
    if grep -Eq '^[^#]*guesslang' app.py requirements.txt; then echo "guesslang still active"; exit 1; fi; \
    echo "*** Relaxing pins for Python 3.15 ***"; \
    sed -i -E 's/^(Flask|Flask-Limiter|cryptography)~=.*/\1/' requirements.txt; \
    grep -Eq '^Flask$' requirements.txt; \
    sed -i 's/^    app,$/    app=app,/' app.py; \
    grep -q 'app=app,' app.py; \
    find /app/pastey -name '*.py' -exec sed -i \
      's/^from distutils.util import strtobool$/strtobool = lambda v: str(v).strip().lower() in ("y", "yes", "t", "true", "on", "1")/' {} +; \
    if grep -rq --include='*.py' 'distutils' /app/pastey; then echo "distutils still imported"; exit 1; fi; \
    echo "*** Installing Python dependencies ***"; \
    python3 -m pip install --no-cache-dir -r requirements.txt; \
    cp LICENSE /usr/share/licenses/pastey/LICENSE; \
    echo "*** Cleaning up ***"; \
    chown -R root:root /app/pastey; \
    chmod -R a+rX,go-w /app/pastey; \
    rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

WORKDIR /app/pastey

EXPOSE 5000

VOLUME /config
