FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# Java runtime for the Minecraft servers Crafty starts. Only JRE 21 is copied here.
# UNVERIFIED: upstream installs JREs 8, 11, 17, 21 and 25, and which ones are needed is not checked.
COPY --from=ghcr.io/trueforge-org/java21:21.0.8@sha256:5651f46cebe5a42ff069da176dd7ab50f6b050169493fe06ebc1be2fe81cd15e /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk \
    PATH=/opt/java/openjdk/bin:${PATH}

# Fetch the tagged source and check that the tag still points at the pinned commit.
# Install the Python requirements into the bundled /app/venv at build time only.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*; \
    git clone --depth 1 --branch "v${VERSION}" https://gitlab.com/crafty-controller/crafty-4.git /tmp/crafty-src; \
    test "$(git -C /tmp/crafty-src rev-parse HEAD)" = "c5c08effa959d570075f951a364216ebd658ca22"; \
    cp -a /tmp/crafty-src /app/crafty; \
    /app/venv/bin/pip install --no-cache-dir -r /app/crafty/requirements.txt; \
    mkdir -p /usr/local/share/crafty-4; \
    mv /app/crafty/app/config /usr/local/share/crafty-4/config_original; \
    mv /usr/local/share/crafty-4/config_original/default.json.example /usr/local/share/crafty-4/config_original/default.json; \
    install -D -m 0644 /app/crafty/LICENSE /usr/share/licenses/crafty-4/LICENSE; \
    rm -rf /app/crafty/.git /tmp/crafty-src

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8443 8000
VOLUME /config
