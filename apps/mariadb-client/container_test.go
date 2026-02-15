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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/mariadb-client:rolling")

	container, err := testcontainers.Run(
		ctx,
		image,
		testcontainers.WithCmdArgs("mariadb", "--version"),
	)
	require.NoError(t, err)
	defer testcontainers.CleanupContainer(t, container)
}
