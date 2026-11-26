# Context sources: victoriametrics

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/VictoriaMetrics/VictoriaMetrics (and /tree/master) | github-victoriametrics-victoriametrics.md |
| https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v1.156.0/app/victoria-metrics/deployment/Dockerfile | github-victoriametrics-victoriametrics.md |
| https://github.com/VictoriaMetrics/VictoriaMetrics/blob/v1.156.0/app/victoria-metrics/deployment/Dockerfile | github-victoriametrics-victoriametrics.md (raw fetch) |
| https://github.com/VictoriaMetrics/VictoriaMetrics/releases | github-victoriametrics-victoriametrics.md (version and asset naming) |
| https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v1.157.0/LICENSE | github-victoriametrics-victoriametrics.md (license) |
| https://docs.victoriametrics.com/ | docs-victoriametrics-single-node.md |
| https://docs.victoriametrics.com/victoriametrics/single-server-victoriametrics/ | docs-victoriametrics-single-node.md |
| https://hub.docker.com/r/victoriametrics/victoria-metrics | dockerhub-victoriametrics-victoria-metrics.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/victoriametrics | truecharts-victoriametrics.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v${VERSION#v}/... and .../v1.156.0/..., v1.157.0/... (release assets, incl. -cluster.tar.gz and checksums) | direct binary/archive downloads; asset naming recorded in the releases summary |
| https://raw.githubusercontent.com/VictoriaMetrics/VictoriaMetrics/v${VERSION#v}/LICENSE | placeholder version (the v1.157.0 variant was fetched) |
| http://127.0.0.1:8428/health, http://localhost:8428/api/v1/import/prometheus | localhost / 127.0.0.1 |
| http://...:8428/ | placeholder host, not a real URL |
| ghcr.io/trueforge-org/ubuntu (with digest) | ghcr image ref, not a web page |
| docker.io/victoriametrics/victoria-metrics:v1.156.0 | image ref, covered by the Docker Hub page |
| quay.io (mentioned in docs, not in draft) | not in draft; noted only |

## Fetch failures

None. Not fully read: docs single-node page was truncated at ~100k of 323k characters; the release page was read to ~100k of 112k characters.

## plan.md corrections

Edited: none.

Notes (not edited):
- unverified: plan.md section 10 "retentionPeriod bare numbers mean months"; the docs gave the default as "1 month (31 days)" but not the bare-number unit semantics.
- unverified: plan.md section 10 `-storage.minFreeDiskSpaceBytes` (default 100 MB); not in fetched text.
- unverified: plan.md section 7 says VictoriaMetrics "flushes in-memory parts on SIGTERM". The docs say `SIGINT` is the graceful-stop signal; `SIGTERM` is not documented. Kept as-is because the exact behaviour is not confirmed.
- note: plan.md section 1 says the draft pins v1.156.0 "from the chart". At fetch time the TrueCharts chart pins `v1.157.0`. The plan's recommendation (use 1.157.0) is consistent with this.
- confirmed: port 8428, `-envflag.enable` naming rule, `-storageDataPath` default, Apache-2.0 license, latest release v1.157.0, upstream Dockerfile EXPOSE 8428 and ENTRYPOINT.
