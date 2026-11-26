# TrueCharts chart genea (values)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/genea (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/genea/values.yaml (2026-11-26, WebFetch summary)

Container image: `docker.io/biggiesize/genea-app:latest`, digest pinned (starts `acd12892dfaca16e`), pullPolicy IfNotPresent.

Security context: readOnlyRootFilesystem false; runAsUser 0, runAsGroup 0.

Persistence: none defined.

Service: main, http, port 3181, target 3181.

Probes: none defined. Env values: none defined.

Gotchas:
- The chart exposes port 3181, not 80 as in the draft and not 8080 as in plan.md. The image itself does not document its port (Docker Hub page). Treat 3181 as the chart's configured port, not verified against the image; plan.md (nginx on 8080) is unaffected because the container serves its own port.

Failed to fetch: none.
