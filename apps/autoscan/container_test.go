package main

import (
	"bufio"
	"context"
	"os"
	"strings"
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

	// Start container without any wait strategy
	app, err := testcontainers.Run(ctx, image,
		testcontainers.WithExposedPorts("3030/tcp"),
	)
	require.NoError(t, err)
	defer testcontainers.CleanupContainer(t, app)

	// Check logs for "Processor started"
	logs, err := app.Logs(ctx)
	require.NoError(t, err)

	found := false
	scanner := bufio.NewScanner(logs)
	for scanner.Scan() {
		if strings.Contains(scanner.Text(), "Processor started") {
			found = true
			break
		}
	}
	require.NoError(t, scanner.Err())
	require.True(t, found, `"Processor started" not found in container logs`)
}
