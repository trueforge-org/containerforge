# truecharts: whisper-asr-webservice (chart 10.0.0, appVersion 1.11.0)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/whisper-asr-webservice/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## Images
- main: repository `docker.io/onerahmet/openai-whisper-asr-webservice`, tag `v1.11.0@sha256:ee1be3f75828d009517d1f27be2a6a52d0ca5e8e9f6a0d75ed65fd492fa25810`, pullPolicy IfNotPresent. `imageSelector: image`.
- gpuImage: same repo, tag `v1.11.0-gpu@sha256:a9236935bb0b2921f92ed53a477a627275e9ddadcae3cba667bab0acc06f0072`.

## Env (set in values)
| Env | Value |
| --- | --- |
| ASR_MODEL | `tiny` |
| ASR_ENGINE | `faster_whisper` |

## Service / ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 19900 | http | 9000 |

## Probes
- liveness, readiness, startup: all `tcp`.

## Persistence
| Name | enabled | mountPath |
| --- | --- | --- |
| pip | true | `/root/.cache/pip` |
| poetry | true | `/root/.cache/poetry` |
| whisper | true | `/root/.cache/whisper` |

## Security
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Dependencies
- `common` 32.8.5 only (no app dependency).

## Gotchas
- Chart's model cache is `/root/.cache/whisper` (root home). Upstream default `ASR_MODEL_PATH` is `~/.cache/whisper`.
- Chart engine is `faster_whisper`. Upstream config defaults were not fetched in this run.
