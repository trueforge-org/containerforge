
# BLOCKED skeleton (plan.md sections 4 and 10). The server files are not packaged: no confirmed, legal download URL,
# no pinned version and no license. No download is added here. Do not build this as a release until those are resolved.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  SERVER_DIR=/config/nwnee

# The server is x86 only (plan section 4 and 9).
RUN if [ "${TARGETARCH}" != "amd64" ]; then echo "NWN:EE server is amd64 only" >&2; exit 1; fi

# UNVERIFIED: runtime libraries needed by the server binary are not known until ldd is run on it.
# BLOCKER: no server download step. The upstream image (ich777/nwnee-server) fetches the server zip at container start
# from an unpinned URL, which is not a reproducible build.
# UNVERIFIED: the upstream bundles MariaDB and Redis. They are not added here (plan section 10).

RUN echo "*** Preparing server directory ***" && \
  mkdir -p /app/nwnee && \
  chown -R apps:apps /app && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 5121/udp

VOLUME /config
