package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/python:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithMounts(
			testcontainers.BindMount(configDir, testcontainers.ContainerMountTarget("/config")),
		),
		testcontainers.WithCmdArgs("sh", "-c", "test -f /usr/local/bin/python3 && test -d /app/venv && test -f /app/venv/bin/python && test -d /config/venv && test -f /config/venv/bin/python"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
