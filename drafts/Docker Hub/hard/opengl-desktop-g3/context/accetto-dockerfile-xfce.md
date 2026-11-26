# accetto/headless-drawing-g3 docker/Dockerfile.xfce

Source URL(s): https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce (raw fetched) · fetched 2026-11-26

## Global ARGs
- BASEIMAGE=ubuntu, BASETAG=24.04.
- Stage selectors for xfce build; user ARG_HEADLESS_USER_ID=1001, name `headless`, group 1001 `headless`; ARG_SUDO_INITIAL_PW=headless; ARG_HOME=/home/headless.

## Stages (in order)
- stage_cache, stage_essentials: apt gettext-base, gir1.2-rsvg-2.0, gpg, jq, nano, psmisc, sudo, tini, wget.
- stage_xserver: dbus-x11, xauth, xinit, x11-xserver-utils, xdg-utils, libxshmfence1, libxcvt0, libgbm1; NO_AT_BRIDGE=1.
- stage_xfce: xfce4, xfce4-terminal, elementary-xfce-icon-theme.
- stage_tools: mousepad, python3, systemctl (+ optional ristretto, xfce4-screenshooter, tumbler).
- stage_vnc: TigerVNC tarball from sourceforge `tigervnc-${VERSION}.${DISTRO}.tar.gz` extracted to /; symlink /usr/bin/vncserver. ENV DISPLAY=:1, VNC_PORT=5901, VNC_PW=headless, VNC_RESOLUTION=1360x768, VNC_COL_DEPTH=24, VNC_VIEW_ONLY=false. EXPOSE ${VNC_PORT}.
- stage_novnc: python3-numpy; noVNC `v${NOVNC_VERSION}` and websockify `v${WEBSOCKIFY_VERSION}` from GitHub archives; NOVNC_HOME=/usr/libexec/noVNCdim; NOVNC_PORT=6901; EXPOSE ${NOVNC_PORT}.
- merge_stage_vnc: HEADLESS_USER_* env; WORKDIR ${HOME}; COPY ./src/home.
- stage_mesa: mesa-utils, mesa-utils-extra, glmark2; FEATURES_MESA=1.
- stage_virtualgl: VirtualGL deb from sourceforge `virtualgl_${VERSION}_${DISTRO}.deb` via apt; runs `/opt/VirtualGL/bin/vglserver_config -config +s +f -t` (root; changes system config).
- stage_chromium / stage_firefox: optional browsers (not used by plan).
- stage_final: COPY xfce-startup -> /dockerstartup/; config and Desktop to HOME; creates group/user entries (UID/GID 1001), sudoers entry, initial sudo password file `/dockerstartup/.initial_sudo_password`; `chmod 666 /etc/passwd /etc/group` temporarily; `USER 1001`; ENTRYPOINT ["/usr/bin/tini", "--", "/dockerstartup/startup.sh"]. ENV STARTUPDIR=/dockerstartup.
- No VOLUME, HEALTHCHECK, CMD, ADD.
