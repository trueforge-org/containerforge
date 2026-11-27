# Sources for chroma (context, 2026-11-27)

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chroma/values.yaml | truecharts-chroma.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chroma/Chart.yaml | truecharts-chroma.md |
| https://api.github.com/repos/chroma-core/chroma | github-chroma.md |
| https://api.github.com/repos/chroma-core/chroma/releases/latest | github-chroma.md |
| https://api.github.com/repos/chroma-core/chroma/contents/bin/docker_entrypoint.sh?ref=11f3c74... | github-chroma.md |
| https://api.github.com/repos/chroma-core/chroma/contents/chromadb/config.py?ref=11f3c74... | github-chroma.md |
| https://github.com/chroma-core/chroma | github-chroma.md (covered by repo API) |
| https://github.com/chroma-core/chroma/blob/11f3c74.../Dockerfile | github-chroma-dockerfile.md |
| https://raw.githubusercontent.com/chroma-core/chroma/11f3c74.../Dockerfile | github-chroma-dockerfile.md |
| https://pypi.org/pypi/chromadb/1.5.9/json | pypi-chromadb.md |
| https://pypi.org/pypi/chromadb/json | pypi-chromadb.md |
| https://docs.trychroma.com | docs-chroma.md (JS-rendered, no facts) |

Skipped: none beyond the list above. No Docker Hub URL (GHCR image).

Failures: none (docs site returned 200 but JS-rendered, no facts extracted).

## plan.md corrections
- None made. Plan lines 8, 15-20 and 49 (version 1.5.9, python 3.11 upstream base, IS_PERSISTENT, port 8000, chart path /chroma/chroma, entrypoint and CMD) agree with the fetched sources. Plan's `/config/chroma` is a stated deliberate change, not an error.
