FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TheLamer"

COPY requirements.txt /tmp/requirements.txt

RUN \
  echo "**** add 3rd party repos ****" && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | \
    gpg --dearmor -o /etc/apt/keyrings/google.gpg && \
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google.gpg] http://dl.google.com/linux/chrome/deb/ stable main' > \
    /etc/apt/sources.list.d/google-chrome.list && \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    docker-ce \
    google-chrome-stable \
    python3-venv \
    unzip \
    xserver-xephyr \
    xvfb && \
  echo "**** install chrome driver ****" && \
  CHROME_RELEASE=$(curl -sLk https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE) && \
  echo "Retrieving Chrome driver version ${CHROME_RELEASE}" && \
  curl -sk -o \
    /tmp/chrome.zip -L \
    "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_RELEASE}/linux64/chromedriver-linux64.zip" && \
  cd /tmp && \
  unzip chrome.zip && \
  mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && \
  chown root:root /usr/bin/chromedriver && \
  chmod +x /usr/bin/chromedriver && \
  echo "**** Install python deps ****" && \
  python3 -m venv /lsiopy && \
  pip3 install -U --no-cache-dir \
    pip && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    -r /tmp/requirements.txt && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# copy local files
COPY ci /ci
COPY test_build.py test_build.py

ENTRYPOINT [ "" ]
