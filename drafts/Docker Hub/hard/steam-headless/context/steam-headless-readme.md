# Steam-Headless/docker-steam-headless README (upstream)

Source URL(s): https://github.com/Steam-Headless/docker-steam-headless ; https://raw.githubusercontent.com/Steam-Headless/docker-steam-headless/master/README.md (fetched 2026-11-26)

## What it is
- Headless Steam remote game streaming server: browser (noVNC) with audio, Moonlight/Sunshine streaming, Steam Link, Steam Remote Play.
- Xfce4 desktop; Steam with Proton; Flatpak support (EmuDeck, Heroic, Lutris); NVIDIA/AMD/Intel GPUs; controller support; root access; Debian Trixie base.

## Notes
- Extra software: scripts in `~/init.d/*.sh` run at startup; or install via WebUI Applications > System > Software.
- Storage: save in home dir (/home/default) or a mount; files outside home are wiped on container update.
- Games library: recommended mount `/mnt/games`.
- Auto-start: Steam auto-starts; other services via WebUI Session and Startup.
- Remote Play: use a custom network with own IP for LAN detection (else traffic routed via internet).
- Host X mode: DISPLAY=:0, MODE=secondary, HOST_DBUS=true (optional), mount /run/dbus:/run/dbus:ro (optional).
- Install docs: docs/docker-compose.md, docs/unraid.md, docs/ubuntu-server.md.

## TODO in upstream
- Remove SSH; require sudo password; document TrueNAS/other OS.
