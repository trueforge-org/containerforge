# context/ for uptimerobot-prometheus

Fetched 2026-11-26.

## Sources

| Source URL | Summary file |
| --- | --- |
| https://github.com/lekpamartin/uptimerobot_exporter (Dockerfile, README, files/exporter.py @a64c74a) | github-lekpamartin-uptimerobot-exporter.md |
| https://hub.docker.com/r/billimek/prometheus-uptimerobot-exporter | dockerhub-billimek-prometheus-uptimerobot-exporter.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/uptimerobot-prometheus (values.yaml) | truecharts-uptimerobot-prometheus.md |
| https://raw.githubusercontent.com/k8s-at-home/charts/master/charts/stable/uptimerobot-prometheus/values.yaml (from the k8s-at-home link) | truecharts-uptimerobot-prometheus.md (note in its Gotchas; no separate file) |

The k8s-at-home chart (upstream of the TrueCharts chart) was fetched raw. It uses the same `billimek/prometheus-uptimerobot-exporter:0.0.1` image, `UPTIMEROBOT_API_KEY` and `TZ`, and port `9705` (metrics). It is summarised inside the TrueCharts file rather than in its own file.

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page, not a source.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/python and .../apps/ubuntu: containerforge base links.
- https://github.com/lekpamartin/uptimerobot_exporter/archive/refs/heads/master.zip: direct archive download.
- https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/<commit>/... and `${UPTIMEROBOT_COMMIT}` placeholder forms: replaced by the fetched commit `a64c74a`.
- https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/<commit>/files/exporter.py: placeholder form, fetched at `a64c74a`.
- http://<container-ip>: placeholder address, skipped.
- Local `docs/project-fireball.md` is a local reference.

## Fetch failures

- https://api.uptimerobot.com/v3 (base URL, the API docs entry point): HTTP 404. Not retried; the rate-limit and auth details come from the upstream README instead.
- https://github.com/billimek/prometheus-uptimerobot-exporter/blob/0.0.1/Dockerfile: not fetched (not needed; the image is outdated and the draft's link is not a current source).
- GitHub repo page for lekpamartin: release and tag counts not shown; last commit date not shown.

## plan.md corrections

None made. Confirmed: the upstream Dockerfile (python 3.15 alpine, requests only into `/app/deps`, `USER nobody`, `EXPOSE 9705`, healthcheck on `/`, `CMD python3 /app/exporter.py`), the env var names and defaults, the API URL, the `/metrics` and `/` routes, and no disk writes.

Items left as unverified or clarified (not edited):
- Plan section 1: "no releases and no tags (the tags API returns none)". The README mentions `vX.Y.Z` git tags and a `1.0.0` example tag. The repo page did not show a count. Unverified.
- Plan section 1: commit `a64c74a` dated 2026-11-15. Commit date not shown by the fetch. Unverified.
- Plan section 7 (verified, not a mistake): with no API key the exporter does not start. `parser.error(...)` exits with status 2. The plan's start.sh fallback is therefore required, as the plan anticipates. Left for the implementation decision.
- Plan section 8 and 11: the server start log text is `Listening on %s:%d` (verified in `exporter.py`). The plan marked this UNVERIFIED.
- Plan section 1: "the API key is read ... `UPTIMEROBOT_API_KEY` (required, a read-only key is enough)" matches the README.
- Plan section 10: "Free plan 10 requests/minute; each refresh costs 3 requests" matches the README.
