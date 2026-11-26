# OctoPrint/octoprint-docker Dockerfile (upstream image)

Source URL(s): https://github.com/OctoPrint/octoprint-docker/blob/32fdd6eae2a9a2c1f97f26cf4c7d3802cb0559db/Dockerfile (raw fetched) · fetched 2026-11-26

- Global ARG `PYTHON_BASE_IMAGE=3.10-slim-bullseye`.
- Stage s6build: `FROM ubuntu` (untagged); ARG S6_RELEASE (default v2.1.0.0); downloads `s6-overlay-$ARCH.tar.gz` from just-containers GitHub releases. Arch map: amd64, arm64->aarch64, armhf->armhf, else exit 1.
- Stage build: `FROM python:${PYTHON_BASE_IMAGE}`; ARG octoprint_ref (default master).
  - apt: avrdude, build-essential, cmake, curl, imagemagick, ffmpeg, fontconfig, g++, git, haproxy, libffi-dev, libjpeg-dev, libjpeg62-turbo, libprotobuf-dev, libudev-dev, libusb-1.0-0-dev, libv4l-dev, openssh-client, v4l-utils, xz-utils, zlib1g-dev, x265.
  - s6-overlay extracted to /.
  - OctoPrint tarball from GitHub for `${octoprint_ref}` extracted to /opt/octoprint; `pip install .`.
  - mkdir /octoprint/octoprint /octoprint/plugins.
  - mjpg-streamer master built with make/make install.
  - COPY root / (s6 service definitions; contents not fetched).
- ENV: CAMERA_DEV=/dev/video0; MJPG_STREAMER_INPUT="-n -r 640x480"; PIP_USER=true; PYTHONUSERBASE=/octoprint/plugins; PATH adds ${PYTHONUSERBASE}/bin.
- WORKDIR /octoprint; EXPOSE 80 (haproxy frontend); VOLUME /octoprint; ENTRYPOINT ["/init"].
- No USER, CMD, ADD.
