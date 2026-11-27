# TrueCharts jupyter (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/jupyter/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Jupyter web IDE. Chart version 15.0.0, appVersion 7.4.7. Depends on common 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Images (all tag notebook-7.4.7 @digest, quay.io/jupyter/*)
| Chart key | Repository | Digest (short) |
| --- | --- | --- |
| image | base-notebook | 5d1c5649... |
| minimalImage | minimal-notebook | c17170eb... |
| rImage | r-notebook | 6fabd176... |
| scipyImage | scipy-notebook | 3458d4fb... |
| tensorflowImage | tensorflow-notebook | 9280a79c... |
| datascienceImage | datascience-notebook | b12188b0... |
| pysparkImage | pyspark-notebook | 6287c0ba... |
| allsparkImage | all-spark-notebook | ad00c652... |

Container uses `imageSelector: image` (base-notebook) by default.

## Ports
- main: 10300 (http) -> targetPort 8888.

## Command / jupyter values
- DOCKER_STACKS_JUPYTER_CMD = jupyter.jupyter_cmd (default `lab`)
- RESTARTABLE = yes/no from jupyter.restartable (default true)

## Env vars
- NB_UID from securityContext.container.PUID ; NB_GID from securityContext.pod.fsGroup ; NB_UMASK from securityContext.container.UMASK

## Security context
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Persistence
- data -> /home/jovyan/work (enabled)

## Gotchas
- Chart overrides runtime to root with NB_UID remap, relying on docker-stacks start-notebook.py.
