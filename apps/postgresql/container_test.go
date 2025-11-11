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

	// Directory to mount
	hostDataDir := "/tmp/config"

	// Create the directory, including any necessary parents
	err = os.MkdirAll(hostDataDir, 0o777)
	if err != nil {
		fmt.Println("Failed to create directory:", err)
		return
	}

	// Change owner to UID 568 and GID 568
	err = os.Chown(hostDataDir, 568, 568)
	if err != nil {
		fmt.Println("failed to set ownership: ", err)
	}

	fmt.Println("Directory created and ownership set successfully: ", hostDataDir)

	oldAppReq := testcontainers.ContainerRequest{
		Image:        upgradeTestImage,
		ExposedPorts: []string{"5432/tcp"},
		Mounts: testcontainers.Mounts(
			testcontainers.BindMount(hostDataDir, "/config"),
		),
		WaitingFor: wait.ForListeningPort("5432/tcp"),
	}

	oldApp, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: oldAppReq,
		Started:          true,
	})
	defer func() {
		if oldApp != nil {
			oldApp.Terminate(ctx)
		}
	}()
	require.NoError(t, err)

	fmt.Println("=== Logs for oldApp ===")
	printLogs(ctx, oldApp)

	entries, err := os.ReadDir(hostDataDir)
	if err != nil {
		fmt.Println("Failed to read directory:", err)
		return
	}

	fmt.Println("Files in /tmp/config:")
	for _, entry := range entries {
		fmt.Println("-", entry.Name())
	}

	appReq := testcontainers.ContainerRequest{
		Image:        image,
		ExposedPorts: []string{"5432/tcp"},
		Mounts: testcontainers.Mounts(
			testcontainers.BindMount(hostDataDir, "/config"),
		),
		WaitingFor: wait.ForListeningPort("5432/tcp"),
	}

	app, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: appReq,
		Started:          true,
	})
	defer func() {
		if app != nil {
			app.Terminate(ctx)
		}
	}()
	require.NoError(t, err)

	fmt.Println("=== Logs for app ===")
	printLogs(ctx, app)
}
