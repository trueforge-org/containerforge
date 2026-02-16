package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/lazylibrarian:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("5299/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("5299/tcp"),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
