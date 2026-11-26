# Docker Hub: octoprint/octoprint

Source URL(s): https://hub.docker.com/r/octoprint/octoprint · fetched 2026-11-26

- Primary image; matches OctoPi out-of-box features. Tags track bundled OctoPrint version.
- Tags: latest (stable), edge (incl. prereleases), dev, X / X.Y / X.Y.Z / X.Y.Z-rc, minimal and -minimal variants. canary and bleeding deprecated.
- Architectures: amd64, arm64, arm/v7. Pulls 10M+. Latest digest sha256:8966e455b…, ~513.6 MB.
- Ports: web UI container port 80 (`-p 80:80`); config editor 8443; mjpg-streamer 8080+ per camera; webcam `/webcam/?action=stream`, `?action=snapshot`.
- Volume: `/octoprint`; active config `/octoprint/octoprint/config.yaml`.
- Devices: serial (e.g. /dev/ttyACM0) and camera (/dev/video0) must be mapped.
- Env: ENABLE_MJPG_STREAMER (default false), CAMERA_DEV (/dev/video0), MJPG_STREAMER_INPUT (-n -r 640x480), AUTOMIGRATE (default false; migrate older layout, back up first).
- Restart option: `s6-svc -r /var/run/s6/services/octoprint` if missing.
