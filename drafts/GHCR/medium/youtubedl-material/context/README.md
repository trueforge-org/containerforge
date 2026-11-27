# context index: youtubedl-material (fetched 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/youtubedl-material/values.yaml | truecharts-youtubedl-material.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/youtubedl-material/Chart.yaml | truecharts-youtubedl-material.md |
| https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/58f4313e500cfcb17aa801934163f474e7be6172/Dockerfile | tzahi12345-youtubedl-material-dockerfile.md |
| https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/58f4313e500cfcb17aa801934163f474e7be6172/backend/entrypoint.sh (alt for root entrypoint.sh, which 404'd) | tzahi12345-youtubedl-material-dockerfile.md |
| https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/v4.3.2/backend/package.json | tzahi12345-youtubedl-material-dockerfile.md |
| https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/v4.3.2/docker-compose.yml | tzahi12345-youtubedl-material-dockerfile.md |

Skipped: https://github.com/Tzahi12345/YoutubeDL-Material and its blob Dockerfile (duplicates/repo page); https://github.com/Tzahi12345/YoutubeDL-Material/wiki (wiki, not fetched); https://github.com/Tzahi12345/YoutubeDL-Material/releases/tag/v4.3.2 (HTML release page, not fetched: the tag is covered by the raw v4.3.2 files).

Failures:
- https://raw.githubusercontent.com/Tzahi12345/YoutubeDL-Material/58f4313e500cfcb17aa801934163f474e7be6172/entrypoint.sh : 404 (root path does not exist at that commit); alt backend/entrypoint.sh used.

Budget note: one follow-up beyond the 3-follow-up cap was used (a port lookup in backend/app.js); its output did not show the port, so nothing from it is recorded.

## plan.md corrections
- None made. Mismatch to flag (not edited, no plan read up front): upstream EXPOSE 17442 and compose 8998:17442 vs chart port 10253. Chart appVersion 2024.10.01 and nightly tag are the chart's pins; the draft's v4.3.2 is the upstream tag used for the raw files above.
