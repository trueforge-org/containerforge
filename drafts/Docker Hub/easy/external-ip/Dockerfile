FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# renovate: datasource=pypi depName=apprise
ARG APPRISE_VERSION=2.3.0

ENV PATH=/app/venv/bin:$PATH

USER root

# dig (bind9-dnsutils) for the cloudflare, google and opendns providers. bash and curl come from the base.
RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9-dnsutils && \
    rm -rf /var/lib/apt/lists/*

# apprise CLI into the base venv at build time only (/app/venv is read-only at runtime).
RUN /app/venv/bin/pip install --no-cache-dir "apprise==${APPRISE_VERSION}"

# Upstream shell libraries at the pinned commit. Our own start.sh replaces upstream scripts/start.sh.
# Upstream publishes no checksum, so the full commit SHA in the URL is the integrity anchor.
RUN mkdir -p /app/scripts /usr/share/licenses/external-ip && \
    curl -fsSL -o /tmp/external-ip.tar.gz "https://github.com/xavier-hernandez/docker-external-ip/archive/${VERSION}.tar.gz" && \
    tar xzf /tmp/external-ip.tar.gz -C /tmp && \
    cp -r /tmp/docker-external-ip-*/scripts/lib /app/scripts/lib && \
    cp /tmp/docker-external-ip-*/LICENSE /usr/share/licenses/external-ip/LICENSE && \
    sed -i 's/curl -s -k /curl -s /' /app/scripts/lib/ipv4.sh && \
    chown -R apps:apps /app/scripts && chmod -R 755 /app/scripts && \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

VOLUME /config
