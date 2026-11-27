# Splunk Enterprise 10.6 (proprietary, see LICENSE). Plain tarball install on the ContainerForge ubuntu base.
# The upstream splunk/docker-splunk packaging (ansible, root) is not ported.
# Checksum: SPLUNK_SHA512 is copied from the .sha512 file published next to the tarball (UNVERIFIED value, see docker-bake.hcl).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG SPLUNK_BUILD
ARG SPLUNK_SHA512
ARG TARGETARCH

ENV SPLUNK_HOME=/app/splunk \
    HOME=/config \
    TMPDIR=/tmp \
    PATH=/app/splunk/bin:${PATH}

USER root

# Splunk ships a 64-bit x86 Linux build only. Fail early for other platforms and for an empty checksum.
RUN set -eux; \
    [ "${TARGETARCH}" = "amd64" ] || { echo "Splunk ${SPLUNK_BUILD} has no ${TARGETARCH} build"; exit 1; }; \
    [ -n "${SPLUNK_SHA512}" ] || { echo "SPLUNK_SHA512 is empty"; exit 1; }; \
    curl -fsSL -o /tmp/splunk.tgz "https://download.splunk.com/products/splunk/releases/${SPLUNK_BUILD%%-*}/linux/splunk-${SPLUNK_BUILD}-linux-amd64.tgz"; \
    echo "${SPLUNK_SHA512}  /tmp/splunk.tgz" | sha512sum -c -; \
    tar xzf /tmp/splunk.tgz -C /app; \
    rm -f /tmp/splunk.tgz; \
    /app/splunk/bin/splunk version --accept-license | grep -q "${VERSION}"

# Keep the pristine config for first-start seeding, and point etc and var at /config (persistent, /app is read-only at runtime).
# UNVERIFIED: the license file names in the tarball; copy whatever license and credits files it ships.
RUN set -eux; \
    mv /app/splunk/etc /app/splunk/etc.dist; \
    rm -rf /app/splunk/var; \
    ln -s /config/etc /app/splunk/etc; \
    ln -s /config/var /app/splunk/var; \
    install -d -m 0755 /usr/share/licenses/splunk; \
    cp /app/splunk/license-eula.txt /usr/share/licenses/splunk/license-eula.txt; \
    cp /app/splunk/third-party-credits.txt /usr/share/licenses/splunk/third-party-credits.txt; \
    chown -R apps:apps /app/splunk

USER apps
COPY --chmod=0755 . /

WORKDIR /app/splunk

EXPOSE 8000 8089 9997

VOLUME /config

USER apps
