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

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithExposedPorts("5055/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("5055/tcp"),
			wait.ForHTTP("/").WithPort("5055/tcp").WithStatusCodeMatcher(func(status int) bool {
				return status == 400
			}),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
