# Context sources: pastey

| Source URL | Summary file |
| --- | --- |
| https://github.com/Cesura/pastey | github-cesura-pastey.md |
| https://github.com/Cesura/pastey/blob/533dda7ad7d8b20407d0bc750f1dbdbb69308d1c/Dockerfile-slim | github-cesura-pastey.md (read at tag 0.5.1) |
| https://raw.githubusercontent.com/Cesura/pastey/0.5.1/README.md | github-cesura-pastey.md |
| https://raw.githubusercontent.com/Cesura/pastey/0.5.1/requirements.txt | github-cesura-pastey.md |
| https://raw.githubusercontent.com/Cesura/pastey/0.5.1/pastey/config.py | github-cesura-pastey.md |
| https://raw.githubusercontent.com/Cesura/pastey/0.5.1/patch_no_tensorflow.sh | github-cesura-pastey.md |
| https://raw.githubusercontent.com/Cesura/pastey/0.5.1/app.py | github-cesura-pastey.md |
| https://raw.githubusercontent.com/Cesura/pastey/0.5.1/LICENSE | github-cesura-pastey.md |
| https://github.com/Cesura/pastey/releases/tag/0.5.1 | github-cesura-pastey.md |
| https://github.com/Cesura/pastey/archive/refs/tags/0.5.1.tar.gz | github-cesura-pastey.md (source archive pattern; not downloaded) |
| https://hub.docker.com/r/cesura/pastey | dockerhub-cesura-pastey.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pastey | truecharts-pastey.md |

## Skipped URLs

- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu (containerforge `apps/<base>` link)
- https://github.com/trueforge-org/containerforge/tree/main/apps/python (containerforge `apps/<base>` link)
- https://cla-assistant.io/trueforge-org/containerforge (CLA link; noted for reference)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json (forgetool schema URL)
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json (forgetool schema URL)
- ghcr.io/trueforge-org/python:3.15.2@sha256:... (image ref, not a web page)
- docker.io/cesura/pastey:0.5.1 and `0.5.1-slim` (image refs; covered by the Docker Hub and chart entries)
- https://github.com/Cesura/pastey/blob/HEAD/requirements.txt (draft/plan link; HEAD not fetched; tag 0.5.1 requirements read instead)

## Fetch failures

- `https://github.com/Cesura/pastey/releases/tag/0.5.1`: page fetched, but the asset list showed an error and did not load. Asset names not recorded.

## plan.md corrections

- None. Checked against source: Dockerfile-slim (`python:3.8.13-slim-bullseye`, `COPY . /app/`, `patch_no_tensorflow.sh`, `pip install -r requirements.txt`, `EXPOSE 5000`, `PASTEY_DATA_DIRECTORY=/app/data`, `CMD python3 app.py`); requirements pins; env var names and defaults; port 5000; BSD-3-Clause license; `app.py` uses `distutils` and `Limiter(app, ...)` as the plan describes; `patch_no_tensorflow.sh` effects as the plan describes.
- Unverified (not edited): plan says `from __main__ import app, limiter` is in the code and forces `python app.py`. `app.py` has no `from __main__` import; the module that has it (`pastey/routes.py` per plan) was not fetched.
- Unverified (not edited): plan says `main` has commits up to 2024-06-08 and the project is unmaintained since 2024-06. Not checked.
- Unverified (not edited): plan says the tarball top dir is `pastey-0.5.1/`. The tarball was not downloaded.
- Unverified (not edited): plan's sed for `Limiter(` assumes `    app,` on its own line (matches the fetched `app.py` layout, but the sed was not run).
- Noted (not edited): `PASTEY_LISTEN_PORT` is passed to `app.run` without `int()` in `app.py` (per source); the plan's env defaults are strings. The plan should be checked at build time.
- Noted (not edited): Docker Hub lists only `latest`; the draft's `0.5.1` and `0.5.1-slim` tags are supported by the chart digests but not shown on the Hub page.
