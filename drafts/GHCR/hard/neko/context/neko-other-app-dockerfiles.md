# Source: m1k1o/neko apps/* Dockerfiles (commit 92420ca8), 8 apps combined

Source URL(s) + date: https://raw.githubusercontent.com/m1k1o/neko/92420ca8e4709c1ac49961c4bf5d3cc786d44f0d/apps/<app>/Dockerfile for brave, google-chrome, microsoft-edge, remmina, tor-browser, vivaldi, vlc, xfce (fetched 2026-11-27). All `FROM ghcr.io/m1k1o/neko/base:latest` (ARG BASE_IMAGE).

| App | Install method | Notes |
| --- | --- | --- |
| brave | apt repo brave-browser-apt-release.s3.brave.com (keyring + list), apt install brave-browser | arm64: copy base Widevine into /opt/brave.com/brave/WidevineCdm; COPY preferences.json -> /home/neko/.config/brave/Default/Preferences; policies -> /etc/brave/policies/managed/ |
| google-chrome | wget https://dl.google.com/linux/direct/google-chrome-stable_current_${ARCH}.deb (ARG SRC_URL overrides) | amd64/arm64 only, else exit 1; arm64 Widevine copy; policies -> /etc/opt/chrome/policies/managed/ |
| microsoft-edge | packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/ (ARG API_URL); picks highest version by sort --version-sort | apt install deb; policies -> /etc/opt/edge/policies/managed/ |
| remmina | apt remmina-plugin-rdp, -vnc, -x2go, -www | ENV REMMINA_URL= and REMMINA_PROFILE= (empty); run-remmina.sh -> /usr/bin |
| tor-browser | curl https://aus1.torproject.org/torbrowser/update_3/release/download-linux-x86_64.json; grep "binary" key; download tar.xz; extract to /opt; mv to /opt/tor-browser_en-US | no policies; purges curl, xz-utils |
| vivaldi | wget https://downloads.vivaldi.com/stable/vivaldi-stable_${ARCH}.deb; apt install | Google extension CRX (ids ddkjiahejlhfcafbddmgiahcphecmpfh, mnjggcdmjocbbbhaepdhchncahnbgone) fetched to /usr/share/chromium/extensions; arm64 Widevine copy; policies -> /etc/opt/vivaldi/policies/managed/ |
| vlc | apt vlc, vlc-plugin-skins2 | ENV VLC_MEDIA="/media" |
| xfce | apt xfce4, xfce4-terminal, sudo | creates user neko in sudo group, password "neko" (chpasswd), NOPASSWD sudo for %sudo |

## Common
- Each: COPY supervisord.conf -> /etc/neko/supervisord/<app>.conf; openbox.xml -> /etc/neko/openbox.xml (except xfce: supervisord only).
- Each: apt-get clean and rm /var/lib/apt/lists/*.

## Gotchas
- Downloads of Brave/Chrome/Edge/Vivaldi/Tor are unpinned "latest" streams at build time.
- Not fetched (binary or marketing): dist.torproject.org tarball, packages.microsoft.com .deb, vivaldi/chrome/edge/brave homepages, Mozilla ftp tarballs.
