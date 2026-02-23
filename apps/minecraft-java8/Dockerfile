FROM ghcr.io/trueforge-org/java8:8

# hook into docker BuildKit --platform support
# see https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

USER root

EXPOSE 25565

ARG APPS_REV=1
ARG GITHUB_BASEURL=https://github.com

# renovate: datasource=github-releases packageName=itzg/restify
ARG RESTIFY_VERSION=1.7.12

# renovate: datasource=github-releases packageName=itzg/rcon-cli
ARG RCON_CLI_VERSION=1.7.3

# renovate: datasource=github-releases packageName=itzg/mc-monitor
ARG MC_MONITOR_VERSION=0.16.1

# renovate: datasource=github-releases packageName=itzg/mc-server-runner
ARG MC_SERVER_RUNNER_VERSION=1.14.1
RUN set -eux; \
    install_release_binary() { \
      app="$1"; \
      version="$2"; \
      archive="${app}_${version}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.tar.gz"; \
      tmpdir="$(mktemp -d)"; \
      curl -fsSL -o "${tmpdir}/${archive}" "${GITHUB_BASEURL}/itzg/${app}/releases/download/${version}/${archive}"; \
      tar -C "${tmpdir}" -zxf "${tmpdir}/${archive}"; \
      app_path="$(find "${tmpdir}" -type f -name "${app}" | head -n 1)"; \
      install -m 0755 "${app_path}" "/usr/bin/${app}"; \
      rm -rf "${tmpdir}"; \
    }; \
    install_release_binary restify "${RESTIFY_VERSION}"; \
    install_release_binary rcon-cli "${RCON_CLI_VERSION}"; \
    install_release_binary mc-monitor "${MC_MONITOR_VERSION}"; \
    install_release_binary mc-server-runner "${MC_SERVER_RUNNER_VERSION}"

# renovate: datasource=github-releases packageName=itzg/mc-image-helper versioning=loose
ARG MC_HELPER_VERSION=1.54.1
ARG MC_HELPER_BASE_URL=${GITHUB_BASEURL}/itzg/mc-image-helper/releases/download/${MC_HELPER_VERSION}
# used for cache busting local copy of mc-image-helper
ARG MC_HELPER_REV=1
RUN curl -fsSL ${MC_HELPER_BASE_URL}/mc-image-helper-${MC_HELPER_VERSION}.tgz \
    | tar -C /usr/share -zxf - \
        && ln -s /usr/share/mc-image-helper-${MC_HELPER_VERSION}/ /usr/share/mc-image-helper \
        && ln -s /usr/share/mc-image-helper/bin/mc-image-helper /usr/bin

RUN mkdir -p /app /config \
    && chown -R apps:apps /config

WORKDIR /config

STOPSIGNAL SIGTERM

ENV TYPE=VANILLA VERSION=LATEST EULA=true LC_ALL=en_US.UTF-8 HOME=/config RUNTIME_DIR=/config

ARG BUILDTIME=local
ARG VERSION=local
ARG REVISION=local
COPY <<EOF /etc/image.properties
buildtime=${BUILDTIME}
version=${VERSION}
revision=${REVISION}
EOF

COPY --chmod=0755 . /

USER apps
