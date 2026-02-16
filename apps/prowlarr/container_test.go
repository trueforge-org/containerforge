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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/prowlarr:rolling")

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("9696/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForHealthCheck(),
			wait.ForListeningPort("9696/tcp"),
			wait.ForHTTP("/").WithPort("9696/tcp").WithStatusCodeMatcher(func(status int) bool {
				return status >= 200 && status < 400
			}),
		),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
