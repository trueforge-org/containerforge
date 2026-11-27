# Initial draft from plan.md. UNVERIFIED items are marked inline.

# Frontend build (pinry-spa) needs node; the Python runtime comes from the python base.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend
ARG VERSION
USER root
ENV PNPM_HOME=/tmp/pnpm \
    PATH=/tmp/pnpm:$PATH

# The tag archive is the pin. No release assets or published checksum exist (UNVERIFIED: record the sha256 at first build).
RUN mkdir -p /tmp/src \
 && curl -fsSL -o /tmp/pinry.tar.gz "https://github.com/pinry/pinry/archive/refs/tags/v${VERSION}.tar.gz" \
 && tar xzf /tmp/pinry.tar.gz -C /tmp/src --strip-components=1 \
 && rm -f /tmp/pinry.tar.gz

# pnpm version comes from the packageManager field of pinry-spa/package.json (UNVERIFIED that the field exists).
# The dist output name is UNVERIFIED; check it in the build.
RUN corepack enable \
 && cd /tmp/src/pinry-spa \
 && pnpm install --frozen-lockfile \
 && pnpm build

# Final stage: Python runtime from the ContainerForge python base (venv at /app/venv).
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d
ARG VERSION
USER root
WORKDIR /app

COPY --from=frontend /tmp/src /app/pinry
COPY --from=frontend /tmp/src/pinry-spa/dist /app/pinry/static
COPY --from=frontend /tmp/src/LICENSE /usr/share/licenses/pinry/LICENSE

# Upstream also installs nginx and pwgen; not carried over unless the runtime needs them (UNVERIFIED).
# requirements.txt location is UNVERIFIED.
RUN PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install --no-cache-dir -r /app/pinry/requirements.txt \
 && chown -R root:root /app && chmod -R 755 /app \
 && rm -rf /tmp/*

# DJANGO_SETTINGS_MODULE is set by the upstream image, but its module path is UNVERIFIED. Do not guess it here.
ENV PYTHONPATH=/app/pinry \
    PATH=/app/venv/bin:$PATH

USER apps
COPY --chmod=0755 . /

WORKDIR /app/pinry
EXPOSE 8000
VOLUME /config
