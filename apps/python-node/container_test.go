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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/python-node:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("python3", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	app, err = testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("node", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	app, err = testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("npm", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	app, err = testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("yarn", "--version"),
	)
	testcontainers.CleanupContainer(t, app)

	require.NoError(t, err)
}
