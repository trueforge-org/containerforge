# Download stage: fetch the vendor binary and verify it against the vendor's SHA-256 file.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS download

ARG VERSION
ARG TARGETARCH
USER root

RUN set -eux; \
    case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac; \
    base="https://dl.min.io/aistor/minio/release/linux-${TARGETARCH}"; \
    curl -fL -o /tmp/minio "${base}/minio"; \
    curl -fL -o /tmp/minio.sha256sum "${base}/minio.sha256sum"; \
    read -r sum name < /tmp/minio.sha256sum; \
    if [ "${name}" != "minio.${VERSION}" ]; then \
        echo "release mismatch: ${name} != minio.${VERSION}" >&2; exit 1; \
    fi; \
    echo "${sum}  /tmp/minio" | sha256sum -c -; \
    chmod 0755 /tmp/minio; \
    rm /tmp/minio.sha256sum

# Final stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

COPY --from=download --chmod=0755 /tmp/minio /app/aistor/minio

# UNVERIFIED: vendor licence text for /usr/share/licenses/aistor/LICENSE is not available. The
# licence and redistribution terms must be confirmed before merge.

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 9000 9001

VOLUME /config
