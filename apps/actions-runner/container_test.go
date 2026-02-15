package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/actions-runner:rolling")
	testhelpers.TestFileExists(t, ctx, image, "/usr/local/bin/yq", nil)
}
