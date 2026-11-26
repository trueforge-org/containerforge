# ShaneIsrael/fireshare (old location, Dockerfile at pinned commit)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/ShaneIsrael/fireshare/6889f4484e3163231ce337ea0aa231b99cbfb5c4/Dockerfile (fetched 2026-11-26; the blob URL from the draft is `.../blob/6889f44.../Dockerfile`)
- Repo root https://github.com/ShaneIsrael/fireshare: referenced by the draft; not fetched separately (the plan says it is the old location of fireshare-app/fireshare).

## What it is

Old upstream repo. The Dockerfile at commit 6889f44 is the CUDA (GPU) variant of the fireshare image, built with a source-compiled FFmpeg 6.1.

## Build (this Dockerfile, not used by ContainerForge)

- Stage 1 `node:24-slim AS client`: same client build as Dockerfile.lite.
- Stage 2 `nvidia/cuda:11.8.0-devel-ubuntu22.04 AS ffmpeg-builder`: builds SVT-AV1 v1.8.0, Vulkan-Headers v1.3.255, libplacebo v6.338.2, nv-codec-headers n12.1.14.0, FFmpeg 6.1 with `--enable-ffnvcodec --enable-nonfree --enable-libsvtav1 --enable-libplacebo --enable-vulkan` and many codec libs. Verifies `zscale|tonemap|libplacebo` filters.
- Stage 3 `ubuntu:22.04 AS python-source`: builds Python 3.14.0 from source (`--enable-shared --prefix=/opt/python3.14`).
- Final `nvidia/cuda:11.8.0-runtime-ubuntu22.04`: copies ffmpeg from the builder; apt: `nginx-extras supervisor libssl-dev libffi-dev libc-dev build-essential gosu ca-certificates tzdata` plus codec runtime libs and `libglvnd0 libegl1 libx11-6 libxext6 liblcms2-2 libvulkan1 mesa-vulkan-drivers`.
- Python 3.14 placed in `/opt/python3.14`; `/usr/bin/python3` symlinked.
- ENV: `FLASK_APP`, `ENVIRONMENT=production`, `DATA_DIRECTORY=/data`, `VIDEO_DIRECTORY=/videos`, `IMAGE_DIRECTORY=/images`, `PROCESSED_DIRECTORY=/processed`, `TEMPLATE_PATH`, `ADMIN_PASSWORD=admin`, `ANALYTICS_TRACKING_SCRIPT=""`, `TZ=UTC`, `LD_LIBRARY_PATH`, `NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,graphics`, `PATH`.
- `EXPOSE 80`; `CMD ["bash", "/entrypoint.sh"]`. No USER, VOLUME, HEALTHCHECK, ENTRYPOINT.

## Relevance to ContainerForge

- The draft's "CUDA/NVENC" variant. Plan rejects it (no CUDA in ContainerForge; GPU out of scope). Ubuntu apt `ffmpeg` (CPU) is the replacement.
- Vulkan ICD/EGL vendor JSON files baked in (GPU image only).

## Gotchas

- This is the old-location repo; the active repo is `fireshare-app/fireshare`.
