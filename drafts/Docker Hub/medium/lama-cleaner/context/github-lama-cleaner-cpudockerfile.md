# Upstream docker/CPUDockerfile (Sanster/lama-cleaner @ 5114a46) + IOPaint LICENSE

## Source URL(s) + date
- https://raw.githubusercontent.com/Sanster/lama-cleaner/5114a46f5e6ad87f489e5dbbd98ac780bcee34fd/docker/CPUDockerfile (2026-11-26)
- https://raw.githubusercontent.com/Sanster/IOPaint/main/LICENSE (2026-11-26, merged; license of successor project)
- Not fetched (same as raw): https://github.com/Sanster/lama-cleaner/blob/5114a46.../docker/CPUDockerfile

## Full file
```
FROM python:3.7.4-slim-buster
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    libsm6 libxext6 ffmpeg libfontconfig1 libxrender1 libgl1-mesa-glx \
    curl
RUN pip install --upgrade pip && \
    pip install torch==1.12.1 --extra-index-url https://download.pytorch.org/whl/cpu
ARG version
RUN pip install lama-cleaner==$version
EXPOSE 8080
CMD ["bash"]
```

## Install/build steps + deps
- apt: software-properties-common, libsm6, libxext6, ffmpeg, libfontconfig1, libxrender1, libgl1-mesa-glx, curl (no recommends).
- pip: torch==1.12.1 from `https://download.pytorch.org/whl/cpu` as extra index.
- pip: `lama-cleaner==$version` (build arg `version`).

## Runtime deps
- Python 3.7.4 (`python:3.7.4-slim-buster`). torch 1.12.1 CPU.

## Entrypoint/flags
- `CMD ["bash"]`. No ENTRYPOINT. Server start command not in this Dockerfile (chart uses `lama-cleaner`).

## Ports
- `EXPOSE 8080`.

## User/UID
- Not set (root).

## License (IOPaint, successor)
- LICENSE at Sanster/IOPaint main: Apache License Version 2.0, January 2004 (Apache-2.0).

## Gotchas
- Pins Python 3.7 (EOL). Pins torch 1.12.1 (CPU index).
- `ARG version` lowercase; used as `lama-cleaner==$version`.
