# Context: lama-cleaner

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lama-cleaner/values.yaml + Chart.yaml | truecharts-lama-cleaner.md |
| https://hub.docker.com/v2/repositories/cwq1913/lama-cleaner/ (+ tags) | dockerhub-lama-cleaner.md |
| https://raw.githubusercontent.com/Sanster/lama-cleaner/5114a46.../docker/CPUDockerfile (blob variant listed in urls.txt) | github-lama-cleaner-cpudockerfile.md |
| https://raw.githubusercontent.com/Sanster/IOPaint/main/LICENSE (repo root license, merged) | github-lama-cleaner-cpudockerfile.md |
| https://www.iopaint.com (+ /install, /install/download_model) | iopaint-com-docs.md |
| https://lama-cleaner-docs.vercel.app | lama-cleaner-docs-vercel.md |

Skipped: CLA, forgetool schemas, containerforge links, templated, binary downloads, image refs: none beyond what urls.txt already removed. Not fetched, redundant: blob CPUDockerfile (same as raw), github.com/Sanster/lama-cleaner and github.com/Sanster/IOPaint repo roots (covered by raw Dockerfile and LICENSE), www.iopaint.com/install/try_online and windows_1click_installer (budget, not build-relevant). Not summarised: https://download.pytorch.org/whl/cpu (wheel index, referenced by the CPU Dockerfile; no page content).
Shared cache (docs/context/INDEX.md): no hits for this app.

Failed:
- https://api.github.com/repos/Sanster/IOPaint/releases/latest: HTTP 403 (rate limit), not retried. plan.md states latest release is iopaint-1.5.3 (2024-11-23); not re-verified here.

## plan.md corrections
- None proven wrong. Checked: License Apache-2.0 (IOPaint LICENSE raw confirms), upstream CPUDockerfile contents (match plan line 17), Docker Hub latest tags cpu-1.2.5 / gpu-1.2.5 2023-11-01 (match plan line 9), chart tag cpu-0.33.0 (match plan line 22).
- Not verified here: IOPaint 1.6.0 on PyPI and the "archived" status of Sanster/lama-cleaner (plan lines 8 and 10). Not fetched.
