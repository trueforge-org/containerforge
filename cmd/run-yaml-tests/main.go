package main

import (
	"context"
	"flag"
	"fmt"
	"os"
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
		image    = flag.String("image", "", "container image to run")
		yamlPath = flag.String("yaml", "", "path to container-test.yaml")
	)

	var envPairs stringSliceFlag
	flag.Var(&envPairs, "env", "environment variable (KEY=VALUE), repeatable")

	flag.Parse()

	if strings.TrimSpace(*image) == "" {
		fmt.Fprintln(os.Stderr, "--image is required")
		os.Exit(2)
	}
	if strings.TrimSpace(*yamlPath) == "" {
		fmt.Fprintln(os.Stderr, "--yaml is required")
		os.Exit(2)
	}

	env, err := parseEnv(envPairs)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}

	config := &testhelpers.ContainerConfig{Env: env}
	ctx := context.Background()

	if err := testhelpers.RunChecksFromYAML(ctx, *image, *yamlPath, config); err != nil {
		fmt.Fprintf(os.Stderr, "check failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("check passed")
}
