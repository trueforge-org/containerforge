# soft-serve context README

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/soft-serve/values.yaml | truecharts-soft-serve-values.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/soft-serve/Chart.yaml | truecharts-soft-serve-chart.md |
| https://github.com/charmbracelet/soft-serve/blob/v0.12.4/Dockerfile (raw) | soft-serve-dockerfile-v0.12.4.md |
| https://github.com/charmbracelet/soft-serve/blob/52ba4c852667ff464675b0876fcb1ca2da257dce/Dockerfile (raw) | soft-serve-dockerfile-52ba4c8.md |
| https://github.com/charmbracelet/soft-serve/blob/main/LICENSE (raw v0.12.4 used) | soft-serve-license.md |
| https://raw.githubusercontent.com/charmbracelet/soft-serve/v0.12.4/LICENSE | soft-serve-license.md (same file) |
| https://github.com/charmbracelet/soft-serve (README, raw main) | soft-serve-readme.md |
| https://charm.land | charm-land.md (no Soft Serve info) |

Skipped: none by category. No CLA, forgetool, containerforge app, templated, binary download or image-ref URLs were in the list. Release tarballs and `checksums.txt` are binary downloads, not fetched. No Docker Hub source (GHCR app).

Failures: 0.

## plan.md corrections
- No edits made.
- Verified, no edit: `FROM alpine:latest` upstream, ENV/EXPOSE/ENTRYPOINT/no USER (plan line 15); default ports 23231/23232/23233/9418; MIT license; version v0.12.4 (chart appVersion).
- Note for the PR (not a plan error): upstream README says Soft Serve is SUNSET and will not get further security updates. Plan does not mention this.
- Unverified (not contradicted): plan's `SOFT_SERVE_HTTP_LISTEN_ADDR` and `SOFT_SERVE_STATS_LISTEN_ADDR` names are not in the fetched README; plan already marks them UNVERIFIED.
