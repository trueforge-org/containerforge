# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.04 as plugins

# FIXME: Find a way to keep versions up to date
# -- Use the following prefixes to specify plugins to clone
# - TC_PLUGIN_REPO_* for the repo/package name
# - TC_PLUGIN_VERSION_* for the version

# Theme Park
ARG TC_PLUGIN_REPO_THEME_PARK=github.com/packruler/traefik-themepark
ARG TC_PLUGIN_VERSION_THEME_PARK_VERSION=v1.4.2
# GeoBlock
ARG TC_PLUGIN_REPO_GEOBLOCK=github.com/PascalMinder/geoblock
ARG TC_PLUGIN_VERSION_GEOBLOCK_VERSION=v0.2.8
# RealIP
ARG TC_PLUGIN_REPO_REALIP=github.com/jramsgz/traefik-real-ip
ARG TC_PLUGIN_VERSION_REALIP_VERSION=v1.0.6
# Modsecurity
ARG TC_PLUGIN_REPO_MODSECURITY=github.com/acouvreur/traefik-modsecurity-plugin
ARG TC_PLUGIN_VERSION_MODSECURITY_VERSION=v1.3.0
# Crowdsec
ARG TC_PLUGIN_REPO_CROWDSEC_BOUNCER=github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin
ARG TC_PLUGIN_VERSION_CROWDSEC_BOUNCER_VERSION=v1.3.5
# RewriteResponseHeaders
ARG TC_PLUGIN_REPO_REWRITERESPONSEHEADERS=github.com/XciD/traefik-plugin-rewrite-headers
ARG TC_PLUGIN_VERSION_REWRITERESPONSEHEADERS_VERSION=v0.0.4

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3018
RUN apt-get update && apt-get install git; \
    git config --global advice.detachedHead false; \
    for plugin in $(env | grep "TC_PLUGIN_REPO_");
    do \
      # Get the variable name
      plugin_name=$(echo "${plugin}" | cut -d '=' -f1); \
      plugin_name=${plugin_name#"TC_PLUGIN_REPO_"}; \
      # Get the plugin repo from the variable
      plugin_repo=$(echo "${plugin}" | cut -d '=' -f2); \
      # Get the version from the VERSION Prefixed variable
      version=$(env | grep "TC_PLUGIN_VERSION_$plugin_name" | cut -d '=' -f2); \
      echo "${plugin_name}: Cloning ${plugin_repo} at ${version} into /plugins-local/src/${plugin_repo}";
      # Clone the single "branch" (tag) into the plugins-local folder
      git clone "https://${plugin_repo}" "/plugins-local/src/${plugin_repo}" \
        --depth 1 --branch "${version}" --single-branch; \
    done; \

    echo "Plugins cloned into /plugins-local/src:"; \

ls -lah /plugins-local/src;

FROM ghcr.io/trueforge-org/ubuntu:24.04
ARG TARGETARCH
ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -ex; \
	wget --quiet -O /tmp/traefik.tar.gz "https://github.com/traefik/traefik/releases/download/v${VERSION}/traefik_v${VERSION}_linux_${TARGETARCH}.tar.gz"; \
	tar xzvf /tmp/traefik.tar.gz -C /usr/local/bin traefik; \
	rm -f /tmp/traefik.tar.gz; \
	chmod +x /usr/local/bin/traefik
EXPOSE 80

USER nobody:nogroup

# Copy the plugins from the previous stage
COPY --from=plugins /plugins-local /plugins-local

WORKDIR /config
CMD ["traefik"]
