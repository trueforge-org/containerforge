# UNVERIFIED: base and digest taken from plan.md section 3 (ubuntu 26.04). The upstream php:8.5-fpm-alpine (musl) is not usable.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: nginx, php-fpm, php-cli and php-curl package names and versions on ubuntu 26.04.
# UNVERIFIED: the minimum PHP version required by FlashPaper; pin the packages after an apt-cache policy check.
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php-fpm \
    php-cli \
    php-curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Fetch the tagged source and lay it out under /app/flashpaper (read-only at runtime).
# TODO: pin the commit SHA or archive sha256 for v2.6.1 once it is verified (no checksum is published).
# UNVERIFIED: the LICENSE file name at the repository root.
# The upstream docker/settings.php is copied to the app root, as the upstream Dockerfile does.
# The data folder is a symlink to /config/data, created by start.sh on first start.
RUN \
  mkdir -p /tmp/flashpaper-src /app/flashpaper && \
  curl -fsSL -o /tmp/flashpaper.tar.gz \
    "https://github.com/AndrewPaglusch/FlashPaper/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar -xzf /tmp/flashpaper.tar.gz -C /tmp/flashpaper-src --strip-components=1 && \
  cp -a /tmp/flashpaper-src/. /app/flashpaper/ && \
  cp /tmp/flashpaper-src/docker/settings.php /app/flashpaper/settings.php && \
  rm -rf /app/flashpaper/docker && \
  ln -s /config/data /app/flashpaper/data && \
  mkdir -p /usr/share/licenses/flashpaper && \
  cp /tmp/flashpaper-src/LICENSE /usr/share/licenses/flashpaper/LICENSE && \
  rm -rf /tmp/*

COPY --chmod=0755 . /

# Upstream disables upload progress (GHSA-6wmf-4rv5-p3rp). The ini file is copied into the
# php-fpm conf.d folder(s) here, while still root. The version directory is UNVERIFIED.
RUN for d in /etc/php/*/fpm/conf.d; do cp /etc/php/conf.d/upload-progress.ini "${d}/"; done

USER apps

EXPOSE 8080

VOLUME /config
