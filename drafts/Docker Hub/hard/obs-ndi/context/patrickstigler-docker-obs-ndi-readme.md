# patrickstigler/docker-obs-ndi README

Source URL(s): https://github.com/patrickstigler/docker-obs-ndi (raw README) · fetched 2026-11-26

- Run: `docker run --shm-size=256m -it -p 5901:5901 -p 6901:6901 -p 4455:4455 patrickstigler/docker-obs-ndi:latest`
- Derived from bb12489/docker-obs; rebuilt on accetto/ubuntu-vnc-xfce-g3.
- Ports: 5901 VNC; 6901 browser client; 4455 (purpose not stated; likely obs-websocket).
- VNC password: `headless`.
- GPU (NVIDIA): `NVIDIA_VISIBLE_DEVICES=<id>`, `NVIDIA_DRIVER_CAPABILITIES=all`, `--runtime=nvidia`.
- Gotchas: `--shm-size=256m` required for web client; default VNC password public.
- No env var list, volumes or display settings documented.
