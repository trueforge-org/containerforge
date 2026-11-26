# openaudible_docker Dockerfile

Source URL(s): https://github.com/openaudible/openaudible_docker/blob/master/Dockerfile (raw fetched) · fetched 2026-11-26

- `FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm`.
- ARG: none.
- ENV: DEBIAN_FRONTEND=noninteractive; LANG, LC_ALL, LANGUAGE=C.UTF-8; KASM_AUDIO_ENABLED=1; KASM_AUDIO_QUALITY=medium; START_PULSEAUDIO=1; OA_PACKAGING=docker; OA_BETA=true; XDG_CURRENT_DESKTOP=XFCE; APP_DIR=/app/OpenAudible; OA_KIOSK=true; oa_internal_browser=true.
- RUN: arch check (x86_64 or aarch64 only); apt install libgtk-3-bin, ca-certificates, ca-certificates-java, wget, libwebkit2gtk-4.1-0, vim, xdg-utils, xterm, thunar, python3-xdg, pulseaudio, alsa-utils; clean lists; update-ca-certificates; chown abc and chmod +x /app/*.sh; chmod +x /etc/cont-init.d/98-configure-openbox; `echo "/app/start_openaudible.sh" > /defaults/autostart`; chown/chmod -R /config; mkdir APP_DIR owned by abc.
- No download URLs in Dockerfile (app fetched by scripts at start; not shown).
- COPY assets/*.sh -> /app/; assets/index.html -> /kclient/public/index.html; assets/configure-openbox -> /etc/cont-init.d/98-configure-openbox.
- EXPOSE 3000. No VOLUME, WORKDIR, USER (base `abc`), HEALTHCHECK.
- ENTRYPOINT ["/app/entrypoint.sh"]; CMD ["/init"].
- Scripts' contents not fetched.
