package main

import (
	"context"
	"os"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
)

func Test(t *testing.T) {
	ctx := context.Background()

	appName := os.Getenv("APP")
	require.NotEmpty(t, appName, "APP environment variable must be set")
	image := os.Getenv("TEST_IMAGE")
	if image == "" {
		image = "ghcr.io/trueforge-org/" + appName + ":rolling"
	}

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithCmdArgs("python3", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	app, err = testcontainers.Run(
		ctx, image,
		testcontainers.WithCmdArgs("node", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	app, err = testcontainers.Run(
		ctx, image,
		testcontainers.WithCmdArgs("npm", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	app, err = testcontainers.Run(
		ctx, image,
		testcontainers.WithCmdArgs("yarn", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	require.NoError(t, err)
}
