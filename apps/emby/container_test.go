package main

import (
	"context"
	"github.com/trueforge-org/containerforge/testhelpers"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/emby:rolling")

	configDir := t.TempDir()

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithMounts(
			testcontainers.BindMount(configDir, testcontainers.ContainerMountTarget("/config")),
		),
		testcontainers.WithExposedPorts("8096/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("8096/tcp"),
			wait.ForHTTP("/").WithPort("8096/tcp").WithStatusCodeMatcher(func(status int) bool {
				return status >= 200 && status < 400
			}),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
