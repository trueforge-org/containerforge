# tytn/fabulinus (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/tytn/fabulinus
- Fetched 2026-11-26

## What it is
- "The server component of the TitanML Takeoff server." Community-edition Docker repo for LLM inference. Managed through the `iris` CLI (`pip install titan-iris`).
- Community features: streaming responses, int8 quantization, chat and playground UI, T5 encoder-decoder and decoder models. Multi-GPU and int4 quantization listed as pro-edition only.
- 1 star, 10K+ pulls, updated about 3 years before fetch.

## Architectures and tags
- Not listed. Only `latest` shown (3.2 GB; digest `sha256:9a826a578...`). Usage text mentions `latest-cpu`, which is not in the tag list. `latest-gpu` not mentioned.
- Digest `9a826a578...` is the same digest TrueCharts pins for `latest-gpu`.

## Run commands (documented)
- CPU: `docker run -e TAKEOFF_MODEL_NAME=<model_name> -p 8000:80 tytn/fabulinus:latest-cpu`
- GPU: `docker run --gpus all -e TAKEOFF_MODEL_NAME=<model_name> -e TAKEOFF_DEVICE=cuda -p 8000:80 tytn/fabulinus:latest`
- iris: `iris takeoff --model tiiuae/falcon-7b-instruct --device cpu --port 8000` (prompts for login; `--device cuda` for GPU).

## Env vars
- TAKEOFF_MODEL_NAME (model to serve), TAKEOFF_DEVICE (`cuda` for GPU).
- Port: container listens on 80 (host 8000 mapped to 80 in the run example).
- Volumes: none documented. Model paths: none documented on the page.

## Endpoints
- `/demos/playground`, `/demos/chat`, `/docs` on port 8000 (host).

## License
- No license text shown; page points to the GitHub repo for contribution info.
