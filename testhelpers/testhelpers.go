package testhelpers

import (
	"context"
	"fmt"
	"io"
	"os"
	"sort"
	"strings"
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

func readContainerLogs(ctx context.Context, c testcontainers.Container) (string, error) {
	reader, err := c.Logs(ctx)
	if err != nil {
		return "", err
	}
	defer reader.Close()

	content, err := io.ReadAll(reader)
	if err != nil {
		return "", err
	}

	return string(content), nil
}

// assertExitCode waits for container exit (via wait strategy set by caller) and verifies the exit code.
func assertExitCode(ctx context.Context, c testcontainers.Container, what string, expectedExitCode int) error {
	logInfo("Checking container exit code for %s", what)
	state, err := c.State(ctx)
	if err != nil {
		logError("Failed to read container state for %s: %v", what, err)
		return fmt.Errorf("failed to get container state: %w", err)
	}
	logDebug("Container state for %s: running=%t, status=%s, exitCode=%d", what, state.Running, state.Status, state.ExitCode)
	if state.ExitCode != expectedExitCode {
		logError("Container exit code mismatch for %s: expected=%d actual=%d", what, expectedExitCode, state.ExitCode)
		return fmt.Errorf("%s: exit code %d", what, state.ExitCode)
	}
	logOK("Container exit code is %d for %s", expectedExitCode, what)
	return nil
}

// assertExitZero waits for container exit (via wait strategy set by caller) and verifies the exit code is zero.
func assertExitZero(ctx context.Context, c testcontainers.Container, what string) error {
	return assertExitCode(ctx, c, what, 0)
}

// HTTPTestConfig holds the configuration for HTTP endpoint tests
type HTTPTestConfig struct {
	Port              string `yaml:"port"`
	Path              string `yaml:"path"`
	StatusCode        int    `yaml:"statusCode"`
	StatusCodeMatcher func(int) bool
}

// TCPTestConfig holds the configuration for TCP wait checks.
type TCPTestConfig struct {
	Port string `yaml:"port"`
}

// CommandTestConfig holds optional configuration for command checks.
type CommandTestConfig struct {
	Command          string `yaml:"command"`
	ExpectedExitCode int    `yaml:"expectedExitCode"`
	ExpectedContent  string `yaml:"expectedContent"`
	MatchContent     bool   `yaml:"matchContent"`
}

func normalizeHTTPConfig(httpConfig HTTPTestConfig) HTTPTestConfig {
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

	return httpConfig
}

func appendHTTPWaitStrategies(httpConfigs []HTTPTestConfig, portsSet map[string]struct{}, tcpWaitStrategies []wait.Strategy, httpWaitStrategies []wait.Strategy) ([]wait.Strategy, []wait.Strategy, error) {
	for index, httpConfig := range httpConfigs {
		httpConfig = normalizeHTTPConfig(httpConfig)
		if strings.TrimSpace(httpConfig.Port) == "" {
			return nil, nil, fmt.Errorf("http wait #%d missing port", index+1)
		}

		portStr := strings.TrimSpace(httpConfig.Port) + "/tcp"
		portTCP := nat.Port(portStr)
		portsSet[portStr] = struct{}{}

		statusCodeMatcher := httpConfig.StatusCodeMatcher
		tcpWaitStrategies = append(tcpWaitStrategies,
			wait.ForListeningPort(portTCP),
		)
		httpWaitStrategies = append(httpWaitStrategies,
			wait.ForHTTP(httpConfig.Path).WithPort(portTCP).WithStatusCodeMatcher(func(status int) bool {
				return statusCodeMatcher(status)
			}),
		)
	}

	return tcpWaitStrategies, httpWaitStrategies, nil
}

func appendTCPWaitStrategies(tcpConfigs []TCPTestConfig, portsSet map[string]struct{}, tcpWaitStrategies []wait.Strategy) ([]wait.Strategy, error) {
	for index, tcpConfig := range tcpConfigs {
		if strings.TrimSpace(tcpConfig.Port) == "" {
			return nil, fmt.Errorf("tcp wait #%d missing port", index+1)
		}

		portStr := strings.TrimSpace(tcpConfig.Port) + "/tcp"
		portTCP := nat.Port(portStr)
		portsSet[portStr] = struct{}{}

		tcpWaitStrategies = append(tcpWaitStrategies, wait.ForListeningPort(portTCP))
	}

	return tcpWaitStrategies, nil
}

// CheckWaits verifies HTTP and TCP waits within one container start/stop lifecycle.
func CheckWaits(ctx context.Context, image string, httpConfigs []HTTPTestConfig, tcpConfigs []TCPTestConfig, containerConfig *ContainerConfig) (err error) {
	if len(httpConfigs) == 0 && len(tcpConfigs) == 0 {
		return fmt.Errorf("at least one HTTP or TCP wait must be provided")
	}

	logInfo("🧪 Wait checks: image=%s http=%d tcp=%d", image, len(httpConfigs), len(tcpConfigs))
	if containerConfig != nil {
		logInfo("Wait checks container config: env=%s", envSummary(containerConfig.Env))
	}

	portsSet := map[string]struct{}{}
	var tcpWaitStrategies []wait.Strategy
	var httpWaitStrategies []wait.Strategy

	var errBuild error
	tcpWaitStrategies, httpWaitStrategies, errBuild = appendHTTPWaitStrategies(httpConfigs, portsSet, tcpWaitStrategies, httpWaitStrategies)
	if errBuild != nil {
		return errBuild
	}

	tcpWaitStrategies, errBuild = appendTCPWaitStrategies(tcpConfigs, portsSet, tcpWaitStrategies)
	if errBuild != nil {
		return errBuild
	}

	// Global invariant: run all TCP waits before any HTTP waits.
	waitStrategies := append(tcpWaitStrategies, httpWaitStrategies...)

	exposedPorts := make([]string, 0, len(portsSet))
	for port := range portsSet {
		exposedPorts = append(exposedPorts, port)
	}
	sort.Strings(exposedPorts)

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithExposedPorts(exposedPorts...),
		testcontainers.WithWaitStrategy(waitStrategies...),
	}

	// Apply optional container config
	opts = append(opts, applyContainerConfig(containerConfig)...)

	container, err := runContainer(ctx, image, opts...)
	if err != nil {
		return err
	}
	defer func() {
		if shouldDumpContainerLogs(err != nil) {
			dumpContainerLogs(ctx, container, "wait checks")
		} else {
			logDebug("Skipping container logs for wait checks (mode=%q, failed=%t)", strings.TrimSpace(strings.ToLower(os.Getenv("TESTHELPERS_CONTAINER_LOGS"))), err != nil)
		}
		termErr := terminateContainer(ctx, container, "wait checks")
		if err == nil && termErr != nil {
			err = fmt.Errorf("failed to terminate container: %w", termErr)
		}
	}()

	logInfo("Wait checks completed successfully for image=%s", image)

	return nil
}

// CheckHTTPEndpoint verifies that an HTTP endpoint is accessible and returns the expected status code.
func CheckHTTPEndpoint(ctx context.Context, image string, httpConfig HTTPTestConfig, containerConfig *ContainerConfig) (err error) {
	httpConfig = normalizeHTTPConfig(httpConfig)

	logInfo("🧪 HTTP endpoint check: image=%s port=%s/tcp path=%s expected=%d", image, httpConfig.Port, httpConfig.Path, httpConfig.StatusCode)
	logDebug("HTTP endpoint checks always include mandatory TCP listening wait first")
	if httpConfig.StatusCodeMatcher != nil {
		logDebug("Custom HTTP status matcher configured")
	}

	return CheckWaits(ctx, image, []HTTPTestConfig{httpConfig}, nil, containerConfig)
}

// CheckTCPListening verifies that a TCP port is listening in the container.
func CheckTCPListening(ctx context.Context, image string, port string, config *ContainerConfig) (err error) {
	logInfo("🧪 TCP listening check: image=%s port=%s/tcp", image, port)

	return CheckWaits(ctx, image, nil, []TCPTestConfig{{Port: port}}, config)
}

// CheckFileExists verifies a file exists in the container.
func CheckFileExists(ctx context.Context, image string, filePath string, config *ContainerConfig) error {
	return CheckCommandSucceeds(ctx, image, config, "test", "-f", filePath)
}

// CheckFilesExist verifies that all provided files exist in the container.
func CheckFilesExist(ctx context.Context, image string, filePaths []string, config *ContainerConfig) error {
	if len(filePaths) == 0 {
		return fmt.Errorf("at least one file path must be provided")
	}

	for index, filePath := range filePaths {
		if strings.TrimSpace(filePath) == "" {
			return fmt.Errorf("file check #%d missing file path", index+1)
		}
		if err := CheckFileExists(ctx, image, filePath, config); err != nil {
			return fmt.Errorf("file check #%d failed: %w", index+1, err)
		}
	}

	return nil
}

// CheckCommand verifies that a command runs with optional expected exit code and output content checks.
func CheckCommand(ctx context.Context, image string, containerConfig *ContainerConfig, commandConfig *CommandTestConfig, entrypoint string, args ...string) (err error) {
	expectedExitCode := 0
	if commandConfig != nil {
		expectedExitCode = commandConfig.ExpectedExitCode
	}

	fullCommand := commandString(entrypoint, args)
	logInfo("🧪 Command check: image=%s command=%q expectedExitCode=%d", image, fullCommand, expectedExitCode)
	if containerConfig != nil {
		logInfo("Command check container config: env=%s", envSummary(containerConfig.Env))
	}
	if commandConfig != nil && commandConfig.MatchContent {
		logInfo("Command check output match enabled")
	}

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithEntrypoint(entrypoint),
		testcontainers.WithWaitStrategy(wait.ForExit()),
	}

	if len(args) > 0 {
		opts = append(opts, testcontainers.WithEntrypointArgs(args...))
	}

	// Apply optional container config
	opts = append(opts, applyContainerConfig(containerConfig)...)

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

	if err := assertExitCode(ctx, container, fmt.Sprintf("command %q", fullCommand), expectedExitCode); err != nil {
		logWarn("Command check failed: %q", fullCommand)
		return err
	}

	if commandConfig != nil && commandConfig.MatchContent {
		output, logErr := readContainerLogs(ctx, container)
		if logErr != nil {
			return fmt.Errorf("failed reading command output: %w", logErr)
		}

		actual := strings.TrimSpace(output)
		expected := strings.TrimSpace(commandConfig.ExpectedContent)
		if !strings.Contains(actual, expected) {
			return fmt.Errorf("command %q output mismatch: expected content %q not found in %q", fullCommand, expected, actual)
		}
		logOK("Command output contains expected content")
	}

	logInfo("Command check completed successfully: %q", fullCommand)

	return nil
}

// CheckCommands verifies that all provided commands pass using the command backend checks.
func CheckCommands(ctx context.Context, image string, containerConfig *ContainerConfig, commands []CommandTestConfig) error {
	if len(commands) == 0 {
		return fmt.Errorf("at least one command must be provided")
	}

	for index, command := range commands {
		if strings.TrimSpace(command.Command) == "" {
			return fmt.Errorf("command check #%d missing command", index+1)
		}

		commandConfig := command
		if err := CheckCommand(ctx, image, containerConfig, &commandConfig, "sh", "-c", command.Command); err != nil {
			return fmt.Errorf("command check #%d failed: %w", index+1, err)
		}
	}

	return nil
}

// CheckCommandSucceeds verifies that a command runs successfully in the container (exit code 0).
func CheckCommandSucceeds(ctx context.Context, image string, config *ContainerConfig, entrypoint string, args ...string) error {
	return CheckCommand(ctx, image, config, nil, entrypoint, args...)
}
