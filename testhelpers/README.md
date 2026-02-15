# Go container testhelpers

Shared helpers for Go `container_test.go` files.

## Purpose

- Reduce repeated `testcontainers-go` setup across app tests.
- Keep common behavior consistent:
  - `TEST_IMAGE` override support.
  - automatic temporary `/config` bind mount.
  - container cleanup and exit-code assertions.

## Helpers

- `GetTestImage(defaultImage string)`  
  Returns `TEST_IMAGE` when set, otherwise the provided default image.

- `TestHTTPEndpoint(...)`  
  Runs a container and waits for an HTTP endpoint on a port/path to match the expected status (or matcher).

- `TestFileExists(...)`  
  Verifies a file exists inside the container by running `test -f`.

- `TestCommandSucceeds(...)`  
  Runs a command via container cmd args and asserts exit code `0`.
