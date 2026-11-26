# patrickstigler/docker-obs-ndi Dockerfile (third-party wrapper)

Source URL(s): https://github.com/patrickstigler/docker-obs-ndi/blob/400fc92a0a6953feef3bee371f5e0c2cd23991e2/Dockerfile (raw fetched) · fetched 2026-11-26

- `FROM accetto/ubuntu-vnc-xfce-g3` (untagged, latest).
- EXPOSE 5901 (VNC), 6901 (web VNC), 4455 (obs-websocket).
- ENV `VNC_PASSWD=headless`; `NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"`.
- VOLUME ["/config"].
- No ARG, COPY, WORKDIR, USER, ENTRYPOINT, CMD.
- Single RUN chain (sudo via `echo headless | sudo -S -k`):
  - apt-get update; apt install --fix-broken: avahi-daemon, xterm, git, build-essential, cmake, curl, ffmpeg, libboost-dev, libnss3, mesa-utils, qtbase5-dev, strace, x11-xserver-utils, net-tools, python3, python3-numpy, scrot, wget, software-properties-common, vlc, jq, udev, unrar, qt5-image-formats-plugins.
  - `sed -i 's/geteuid/getppid/' /usr/bin/vlc`.
  - `add-apt-repository ppa:obsproject/obs-studio`; `mkdir -p /config/obs-studio /root/.config/`; `ln -s /config/obs-studio/ /root/.config/obs-studio`; `apt install -y obs-studio`.
  - wget `libndi4_4.5.1-1_amd64.deb` and `obs-ndi-4.10.0-Ubuntu64.deb` from Palakis/obs-ndi release `dummy-tag-4.10.0`; `dpkg -i /tmp/*.deb`; cleanup.
- Gotcha: final RUN line ends with trailing `\` before VOLUME (summary says this may break build; unverified).
- Stale: installs obs-ndi 4.10.0 (pre-DistroAV).
- No scripts created or copied.
