# neggles/sd-webui-docker docker/Dockerfile.auto (commit 8d163826a402)

Source URL(s) + date:
- https://raw.githubusercontent.com/neggles/sd-webui-docker/8d163826a402/docker/Dockerfile.auto (fetched 2026-11-27)
- https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/HEAD/requirements.txt (fetched 2026-11-27)
- https://github.com/AUTOMATIC1111/stable-diffusion-webui/releases/latest (redirect, fetched 2026-11-27) -> tag v1.10.1

## What it is
- Dockerfile for AUTOMATIC1111 stable-diffusion-webui ("auto" variant). Two stages shown: `download` (git clones) and `webui` (FROM `base`, defined in another file not fetched).

## Build steps
1. Stage `download` (alpine/git:2.36.2): bash shell; git clones with ARG refs, depth=1, then `git fetch origin <ref>` + `reset --hard FETCH_HEAD`:
   - Stability-AI/stablediffusion (STABLE_DIFFUSION_REF)
   - salesforce/BLIP (BLIP_REF)
   - crowsonkb/k-diffusion (K_DIFFUSION_REF)
   - Stability-AI/generative-models (STABLE_DIFFUSION_XL_REF)
   - AUTOMATIC1111/stable-diffusion-webui-assets (SD_WEBUI_ASSETS_REF)
2. Stage `webui` FROM `base`:
   - ENV LC_ALL=C.UTF-8, PYTHONUNBUFFERED=1, PYTHONIOENCODING=utf-8, PIP_ROOT_USER_ACTION=ignore, CUDA_MODULE_LOADING=LAZY, TORCH_ALLOW_TF32_CUBLAS_OVERRIDE=1, PYTORCH_CUDA_ALLOC_CONF, NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics, NVIDIA_REQUIRE_CUDA="cuda>=12.1 driver>=500", TCMALLOC_AGGRESSIVE_DECOMMIT=t
   - ROOT_DIR=/stable-diffusion-webui
   - pip: pyngrok, CLIP (git, CLIP_PKG_REF), open_clip (git, OPENCLIP_PKG_REF)
   - git clone SD_WEBUI_REPO into ROOT_DIR, checkout SD_WEBUI_REF, submodules init
   - `pip install -r requirements_versions.txt` (pinned file in repo, not requirements.txt)
   - copy download-stage repos into ROOT_DIR/repositories
   - extra pip: accelerate diffusers ffmpeg-python natsort onnxruntime-gpu opencv-contrib-python-headless scenedetect scikit-learn segment-anything segmentation-refinement; moviepy>=1.0.3, tqdm>=4.65.0, imageio-ffmpeg
   - xformers (XFORMERS_PACKAGE, XFORMERS_PIP_ARGS; retries with --pre)
   - COPY . /docker; COPY entrypoint.sh /docker/entrypoint.sh
   - sed patch on gradio routes.py (`in_app_dir = True`) under /usr/local/lib/python3.10/site-packages
   - ENV CLI_ARGS="", DATA_DIR=/data, WEBUI_PORT=7860, UID=1000, GID=1000
   - EXPOSE ${WEBUI_PORT}; ENTRYPOINT `/docker/entrypoint.sh`
   - CMD `python -u webui.py --listen --port ${WEBUI_PORT} --skip-version-check ${CLI_ARGS}`

## Runtime deps
- Python 3.10 (site-packages path hardcoded), CUDA-capable torch via requirements, gradio, xformers, ffmpeg (ffmpeg-python/imageio-ffmpeg).
- Base image `base` is not in this file (not fetched).

## Entrypoint/flags
- `/docker/entrypoint.sh`; default CMD `python -u webui.py --listen --port 7860 --skip-version-check`.
- Chart passes `--skip-version-check` as args.

## Ports
- 7860 (WEBUI_PORT).

## Volumes/paths
- DATA_DIR=/data; ROOT_DIR=/stable-diffusion-webui. Chart mounts /data and /output.

## User/UID
- ENV UID=1000, GID=1000 (used by entrypoint, not fetched). Chart runs as root.

## Version/asset naming
- Upstream repo pinned by ARG refs (commit SHAs / tags), not fetched.
- AUTOMATIC1111 latest release tag: v1.10.1 (GitHub redirect). API releases/latest returned 403 (rate limit).

## Upstream requirements (AUTOMATIC1111 HEAD requirements.txt, fetched)
- Pins include gradio==3.41.2, transformers==4.30.2, protobuf==3.20.0, pillow-avif-plugin==1.4.3, fastapi>=0.90.1, torch (unpinned), open-clip-torch.
- Dockerfile installs requirements_versions.txt (not this file); that file not fetched.

## License
- AUTOMATIC1111 stable-diffusion-webui LICENSE.txt (raw HEAD): GNU AGPL v3, Copyright 2023 AUTOMATIC1111.

## Gotchas
- Dockerfile.auto is a partial stage file; needs `base` stage from sibling Dockerfile.
- `sed` on gradio routes.py is a hard-coded patch tied to python3.10 site-packages path.
- `RUN ls -l && sleep 5` debug line in download stage.
- Floating refs (ARG *_REF) must be pinned by the consumer to be reproducible.
