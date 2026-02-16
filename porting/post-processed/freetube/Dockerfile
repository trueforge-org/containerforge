FROM ghcr.io/trueforge-org/baseimage-kasmvnc:debianbookworm

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# title
ENV TITLE=FreeTube

RUN \
    echo "**** add icon ****" && \
    curl -o /kclient/public/icon.png https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/freetube-logo.png && \
    echo "**** install packages ****" && \
    URL=$(curl -sL "https://api.github.com/repos/FreeTubeApp/FreeTube/releases/${VERSION}" \
        | jq -r --arg arch "${TARGETARCH}.deb" '.assets[] | select(.name | endswith($arch)) | .browser_download_url') && \
    curl -o /tmp/freetube.deb -L "${URL}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/freetube.deb && \
    rm -f /usr/bin/freetube && \
    echo "**** cleanup ****" && \
    apt-get autoclean && \
    rm -rf /config/.cache /var/lib/apt/lists/* /var/tmp/* /tmp/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3000

VOLUME /config

WORKDIR /config
