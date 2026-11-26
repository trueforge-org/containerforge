# billimek/prometheus-uptimerobot-exporter (Docker Hub, outdated image)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/billimek/prometheus-uptimerobot-exporter (fetched 2026-11-26)
- Also referenced: https://github.com/billimek/prometheus-uptimerobot-exporter/blob/0.0.1/Dockerfile (in draft; not fetched).

**What it is**
Docker Hub image of an UptimeRobot Prometheus exporter by `billimek`. No overview on the page. 100K+ pulls, rating 0.

**Tags**
- `0.0.1` is the only recent tag. Last updated over 6 years ago (no exact date). Size 30.9 MB. Digest blank in the fetch.
- TrueCharts pins `0.0.1@sha256:f14ccd7aad0e0ef19dc5c5c359b0921030a769e2505acec5b913d749281327be`.

**Arch support**
Not shown.

**Usage**
`docker pull billimek/prometheus-uptimerobot-exporter:0.0.1`. No env, ports or volumes on the page.

**Gotchas**
- Image has not been updated in over 6 years. Plan.md says the image curls master `exporter.py` unpinned and predates the UptimeRobot v3 API (not verified here; the image's own content was not inspected).
- Not the source for our build; the current upstream is `lekpamartin/uptimerobot_exporter` (see GitHub file).
