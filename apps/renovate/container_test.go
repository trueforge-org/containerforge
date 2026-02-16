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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/renovate:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("test", "-f", "/etc/os-release"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
