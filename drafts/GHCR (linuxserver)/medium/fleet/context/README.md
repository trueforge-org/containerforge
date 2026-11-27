# Context sources: fleet

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fleet/values.yaml | truecharts-fleet.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fleet/Chart.yaml | truecharts-fleet.md |
| https://hub.docker.com/v2/repositories/linuxserver/fleet/ | dockerhub-fleet.md |
| https://hub.docker.com/v2/repositories/linuxserver/fleet/tags?page_size=10 | dockerhub-fleet.md |
| https://raw.githubusercontent.com/linuxserver/docker-fleet/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/Dockerfile | linuxserver-dockerfile.md |
| https://raw.githubusercontent.com/linuxserver/docker-fleet/68995eabc52afa0c3a1fddf3c5dbc803d6943c36/readme-vars.yml | linuxserver-readme-vars.md |
| https://api.github.com/repos/linuxserver/fleet/releases/latest | upstream-release.md |
| https://fleetdm.com/docs | fleetdm-docs.md |

Skipped categories:
- Duplicates: github.com blob/tree/repo-root URLs (covered by raw or API), https://fleetdm.com root (same product as fleetdm docs), linuxserver/fleet releases/tag/2.3.3 (covered by API).
- Binary: fleet-2.3.3.jar download (not fetched, size and URL recorded in upstream-release.md).
- Templated/other: none in list.

Failures: none.

Note: fleetdm.com is a different product (endpoint management). Not a build source for linuxserver/fleet.

## plan.md corrections
- None. Plan values (2.3.3, port 8080, env vars, `/config`, alpine 3.21 base, deprecation) match the fetched sources.
