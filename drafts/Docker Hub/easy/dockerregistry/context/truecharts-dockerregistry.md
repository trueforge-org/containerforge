# TrueCharts chart: dockerregistry

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dockerregistry (directory; content read from raw `values.yaml`) · 2026-11-26

## Values (as of fetch)
- Image: `registry` tag `3@sha256:82f6ff4a7f982960c8aa51617fea3aabc485df6e55cce80d22deb1de36f1bc3c`, pullPolicy `IfNotPresent`.
- Env: none.
- Service `main`, port `main` 5000/tcp (targetPort 5000).
- Persistence: `datastoragepath` mounted at `/var/lib/registry`.
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
- Probes: none. Args: none.

## Notes vs plan.md
- Chart image is `registry:3` (matches plan's "same major"). Chart uses `/var/lib/registry` as in plan section 9.
