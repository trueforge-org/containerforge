# Context index: whisper-asr-webservice

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/whisper-asr-webservice/values.yaml + Chart.yaml | truecharts-whisper-asr-webservice.md |
| https://hub.docker.com/v2/repositories/onerahmet/openai-whisper-asr-webservice/ + tags?page_size=10 | dockerhub-openai-whisper-asr-webservice.md |
| https://raw.githubusercontent.com/ahmetoner/whisper-asr-webservice/v1.10.0/Dockerfile (also blob URL) | whisper-asr-dockerfile-v1.10.0.md |

Skipped (one line): https://download.pytorch.org/whl/cpu (pip wheel index, not fetched; wheels not downloaded), https://ahmetoner.github.io/whisper-asr-webservice (project site), https://github.com/ahmetoner/whisper-asr-webservice (repo HTML), releases/tag/v1.10.0 (HTML; tag is covered by the raw Dockerfile). No CLA, forgetool, containerforge, templated or image-ref URLs in this list beyond the Dockerfile's own FROM lines.
Failures: none.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: Dockerfile v1.10.0 stages (`onerahmet/ffmpeg:n7.1`, `swaggerapi/swagger-ui:v5.9.1`, `python:3.12-bookworm`), `poetry==2.1.3`, `poetry install --extras cpu`, `EXPOSE 9000`, `ENTRYPOINT whisper-asr-webservice`, no apt, no USER, no VOLUME, ffmpeg copied from `onerahmet/ffmpeg`.
- Unverified conflict: plan.md says "Latest stable is `v1.11.0`". Docker Hub (2026-11-27) lists `v2.0.0` and `v2.0.0-gpu` as the newest tags, and the TrueCharts chart pins v1.11.0. The plan's "latest stable" line may be stale. Not edited, version choice is the user's.
- Stale count (not an error): plan.md says Docker Hub has 67 tags; the tags API now reports 73.
- Not verified here: pyproject `requires-python >=3.10,<3.14` and the torch 2.7.1 pins (pyproject.toml not fetched).
