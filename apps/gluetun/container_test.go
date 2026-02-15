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

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/gluetun:rolling")

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithCmdArgs("sh", "-c", "test -x /usr/local/bin/gluetun && command -v openvpn && command -v iptables"),
	)
	testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)
}
