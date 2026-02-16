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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/jbops:rolling")

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithCmdArgs("test", "-f", "/app/fun/plexapi_haiku.py"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
