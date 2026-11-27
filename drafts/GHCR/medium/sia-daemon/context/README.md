# Context: sia-daemon

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sia-daemon/values.yaml + Chart.yaml | truecharts-sia-daemon.md |
| https://raw.githubusercontent.com/SiaFoundation/siad/66e7fc6/Dockerfile | siad-dockerfile.md |
| https://github.com/SiaFoundation/siad (HTML fallback for failed API), https://docs.sia.tech | siad-repo-and-docs.md |

Skipped (not fetched): Docker Hub (image on GHCR); https://github.com/SiaFoundation/siad/pkgs/container/siad (registry page); https://github.com/siafoundation/siad (lowercase duplicate of repo); https://sia.tech (home); upstream Makefile (plan cites it via gh api); CLA; forgetool schemas; containerforge app links; image refs.

Failures:
- https://api.github.com/repos/SiaFoundation/siad: 403. HTML repo page used instead: archived on Jul 3, 2025 (read-only). Last-push date and release v1.5.9 from the plan remain unverified.

## plan.md corrections
- None applied.
- Confirmed by fetch: Dockerfile at 66e7fc6 matches plan line 17 (alpine:latest runtime, `EXPOSE 9981/9982/9983`, `VOLUME /sia-data`, ENV blanks, ENTRYPOINT with `--disable-api-security` and `--api-addr :9980`). TrueCharts chart also exposes 9981, 9982, 9983 (so plan R3's RHP3 open question is answered by two fetched sources, not edited).
- Unverified (not edited): plan line 9 "last push 2025-05-05"; plan line 8 latest release v1.5.9 (2022-08-01).
- Note for plan R1: docs.sia.tech names hostd, renterd and walletd as current products; it does not name a successor for siad.
