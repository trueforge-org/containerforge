FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# Upstream abusesa/github-backup commit (VERSION in docker-bake.hcl)
ARG VERSION
ARG GITHUB_BACKUP_REF

ENV HOME=/config \
    GIT_CONFIG_GLOBAL=/tmp/gitconfig

USER root

# git is needed at runtime: backup.py clones repositories.
# UNVERIFIED: check whether the base already ships git and drop it if so.
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Fetch the pinned upstream source. UNVERIFIED: no sha256 is recorded in the plan, so only the commit ref pins it.
RUN set -eux; \
    curl -fsSL -o /tmp/github-backup.tar.gz "https://github.com/abusesa/github-backup/archive/${GITHUB_BACKUP_REF}.tar.gz"; \
    mkdir -p /app/github-backup; \
    tar -xzf /tmp/github-backup.tar.gz -C /app/github-backup --strip-components=1; \
    rm -f /tmp/github-backup.tar.gz

# Python dependencies go into the base image venv at build time. Nothing is written to /app at runtime.
RUN set -eux; \
    pip install --no-cache-dir uv; \
    uv pip install --no-cache --requirement /app/github-backup/requirements.txt; \
    pip uninstall --yes uv; \
    rm -rf /root/.cache /tmp/*

# Licenses: upstream is MIT.
RUN set -eux; \
    mkdir -p /usr/share/licenses/llalon-github-backup; \
    cp /app/github-backup/LICENSE /usr/share/licenses/llalon-github-backup/LICENSE; \
    chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

VOLUME ["/config"]

CMD ["/start.sh"]
