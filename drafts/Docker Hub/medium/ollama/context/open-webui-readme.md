# Open WebUI README (UI sidecar)

## Source URL(s) + date
- https://raw.githubusercontent.com/open-webui/open-webui/main/README.md (2026-11-26)
- https://github.com/open-webui/open-webui (repo root, covered by this README)

## What it is
Web UI for Ollama and OpenAI-compatible APIs. Chart uses `ghcr.io/open-webui/open-webui` as `uiImage`.

## Run (from README)
- `DATA_DIR=~/.open-webui uvx --python 3.12 open-webui@latest serve`, then http://localhost:8080.
- Docker: `docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main`, UI on port 3000 (host) -> 8080 (container).

## Options from README
| Option | Purpose |
| --- | --- |
| `-e OLLAMA_BASE_URL=http://your-ollama-server:11434` | Ollama on another server |

## Ports / volumes
- Container port 8080. Data volume `/app/backend/data`.

## Gotchas
- Open WebUI is a separate Python stack. Not in plan scope (plan.md says no `apps/open-webui`).
- Container listens on 8080 by default; chart uses PORT=10686 env to override.
