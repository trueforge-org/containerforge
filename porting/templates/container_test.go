package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/cloudflareddns:rolling")
	testhelpers.TestFileExists(t, ctx, image, "/app/cloudflare-ddns.sh", nil)
}
