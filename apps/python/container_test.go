package main

import (
	"context"
	"github.com/trueforge-org/containerforge/testhelpers"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/python:rolling")

	configDir := t.TempDir()

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithMounts(
			testcontainers.BindMount(configDir, testcontainers.ContainerMountTarget("/config")),
		),
		testcontainers.WithCmdArgs("sh", "-c", "test -f /usr/local/bin/python3 && test -L /config/venv && test \"$(readlink /config/venv)\" = /defaults/venv"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
