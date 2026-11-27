# TileServer GL docs (readthedocs): usage, endpoints

Source URL(s) + date:
- https://tileserver.readthedocs.io (index, fetched)
- https://tileserver.readthedocs.io/en/latest/usage.html
- https://tileserver.readthedocs.io/en/latest/endpoints.html
- Fetched 2026-11-27

## Usage (usage.html)
- CLI: `tileserver-gl [file] [options]`
- `--file` MBTiles or PMTiles file (local path, http(s), s3, pmtiles://, mbtiles://); ignored if config file given
- `-c` / `--config` config file; `--fetch-timeout 5000` option seen in examples
- Reload config: send SIGHUP; `docker kill -s HUP tileserver-gl`
- Docker and `--port`: when running in Docker, do not use `--port` (container looks unhealthy); map the default port 8080 with Docker port mapping instead.
- Security: `allowedHosts` config option (comma-separated) to mitigate Host header poisoning; docs say it takes priority when both it and the env var are set (env var name not in the fetched text).

## Endpoints (endpoints.html)
- Health: `/health` returns `503` Starting (briefly during init), `200 OK` when running.
- Fonts: `/fonts.json`
- Static files: `/files/{filename}`
- Styles, rendered tiles, WMTS capabilities, static images, source data, TileJSON arrays, elevation API (not in tileserver-gl-light).

## Docker (Docker Hub README, see dockerhub-tileserver-gl.md)
- Example `-p 8080:80` (container port 80 in example; conflicts with EXPOSE 8080).

## Gotchas
- Health check endpoint is `/health` (returns 503 until initialized).
