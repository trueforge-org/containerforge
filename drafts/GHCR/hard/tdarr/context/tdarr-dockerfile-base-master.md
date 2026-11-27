# Tdarr docker/Dockerfile.base (master, first 3000 bytes only)
Source URL: https://raw.githubusercontent.com/HaveAGitGat/Tdarr/master/docker/Dockerfile.base (fetched 2026-11-27; remainder not read)

- `FROM lsiobase/ubuntu:jammy`
- ENV LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri, LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu, NVIDIA_DRIVER_CAPABILITIES=compute,video,utility, NVIDIA_VISIBLE_DEVICES=all, HANDBRAKE=1.7.3
- ENV WEB_UI_PORT=8265 SERVER_PORT=8266 NODE_PORT=8267 PUID=1000 PGID=1000 UMASK=002 TZ=Etc/UTC HOME=/home/Tdarr
- mkdir /app /logs /temp $HOME
- apt: software-properties-common git trash-cli; curl unzip wget comskip python3-pip; pip3 install apprise
- mkvtoolnix from mkvtoolnix.download apt repo (jammy)
- ccextractor built from git commit 35e73c1c90ce3ca69394d3523836bb1cdec28f11 (`./build -without-rust`), installed to /usr/bin/ccextractor
- tesseract-ocr, libtesseract-dev, leptonica, clang, cmake and related build libs
- amd64 only (grep x86): Intel GPU repo + intel-opencl-icd, level-zero, intel-media-va-driver-non-free, libmfx, libvpl, mesa packages
