FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# commit SHA of thibaud-rohmer/PhotoShow master (the v2 tag from 2014 is stale)
ARG VERSION

ENV HOME=/tmp

USER root

# runtime packages (UNVERIFIED on 26.04: package names, PHP version and arm64 availability; check apt-cache policy on the first build)
# exif support is assumed to be in php-common or php-gd; add a php-exif package only if the first run needs it
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nginx \
      php-fpm \
      php-gd \
      php-imagick \
      php-xml \
      imagemagick \
      ffmpeg \
      fbida \
      zip \
      supervisor \
 && rm -rf /var/lib/apt/lists/* \
 # supervisord starts php-fpm by a fixed path, so link the versioned binary (UNVERIFIED name on 26.04)
 && ln -s "$(ls /usr/sbin/php-fpm* | head -n 1)" /usr/local/bin/php-fpm

# download the source at the pinned commit
RUN mkdir -p /app/photoshow \
 && curl -fsSL -o /tmp/photoshow.tar.gz \
      "https://github.com/thibaud-rohmer/PhotoShow/archive/${VERSION}.tar.gz" \
 && tar xzf /tmp/photoshow.tar.gz -C /app/photoshow --strip-components=1 \
 && rm -f /tmp/photoshow.tar.gz \
 && echo "${VERSION}" > /app/photoshow/version.txt \
 \
 # build-time config: the image is read-only at runtime
 && sed -i \
      -e 's#\$config->photos_dir.*#$config->photos_dir = "/Pictures";#' \
      -e 's#\$config->ps_generated.*#$config->ps_generated = "/config/photoshow/generated";#' \
      /app/photoshow/config.php \
 \
 # user/ (accounts, settings, themes) is seeded to /config by start.sh; /app/photoshow/user points at /config
 && mkdir -p /defaults/photoshow \
 && cp -a /app/photoshow/user /defaults/photoshow/user \
 && rm -rf /app/photoshow/user \
 && ln -s /config/photoshow/user /app/photoshow/user \
 \
 # drop files that are not needed at runtime
 && rm -rf /app/photoshow/docker \
 \
 && chown -R root:root /app/photoshow /defaults/photoshow \
 && chmod -R 755 /app/photoshow /defaults/photoshow \
 && rm -rf /tmp/*

# no LICENSE file upstream; see docker-bake.hcl. start.sh, etc/photoshow/ come in with COPY . /
COPY --chmod=0755 . /

# run as 568
USER apps

WORKDIR /config
ENV TZ=Etc/UTC
EXPOSE 8080
VOLUME ["/config"]

CMD ["/start.sh"]
