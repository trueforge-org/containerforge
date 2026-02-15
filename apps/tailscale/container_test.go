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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/tailscale:rolling")

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithCmdArgs("tailscale", "version"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
