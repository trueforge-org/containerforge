# Context: qwantify

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qwantify/values.yaml + Chart.yaml | truecharts-qwantify.md |
| https://raw.githubusercontent.com/wanjohiryan/qwantify/master/docker/base/Dockerfile | qwantify-docker-base-dockerfile.md (truncated fetch) |
| https://raw.githubusercontent.com/wanjohiryan/qwantify/master/docker/base/entrypoint.sh | qwantify-docker-base-entrypoint.md |
| https://raw.githubusercontent.com/wanjohiryan/qwantify/2d4c204c8902da9026fc15baf21eab0fedc0f0dd/gamevm/base/Dockerfile (blob URL at same commit is a duplicate) | qwantify-gamevm-dockerfile.md (truncated fetch) |
| https://github.com/wanjohiryan/qwantify (HTML, after API 403) | no file (see conflicts) |

Skipped: GitHub blob URL of gamevm at 2d4c204 (duplicate of the raw URL); api.github.com/repos/wanjohiryan/qwantify (403, failure below); raw gamevm at master (404, failure below).
No Docker Hub URL in list (image is GHCR).

Failures:
- https://api.github.com/repos/wanjohiryan/qwantify: 403 rate limit (not retried).
- https://raw.githubusercontent.com/wanjohiryan/qwantify/master/gamevm/base/Dockerfile: 404 (not retried). The same path at the pinned commit 2d4c204 does resolve.

## plan.md corrections
1. Line 18 (Draft Dockerfile link): "Stale ... returned HTTP 404 on master" changed to say the pinned commit 2d4c204 resolves (fetched content: golang:1.18 server build, node:14 client build, `nvcr.io/nvidia/cudagl:11.2.2-runtime-ubuntu20.04` runtime) and only master returns 404. Source: qwantify-gamevm-dockerfile.md.

Unverified conflicts (not edited):
- Plan line 27 says "None of the fetched sources confirms" the CUDA/Go/Node build. The pinned gamevm/base Dockerfile (qwantify-gamevm-dockerfile.md) shows exactly that stack. Whether it builds `qwantify:20.04` is still unverified. The plan text was not changed because the decision is the user's.
- Plan line 14 gives `https://github.com/wanjohiryan/qwantify` as the source. The HTML fetch at that URL returned a page titled `wanjohiryan/Arc3dia` ("Self-Hosted Stadia"). That may be a rename redirect, or a different project. Not verified; check the repo name before using the URL.
- Plan line 10 says upstream repo has not been pushed since 2024-05-19 (from API, not re-checked here: API returned 403).
