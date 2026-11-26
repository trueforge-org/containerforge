# Context sources: newyearcountdownclock

| Source URL | Summary file |
| --- | --- |
| https://github.com/modem7/Docker-NewYearCountdown | github-modem7-docker-newyearcountdown.md |
| https://raw.githubusercontent.com/modem7/Docker-NewYearCountdown/master/README.md | github-modem7-docker-newyearcountdown.md |
| https://github.com/modem7/Docker-NewYearCountdown/blob/a1c6bede2351d2912dcd25e7d15e30f82be6b12f/Dockerfile | github-modem7-docker-newyearcountdown.md (pinned HEAD `393458057...` Dockerfile used; draft commit content not fetched) |
| https://github.com/modem7/Docker-NewYearCountdown/releases | github-modem7-docker-newyearcountdown.md |
| https://hub.docker.com/r/modem7/newyearcountdown | dockerhub-modem7-newyearcountdown.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/newyearcountdownclock | truecharts-newyearcountdownclock.md (values.yaml fetched raw) |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://github.com/trueforge-org/containerforge/tree/main/apps/nginx (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/nginx:1.28.3@sha256:... and ghcr.io/trueforge-org/ubuntu (image refs, not web pages)
- docker.io/modem7/newyearcountdown:latest (image ref; covered by the Docker Hub page above)
- https://modem7.github.io/Docker-NewYearCountdown/ (live demo, linked from README; not needed for build)

## Fetch failures

- None.

## plan.md corrections

- Line in "Draft caveats" (section 10): "the chart pulled `:latest`" -> "the chart pulled `:latest` pinned by digest (`sha256:7a3b00067ae17a7c8792f184a91542ed20218d690e65b370444d8a43ac3acf88`)". Source: `truecharts-newyearcountdownclock.md` (values.yaml `image.tag`).
- Unverified (not edited): plan says `index.html` is a meta refresh to `countdown.html` and that no external URLs exist in HTML/JS/CSS; those files were not fetched.
- Unverified (not edited): plan says the countdown is computed in the visitor's browser; the README says "local system time" without saying where it runs.
- Noted (not edited): upstream Dockerfile also sets `STOPSIGNAL SIGQUIT` and `HEALTHCHECK` (curl to 127.0.0.1:8080/healthz); plan does not mention STOPSIGNAL. Not a factual error.
