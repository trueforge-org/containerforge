FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG PACKAGE_VERSION

USER root

# UNVERIFIED: libgtk-3-bin is expected to provide broadwayd (check: dpkg -L libgtk-3-bin | grep broadway)
# UNVERIFIED: gir1.2-gtk-vnc-2.0 is not in upstream's list, drop it if virt-manager already pulls it in
# hadolint ignore=DL3008,DL3015
RUN test "$(echo "${PACKAGE_VERSION#*:}" | sed 's/-.*//')" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "virt-manager=${PACKAGE_VERSION}" \
        libgtk-3-bin \
        dbus-x11 \
        libglib2.0-bin \
        gir1.2-spiceclientgtk-3.0 \
        gir1.2-gtk-vnc-2.0 \
        openssh-client \
        at-spi2-core \
        libvirt-clients \
        adwaita-icon-theme && \
    # UNVERIFIED: copyright path of the virt-manager package, confirm in the built image
    mkdir -p /usr/share/licenses/virt-manager && \
    cp /usr/share/doc/virt-manager/copyright /usr/share/licenses/virt-manager/ && \
    apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/config \
    XDG_CONFIG_HOME=/config \
    XDG_CACHE_HOME=/tmp/cache \
    XDG_RUNTIME_DIR=/tmp/runtime \
    GSETTINGS_BACKEND=keyfile \
    GDK_BACKEND=broadway \
    BROADWAY_DISPLAY=:5

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
# Broadway serves the GUI on port 8085 (display :5, port set explicitly in start.sh)
EXPOSE 8085

CMD ["/start.sh"]
