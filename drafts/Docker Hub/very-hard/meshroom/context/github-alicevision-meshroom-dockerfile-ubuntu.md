# GitHub: alicevision/Meshroom docker/Dockerfile_ubuntu (v2025.1.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/alicevision/Meshroom/v2025.1.0/docker/Dockerfile_ubuntu (2026-11-27)
- Blob URL in urls.txt (github.com/alicevision/meshroom/blob/v2025.1.0/...) is the same file.
- Not fetched: https://api.github.com/repos/alicevision/Meshroom/releases/tags/v2025.1.0 (HTTP 403 rate limit; not retried). Repo root and GitHub releases HTML not fetched.

## What it is
Upstream Dockerfile for the Meshroom dev image (`alicevision/meshroom`). Builds Meshroom from source on top of the deps image.

## Base / build
- ARGs: `MESHROOM_VERSION`, `AV_VERSION`, `CUDA_VERSION`, `UBUNTU_VERSION` (no defaults in file).
- `FROM alicevision/meshroom-deps:${MESHROOM_VERSION}-av${AV_VERSION}-ubuntu${UBUNTU_VERSION}-cuda${CUDA_VERSION}`
- ENV: `MESHROOM_DEV=/opt/Meshroom`, `MESHROOM_BUILD=/tmp/Meshroom_build`, `MESHROOM_BUNDLE=/opt/Meshroom_bundle`, `AV_INSTALL=/opt/AliceVision_install`, `QT_DIR=/opt/Qt/6.8.3/gcc_64`, `PATH` += bundle.
- Copies `*.txt *.md *.py`, `docs/`, `meshroom/`, `tests/`, `bin/` into `/opt/Meshroom`.
- Build: `python setup.py install_exe -d $MESHROOM_BUNDLE`, prunes Qt6Web/Designer and PySide6 extras.
- Moves `/opt/AliceVision_bundle/*` into `$MESHROOM_BUNDLE/aliceVision`.
- Builds Qt plugins: `cmake ... -DALICEVISION_ROOT=$AV_INSTALL -DCMAKE_INSTALL_PREFIX=$MESHROOM_BUNDLE/qtPlugins`; `make QtAliceVision`; `make`.
- Removes build dirs and share/doc, eigen3, fonts, lemon, libraw, man.
- Copies several Qt3D `.so.6` libs into PySide6 QtQuick/Dialogs (runtime fix).
- Installs `ssh xauth`, enables ssh, `mkdir /run/sshd`.

## Runtime
- `WORKDIR /root`, `EXPOSE 22`, `CMD ["/usr/sbin/sshd", "-D"]`. No ENTRYPOINT, no USER (root), no VOLUME.
- Header comment: run with `--runtime nvidia`, `-p 2222:22`, data at `/data`.
- Upstream sshd config via sed: `X11Forwarding yes`, `X11UseLocalhost no`, `PermitRootLogin yes`.

## Ports
- 22/tcp (ssh, X11 forwarding).

## User / UID
- root. Fixed password set in Dockerfile (`root:meshroom`). Do not copy.

## Gotchas
- Access is SSH with X11 forwarding only (no GUI server, no VNC). No 5800 port in this source.
- Needs NVIDIA runtime per header comment.
- Tag `v2025.1.0` (no `v` in image tag).
