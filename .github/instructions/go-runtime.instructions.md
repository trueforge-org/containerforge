---
description: "Use when working on Go-based ContainerForge apps (Dockerfiles using golang build stages or based on ghcr.io/trueforge-org/golang). Covers build-stage compilation, runtime-stage copy, go.mod/go.sum hygiene, empty /config behavior."
---

# Go Runtime Rules

## Build vs runtime stages

- Compile Go binaries in a dedicated build stage (e.g. `FROM golang:<ver> AS build`).
- Copy the resulting binary into the runtime stage with `COPY --from=build ...`.
- Do NOT compile Go in the runtime stage.

## Module hygiene

- Do NOT modify `go.mod` or `go.sum` on PRs unrelated to dependency changes.

## Runtime expectations

- Apps using `ghcr.io/trueforge-org/golang` as the final stage MUST run correctly when `/config` is empty.
- `GOCACHE` and any other build/run caches MUST point at `/tmp`, never `/config`, never `/app`.
