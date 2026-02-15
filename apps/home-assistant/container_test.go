package main

import (
	"context"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/home-assistant:rolling")
	testhelpers.TestHTTPEndpoint(t, ctx, image, testhelpers.HTTPTestConfig{Port: "8123"}, nil)
}
