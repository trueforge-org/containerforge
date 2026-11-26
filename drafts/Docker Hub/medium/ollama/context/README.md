# context: ollama

Fetched 2026-11-26.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/values.yaml | truecharts-ollama.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/Chart.yaml | truecharts-ollama.md |
| https://hub.docker.com/v2/repositories/ollama/ollama/ | dockerhub-ollama-ollama.md |
| https://hub.docker.com/v2/repositories/ollama/ollama/tags?page_size=10 | dockerhub-ollama-ollama.md |
| https://docs.ollama.com | ollama-docs.md (Docker page: https://docs.ollama.com/docker) |
| https://docs.ollama.com/docker | ollama-docs.md |
| https://github.com/ollama/ollama | github-ollama.md (repo root, README via raw main) |
| https://github.com/ollama/ollama/blob/v0.40.16/Dockerfile | github-ollama.md (same as raw) |
| https://raw.githubusercontent.com/ollama/ollama/v0.40.16/Dockerfile | github-ollama.md |
| https://github.com/open-webui/open-webui | open-webui-readme.md |
| https://ollama.com | ollama-com-home.md |

Skipped: none of the categories listed in the batch brief were present. No CLA, forgetool schema, containerforge or templated URLs were in the list.

Failures:
- https://api.github.com/repos/ollama/ollama/releases/latest: HTTP 403. Not retried; release asset names taken from plan's v0.40.16 notes are not re-verified here.

## plan.md corrections
- plan.md line 20: `TrueCharts charts/stable/ollama 11.0.2` -> `11.0.3` (source: truecharts-ollama.md, Chart.yaml `version: 11.0.3`).

Unverified conflicts (not edited):
- plan.md line 18, 144, 179, 191: plan assumes Ollama default models dir `~/.ollama`. FAQ (docs.ollama.com/faq) gives macOS `~/.ollama/models` and Linux `/usr/share/ollama/.ollama/models`. Behaviour when HOME=/config is not verified here; setting `OLLAMA_MODELS` explicitly removes the ambiguity.
- plan.md line 8: 0.40.18 release date 2026-11-24 not verified against the release API (403); the Docker Hub tag date matches.
