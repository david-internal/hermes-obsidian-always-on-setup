#!/usr/bin/env bash
set -u

echo "Hermes + Obsidian VPS prerequisite check"
echo

failures=0

check_cmd() {
  local name="$1"
  local cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[ok] $name: $(command -v "$cmd")"
  else
    echo "[missing] $name: command '$cmd' not found"
    failures=$((failures + 1))
  fi
}

if [ "$(id -u)" -eq 0 ]; then
  echo "[ok] running as root"
else
  echo "[warn] not running as root; some setup commands may need sudo"
fi

if [ -f /etc/os-release ]; then
  . /etc/os-release
  echo "[info] OS: ${PRETTY_NAME:-unknown}"
else
  echo "[warn] /etc/os-release not found"
fi

check_cmd "curl" curl
check_cmd "systemctl" systemctl
check_cmd "node" node
check_cmd "npm" npm
check_cmd "obsidian-headless CLI" ob
check_cmd "Hermes CLI" hermes

if command -v node >/dev/null 2>&1; then
  node_major="$(node -v | sed 's/^v//' | cut -d. -f1)"
  if [ "${node_major:-0}" -ge 22 ]; then
    echo "[ok] Node major version is $node_major"
  else
    echo "[missing] Node 22+ required; current version: $(node -v)"
    failures=$((failures + 1))
  fi
fi

vault_path="${OBSIDIAN_VAULT_PATH:-/root/HermesVault}"
echo "[info] expected vault path: $vault_path"

if [ -d "$vault_path" ]; then
  echo "[ok] vault directory exists"
else
  echo "[warn] vault directory does not exist yet"
fi

if [ -f "$HOME/.hermes/.env" ]; then
  echo "[ok] Hermes env file found: $HOME/.hermes/.env"
  if grep -q '^OBSIDIAN_VAULT_PATH=' "$HOME/.hermes/.env"; then
    echo "[ok] OBSIDIAN_VAULT_PATH is set in Hermes env"
  else
    echo "[warn] OBSIDIAN_VAULT_PATH is not set in Hermes env"
  fi
else
  echo "[warn] Hermes env file not found yet"
fi

if command -v systemctl >/dev/null 2>&1; then
  if systemctl list-unit-files obsidian-sync.service >/dev/null 2>&1; then
    echo "[ok] obsidian-sync.service is installed"
    systemctl is-active obsidian-sync >/dev/null 2>&1 && echo "[ok] obsidian-sync is active" || echo "[warn] obsidian-sync is not active"
    systemctl is-enabled obsidian-sync >/dev/null 2>&1 && echo "[ok] obsidian-sync is enabled" || echo "[warn] obsidian-sync is not enabled"
  else
    echo "[warn] obsidian-sync.service not installed yet"
  fi
fi

echo
if [ "$failures" -eq 0 ]; then
  echo "Result: prerequisites look usable. Continue with the setup runbook."
  exit 0
else
  echo "Result: $failures required item(s) missing. Fix those before continuing."
  exit 1
fi
