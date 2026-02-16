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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/resilio-sync:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("8888/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("8888/tcp"),
			// wait.ForHTTP("/gui'").WithPort("8888/tcp").WithStatusCodeMatcher(func(status int) bool {
			// 	return status >= 200 && status < 400
			// }),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
