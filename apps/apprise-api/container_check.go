package main

import (
	"context"
	"fmt"
	"os"

	"github.com/trueforge-org/containerforge/testhelpers"
)

func main() {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/apprise-api:rolling")

	if err := testhelpers.CheckWaits(
		ctx,
		image,
		nil,
		[]testhelpers.TCPTestConfig{
			{Port: "8000"},
		},
		nil,
	); err != nil {
		fmt.Fprintf(os.Stderr, "container check failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("container check passed")
}
