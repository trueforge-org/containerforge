package main

import (
	"context"
	"fmt"
	"os"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func main() {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/actions-runner:rolling")

	if err := testhelpers.CheckFileExists(ctx, image, "/usr/local/bin/yq", nil); err != nil {
		fmt.Fprintf(os.Stderr, "container check failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("container check passed")
}
