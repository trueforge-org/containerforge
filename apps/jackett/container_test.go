package main

import (
	"context"
	"os"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
	"github.com/trueforge-org/containerforge/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/jackett:rolling")

	configDir, err := os.MkdirTemp("", "jackett-config-")
	require.NoError(t, err)
	require.NoError(t, os.Chmod(configDir, 0o777))

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithMounts(
			testcontainers.BindMount(configDir, testcontainers.ContainerMountTarget("/config")),
		),
		testcontainers.WithExposedPorts("9117/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("9117/tcp"),
			wait.ForHTTP("/").WithPort("9117/tcp").WithStatusCodeMatcher(func(status int) bool {
				return status == 400
			}),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
