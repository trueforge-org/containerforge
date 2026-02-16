package main

import (
	"context"
	"os"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/kometa:rolling")

	configDir, err := os.MkdirTemp("", "kometa-config-")
	require.NoError(t, err)
	t.Cleanup(func() {
		if cleanupErr := os.RemoveAll(configDir); cleanupErr != nil {
			t.Errorf("failed to remove temp config dir %q: %v", configDir, cleanupErr)
		}
	})
	require.NoError(t, os.Chmod(configDir, 0o777))

	app, err := testcontainers.Run(
		ctx,
		image,

		testcontainers.WithWaitStrategy(
			wait.ForLog("Finished Run"),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
