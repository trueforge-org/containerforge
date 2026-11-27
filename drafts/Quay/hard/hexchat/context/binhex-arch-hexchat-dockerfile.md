# binhex/arch-hexchat Dockerfile (pinned commit 2c35dde8)

Source URL(s): https://raw.githubusercontent.com/binhex/arch-hexchat/2c35dde8b489a4cfec0ffbd3118c6166fb11516a/Dockerfile (blob variant maps here; fetched 2026-11-27)

## Dockerfile
```
FROM ghcr.io/binhex/arch-int-gui:latest
LABEL org.opencontainers.image.authors="binhex"
LABEL org.opencontainers.image.source="https://github.com/binhex/arch-hexchat"
ARG APPNAME
ARG RELEASETAG
ARG TARGETARCH
ADD build/root/*.sh /root/
ADD config/nobody/* /home/nobody/
RUN chmod +x /root/*.sh && /bin/bash /root/install.sh "${APPNAME}" "${RELEASETAG}" "${TARGETARCH}"
HEALTHCHECK --interval=2m --timeout=2m --retries=3 --start-period=2m \
  CMD /usr/local/bin/system/scripts/docker/healthcheck.sh || exit 1
CMD ["/bin/bash", "init.sh"]
```

## Facts
- Base: ghcr.io/binhex/arch-int-gui:latest (Arch-based GUI base, unpinned).
- Build args: APPNAME, RELEASETAG, TARGETARCH (amd64/arm64 per buildx).
- Install: /root/install.sh <APPNAME> <RELEASETAG> <TARGETARCH>; build scripts from build/root/*.sh; preconfig from config/nobody/* into /home/nobody.
- Healthcheck: /usr/local/bin/system/scripts/docker/healthcheck.sh (2m interval, 2m start period).
- CMD: /bin/bash init.sh (no ENTRYPOINT).
- No USER directive; runs as root in base unless base drops privileges.
- Install script contents not fetched (not in this list).
