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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/valkey-tools:rolling")

	container, err := testcontainers.Run(
		ctx,
		image,
		testcontainers.WithCmdArgs("valkey-cli", "--help"),
	)
	require.NoError(t, err)
	defer testcontainers.CleanupContainer(t, container)
}
