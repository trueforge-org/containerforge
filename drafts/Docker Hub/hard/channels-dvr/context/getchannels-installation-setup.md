# getchannels.com/docs/channels-dvr-server/quick-guide/installation-setup/

Source URL(s) + fetch date:
- https://getchannels.com/docs/channels-dvr-server/quick-guide/installation-setup/ · fetched 2026-11-26

## Facts
- General quick-start guide. Linux is listed as a platform (with macOS, Windows, Raspberry Pi 4, NAS). Platform-specific install notes are on the Channels DVR Server download page (getchannels-dvr-server.md).
- Docker is not mentioned on this page.
- Web admin: `http://127.0.0.1:8089` on the same machine; `http://$IP_ADDRESS:8089` for a NAS or another computer. Port 8089 confirmed.
- Setup wizard asks for a recordings storage location: a drive with plenty of free space (external drive or NAS volume), a new empty dedicated directory.
- TV Everywhere: add a source via "Add Source", choose the type, log in; Channels then scans channels and loads guide data (14 days; can take a while).
- HDHomeRun tuners are discovered automatically. Country, zip code and lineup are chosen during setup.
- Not covered: data directory path, hardware-acceleration groups or devices, trial/subscription terms, service behaviour.
