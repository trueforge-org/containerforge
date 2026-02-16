package main

import (
	"bufio"
	"context"
	"fmt"
	"testing"

	"github.com/trueforge-org/containerforge/testhelpers"

	"github.com/stretchr/testify/require"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func printLogs(ctx context.Context, container testcontainers.Container) {
	logs, err := container.Logs(ctx)
	if err != nil {
		fmt.Println("failed to get logs:", err)
		return
	}
	defer logs.Close()

	scanner := bufio.NewScanner(logs)
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		fmt.Println("error reading logs:", err)
	}
}

func Test(t *testing.T) {
	ctx := context.Background()

	image := testhelpers.GetTestImage("ghcr.io/trueforge-org/postgresql:rolling")

	configDir := t.TempDir()
	testhelpers.PrepareConfigDir(t, configDir)

	app, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("5432/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForHealthCheck(),
			wait.ForListeningPort("5432/tcp"),
		),
	)
	defer testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)

	fmt.Println("=== Logs for fresh app ===")
	printLogs(ctx, app)

	fmt.Println("=== Starting In-App Upgrade tests... ===")

	upgrade, err := testcontainers.Run(
		ctx, image,

		testcontainers.WithExposedPorts("5432/tcp"),
		testcontainers.WithEnv(map[string]string{
			"PREPTEST": "true",
		}),
		testcontainers.WithWaitStrategy(
			wait.ForHealthCheck(),
			wait.ForListeningPort("5432/tcp"),
		),
	)
	defer testcontainers.CleanupContainer(t, upgrade)
	require.NoError(t, err)

	fmt.Println("=== Logs for in-app upgrade ===")
	printLogs(ctx, upgrade)
}
