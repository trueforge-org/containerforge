---
description: "docker-bake.hcl rules: VERSION/APP/LICENSE/SOURCE alignment with Dockerfile, renovate annotation comment, image/image-local/image-all targets, and validation via `docker buildx bake --print`."
applyTo: "apps/**/docker-bake.hcl"
---

# docker-bake.hcl Rules (apps/**/docker-bake.hcl)

## Alignment

- `VERSION` (and any other `variable` defaults) MUST match what the sibling `Dockerfile` consumes via `ARG`.
- `APP`, `LICENSE`, `SOURCE` MUST be present and match the upstream project.

## Renovate annotation

- The `VERSION` default MUST be preceded by a renovate datasource comment, e.g.:
  ```hcl
  // renovate: datasource=github-releases depName=<owner>/<repo> versioning=semver
  default = "1.2.3"
  ```
- Use `versioning=loose` only when the upstream tags are not strict semver.

## Required targets

Mirror the layout used by sibling apps:

- `target "docker-metadata-action" {}`
- `target "image"` — sets `args.VERSION` and OCI labels (`org.opencontainers.image.source`, `.licenses`).
- `target "image-local"` — inherits `image`, `output = ["type=docker"]`, tagged `${APP}:${VERSION}`.
- `target "image-all"` — inherits `image`, multi-arch (`linux/amd64`, `linux/arm64`).
- `group "default" { targets = ["image-local"] }`.

## Validation (mandatory before commit)

From the app directory:

```sh
docker buildx bake --print
```

Must succeed for any change to this file or the sibling Dockerfile.
