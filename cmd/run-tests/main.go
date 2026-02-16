package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/trueforge-org/containerforge/testhelpers"
)

type stringSliceFlag []string

func (s *stringSliceFlag) String() string {
	return strings.Join(*s, ",")
}

func (s *stringSliceFlag) Set(value string) error {
	*s = append(*s, value)
	return nil
}

func parseEnv(pairs []string) (map[string]string, error) {
	env := map[string]string{}
	for _, pair := range pairs {
		key, value, ok := strings.Cut(pair, "=")
		if !ok || strings.TrimSpace(key) == "" {
			return nil, fmt.Errorf("invalid --env value %q, expected KEY=VALUE", pair)
		}
		env[key] = value
	}
	return env, nil
}

func main() {
	var (
		mode       = flag.String("mode", "file", "check mode: file|http|command")
		image      = flag.String("image", "", "container image to run")
		filePath   = flag.String("file", "", "path to file to verify in mode=file")
		httpPort   = flag.String("http-port", "", "http port in mode=http (without /tcp)")
		httpPath   = flag.String("http-path", "/", "http path in mode=http")
		httpStatus = flag.Int("http-status", 200, "expected http status in mode=http")
		entrypoint = flag.String("entrypoint", "", "entrypoint command in mode=command")
	)

	var envPairs stringSliceFlag
	var cmdArgs stringSliceFlag
	flag.Var(&envPairs, "env", "environment variable (KEY=VALUE), repeatable")
	flag.Var(&cmdArgs, "arg", "entrypoint argument, repeatable (mode=command)")

	flag.Parse()

	if strings.TrimSpace(*image) == "" {
		fmt.Fprintln(os.Stderr, "--image is required")
		os.Exit(2)
	}

	env, err := parseEnv(envPairs)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}

	config := &testhelpers.ContainerConfig{Env: env}
	ctx := context.Background()

	var runErr error
	switch *mode {
	case "file":
		if strings.TrimSpace(*filePath) == "" {
			fmt.Fprintln(os.Stderr, "--file is required in mode=file")
			os.Exit(2)
		}
		runErr = testhelpers.CheckFileExists(ctx, *image, *filePath, config)
	case "http":
		if strings.TrimSpace(*httpPort) == "" {
			fmt.Fprintln(os.Stderr, "--http-port is required in mode=http")
			os.Exit(2)
		}
		if _, err := strconv.Atoi(*httpPort); err != nil {
			fmt.Fprintf(os.Stderr, "invalid --http-port value %q\n", *httpPort)
			os.Exit(2)
		}
		runErr = testhelpers.CheckHTTPEndpoint(ctx, *image, testhelpers.HTTPTestConfig{
			Port:       *httpPort,
			Path:       *httpPath,
			StatusCode: *httpStatus,
		}, config)
	case "command":
		if strings.TrimSpace(*entrypoint) == "" {
			fmt.Fprintln(os.Stderr, "--entrypoint is required in mode=command")
			os.Exit(2)
		}
		runErr = testhelpers.CheckCommandSucceeds(ctx, *image, config, *entrypoint, cmdArgs...)
	default:
		fmt.Fprintf(os.Stderr, "unknown --mode %q, expected one of: file, http, command\n", *mode)
		os.Exit(2)
	}

	if runErr != nil {
		var exitErr interface{ ExitCode() int }
		if errors.As(runErr, &exitErr) {
			fmt.Fprintf(os.Stderr, "check failed (exit=%d): %v\n", exitErr.ExitCode(), runErr)
			os.Exit(1)
		}
		fmt.Fprintf(os.Stderr, "check failed: %v\n", runErr)
		os.Exit(1)
	}

	fmt.Println("check passed")
}
