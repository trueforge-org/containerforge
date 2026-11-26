# Context: ipmi-tools

| Source URL | File |
| --- | --- |
| https://github.com/EdwardChamberlain/IPMI-Fan-Controller | upstream-readme.md |
| https://github.com/EdwardChamberlain/IPMI-Fan-Controller/blob/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246/dockerfile | upstream-dockerfile.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ipmi-tools | truecharts-ipmi-tools-chart.md |
| https://hub.docker.com/r/edchamberlain/ipmi-tools | hub-docker-ipmi-tools.md |
| (follow-up) https://github.com/EdwardChamberlain/IPMI-Fan-Controller/tree/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246 | upstream-quickstart-py.md |
| (follow-up) https://raw.githubusercontent.com/EdwardChamberlain/IPMI-Fan-Controller/d1ea5f15163a5ca6a5e20d6ba5c9b2fea128b246/quickstart.py | upstream-quickstart-py.md |

Skipped categories: none in urls.txt.

## Gaps
- `app/` folder at the pinned commit was not fetched (follow-up budget used; the tree page lists only the folder name). Plan.md's app layout, config.py env var names, `-I lanplus` ipmitool usage and port 5000 claims are therefore NOT re-verified by these sources.

## Failures
- None.

## plan.md corrections
- No edits made.
- Unverified: plan claims the base image serves `app/main.py` on port 80 and that env vars are `SECRET_KEY`, `APP_IPMI_HOST`, `APP_IPMI_USER`, `APP_IPMI_PASS`, `APP_LOG_LEVEL`. Not checkable from fetched sources.
