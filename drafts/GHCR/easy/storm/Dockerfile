FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Static Go binary from the upstream release tarball, verified against the
# published .sha256 file. The .sha256 file holds only the hash, so the filename
# is added for sha256sum.
# UNVERIFIED: the tarball layout (binary at root or in a subdirectory). The
# install below assumes the binary is named "storm" at the top level.
# UNVERIFIED: the LICENSE path at the tag. Only the binary is extracted, so the license is shipped separately.
RUN set -eux; \
    base="https://github.com/relvacode/storm/releases/download/v${VERSION}"; \
    file="storm-v${VERSION}-linux-${TARGETARCH}.tar.gz"; \
    mkdir -p /tmp/storm /app /usr/share/licenses/storm; \
    curl -fsSL -o "/tmp/storm/${file}" "${base}/${file}"; \
    curl -fsSL -o /tmp/storm/storm.sha256 "${base}/${file}.sha256"; \
    (cd /tmp/storm && echo "$(cat storm.sha256)  ${file}" | sha256sum -c -); \
    tar -xzf "/tmp/storm/${file}" -C /tmp/storm; \
    install -m 0755 /tmp/storm/storm /app/storm; \
    curl -fsSL -o /usr/share/licenses/storm/LICENSE "https://raw.githubusercontent.com/relvacode/storm/v${VERSION}/LICENSE"; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/storm

USER apps
COPY --chmod=0755 . /

EXPOSE 8221
