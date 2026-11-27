# BLOCKERS (see plan.md section 10): the Ace Stream engine is closed source with no redistribution terms found,
# and it needs a CPython 3.10 shared library that this python:3.15 base does not ship. Do not publish before both are cleared.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
ARG VERSION
ARG ENGINE_VERSION
# UNVERIFIED: commit of vstavrinov/acestream_search to pin (the upstream install is an unpinned git HEAD)
ARG ACESTREAM_SEARCH_REF
ARG TARGETARCH
USER root
RUN test "${TARGETARCH}" = "amd64" || { echo "Ace Stream engine is amd64 only" >&2; exit 1; }
ENV PIP_CACHE_DIR=/tmp/pip UV_CACHE_DIR=/tmp/uv-cache PYTHONDONTWRITEBYTECODE=1
# UNVERIFIED: package availability on the base OS
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx git unzip ca-certificates curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ace Stream engine. The sha256 below is the measured value for ENGINE_VERSION 3.2.11 only, update it with the version.
RUN set -eux; \
    curl -fsSL -o /tmp/ace.tgz "https://download.acestream.media/linux/acestream_${ENGINE_VERSION}_ubuntu_22.04_x86_64_py3.10.tar.gz"; \
    echo "9b6bbd76a55e5a434641afae3b9cf8e6154ce1cf392152ec3aed5ac265432b2e  /tmp/ace.tgz" | sha256sum -c -; \
    mkdir -p /app/engine; \
    tar xzf /tmp/ace.tgz -C /app/engine; \
    cd /app/engine/lib; \
    for e in *.egg; do [ -e "$e" ] || break; unzip -q -o "$e"; rm -f "$e"; done; \
    rm -f /tmp/ace.tgz

# CPython 3.10 for the engine via uv (python-build-standalone). UNVERIFIED: shared libpython3.10 is provided.
RUN set -eux; \
    python3 -m venv /tmp/uvtool; \
    /tmp/uvtool/bin/pip install --no-cache-dir uv; \
    UV_PYTHON_INSTALL_DIR=/opt/python310 /tmp/uvtool/bin/uv python install 3.10; \
    PY310="$(find /opt/python310 -path '*/bin/python3.10' | head -n 1)"; \
    test -x "$PY310"; \
    /tmp/uvtool/bin/uv venv --python "$PY310" /app/venv310; \
    /tmp/uvtool/bin/uv pip install --python /app/venv310/bin/python -r /app/engine/requirements.txt; \
    LD_LIBRARY_PATH="/app/engine/lib:$(dirname "$PY310")/../lib" ldd /app/engine/acestreamengine | grep -q 'not found' && exit 1 || true; \
    rm -rf /tmp/uvtool /tmp/uv-cache

# Search service (gunicorn + flask + acestream_search) into the base venv, at build time only
RUN set -eux; \
    [ -n "${ACESTREAM_SEARCH_REF}" ] || { echo "ACESTREAM_SEARCH_REF not pinned (UNVERIFIED)" >&2; exit 1; }; \
    /app/venv/bin/pip install --no-cache-dir gunicorn flask "git+https://github.com/vstavrinov/acestream_search.git@${ACESTREAM_SEARCH_REF}"

# No vendor licence file in the tarball or the wrapper repo: write a notice instead
RUN mkdir -p /usr/share/licenses/acestream \
    && printf '%s\n' "Ace Stream engine: proprietary, see https://acestream.org/ (licence terms UNVERIFIED)." "Wrapper: https://github.com/vstavrinov/acestream-service (no licence file found)." > /usr/share/licenses/acestream/NOTICE

RUN rm -rf /var/lib/apt/lists/* /tmp/* \
    && chown -R root:root /app \
    && chmod -R a+rX /app

# Copy configuration files into container (start.sh, scripts/, etc/nginx/)
COPY --chmod=0755 . /

ENV HOME=/tmp TMPDIR=/tmp PORT=8080 SCHEME=http ENTRY= COLUMNS=116
EXPOSE 8080
VOLUME /config
USER apps
CMD ["/start.sh"]
