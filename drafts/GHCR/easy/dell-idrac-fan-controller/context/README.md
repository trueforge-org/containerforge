# Context index: dell-idrac-fan-controller

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dell-idrac-fan-controller/values.yaml | truecharts-dell-idrac-fan-controller.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dell-idrac-fan-controller/Chart.yaml | truecharts-dell-idrac-fan-controller.md | fetched |
| https://api.github.com/repos/tigerblue77/Dell_iDRAC_fan_controller_Docker/releases/latest | github-release-latest-dell-idrac-fan-controller.md | fetched (v1.108) |
| https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/releases/tag/v1.108 | github-release-latest-dell-idrac-fan-controller.md | same release as the API call, not fetched twice |
| https://raw.githubusercontent.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/24fa182fa86f5c247466f023316939096b96042d/Dockerfile | upstream-dockerfile-dell-idrac-fan-controller.md | fetched |
| https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/blob/24fa182fa86f5c247466f023316939096b96042d/Dockerfile | upstream-dockerfile-dell-idrac-fan-controller.md | same as raw Dockerfile, not fetched twice |
| https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker | github-readme-dell-idrac-fan-controller.md | covered by raw README (master) |
| (raw supervisor.sh and healthcheck.sh at 24fa182, not in urls.txt) | upstream-dockerfile-dell-idrac-fan-controller.md | fetched as Dockerfile follow-ups (head only) |
| (raw README.md master, not in urls.txt) | github-readme-dell-idrac-fan-controller.md | fetched as a follow-up for env rules and usage |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not fetched; chart image is GHCR (`ghcr.io/tigerblue77/dell_idrac_fan_controller`). Upstream's Docker Hub mirror `tigerblue77/dell_idrac_fan_controller` is noted in the README file only.

## Failures
- None.

## plan.md corrections
- plan.md line 14: `` `RUN chmod 0755` on four scripts (supervisor.sh not included). `` -> `` `RUN chmod 0755` on four scripts (functions.sh, healthcheck.sh, Dell_iDRAC_fan_controller.sh, supervisor.sh). `` Source: upstream Dockerfile at 24fa182 (the chmod line lists supervisor.sh).
- Not edited, open for the user: plan line 10 license is still UNVERIFIED. The packaged LICENSE at tag v1.108 is the plain AGPLv3 text (no SPDX id line), and the NOTICE first lines do not state `-only`. Upstream Dockerfile label says `AGPL-3.0-only`. Decision left to the plan.
