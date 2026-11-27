FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
  TZ=Etc/UTC

# pin the Ubuntu archive package to the bake VERSION and fail if it drifts
RUN apt-get update && \
  apt-get install -y --no-install-recommends filezilla=${VERSION}-1 && \
  dpkg -s filezilla | grep -q "^Version: ${VERSION}-" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# UNVERIFIED: copyright path inside the package, confirm on first build
RUN mkdir -p /usr/share/licenses/filezilla && \
  cp /usr/share/doc/filezilla/copyright /usr/share/licenses/filezilla/LICENSE

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: 3000 depends on the display stack decision (see plan section 10)
EXPOSE 3000
VOLUME /config
WORKDIR /config
