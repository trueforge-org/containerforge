# TrueCharts slink chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/slink (values.yaml raw, fetched 2026-11-26; tree page URL in urls.txt not separately fetched, values.yaml suffices).

## values.yaml facts
- Image: `docker.io/anirdev/slink`, tag `v1.14.6@sha256:7f7cab180971caeb83ce8818a676be04a7923dff6bf6e201ae0a9ce4f64be593`, pullPolicy IfNotPresent
- `readOnlyRootFilesystem: false`; `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`
- Service main port 3000, protocol http
- env: `ORIGIN` = chart appUrl; `USER_APPROVAL_REQUIRED: true`; `IMAGE_MAX_SIZE: "15M"`
- Persistence: `/app/var/data` and `/app/slink/images` (mountPath); a required persistence entry
