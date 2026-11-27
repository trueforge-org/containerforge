# Context index: unmanic

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/unmanic/values.yaml + Chart.yaml | truecharts-unmanic.md |
| https://hub.docker.com/v2/repositories/josh5/unmanic/ + tags?page_size=10 | dockerhub-unmanic.md |
| https://raw.githubusercontent.com/Unmanic/unmanic/1c324b8/docker/Dockerfile | unmanic-dockerfile.md |
| https://raw.githubusercontent.com/Unmanic/unmanic/HEAD/requirements.txt (raw of blob/HEAD URL) | unmanic-requirements.md |
| https://pypi.org/pypi/unmanic/0.4.1/json | pypi-unmanic-0.4.1.md |

Skipped (one line): GitHub repo root and `blob/1c324b8` URL (duplicates of raw files). No CLA, forgetool, containerforge, templated, binary-download or image-ref URLs in this list.
Failures: none.

## plan.md corrections
- No in-place edits.
- Checked and matching fetched sources: version 0.4.1 (PyPI, Docker Hub), PyPI sha256 for the wheel and sdist (both match plan.md), `requires_python >=3.8`, license GPL-3.0-only, Dockerfile base ubuntu:24.04 and EXPOSE 8888/tcp, requirements pins match plan.md list.
- Unverified: requirements.txt was fetched from HEAD, not from commit 1c324b8. The plan lists the 1c324b8 values, and they match HEAD at fetch time.
- Chart state (not a plan error): TrueCharts master uses port 10157 -> 8888 and mounts `/config`, `/library`, `/tmp/unmanic/remote_library`, `/tmp/unmanic`, matching plan.md section on data paths.
