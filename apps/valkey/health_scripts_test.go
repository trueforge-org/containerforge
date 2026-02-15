package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestHealthScriptsUseValkeyEnvWithRedisAlias(t *testing.T) {
	t.Run("local readiness prefers VALKEY over REDIS", func(t *testing.T) {
		output := runHealthScript(t, "ping_readiness_local.sh", map[string]string{
			"VALKEY_PASSWORD": "valkey-pass",
			"REDIS_PASSWORD":  "redis-pass",
			"VALKEY_PORT":     "6381",
			"REDIS_PORT":      "6382",
		})
		require.Contains(t, output, "AUTH=valkey-pass")
		require.Contains(t, output, "ARGS=-h localhost -p 6381 ping")
	})

	t.Run("master readiness falls back to REDIS alias", func(t *testing.T) {
		output := runHealthScript(t, "ping_readiness_master.sh", map[string]string{
			"REDIS_MASTER_PASSWORD":    "redis-master-pass",
			"REDIS_MASTER_HOST":        "redis-master-host",
			"REDIS_MASTER_PORT_NUMBER": "6390",
		})
		require.Contains(t, output, "AUTH=redis-master-pass")
		require.Contains(t, output, "ARGS=-h redis-master-host -p 6390 ping")
	})
}

func runHealthScript(t *testing.T, scriptName string, vars map[string]string) string {
	t.Helper()

	tmpDir := t.TempDir()
	resultFile := filepath.Join(tmpDir, "result.txt")
	stub := filepath.Join(tmpDir, "valkey-cli")
	err := os.WriteFile(stub, []byte("#!/bin/sh\nprintf 'AUTH=%s\\n' \"${REDISCLI_AUTH:-}\" > \"$VALKEY_CLI_RESULT_FILE\"\nprintf 'ARGS=%s\\n' \"$*\" >> \"$VALKEY_CLI_RESULT_FILE\"\necho PONG\n"), 0o755)
	require.NoError(t, err)

	scriptPath := filepath.Join("/home/runner/work/containerforge/containerforge/apps/valkey/health", scriptName)
	cmd := exec.Command("bash", scriptPath, "2")
	cmd.Env = append(os.Environ(),
		"PATH="+tmpDir+":"+os.Getenv("PATH"),
		"VALKEY_CLI_RESULT_FILE="+resultFile,
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
