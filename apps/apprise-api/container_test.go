package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/apprise-api:rolling")
	testhelpers.TestTCPListening(t, ctx, image, "8000", nil)
}
