# Go container testhelpers

Shared helpers for standalone Go container checks.

## Purpose

- Reduce repeated `testcontainers-go` setup across app checks.
- Keep common behavior consistent:
  - `TEST_IMAGE` override support.
  - container cleanup and exit-code assertions.

## Helpers

- `GetTestImage(defaultImage string)`
  Returns `TEST_IMAGE` when set, otherwise the provided default image.

- `CheckHTTPEndpoint(...) error`
  Runs a container and waits for an HTTP endpoint on a port/path to match the expected status.
  HTTP checks always include a TCP listening wait on the same port first.

- `CheckTCPListening(...) error`
  Runs a container and waits for a TCP port to become reachable.

- `CheckWaits(..., httpConfigs []HTTPTestConfig, tcpConfigs []TCPTestConfig, ...) error`
  Runs one container and waits for multiple checks in the same lifecycle:
  - `httpConfigs []HTTPTestConfig`
  - `tcpConfigs []TCPTestConfig`
  Every HTTP item implicitly enforces TCP listening wait first on the same port.

- `CheckFileExists(...) error`
  Verifies a file exists inside the container by running `test -f`.

- `CheckFilesExist(..., filePaths []string, ...) error`
  Verifies multiple files exist (one check per file path).

- `CheckCommandSucceeds(...) error`
  Runs a command via container cmd args and verifies exit code `0`.

- `CheckCommand(..., commandConfig *CommandTestConfig, ...) error`
  Runs a command with optional assertions:
  - `ExpectedExitCode` (defaults to `0` when omitted)
  - `ExpectedContent` + `MatchContent=true` for output contains match (after trimming)

- `CheckCommands(..., commands []CommandTestConfig) error`
  Runs multiple command checks.
  Each item uses `CommandTestConfig.Command` executed as `sh -c <command>`.

For list-based file/command checks, each item currently starts its own container run.

- `TestHTTPEndpoint(...)`, `TestTCPListening(...)`, `TestFileExists(...)`, `TestFilesExist(...)`, `TestCommandSucceeds(...)`, `TestCommands(...)`
  Convenience wrappers for `go test` that fail the test immediately when the check returns an error.

- `TestWaits(...)`
  Convenience wrapper for combined HTTP/TCP wait lists.

- `HTTPTestConfig.StatusCodeMatcher func(int) bool`
  Optional custom matcher for HTTP status codes.

## Standalone usage (no `go test`)

You can run checks directly via:

```bash
go run ./cmd/run-tests --mode file --image ghcr.io/trueforge-org/actions-runner:rolling --file /usr/local/bin/yq

go run ./cmd/run-tests --mode http --image ghcr.io/trueforge-org/adguardhome-sync:rolling --http-port 8080 --http-path / --http-status 200

go run ./cmd/run-tests --mode command --image ghcr.io/trueforge-org/cloudflareddns:rolling --entrypoint test --arg -f --arg /app/cloudflare-ddns.sh

go run ./cmd/run-tests --mode command --image ghcr.io/trueforge-org/cloudflareddns:rolling --entrypoint sh --arg -c --arg 'echo ok' --command-exit-code 0 --command-content ok
```

Optional env vars for the started container can be added with repeated `--env KEY=VALUE`.
