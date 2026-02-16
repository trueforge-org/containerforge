package main

import (
	"context"
	"os"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	appName := os.Getenv("APP")
	require.NotEmpty(t, appName, "APP environment variable must be set")
	image := os.Getenv("TEST_IMAGE")
	if image == "" {
		image = "ghcr.io/trueforge-org/" + appName + ":rolling"
	}

	configDir, err := os.MkdirTemp("", "mariadb-test-*")
	require.NoError(t, err)
	t.Cleanup(func() { _ = os.RemoveAll(configDir) })
	require.NoError(t, os.Chmod(configDir, 0o777))

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("3306/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("3306/tcp"),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
