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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/nextcloud-imaginary:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("/usr/local/bin/imaginary", "-version"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}

func TestRunsAsAppsUser(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/nextcloud-imaginary:rolling")

	testhelpers.TestCommandSucceeds(t, ctx, image, nil, "sh", "-c", "[ \"$(id -un)\" = \"apps\" ]")
}
