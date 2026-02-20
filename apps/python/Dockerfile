

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:e5507376cb59a4669ad6179bc43e081b150558c96ab8e06b558e3b62c71241c8

# Environment variables
ARG VERSION
ARG PIP_VERSION
ARG SETUPTOOLS_VERSION
ARG WHEEL_VERSION

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_PREFER_BINARY=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    PIP_PREFER_BINARY=1 \
    UV_NO_CACHE=true \
    UV_SYSTEM_PYTHON=true \
    UV_EXTRA_INDEX_URL="https://wheel-index.linuxserver.io/ubuntu/ https://pypi.org/simple" \
    UV_INDEX_STRATEGY="unsafe-best-match" \
    PATH=/usr/local/bin:$PATH \
    VENV_FOLDER="/app/venv"

USER root

# Install runtime and build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        libbluetooth-dev \
        tk-dev \
        uuid-dev \
        libncurses-dev \
        libreadline-dev \
        libssl-dev \
        libbz2-dev \
        libffi-dev \
        libsqlite3-dev \
        libgdbm-dev \
        liblzma-dev \
        zlib1g-dev \
        dpkg-dev \
    ; \
    rm -rf /var/lib/apt/lists/*

# Download and verify Python with Sigstore
RUN set -eux; \
    wget -O python.tar.xz "https://www.python.org/ftp/python/${VERSION%%[a-z]*}/Python-${VERSION}.tar.xz"; \
    wget -O python.tar.xz.sigstore "https://www.python.org/ftp/python/${VERSION%%[a-z]*}/Python-${VERSION}.tar.xz.sigstore"; \
    # TODO: setup verification
    # cosign verify-blob --cert python.tar.xz.sigstore python.tar.xz; \
    mkdir -p /usr/src/python; \
    tar -xf python.tar.xz -C /usr/src/python --strip-components=1; \
    rm -f python.tar.xz python.tar.xz.sigstore

# Build Python with official compile flags
RUN set -eux; \
    cd /usr/src/python; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
        --build="$gnuArch" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --with-lto \
        --with-ensurepip \
    ; \
    nproc="$(nproc)"; \
    EXTRA_CFLAGS="$(dpkg-buildflags --get CFLAGS)"; \
    LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
    arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
    EXTRA_CFLAGS="${EXTRA_CFLAGS:-} -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer"; \
    make -j"$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:-}"; \
    rm python; \
    make -j"$nproc" "EXTRA_CFLAGS=${EXTRA_CFLAGS:-}" "LDFLAGS=${LDFLAGS:--Wl},-rpath='\$\$ORIGIN/../lib'" python; \
    make install; \
    cd /; \
    rm -rf /usr/src/python; \
    find /usr/local -depth \
        \( -type d -a \( -name test -o -name tests -o -name idle_test \) \
        -o -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name 'libpython*.a' \) \) -exec rm -rf '{}' +; \
    ldconfig; \
    mkdir -p /app /app; \
    python3 -m venv /app/venv; \
    /app/venv/bin/python -m pip install --upgrade pip==${PIP_VERSION} setuptools==${SETUPTOOLS_VERSION} wheel==${WHEEL_VERSION}; \
    chown -R apps:apps /app && chmod -R 755 /app; \
    python3 --version; \
    pip3 --version

# Create symlinks like official image
RUN set -eux; \
    for src in idle3 pip3 pydoc3 python3 python3-config; do \
        dst="$(echo "$src" | tr -d 3)"; \
        [ -s "/usr/local/bin/$src" ]; \
        [ ! -e "/usr/local/bin/$dst" ]; \
        ln -svT "$src" "/usr/local/bin/$dst"; \
    done

# Switch to non-root user
USER apps
COPY --chmod=0755 . /

HEALTHCHECK CMD ["/healthcheck.sh"]
COPY --chmod=0755 start.sh /start.sh
