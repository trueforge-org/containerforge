# TrueCharts chart: ollama

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ollama/Chart.yaml (2026-11-26)

## What it is
Chart version 11.0.3, `appVersion: 0.40.18`, category AI, library `common` 32.8.5. Sources: ollama/ollama, open-webui/open-webui, ghcr.io/open-webui/open-webui.

## Images
| Role | Repository | Tag (pinned digest) |
| --- | --- | --- |
| image (main/api) | docker.io/ollama/ollama | 0.40.18@sha256:1cabd20e1762a7a8444bf4a7110b346d923cd77ab6c97c984434140638c913ec |
| rocmImage | docker.io/ollama/ollama | 0.40.18-rocm@sha256:ab28cc8337abd53e03d21a3d160f3fff2e798ff13d0eb6125284622f9074e5ac |
| uiImage | ghcr.io/open-webui/open-webui | latest@sha256:ff7f7cbb4545aacec2c22d085b2bc406b299c119bd98747421124a1a6c03795f |

## Ports / services
| Service | Port | Protocol | Notes |
| --- | --- | --- | --- |
| main (targetSelector ui) | 10686 | http | UI |
| api (targetSelector main) | 11434 | http | Ollama API, targetPort 11434 |
| ingress api | - | - | disabled |

## Env vars (ui container)
| Name | Value |
| --- | --- |
| PORT | 10686 (from service main) |
| OLLAMA_BASE_URL | http://<fullname>-api:11434 |
| WEBUI_SECRET_KEY | secretKeyRef ollama-secrets/WEBUI_SECRET_KEY |
| AUTOMATIC1111_BASE_URL | "" (ollama.stable_diffusion.base_url) |
| ENABLE_SIGNUP | true (registration.enabled) |
| DEFAULT_USER_ROLE | pending (registration.def_user_role) |
| WHISPER_MODEL | base |
| RAG_EMBEDDING_MODEL | all-MiniLM-L6-v2 |
| RAG_EMBEDDING_MODEL_DEVICE_TYPE | cpu |
| WEBUI_AUTH_TRUSTED_EMAIL_HEADER | from registration.trusted_email_header (not set in values) |

Commented out: OPENAI_API_BASE_URL, OPENAI_API_KEY, DEFAULT_MODELS.

## Secrets
- `ollama.webuiSecretKey`: placeholder "PLACEHOLDERWEBUISECRETKEYCHANGEME..." (must change; 64+ chars recommended).

## Persistence
| Name | Mount | Target |
| --- | --- | --- |
| config | /root/.ollama | main/main |
| data | /app/backend/data | ui/ui |

## Probes
- api workload main: liveness/readiness http `/api/version` on 11434; startup tcp 11434.
- ui workload: liveness/readiness http `/` on 10686; startup tcp 10686.

## Security
- securityContext.container: `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- Chart runs two containers: Ollama API and open-webui UI (separate Deployment `ui`).
- Chart persists models in `/root/.ollama`.
