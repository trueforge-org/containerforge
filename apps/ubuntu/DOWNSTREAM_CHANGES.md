# Downstream changes

## Explicit HEALTHCHECK timings

The base image now declares `--interval=30s --timeout=10s --start-period=120s --start-interval=5s --retries=3` instead of Docker's defaults. Failures during the first 120 seconds do not count against `--retries`, and the check runs every 5 seconds until the first success. Apps start reporting `healthy` as soon as they are up, instead of waiting a full interval.

| Downstream container | Required change | Base-image version |
| --- | --- | --- |
| Every app with `FROM ghcr.io/trueforge-org/ubuntu` | None. The flags are inherited on the next base digest bump. | 26.4.0 |
| `apps/docusaurus` | None. It sets its own `HEALTHCHECK --start-period=10m` and keeps it. | 26.4.0 |

`/healthcheck.sh` itself is not part of the base image. `include/healthcheck.sh` is copied into each app at build time, so script changes reach an app with its own next build.
