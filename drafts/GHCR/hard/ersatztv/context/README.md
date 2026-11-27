# ersatztv context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ersatztv/values.yaml | truecharts-ersatztv-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ersatztv/Chart.yaml | truecharts-ersatztv-chart.md |
| https://raw.githubusercontent.com/ErsatzTV/ErsatzTV/2271d5497becc30f8cf689715d115fb36d0abc8a/docker/nvidia/Dockerfile | ersatztv-nvidia-dockerfile.md |
| https://ersatztv.org/docs (+ /docs/installation, /docs/networking) | ersatztv-docs.md |

Skipped: github.com blob Dockerfile (same as raw), github.com repo root and jasongdove/ErsatzTV (HTML/redirect, covered by Dockerfile and release data in plan), docs Media/Advanced/Troubleshooting pages (not fetched, budget), Docker Hub / boilerplate: none in urls.txt.

Failures: none.

## plan.md corrections
None.
Notes (not edited, not errors):
- Docs (ersatztv-docs.md) confirm default port 8409 for all requests; plan.md lines 16 and 126 still say 8409 is unverified. Plan's statement "not declared in the Dockerfile" is still true.
- Docs describe "ErsatzTV Legacy". Check the product line before pinning the 26.x release (plan line 8).
