# duckdns: migrated

This container has been migrated to `/apps/duckdns` and now has build/test coverage there.

The `/porting/post-processed/duckdns` copy is retained as generated porting output.

## AMD64 build check (2026-02-16)
- Command: `docker buildx bake --set image-local.platform=linux/amd64 image-local`
- Result: PASS
