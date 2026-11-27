# Context: reubah

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/reubah/values.yaml + Chart.yaml | truecharts-reubah.md |
| https://raw.githubusercontent.com/dendianugerah/reubah/04469cf95ea7105f9d60e4906eab5533fb70ccd1/Dockerfile | reubah-dockerfile.md |
| https://raw.githubusercontent.com/dendianugerah/reubah/04469cf95ea7105f9d60e4906eab5533fb70ccd1/README.md (follow-up, same repo) | reubah-readme.md |

Skipped (not fetched): Docker Hub (image on GHCR); api.github.com/repos/DenDianUgerah/reubah (licence from API unverified); github.com repo root (both casings) and Dockerfile blob URL (raw used); CLA; forgetool schemas; containerforge app links; image refs.

Failures: none.

## plan.md corrections
- None applied.
- Confirmed: Dockerfile matches plan line 14 (golang:1.22-alpine, alpine:3.19, appuser UID/GID 1000, HOME=/tmp, EXPOSE 8081, CMD /app/reubah). Port 8081 is correct (the chart and README agree).
- Unverified: plan line 10 licence MIT comes from the API call not made here. README states MIT, so no conflict.
- Note: plan line 16 says the README example sets PORT=8081; confirmed.
