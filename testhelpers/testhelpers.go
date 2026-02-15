package testhelpers

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/docker/go-connections/nat"
	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

// GetTestImage returns the image to test from TEST_IMAGE env var or falls back to the default.
func GetTestImage(defaultImage string) string {
	image := os.Getenv("TEST_IMAGE")
	if image == "" {
		return defaultImage
	}
	return image
}

// ContainerConfig holds optional container configuration.
type ContainerConfig struct {
	Env map[string]string
}

// applyContainerConfig applies optional container configuration.
func applyContainerConfig(config *ContainerConfig) []testcontainers.ContainerCustomizer {
	var opts []testcontainers.ContainerCustomizer

	if config == nil {
		return opts
	}

	if len(config.Env) > 0 {
		opts = append(opts, testcontainers.WithEnv(config.Env))
	}

	return opts
}

// runContainer starts a container, ensures cleanup, and centralizes common assertions.
func runContainer(t *testing.T, ctx context.Context, image string, opts ...testcontainers.ContainerCustomizer) testcontainers.Container {
	t.Helper()

	configDir := t.TempDir()
	opts = append([]testcontainers.ContainerCustomizer{
		testcontainers.WithMounts(
			testcontainers.BindMount(configDir, testcontainers.ContainerMountTarget("/config")),
		),
	}, opts...)

	c, err := testcontainers.Run(ctx, image, opts...)
	testcontainers.CleanupContainer(t, c)
	require.NoError(t, err)
	return c
}

// assertExitZero waits for container exit (via wait strategy set by caller) and asserts the exit code is zero.
func assertExitZero(t *testing.T, ctx context.Context, c testcontainers.Container, what string) {
	t.Helper()
	state, err := c.State(ctx)
	require.NoError(t, err)
	require.Equal(t, 0, state.ExitCode, what)
}

// HTTPTestConfig holds the configuration for HTTP endpoint tests.
type HTTPTestConfig struct {
	Port       string
	Path       string
	StatusCode int
}

// TestHTTPEndpoint tests that an HTTP endpoint is accessible and returns the expected status code.
func TestHTTPEndpoint(t *testing.T, ctx context.Context, image string, httpConfig HTTPTestConfig, containerConfig *ContainerConfig) {
	t.Helper()

	if httpConfig.Path == "" {
		httpConfig.Path = "/"
	}
	if httpConfig.StatusCode == 0 {
		httpConfig.StatusCode = 200
	}

	portStr := httpConfig.Port + "/tcp"
	portTCP := nat.Port(portStr)

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithExposedPorts(portStr),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort(portTCP),
			wait.ForHTTP(httpConfig.Path).WithPort(portTCP).WithStatusCodeMatcher(func(status int) bool {
				return status == httpConfig.StatusCode
			}),
		),
	}

	opts = append(opts, applyContainerConfig(containerConfig)...)
	_ = runContainer(t, ctx, image, opts...)
}

// TestFileExists tests that a file exists in the container.
func TestFileExists(t *testing.T, ctx context.Context, image string, filePath string, config *ContainerConfig) {
	t.Helper()
	TestCommandSucceeds(t, ctx, image, config, "test", "-f", filePath)
}

// TestCommandSucceeds tests that a command runs successfully in the container (exit code 0).
func TestCommandSucceeds(t *testing.T, ctx context.Context, image string, config *ContainerConfig, entrypoint string, args ...string) {
	t.Helper()

	opts := []testcontainers.ContainerCustomizer{
		testcontainers.WithEntrypoint(entrypoint),
		testcontainers.WithWaitStrategy(wait.ForExit()),
	}

	if len(args) > 0 {
		opts = append(opts, testcontainers.WithEntrypointArgs(args...))
	}

	opts = append(opts, applyContainerConfig(config)...)

	container := runContainer(t, ctx, image, opts...)
	assertExitZero(t, ctx, container, fmt.Sprintf("command '%s %v' should succeed", entrypoint, args))
}
