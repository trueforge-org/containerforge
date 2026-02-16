package testhelpers

import (
	"context"
	"fmt"
	"io"
	"os"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/docker/go-connections/nat"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

const (
	colorReset  = "\033[0m"
	colorBlue   = "\033[34m"
	colorCyan   = "\033[36m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorRed    = "\033[31m"
)

func envTruthy(name string) bool {
	value := strings.TrimSpace(strings.ToLower(os.Getenv(name)))
	switch value {
	case "1", "true", "yes", "on", "y":
		return true
	default:
		return false
	}
}

func colorsEnabled() bool {
	if os.Getenv("NO_COLOR") != "" {
		return false
	}

	if envTruthy("FORCE_COLOR") || envTruthy("CLICOLOR_FORCE") {
		return true
	}

	if strings.EqualFold(strings.TrimSpace(os.Getenv("TERM")), "dumb") {
		return false
	}

	return true
}

func debugEnabled() bool {
	return envTruthy("TESTHELPERS_DEBUG")
}

func shouldDumpContainerLogs(testFailed bool) bool {
	mode := strings.TrimSpace(strings.ToLower(os.Getenv("TESTHELPERS_CONTAINER_LOGS")))
	switch mode {
	case "always", "all":
		return true
	case "never", "off", "none", "0", "false", "no":
		return false
	case "success", "passed", "pass":
		return !testFailed
	case "failure", "fail", "failed", "onfail", "on-fail", "error", "errors", "":
		return testFailed
	default:
		logWarn("Unknown TESTHELPERS_CONTAINER_LOGS mode %q, defaulting to failure-only", mode)
		return testFailed
	}
}

func logPrefix(level string) string {
	if !colorsEnabled() {
		switch level {
		case "DEBUG":
			return "🐛 [DEBUG]"
		case "WARN":
			return "⚠️ [WARN]"
		case "ERROR":
			return "❌ [ERROR]"
		case "OK":
			return "✅ [OK]"
		default:
			return "ℹ️ [INFO]"
		}
	}

	switch level {
	case "DEBUG":
		return colorCyan + "🐛 [DEBUG]" + colorReset
	case "WARN":
		return colorYellow + "⚠️ [WARN]" + colorReset
	case "ERROR":
		return colorRed + "❌ [ERROR]" + colorReset
	case "OK":
		return colorGreen + "✅ [OK]" + colorReset
	default:
		return colorBlue + "ℹ️ [INFO]" + colorReset
	}
}

func logInfo(format string, args ...any) {
	fmt.Printf("%s %s %s\n", time.Now().Format("15:04:05"), logPrefix("INFO"), fmt.Sprintf(format, args...))
}

func logDebug(format string, args ...any) {
	if !debugEnabled() {
		return
	}
	fmt.Printf("%s %s %s\n", time.Now().Format("15:04:05"), logPrefix("DEBUG"), fmt.Sprintf(format, args...))
}

func logWarn(format string, args ...any) {
	fmt.Printf("%s %s %s\n", time.Now().Format("15:04:05"), logPrefix("WARN"), fmt.Sprintf(format, args...))
}

func logError(format string, args ...any) {
	fmt.Printf("%s %s %s\n", time.Now().Format("15:04:05"), logPrefix("ERROR"), fmt.Sprintf(format, args...))
}

func logOK(format string, args ...any) {
	fmt.Printf("%s %s %s\n", time.Now().Format("15:04:05"), logPrefix("OK"), fmt.Sprintf(format, args...))
}

func separatorLine(runeChar string, count int) string {
	if count <= 0 {
		count = 72
	}
	return strings.Repeat(runeChar, count)
}

func logSection(title string) {
	line := separatorLine("=", 72)
	if colorsEnabled() {
		fmt.Printf("%s %s\n", colorCyan+line+colorReset, colorCyan+title+colorReset)
		fmt.Printf("%s\n", colorCyan+line+colorReset)
		return
	}
	fmt.Printf("%s\n%s\n%s\n", line, title, line)
}

func envSummary(env map[string]string) string {
	if len(env) == 0 {
		return "none"
	}

	keys := make([]string, 0, len(env))
	for key := range env {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	return fmt.Sprintf("%d vars [%s]", len(keys), strings.Join(keys, ", "))
}

func commandString(entrypoint string, args []string) string {
	if len(args) == 0 {
		return entrypoint
	}

	return entrypoint + " " + strings.Join(args, " ")
}

func terminateContainer(ctx context.Context, container testcontainers.Container, label string) error {
	logDebug("🧹 Cleaning up container for %s", label)
	if err := container.Terminate(ctx); err != nil {
		logError("Failed to terminate container for %s: %v", label, err)
		return err
	}
	logDebug("Container terminated for %s", label)
	return nil
}

func dumpContainerLogs(ctx context.Context, c testcontainers.Container, label string) {
	logSection(fmt.Sprintf("📦 Container Logs (%s)", label))

	reader, err := c.Logs(ctx)
	if err != nil {
		logWarn("Unable to fetch container logs for %s: %v", label, err)
		return
	}
	defer reader.Close()

	content, err := io.ReadAll(reader)
	if err != nil {
		logWarn("Unable to read container logs for %s: %v", label, err)
		return
	}

	text := strings.TrimSpace(string(content))
	if text == "" {
		logInfo("No container logs were emitted for %s", label)
		return
	}

	fmt.Println(text)
	logSection(fmt.Sprintf("✅ End Container Logs (%s)", label))
}

// GetTestImage returns the image to test from TEST_IMAGE env var or falls back to the default
func GetTestImage(defaultImage string) string {
	image := os.Getenv("TEST_IMAGE")
	if image == "" {
		logInfo("Using default test image: %s", defaultImage)
		return defaultImage
	}
	logInfo("Using TEST_IMAGE override: %s", image)
	return image
}

// ContainerConfig holds optional container configuration
type ContainerConfig struct {
	Env map[string]string // Environment variables to set in the container
}

// applyContainerConfig applies optional container configuration
func applyContainerConfig(config *ContainerConfig) []testcontainers.ContainerCustomizer {
	var opts []testcontainers.ContainerCustomizer

	if config == nil {
		logDebug("No extra container config provided")
		return opts
	}

	// Apply environment variables
	if len(config.Env) > 0 {
		opts = append(opts, testcontainers.WithEnv(config.Env))
		logInfo("Applying container environment: %s", envSummary(config.Env))
	} else {
		logDebug("Container config provided without env vars")
	}

	return opts
}

// runContainer is a tiny helper to start a container with common patterns centralized.
func runContainer(ctx context.Context, image string, opts ...testcontainers.ContainerCustomizer) (testcontainers.Container, error) {
	logInfo("🚀 Starting container: image=%s customizers=%d", image, len(opts))
	logDebug("Invoking testcontainers.Run for image=%s", image)
	container, err := testcontainers.Run(ctx, image, opts...)
	if err != nil {
		logError("Container start failed for image=%s: %v", image, err)
		return nil, err
	}
	logOK("Container is up: image=%s", image)
	return container, nil
}

// assertExitZero waits for container exit (via wait strategy set by caller) and verifies the exit code is zero.
func assertExitZero(ctx context.Context, c testcontainers.Container, what string) error {
	logInfo("Checking container exit code for %s", what)
	state, err := c.State(ctx)
	if err != nil {
		logError("Failed to read container state for %s: %v", what, err)
		return fmt.Errorf("failed to get container state: %w", err)
	}
	logDebug("Container state for %s: running=%t, status=%s, exitCode=%d", what, state.Running, state.Status, state.ExitCode)
	if state.ExitCode != 0 {
		logError("Container exited with non-zero code for %s: %d", what, state.ExitCode)
		return fmt.Errorf("%s: exit code %d", what, state.ExitCode)
	}
	logOK("Container exit code is 0 for %s", what)
	return nil
}

// HTTPTestConfig holds the configuration for HTTP endpoint tests
type HTTPTestConfig struct {
	Port              string
	Path              string
	StatusCode        int
	StatusCodeMatcher func(int) bool
}

// CheckHTTPEndpoint verifies that an HTTP endpoint is accessible and returns the expected status code.
func CheckHTTPEndpoint(ctx context.Context, image string, httpConfig HTTPTestConfig, containerConfig *ContainerConfig) (err error) {

	if httpConfig.Path == "" {
		httpConfig.Path = "/"
	}
	if httpConfig.StatusCode == 0 {
		httpConfig.StatusCode = 200
	}
	if httpConfig.StatusCodeMatcher == nil {
		httpConfig.StatusCodeMatcher = func(status int) bool {
			return status == httpConfig.StatusCode
		}
	}

	portStr := httpConfig.Port + "/tcp"
	portTCP := nat.Port(portStr)

	logInfo("🧪 HTTP endpoint check: image=%s port=%s path=%s expected=%d", image, portStr, httpConfig.Path, httpConfig.StatusCode)
	if httpConfig.StatusCodeMatcher != nil {
		logDebug("Custom HTTP status matcher configured")
	}
	if containerConfig != nil {
		logInfo("HTTP test container config: env=%s", envSummary(containerConfig.Env))
	}

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithExposedPorts(portStr),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort(portTCP),
			wait.ForHTTP(httpConfig.Path).WithPort(portTCP).WithStatusCodeMatcher(func(status int) bool {
				return httpConfig.StatusCodeMatcher(status)
			}),
		),
	}

	// Apply optional container config
	opts = append(opts, applyContainerConfig(containerConfig)...)

	container, err := runContainer(ctx, image, opts...)
	if err != nil {
		return err
	}
	logOK("HTTP wait strategy passed: %s%s", portStr, httpConfig.Path)
	defer func() {
		if shouldDumpContainerLogs(err != nil) {
			dumpContainerLogs(ctx, container, "HTTP endpoint check")
		} else {
			logDebug("Skipping container logs for HTTP endpoint check (mode=%q, failed=%t)", strings.TrimSpace(strings.ToLower(os.Getenv("TESTHELPERS_CONTAINER_LOGS"))), err != nil)
		}
		termErr := terminateContainer(ctx, container, "HTTP endpoint check")
		if err == nil && termErr != nil {
			err = fmt.Errorf("failed to terminate container: %w", termErr)
		}
	}()

	logInfo("HTTP endpoint check finished successfully for image=%s", image)

	return nil
}

// CheckTCPListening verifies that a TCP port is listening in the container.
func CheckTCPListening(ctx context.Context, image string, port string, config *ContainerConfig) (err error) {
	portStr := port + "/tcp"
	portTCP := nat.Port(portStr)

	logInfo("🧪 TCP listening check: image=%s port=%s", image, portStr)
	if config != nil {
		logInfo("TCP check container config: env=%s", envSummary(config.Env))
	}

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithExposedPorts(portStr),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort(portTCP),
		),
	}

	// Apply optional container config
	opts = append(opts, applyContainerConfig(config)...)

	container, err := runContainer(ctx, image, opts...)
	if err != nil {
		return err
	}
	defer func() {
		if shouldDumpContainerLogs(err != nil) {
			dumpContainerLogs(ctx, container, "tcp listening check")
		} else {
			logDebug("Skipping container logs for TCP listening check (mode=%q, failed=%t)", strings.TrimSpace(strings.ToLower(os.Getenv("TESTHELPERS_CONTAINER_LOGS"))), err != nil)
		}
		termErr := terminateContainer(ctx, container, "tcp listening check")
		if err == nil && termErr != nil {
			err = fmt.Errorf("failed to terminate container: %w", termErr)
		}
	}()

	logInfo("TCP listening check completed successfully for image=%s port=%s", image, portStr)

	return nil
}

// CheckFileExists verifies a file exists in the container.
func CheckFileExists(ctx context.Context, image string, filePath string, config *ContainerConfig) error {
	return CheckCommandSucceeds(ctx, image, config, "test", "-f", filePath)
}

// CheckCommandSucceeds verifies that a command runs successfully in the container (exit code 0).
func CheckCommandSucceeds(ctx context.Context, image string, config *ContainerConfig, entrypoint string, args ...string) (err error) {
	fullCommand := commandString(entrypoint, args)
	logInfo("🧪 Command check: image=%s command=%q", image, fullCommand)
	if config != nil {
		logInfo("Command check container config: env=%s", envSummary(config.Env))
	}

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithEntrypoint(entrypoint),
		testcontainers.WithWaitStrategy(wait.ForExit()),
	}

	if len(args) > 0 {
		opts = append(opts, testcontainers.WithEntrypointArgs(args...))
	}

	// Apply optional container config
	opts = append(opts, applyContainerConfig(config)...)

	container, err := runContainer(ctx, image, opts...)
	if err != nil {
		return err
	}
	defer func() {
		if shouldDumpContainerLogs(err != nil) {
			dumpContainerLogs(ctx, container, "command check")
		} else {
			logDebug("Skipping container logs for command check (mode=%q, failed=%t)", strings.TrimSpace(strings.ToLower(os.Getenv("TESTHELPERS_CONTAINER_LOGS"))), err != nil)
		}
		termErr := terminateContainer(ctx, container, "command check")
		if err == nil && termErr != nil {
			err = fmt.Errorf("failed to terminate container: %w", termErr)
		}
	}()

	if err := assertExitZero(ctx, container, fmt.Sprintf("command %q", fullCommand)); err != nil {
		logWarn("Command check failed: %q", fullCommand)
		return err
	}

	logInfo("Command check completed successfully: %q", fullCommand)

	return nil
}

// TestHTTPEndpoint runs an HTTP endpoint check and fails the test on error.
func TestHTTPEndpoint(t *testing.T, ctx context.Context, image string, httpConfig HTTPTestConfig, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckHTTPEndpoint(ctx, image, httpConfig, containerConfig); err != nil {
		t.Fatalf("HTTP endpoint check failed: %v", err)
	}
}

// TestTCPListening runs a TCP listening check and fails the test on error.
func TestTCPListening(t *testing.T, ctx context.Context, image string, port string, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckTCPListening(ctx, image, port, containerConfig); err != nil {
		t.Fatalf("TCP listening check failed: %v", err)
	}
}

// TestFileExists runs a file existence check and fails the test on error.
func TestFileExists(t *testing.T, ctx context.Context, image string, filePath string, containerConfig *ContainerConfig) {
	t.Helper()
	if err := CheckFileExists(ctx, image, filePath, containerConfig); err != nil {
		t.Fatalf("file existence check failed: %v", err)
	}
}

// TestCommandSucceeds runs a command check and fails the test on error.
func TestCommandSucceeds(t *testing.T, ctx context.Context, image string, containerConfig *ContainerConfig, entrypoint string, args ...string) {
	t.Helper()
	if err := CheckCommandSucceeds(ctx, image, containerConfig, entrypoint, args...); err != nil {
		t.Fatalf("command check failed: %v", err)
	}
}
