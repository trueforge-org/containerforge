# TrueCharts chart: ollama (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/Chart.yaml (2026-11-27)

What it is: "Get up and running with large language models locally." Chart `version: 11.0.3`, `appVersion: 0.40.18`. Category AI. Depends on `common` 32.8.5. Two containers in the chart: Ollama API (`main` workload) and Open WebUI (`ui` workload).

Images (values.yaml):
| Key | Repository | Tag |
| --- | --- | --- |
| image | docker.io/ollama/ollama | 0.40.18 @sha256:1cabd20e... |
| rocmImage | docker.io/ollama/ollama | 0.40.18-rocm @sha256:ab28cc83... |
| uiImage | ghcr.io/open-webui/open-webui | latest @sha256:ff7f7cbb... |

Ports (service):
| Service | Port | targetPort | Notes |
| --- | --- | --- | --- |
| main (ui) | 10686 | targetSelector ui | protocol http |
| api | 11434 | targetSelector main | enabled |

ingress.api: disabled.

Env vars (ui container, chart-set):
| Name | Value |
| --- | --- |
| PORT | `{{ service.main.ports.main.port }}` (10686) |
| OLLAMA_BASE_URL | `http://<fullname>-api:11434` |
| WEBUI_SECRET_KEY | secretKeyRef `ollama-secrets` key `WEBUI_SECRET_KEY` |
| AUTOMATIC1111_BASE_URL | `ollama.stable_diffusion.base_url` (default "") |
| ENABLE_SIGNUP | `ollama.registration.enabled` (default true) |
| DEFAULT_USER_ROLE | `ollama.registration.def_user_role` (default "pending"; allowed admin/user/pending) |
| WHISPER_MODEL | `ollama.whisper.model` (default "base") |
| RAG_EMBEDDING_MODEL | `ollama.rag.model` (default "all-MiniLM-L6-v2") |
| RAG_EMBEDDING_MODEL_DEVICE_TYPE | `ollama.rag.model_device_type` (default "cpu"; cpu/cuda/mps) |
| WEBUI_AUTH_TRUSTED_EMAIL_HEADER | `ollama.registration.trusted_email_header` (not set in values) |
Commented out: OPENAI_API_BASE_URL, OPENAI_API_KEY, DEFAULT_MODELS.

Note: values.yaml `ollama.webuiSecretKey` is a placeholder string ("PLACEHOLDER...CHANGEME"), marked "Must be changed".

Probes:
- main (ollama API): liveness and readiness `http /api/version` on port 11434; startup `tcp` on 11434.
- ui: liveness and readiness `http /` on 10686; startup `tcp` on 10686.

Volumes/paths:
| Persistence | Container path | Workload |
| --- | --- | --- |
| config | `/root/.ollama` | main (ollama) |
| data | `/app/backend/data` | ui (open-webui) |

User/UID: `securityContext.container` runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false (root).

Gotchas:
- Ollama image path in chart is `docker.io/ollama/ollama` (Docker Hub), tag 0.40.18 (older than the Hub `latest` at 2026-11-27).
- ui image `latest` is pinned by digest only, not a versioned tag.
