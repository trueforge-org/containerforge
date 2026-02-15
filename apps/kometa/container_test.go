package main

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/kometa:rolling")

	app, err := testcontainers.Run(
		ctx,
		image,
		testcontainers.WithWaitStrategy(
			wait.ForLog("Finished Run"),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
