#!/usr/bin/env bash
set -euo pipefail

vault_path="${1:-/root/HermesVault}"
service_name="${2:-obsidian-sync}"
ob_bin="${OB_BIN:-$(command -v ob || true)}"

if [ -z "$ob_bin" ]; then
  echo "Could not find 'ob' on PATH. Install obsidian-headless first." >&2
  exit 1
fi

if [ ! -d "$vault_path" ]; then
  echo "Vault path does not exist: $vault_path" >&2
  echo "Create it and run ob sync-setup from inside it first." >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root or with sudo because this writes to /etc/systemd/system." >&2
  exit 1
fi

unit_path="/etc/systemd/system/${service_name}.service"

cat > "$unit_path" <<SERVICE
[Unit]
Description=Obsidian headless continuous sync (${vault_path})
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${vault_path}
ExecStart=${ob_bin} sync --continuous --path ${vault_path}
Restart=always
RestartSec=5
User=root
Environment=HOME=/root

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now "$service_name"

echo "Installed $unit_path"
echo
systemctl is-active "$service_name" || true
systemctl is-enabled "$service_name" || true
echo
echo "Recent logs:"
journalctl -u "$service_name" -n 20 --no-pager || true
