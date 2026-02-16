package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/transmission:rolling")

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("9091/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("9091/tcp"),
			wait.ForHTTP("/").WithPort("9091/tcp").WithStatusCodeMatcher(func(status int) bool {
				return status == 403
			}),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
