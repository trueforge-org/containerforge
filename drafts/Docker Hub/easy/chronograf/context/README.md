# Context: chronograf

Fetched 2026-11-26.

| Source URL | Summary file |
| --- | --- |
| https://github.com/influxdata/chronograf (README and LICENSE at 1.11.7) | github-influxdata-chronograf.md |
| https://docs.influxdata.com/chronograf/latest/introduction/installation/ | docs-influxdata-chronograf-installation.md |
| https://docs.influxdata.com/chronograf/v1/administration/config-options/ | docs-influxdata-chronograf-config-options.md |
| https://github.com/influxdata/influxdata-docker/blob/master/chronograf/1.11/Dockerfile | github-influxdata-influxdata-docker-chronograf.md |
| https://github.com/influxdata/influxdata-docker/blob/f49180e6d0f4acee8c9f8672342cf4496d81b99b/chronograf/1.11/Dockerfile | github-influxdata-influxdata-docker-chronograf.md |
| https://raw.githubusercontent.com/influxdata/influxdata-docker/master/chronograf/1.11/entrypoint.sh | github-influxdata-influxdata-docker-chronograf.md |
| https://hub.docker.com/_/chronograf | dockerhub-chronograf.md |
| https://www.influxdata.com/downloads/ | influxdata-downloads.md |
| https://www.influxdata.com/time-series-platform/chronograf | influxdata-downloads.md |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema URL.
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL.
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: ContainerForge base app link.
- ghcr.io/trueforge-org/ubuntu (and :26.04@sha256 ref): image ref, not a web page.
- https://dl.influxdata.com/chronograf/releases/chronograf_1.11.7_amd64.deb, chronograf_1.11.7_arm64.deb, chronograf_1.11.8_*.deb: direct binary downloads. Asset naming and SHA256 (1.11.8) recorded in influxdata-downloads.md.
- https://raw.githubusercontent.com/influxdata/chronograf/${VERSION}/LICENSE: templated; the 1.11.7 expansion was fetched via github-influxdata-chronograf.md.
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/chronograf: TrueCharts chart. Not in the batch's fetch scope for this app's summary, no fetch made (see note below).
- http://[::]:8888 (listen address, not a source): not fetched.

Note: the TrueCharts chart URL is listed under Skipped because it was not fetched in this run. If the chart values are needed, fetch https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chronograf/values.yaml.

## Fetch failures
- https://dl.influxdata.com/chronograf/releases/ (directory listing): 404. Asset names taken from the downloads page instead (influxdata-downloads.md).
