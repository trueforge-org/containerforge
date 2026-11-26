# hub.docker.com/r/cadquery/cadquery-server

Source: https://hub.docker.com/r/cadquery/cadquery-server (fetched 2026-11-26)

- Tags: `latest` only (digest sha256:d0aed7996...); ~1007.2 MB; 10K+ pulls; last updated ~4 years before fetch (unmaintained)
- Run: `docker run -p 5000:5000 -v $(pwd)/examples:/data cadquery/cadquery-server`
- Port 5000; scripts mounted at /data
- Env: none documented; command/entrypoint default; arch not stated

## Docker Hub JSON (added 2026-11-26)
- Source: https://hub.docker.com/v2/repositories/cadquery/cadquery-server/ and /tags?page_size=10
- description "A web server used to render 3d models from CadQuery code loaded dynamically."; pull_count 33082; star_count 0; last_updated 2022-09-23 (stale)
- Tags: latest (2022-09-23, 1056083446 B, linux/amd64), 0.4.1 (2022-09-23, same size, amd64), 0.4.0 (2022-09-16, amd64). amd64 only.
- Plan pins 0.4.1 (PyPI); a 0.4.1 image tag exists upstream, amd64 only
