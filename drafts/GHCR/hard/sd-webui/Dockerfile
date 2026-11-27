FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# Git refs for CLIP and open_clip. The plan does not name them, so they have no default and
# the build fails until they are set to pinned commits (UNVERIFIED values, not invented here).
ARG CLIP_PKG_REF
ARG OPENCLIP_PKG_REF
USER root

# /app is read-only at runtime. Caches and HOME go to /tmp, data and outputs to /config.
ENV PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_CACHE_DIR=/tmp/pip \
    HOME=/tmp/home \
    XDG_CACHE_HOME=/tmp/.cache \
    DATA_DIR=/config/data \
    WEBUI_PORT=7860

# UNVERIFIED: package names. git is needed for the CLIP and open_clip git installs.
# ffmpeg and libgl1 are assumed needed by the pinned requirements. Check on the first build.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        ffmpeg \
        libgl1 \
        libglib2.0-0; \
    rm -rf /var/lib/apt/lists/*

# Source at build time, from the release tag. Upstream clones five more repos (stablediffusion,
# BLIP, k-diffusion, generative-models, stable-diffusion-webui-assets) into repositories/ at
# pinned refs. Those refs are not in the plan, so they are not added yet (UNVERIFIED gap).
RUN set -eux; \
    mkdir -p /app/stable-diffusion-webui; \
    curl -fsSL -o /tmp/sd-webui.tar.gz \
        "https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/tags/v${VERSION}.tar.gz"; \
    tar xzf /tmp/sd-webui.tar.gz -C /app/stable-diffusion-webui --strip-components=1; \
    rm -f /tmp/sd-webui.tar.gz

# Python deps go into the base image's /app/venv at build time, never at runtime.
# UNVERIFIED: Python 3.15 compatibility of the pinned torch, xformers and gradio stack.
# xformers is not installed. The upstream gradio routes.py sed patch is dropped: it is tied to
# /usr/local/lib/python3.10 and must be re-checked against the venv's gradio before it is added back.
RUN set -eux; \
    /app/venv/bin/pip install --no-cache-dir -r /app/stable-diffusion-webui/requirements_versions.txt; \
    /app/venv/bin/pip install --no-cache-dir "git+https://github.com/openai/CLIP.git@${CLIP_PKG_REF}"; \
    /app/venv/bin/pip install --no-cache-dir "git+https://github.com/mlfoundations/open_clip.git@${OPENCLIP_PKG_REF}"

# Licence from the upstream tarball (AGPL-3.0; upstream LICENSE.txt).
RUN set -eux; \
    install -D -m 0644 /app/stable-diffusion-webui/LICENSE.txt /usr/share/licenses/sd-webui/LICENSE.txt; \
    chmod -R a+rX /app; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 7860
VOLUME /config

WORKDIR /app/stable-diffusion-webui
