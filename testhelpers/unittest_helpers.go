package testhelpers

import "context"

type testFailureReporter interface {
	Helper()
	Fatalf(format string, args ...any)
}

// TestHTTPEndpoint runs an HTTP endpoint check and fails the test on error.
func TestHTTPEndpoint(t testFailureReporter, ctx context.Context, image string, httpConfig HTTPTestConfig, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckHTTPEndpoint(ctx, image, httpConfig, containerConfig); err != nil {
		t.Fatalf("HTTP endpoint check failed: %v", err)
	}
}

// TestTCPListening runs a TCP listening check and fails the test on error.
func TestTCPListening(t testFailureReporter, ctx context.Context, image string, port string, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckTCPListening(ctx, image, port, containerConfig); err != nil {
		t.Fatalf("TCP listening check failed: %v", err)
	}
}

// TestWaits runs combined HTTP/TCP waits and fails the test on error.
func TestWaits(t testFailureReporter, ctx context.Context, image string, httpConfigs []HTTPTestConfig, tcpConfigs []TCPTestConfig, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckWaits(ctx, image, httpConfigs, tcpConfigs, containerConfig); err != nil {
		t.Fatalf("wait checks failed: %v", err)
	}
}

// TestFileExists runs a file existence check and fails the test on error.
func TestFileExists(t testFailureReporter, ctx context.Context, image string, filePath string, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckFileExists(ctx, image, filePath, containerConfig); err != nil {
		t.Fatalf("file existence check failed: %v", err)
	}
}

// TestFilesExist runs list-based file existence checks and fails the test on error.
func TestFilesExist(t testFailureReporter, ctx context.Context, image string, filePaths []string, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckFilesExist(ctx, image, filePaths, containerConfig); err != nil {
		t.Fatalf("file existence checks failed: %v", err)
	}
}

// TestCommandSucceeds runs a command check and fails the test on error.
func TestCommandSucceeds(t testFailureReporter, ctx context.Context, image string, containerConfig *ContainerConfig, entrypoint string, args ...string) {
	t.Helper()
	if err := CheckCommandSucceeds(ctx, image, containerConfig, entrypoint, args...); err != nil {
		t.Fatalf("command check failed: %v", err)
	}
}

// TestCommand runs a command check with optional expected exit code and output content checks.
func TestCommand(t testFailureReporter, ctx context.Context, image string, containerConfig *ContainerConfig, commandConfig *CommandTestConfig, entrypoint string, args ...string) {
	t.Helper()
	if err := CheckCommand(ctx, image, containerConfig, commandConfig, entrypoint, args...); err != nil {
		t.Fatalf("command check failed: %v", err)
	}
}

// TestCommands runs list-based command checks and fails the test on error.
func TestCommands(t testFailureReporter, ctx context.Context, image string, containerConfig *ContainerConfig, commands []CommandTestConfig) {
	t.Helper()
	if err := CheckCommands(ctx, image, containerConfig, commands); err != nil {
		t.Fatalf("command checks failed: %v", err)
	}
}
