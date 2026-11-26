# hauxir/imgpush: README (master)
Source URL: https://raw.githubusercontent.com/hauxir/imgpush/master/README.md (fetched 2026-11-26, 188 lines)

- Minimal self-hosted image service: one upload endpoint, auto-convert format, auto-resize, rate limiting, origin whitelist, liveness API, delete API with API key, optional S3-compatible backend.
- Run: `docker run -v <PATH>:/images -p 5000:5000 hauxir/imgpush:latest`
- Liveness: `/liveness` returns 200 OK (for Docker healthcheck or k8s probe).
- Env vars named in README: API_KEY, REQUIRE_API_KEY_FOR_UPLOAD, REQUIRE_API_KEY_FOR_DELETE, ALLOWED_ORIGINS, STORAGE_BACKEND, S3_BUCKET_NAME, S3_ENDPOINT_URL, S3_ACCESS_KEY_ID, S3_SECRET_ACCESS_KEY, S3_REGION, S3_IMAGES_PREFIX, S3_CACHE_PREFIX, LOCAL_CACHE_DIR, LOCAL_CACHE_MAX_SIZE_MB, NUDE_FILTER_MAX_THRESHOLD, NUDE_FILTER_VIDEO_INTERVAL, MAX_VIDEO_DURATION, VALID_SIZES, OUTPUT_TYPE, NAME_STRATEGY
- Delete requires API_KEY set.
