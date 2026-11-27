# spegel-org/spegel Dockerfile at commit 7e2e042
Source URL: https://raw.githubusercontent.com/spegel-org/spegel/7e2e042/Dockerfile (fetched 2026-11-27)

```
FROM gcr.io/distroless/static:nonroot
ARG TARGETOS
ARG TARGETARCH
COPY ./dist/spegel_${TARGETOS}_${TARGETARCH}/spegel /
USER root:root
ENTRYPOINT ["/spegel"]
```

- Base: gcr.io/distroless/static:nonroot (no shell, no package manager)
- Binary is pre-built into `./dist/spegel_<os>_<arch>/spegel` by the build context (not compiled in the Dockerfile); args TARGETOS/TARGETARCH required
- Runs as root:root (USER overridden to root despite nonroot base)
- Entrypoint: /spegel (no default args)
- Gotcha: build needs a dist/ directory with the layout above
