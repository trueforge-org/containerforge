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

	upgradeTestImage := "ghcr.io/trueforge-org/" + appName + ":17.6"

	oldApp, err := testcontainers.Run(
		ctx, upgradeTestImage,
		testcontainers.WithExposedPorts("5432/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("5432/tcp"),
		),
	)
	testcontainers.CleanupContainer(t, oldApp)
	require.NoError(t, err)

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithExposedPorts("5432/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("5432/tcp"),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
