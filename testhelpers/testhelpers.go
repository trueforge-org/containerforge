package testhelpers

import (
	"context"
	"fmt"
	"os"

	"github.com/docker/go-connections/nat"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

// GetTestImage returns the image to test from TEST_IMAGE env var or falls back to the default
func GetTestImage(defaultImage string) string {
	image := os.Getenv("TEST_IMAGE")
	if image == "" {
		return defaultImage
	}
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
		return opts
	}

	// Apply environment variables
	if len(config.Env) > 0 {
		opts = append(opts, testcontainers.WithEnv(config.Env))
	}

	return opts
}

// runContainer is a tiny helper to start a container with common patterns centralized.
func runContainer(ctx context.Context, image string, opts ...testcontainers.ContainerCustomizer) (testcontainers.Container, error) {
	container, err := testcontainers.Run(ctx, image, opts...)
	if err != nil {
		return nil, err
	}
	return container, nil
}

// assertExitZero waits for container exit (via wait strategy set by caller) and verifies the exit code is zero.
func assertExitZero(ctx context.Context, c testcontainers.Container, what string) error {
	state, err := c.State(ctx)
	if err != nil {
		return fmt.Errorf("failed to get container state: %w", err)
	}
	if state.ExitCode != 0 {
		return fmt.Errorf("%s: exit code %d", what, state.ExitCode)
	}
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
	defer func() {
		termErr := container.Terminate(ctx)
		if err == nil && termErr != nil {
			err = fmt.Errorf("failed to terminate container: %w", termErr)
		}
	}()

	return nil
}

// CheckFileExists verifies a file exists in the container.
func CheckFileExists(ctx context.Context, image string, filePath string, config *ContainerConfig) error {
	return CheckCommandSucceeds(ctx, image, config, "test", "-f", filePath)
}

// CheckCommandSucceeds verifies that a command runs successfully in the container (exit code 0).
func CheckCommandSucceeds(ctx context.Context, image string, config *ContainerConfig, entrypoint string, args ...string) (err error) {

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
		termErr := container.Terminate(ctx)
		if err == nil && termErr != nil {
			err = fmt.Errorf("failed to terminate container: %w", termErr)
		}
	}()

	if err := assertExitZero(ctx, container, fmt.Sprintf("command '%s %v' should succeed", entrypoint, args)); err != nil {
		return err
	}

	return nil
}
