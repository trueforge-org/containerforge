# hub.docker.com/r/codeproject/ai-server (draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/codeproject/ai-server · fetched 2026-11-26

## Image
- Description: standalone self-hosted AI microserver (same as repo README).
- Only `latest` is listed under recent tags; digest `sha256:fff2c957f…`, size **2.5 GB**. "Updated almost 2 years ago". 1M+ pulls, 76 stars.
- The page does not list cpu, cuda, rpi64 or arm64 tags. GPU example uses `codeproject/ai-server:gpu`.
- Architectures not listed on the page.

## Run example
- `docker pull codeproject/ai-server`; host port 32168 (Docker Desktop setting).
- GPU example: `docker run --name CodeProject.AI-Server -d -p 32168:32168 --gpus all` with bind mounts `<host data>` -> `/etc/codeproject/ai` and `<host modules>` -> `/app/modules`, image `codeproject/ai-server:gpu`.
- No environment variables specified.

## Conflicts noted on the page
- Dashboard and API example use **port 5000** (`http://localhost:5000`, `.../v1/vision/detect/scene`), while the docs and the GPU run example use **32168**. Port 5000 is the legacy port; plan.md's section 1 says it is opened unless `DisableLegacyPort` is set (appsettings.json, not verified here).
- GPU image is for NVIDIA CUDA cards with compute capability 6.0+ and needs `--gpus all`. The page also says the current release is CPU-focused with GPU planned, which conflicts with the GPU image section.

## Modules
GPU image specifics as above. The modules directory is mounted at `/app/modules`. Development version has extra modules not in the container.
