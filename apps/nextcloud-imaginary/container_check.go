package main

import (
	"context"
	"fmt"
	"os"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func main() {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/nextcloud-imaginary:rolling")

	if err := testhelpers.CheckCommand(ctx, image, nil, &testhelpers.CommandTestConfig{
		ExpectedExitCode: 1,
		ExpectedContent:  "dev",
		MatchContent:     true,
	}, "/usr/local/bin/imaginary", "-version"); err != nil {
		fmt.Fprintf(os.Stderr, "container check failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("container check passed")
}
