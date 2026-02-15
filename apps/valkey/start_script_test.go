package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestStartScriptMapsEnvToValkeyArgs(t *testing.T) {
	t.Run("VALKEY env takes precedence", func(t *testing.T) {
		args := runStartScript(t, map[string]string{
			"VALKEY_PORT":     "6381",
			"REDIS_PORT":      "6382",
			"VALKEY_PASSWORD": "valkey-pass",
			"REDIS_PASSWORD":  "redis-pass",
		})
		require.Contains(t, args, "ARG=--port\nARG=6381")
		require.Contains(t, args, "ARG=--requirepass\nARG=valkey-pass")
	})

	t.Run("REDIS env aliases are supported", func(t *testing.T) {
		args := runStartScript(t, map[string]string{
			"REDIS_PORT":     "6391",
			"REDIS_PASSWORD": "redis-pass",
		})
		require.Contains(t, args, "ARG=--port\nARG=6391")
		require.Contains(t, args, "ARG=--requirepass\nARG=redis-pass")
	})
}

func runStartScript(t *testing.T, vars map[string]string) string {
	t.Helper()

	tmpDir := t.TempDir()
	resultFile := filepath.Join(tmpDir, "result.txt")
	stub := filepath.Join(tmpDir, "valkey-server")
const stubScript = `#!/bin/sh
for arg in "$@"; do
  printf 'ARG=%s\n' "$arg" >> "$VALKEY_SERVER_ARGS_FILE"
done
`
	err := os.WriteFile(stub, []byte(stubScript), 0o755)
	require.NoError(t, err)

	_, file, _, ok := runtime.Caller(0)
	require.True(t, ok)
	startScriptPath := filepath.Join(filepath.Dir(file), "start.sh")
	cmd := exec.Command("bash", startScriptPath)
	cmd.Env = append(os.Environ(),
		"PATH="+tmpDir+":"+os.Getenv("PATH"),
		"VALKEY_SERVER_ARGS_FILE="+resultFile,
	)
	for k, v := range vars {
		cmd.Env = append(cmd.Env, k+"="+v)
	}

	out, err := cmd.CombinedOutput()
	require.NoError(t, err, string(out))

	data, err := os.ReadFile(resultFile)
	require.NoError(t, err)
	return string(data)
}
