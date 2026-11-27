# Context sources: ctfd

| Source URL | File | Notes |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ctfd/values.yaml | truecharts-ctfd-values.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/ctfd/Chart.yaml | truecharts-ctfd-chart.md | fetched |
| https://docs.ctfd.io | ctfd-docs.md | fetched; nav only |
| https://docs.ctfd.io/docs/deployment/installation | ctfd-docs.md | follow-up, merged |
| https://docs.ctfd.io/docs/settings/overview | ctfd-docs.md | follow-up, merged |
| https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/Dockerfile | ctfd-3.8.9-dockerfile.md | fetched |
| https://github.com/CTFd/CTFd/blob/5f345fbaa424e6a22b51addf7f27430927879ae2/Dockerfile (raw variant) | ctfd-3.8.9-dockerfile.md | fetched; identical to 3.8.9 |
| https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/docker-entrypoint.sh | ctfd-3.8.9-docker-entrypoint.md | fetched |
| https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/requirements.txt | ctfd-3.8.9-requirements.md | fetched |
| https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/LICENSE | ctfd-3.8.9-license.md | fetched |
| https://api.github.com/repos/CTFd/CTFd/releases/latest (for the GitHub repo URL https://github.com/CTFd/CTFd) | github-ctfd-releases-latest.md | fetched via API; repo HTML not fetched |

Skipped categories: no Docker Hub URL (chart image is GHCR `ghcr.io/ctfd/ctfd`); `https://github.com/CTFd/CTFd/blob/HEAD/requirements.txt` (HEAD, not the 3.8.9 pin; 3.8.9 requirements used instead); `https://github.com/CTFd/CTFd` repo HTML (covered by raw and API); no templated, binary-download or image-ref URLs in the list.

Failures: none.

## plan.md corrections
- None. The plan's Dockerfile, entrypoint, LICENSE (Apache-2.0), port 8000, UID 1001, and gunicorn 23.0.0 facts match the fetched 3.8.9 sources.
- Not an error, noted only: plan `WORKER_TEMP_DIR` fallback `/tmp` differs from upstream default `/dev/shm`. The plan's own design, left unchanged.
