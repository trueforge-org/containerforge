# GitHub chroma-core/chroma (repo, latest release, entrypoint, config.py)

## Source URL(s) + date
- https://api.github.com/repos/chroma-core/chroma (fetched 2026-11-27)
- https://api.github.com/repos/chroma-core/chroma/releases/latest (fetched 2026-11-27)
- https://api.github.com/repos/chroma-core/chroma/contents/bin/docker_entrypoint.sh?ref=11f3c7435e71024aa0a2b53710a28d3289d922d1 (fetched 2026-11-27)
- https://api.github.com/repos/chroma-core/chroma/contents/chromadb/config.py?ref=11f3c7435e71024aa0a2b53710a28d3289d922d1 (fetched 2026-11-27)

## What it is
- Repo: Rust/Python, Apache-2.0, 29796 stars at fetch time.
- Latest release: tag `1.5.9`, published 2026-05-05T05:55:40Z. No release assets (assets list empty).

## docker_entrypoint.sh (pinned commit 11f3c74)
- `set -e`; `export IS_PERSISTENT=1`; `CHROMA_SERVER_NOFILE` default 65536.
- If args start with `uvicorn`: exec args as given (with warning to drop `uvicorn chromadb.app:app`).
- Else: `exec uvicorn chromadb.app:app $args` (args eval'd).

## Settings (chromadb/config.py, pydantic BaseSettings; env var names = field names uppercased)
| Field | Default |
| --- | --- |
| chroma_server_host | None |
| chroma_server_http_port | None |
| chroma_server_nofile | None |
| chroma_server_thread_pool_size | 40 |
| chroma_server_ssl_enabled | False |
| chroma_server_api_default_path | V2 |
| chroma_server_cors_allow_origins | [] |
| chroma_http_keepalive_secs | 40.0 |
| is_persistent | False |
| persist_directory | ./chroma |
| anonymized_telemetry | True |
| allow_reset | False |
| chroma_memory_limit_bytes | 0 |
| chroma_server_authn_provider / _credentials / _credentials_file | None |
| chroma_server_authz_provider / _config / _config_file | None |
| chroma_otel_collection_endpoint | "" |
| chroma_api_impl | chromadb.api.rust.RustBindingsAPI |
- `model_config`: env_file ".env", extra ignore.

## Runtime deps
- Python package chromadb (uvicorn server).

## Gotchas
- Settings default `chroma_server_http_port` is None here; Dockerfile sets CHROMA_HOST_PORT=8000 (see github-chroma-dockerfile.md).
- anonymized_telemetry defaults to True (posthog telemetry) in config.py.
