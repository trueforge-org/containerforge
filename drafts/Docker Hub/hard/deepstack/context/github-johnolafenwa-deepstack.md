# github.com/johnolafenwa/DeepStack (source, README, releases, LICENSE, Dockerfile.cpu)

Source URL(s) + fetch date (all 2026-11-26):
- https://raw.githubusercontent.com/johnolafenwa/DeepStack/master/README.md
- https://github.com/johnolafenwa/DeepStack/releases (first attempt DNS error, retry succeeded)
- https://raw.githubusercontent.com/johnolafenwa/DeepStack/master/LICENSE
- https://raw.githubusercontent.com/johnolafenwa/DeepStack/master/Dockerfile.cpu (plan's commit 73b6f7ab is the pinned draft commit; this is master)
- https://raw.githubusercontent.com/johnolafenwa/DeepStack/master/.gitattributes (returned empty; no LFS rules seen)

## What it is
"AI API engine" serving pre-built models (face detection/recognition, object detection for 80 objects, scene recognition, 4x super-resolution, custom models) via REST APIs. Developed by John Ishola Olafenwa; the README says it is owned and maintained by DeepQuest AI. Runs offline; SSL and API-key support.

## Version / releases
- Latest release: **2022.01.1** ("DeepStack 2022.01.1 Release"), tag `2022.01.1`, commit `5da0520`, 22 Jan (year not shown; plan says 2022-01-22). 4 assets, names not loaded. The notes say Windows CPU and GPU installers are among the assets.
- Docker tags named in the release notes:
  - `deepquestai/deepstack:cpu-2022.01.1`
  - `deepquestai/deepstack:gpu-2022.01.1`
  - `deepquestai/deepstack:jetpack-2021.01.1` (**not 2022.01.1**)
  - `deepquestai/deepstack:arm64-2022.01.1`
  - `deepquestai/deepstack:arm64-server-2022.01.1`
- Renovate: the tag is `2022.01.1` (not the release title text).

## Licence
Apache License 2.0 (LICENSE file, "Version 2.0, January 2004"; README badge). Model weight licences not stated anywhere fetched.

## Upstream Dockerfile.cpu (master)
- `FROM deepquestai/deepstack-base:cpu-1647248158 AS cpu`.
- ENV: `SLEEP_TIME=0.01`, `TIMEOUT=60`, `SEND_LOGS=True`, `CUDA_MODE=False`, `APPDIR=/app`, `DATA_DIR=/datastore`, `TEMP_PATH=/deeptemp/`, `PROFILE=desktop_cpu`; PATH includes `/usr/local/go/bin`.
- Creates `/deeptemp`, `/datastore`, `/app/sharedfiles`, `/app/server`, `/app/intelligencelayer`.
- Go 1.17.6 linux-amd64 tarball via wget into `/usr/local`.
- `pip install onnxruntime==0.4.0`; unpinned pip: redis, opencv-python, Cython, pillow, scipy, tqdm, tensorboard, PyYAML, Matplotlib, easydict, future, numpy.
- `go build` in `/app/server` -> `/app/server/server`.
- COPY model files: `./sharedfiles/yolov5m.pt`, `face.pt`, `facerec-high.model`, `scene.pt`, `categories_places365.txt`, `bebygan_x4.pth` -> `/app/sharedfiles/`; `./server` -> `/app/server`; `./intelligencelayer` -> `/app/intelligencelayer`; `./init.py` -> `/app`.
- `EXPOSE 5000`; no VOLUME; no USER (root); no ENTRYPOINT; `CMD ["/app/server/server"]`.

## Weights / LFS (conflicts with plan.md)
- README build steps: `git lfs pull` ("fetches large repo files") then `.\download_dependencies.ps1` for binary dependencies. Git LFS is a listed prerequisite.
- `.gitattributes` could not be read (empty response), so whether `sharedfiles/*.pt` are LFS objects in the repo is UNVERIFIED.
- plan.md says weights are NOT in the git repo and only the Docker image has them. The README's LFS step contradicts or at least complicates that; see the plan corrections in README.md.

## Run / env (README, docs)
- README: no `docker run` example; docs (docs.deepstack.cc replacement, see deepstack-readthedocs.md) show `docker run -e VISION-SCENE=True -v localstorage:/datastore -p 80:5000 deepquestai/deepstack`.
- Env names as used by the server: `VISION-SCENE`, `VISION-DETECTION`, `VISION-FACE` (hyphen names; the local PowerShell run uses `VISION_DETECTION` etc.). No defaults stated.
- Windows: `deepstack --VISION-SCENE True --PORT 80`.
- PyTorch for local run (Python 3.7): `torch==1.6.0+cpu` and `torchvision==0.7.0+cpu` (CPU); `+cu101` for GPU. Requirements: Python 3.7, PowerShell 7+, Golang, Docker, Git, Git LFS, Redis Server.
