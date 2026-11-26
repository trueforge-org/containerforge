# deepstack.readthedocs.io (docs; replacement for docs.deepstack.cc)

Source URL(s) + fetch date:
- https://docs.deepstack.cc (draft) · FAILED 2026-11-26: DNS ENOTFOUND for docs.deepstack.cc.
- https://deepstack.readthedocs.io/ · fetched 2026-11-26 (linked from the Docker Hub page)

## Overview
AI server (face recognition, object detection, scene recognition, enhancement, custom models) on premises or in cloud. Runs on Windows, macOS, Linux and Raspberry Pi. Maintained by DeepQuest AI. Variants: CPU, GPU, NVIDIA Jetson, Raspberry Pi (Intel NCS).

## Docker install (CPU)
- `sudo apt-get install docker.io` (Linux); `docker pull deepquestai/deepstack`.

## Run commands (scene recognition enabled)
- CPU: `docker run -e VISION-SCENE=True -v localstorage:/datastore -p 80:5000 deepquestai/deepstack`
- GPU: `sudo docker run --gpus all -e VISION-SCENE=True -v localstorage:/datastore -p 80:5000 deepquestai/deepstack:gpu`
- Jetson: `sudo docker run --runtime nvidia -e VISION-SCENE=True -p 80:5000 deepquestai/deepstack:jetpack` (no volume)
- Windows: `deepstack --VISION-SCENE True --PORT 80`; Raspberry Pi: `sudo deepstack start "VISION-SCENE=True"`.

## Parameters
- `VISION-SCENE=True` enables scene recognition (default not stated). Port 5000 in the container, mapped to host 80 in examples. Volume `/datastore` (CPU/GPU examples).
- API: `POST http://localhost:80/v1/vision/scene` (multipart `image`). Other API endpoints on the API reference page (not followed).

## Status
No deprecation notice; footer copyright 2021.
