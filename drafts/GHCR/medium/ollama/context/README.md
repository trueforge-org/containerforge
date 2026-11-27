# Context: ollama (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/values.yaml | truecharts-ollama.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/Chart.yaml | truecharts-ollama.md |
| https://hub.docker.com/v2/repositories/ollama/ollama/ | dockerhub-ollama.md |
| https://hub.docker.com/v2/repositories/ollama/ollama/tags?page_size=10 | dockerhub-ollama.md |
| https://github.com/ollama/ollama | github-ollama.md (README + Dockerfile) |
| https://raw.githubusercontent.com/open-webui/open-webui/main/Dockerfile | github-open-webui-dockerfile.md |
| https://github.com/open-webui/open-webui/blob/0666e59/Dockerfile | github-open-webui-dockerfile.md (raw variant; identical to main) |
| https://raw.githubusercontent.com/open-webui/open-webui/main/LICENSE | github-open-webui-license.md |
| https://github.com/open-webui/open-webui | github-open-webui-license.md |
| https://github.com/open-webui/open-webui/releases/tag/v0.13.5 | github-open-webui-license.md (via releases/latest alternative) |
| https://pypi.org/pypi/open-webui/json | pypi-open-webui.md |
| https://docs.openwebui.com | docs-openwebui.md |
| https://openwebui.com | misc-sources-ollama.md |
| https://astral.sh/uv | misc-sources-ollama.md |

Skipped categories: none in the list.

Failures:
- https://api.github.com/repos/open-webui/open-webui/releases/latest: 403. Alternative https://github.com/open-webui/open-webui/releases/latest (HTML) gave v0.13.5.
- https://docs.openwebui.com/getting-started/env-configuration/: 404. Alternative without trailing slash: 404. Env var reference not retrieved.

## plan.md corrections

Edits made (2), both from the fetched upstream Dockerfile (`ENV OLLAMA_BASE_URL="/ollama"`, github-open-webui-dockerfile.md):
- plan.md line 17: `OLLAMA_BASE_URL` (empty) -> `OLLAMA_BASE_URL` (`/ollama`)
- plan.md line 118: "(upstream ENV, empty by default)" -> "(upstream ENV, default `/ollama`)"

Unverified conflicts (not edited):
- plan.md line 9 says chart image is `ghcr.io/open-webui/open-webui:latest`, digest unverified. Chart values pin `latest@sha256:ff7f7cbb4545aacec2c22d085b2bc406b299c119bd98747421124a1a6c03795f` (truecharts-ollama.md). Not an error, the digest is now known.
