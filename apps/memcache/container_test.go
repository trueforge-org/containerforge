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

	container, err := testcontainers.Run(
		ctx,
		image,
		testcontainers.WithCmdArgs("memcached", "--version"),
	)
	require.NoError(t, err)
	defer testcontainers.CleanupContainer(t, container)
}
