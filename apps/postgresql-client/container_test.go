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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/postgresql-client:rolling")

	container, err := testcontainers.Run(
		ctx,
		image,
		testcontainers.WithCmdArgs("psql", "--version"),
	)
	require.NoError(t, err)
	defer testcontainers.CleanupContainer(t, container)
}
