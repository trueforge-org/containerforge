package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/stretchr/testify/require"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/cloudflareddns:rolling")
	require.NoError(t, testhelpers.CheckFileExists(ctx, image, "/app/cloudflare-ddns.sh", nil))
}
