# TrueCharts chart: fabulinus

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/fabulinus (directory not fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fabulinus/values.yaml
- Fetched 2026-11-26

## Images
- Main: `docker.io/tytn/fabulinus`, tag `latest-cpu@sha256:f8b30eaa5b61d6085fc715f40619733846927c2266a3e20523e93fb58afeef38`, pullPolicy IfNotPresent.
- GPU (`gpuImage`): `docker.io/tytn/fabulinus`, tag `latest-gpu@sha256:9a826a578ca4157fbe3c091eb78aa35dfca6675f9fae24dcb90495ba4d9715d1`.

## Service
- `service.main` port `main`: protocol http, targetPort 80, port 10687.

## Persistence
- `models`: mountPath `/code/models`, enabled, no type.

## Security context
- readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0. No podSecurityContext.

## Env vars (main container)
- TAKEOFF_DEVICE (default `cpu`; comment cpu | gpu).
- TAKEOFF_MODEL_NAME (default `google/flan-t5-small`).
- TAKEOFF_QUANT_TYPE (default `int8`; comment: int8 | float16 | bfloat16 | int8_float16 | int8_bfloat16).
- TAKEOFF_MAX_BATCH_SIZE (default 32).
- TAKEOFF_DISABLE_BATCHING (default true).

## GPU
- No nvidia settings or GPU resource limits in values; GPU only via gpuImage and device option.

## Probes
- liveness: http `/docs`; readiness: http `/docs`; startup: tcp.
