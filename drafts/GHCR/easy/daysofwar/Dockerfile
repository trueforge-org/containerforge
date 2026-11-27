# UNVERIFIED: pin a digest once ghcr.io/trueforge-org/steamcmd is published.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config

USER root
# This image replaces /start.sh, and the base steamcmd wrapper calls /start.sh,
# so keep the base script under another name for start.sh to call.
RUN cp /start.sh /usr/local/bin/steamcmd-base.sh && \
    chmod 0755 /usr/local/bin/steamcmd-base.sh

COPY --chmod=0755 . /

EXPOSE 7777/udp 27015/udp
VOLUME /config

USER apps
