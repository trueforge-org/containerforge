# Docker Hub: ollama/ollama

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/ollama/ollama/ (2026-11-27, JSON)
- https://hub.docker.com/v2/repositories/ollama/ollama/tags?page_size=10 (2026-11-27, JSON, first page)

What it is: official Ollama image. Pull count 206,175,164; stars 1622; last updated 2026-11-26. Tag count 1332.

Full description (README-like, from Hub): CPU run `docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama`. Nvidia GPU needs NVIDIA Container Toolkit.

Tags seen on first page (2026-11-27):
| Tag | Last updated | Arch |
| --- | --- | --- |
| latest | 2026-11-24 | amd64, arm64 |
| 0.40.19-rc0 | 2026-11-26 | amd64, arm64 |
| 0.40.19-rc0-rocm | 2026-11-26 | amd64 |
| rocm | 2026-11-24 | amd64 |
| 0.40.18 | 2026-11-24 | amd64, arm64 (size about 3.4 GB) |
| 0.40.18-rocm | 2026-11-24 | amd64 (about 1.5 GB) |
| 0.40.18-rc0 | 2026-11-24 | amd64, arm64 |
| 0.40.18-rc0-rocm | 2026-11-24 | amd64 |
| 0.40.17 | 2026-11-21 | amd64, arm64 |
| 0.40.17-rocm | 2026-11-21 | amd64 |

Gotchas:
- Chart pins `0.40.18` (not `latest`), and `0.40.18-rocm` for the ROCm variant.
- Tags with `-rc0` are release candidates.
