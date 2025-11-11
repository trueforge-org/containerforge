package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"strconv"
	"strings"
	"testing"

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

	appName := os.Getenv("APP")
	require.NotEmpty(t, appName, "APP environment variable must be set")
	image := os.Getenv("TEST_IMAGE")
	if image == "" {
		image = "ghcr.io/trueforge-org/" + appName + ":rolling"
	}

	version := os.Getenv("VERSION")
	fmt.Println("Current version:" + version)

	majorVersion := strings.Split(version, ".")[0]

	// Convert major version to int
	majorInt, err := strconv.Atoi(majorVersion)
	if err != nil {
		panic(err)
	}
	oldMajor := strconv.Itoa(majorInt - 1)
	fmt.Println("Old Major version:" + oldMajor)

	upgradeTestImage := "ghcr.io/trueforge-org/" + appName + ":" + oldMajor

	oldApp, err := testcontainers.Run(
		ctx, upgradeTestImage,
		testcontainers.WithExposedPorts("5432/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("5432/tcp"),
		),
	)
	defer testcontainers.CleanupContainer(t, oldApp)
	require.NoError(t, err)

	fmt.Println("=== Logs for oldApp ===")
	printLogs(ctx, oldApp)

	app, err := testcontainers.Run(
		ctx, image,
		testcontainers.WithExposedPorts("5432/tcp"),
		testcontainers.WithWaitStrategy(
			wait.ForListeningPort("5432/tcp"),
		),
	)
	defer testcontainers.CleanupContainer(t, app)
	require.NoError(t, err)

	fmt.Println("=== Logs for app ===")
	printLogs(ctx, app)
}
