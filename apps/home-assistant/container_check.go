package main

import (
	"context"
	"fmt"
	"os"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func main() {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/home-assistant:rolling")

	if err := testhelpers.CheckHTTPEndpoint(ctx, image, testhelpers.HTTPTestConfig{
		Port: "8123",
		StatusCodeMatcher: func(status int) bool {
			return status >= 200 && status < 400
		},
	}, nil); err != nil {
		fmt.Fprintf(os.Stderr, "container check failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("container check passed")
}
