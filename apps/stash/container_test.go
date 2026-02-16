package main

import (
	"context"
	"os"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/stash:rolling")

	configDir, err := os.MkdirTemp("", "stash-config-")
	require.NoError(t, err)
	require.NoError(t, os.Chmod(configDir, 0o777))

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("9999/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("9999/tcp"),
			wait.ForHTTP("/").WithPort("9999/tcp").WithStatusCodeMatcher(func(status int) bool {
				return status >= 200 && status < 400
			}),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
