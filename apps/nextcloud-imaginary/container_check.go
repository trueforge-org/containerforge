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

	if err := testhelpers.CheckCommands(ctx, image, nil, []testhelpers.CommandTestConfig{
		{
			Command:          "/usr/local/bin/imaginary -version",
			ExpectedExitCode: 1,
			ExpectedContent:  "dev",
			MatchContent:     true,
		},
	}); err != nil {
		fmt.Fprintf(os.Stderr, "container check failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("container check passed")
}
