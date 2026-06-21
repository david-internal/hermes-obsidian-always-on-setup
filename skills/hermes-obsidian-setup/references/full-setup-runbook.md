# Full Setup Runbook

Use this reference when guiding the full Hermes + Obsidian VPS setup.

## Target Architecture

- Hermes Agent runs on the VPS 24/7.
- Obsidian runs locally on the Mac.
- Obsidian Sync keeps the Mac vault and VPS folder in sync.
- Hermes writes only to the synced vault folder.
- Telegram is an input surface, not the source of truth.

## Prerequisite Questions

Ask these before commands:

1. Do you have root SSH access to the VPS?
2. Is Obsidian Sync active on the account?
3. Will the remote vault be new, or do you need to connect an existing remote vault?
4. What vault path should Hermes use on the VPS? Default: `/root/HermesVault`.
5. Which model provider will Hermes use? The video path used OpenRouter.

## Command Sequence

### Connect

```bash
ssh root@YOUR_VPS_IP
ss -tlnp | grep ssh
```

### Install Hermes

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes setup
```

### Install Node 22 And obsidian-headless

```bash
apt update && apt install -y curl && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs && npm install -g obsidian-headless && ob login
```

If `ob` is missing:

```bash
export PATH="$(npm prefix -g)/bin:$PATH"
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Create Or Find The Remote Vault

New vault:

```bash
ob sync-create-remote --name "Hermes Vault"
```

Existing vault:

```bash
ob sync-list-remote
```

Copy the Vault ID.

### Configure The VPS Vault Folder

```bash
mkdir -p /root/HermesVault
cd /root/HermesVault
ob sync-setup --vault "YOUR_VAULT_ID"
```

Expected output must include:

```text
Location: /root/HermesVault
```

If it says `/root`, fix before continuing:

```bash
cd /root/HermesVault
ob sync-setup --vault "YOUR_VAULT_ID"
rm -rf /root/.obsidian
```

### Confirm One-Off Sync

```bash
ob sync --path /root/HermesVault
```

Look for a clean sync result.

### Install Continuous Sync

```bash
bash scripts/install_obsidian_sync_service.sh /root/HermesVault
```

Verify:

```bash
systemctl is-active obsidian-sync
systemctl is-enabled obsidian-sync
journalctl -u obsidian-sync -n 20
```

### Configure Hermes

```bash
nano ~/.hermes/.env
```

Add:

```bash
OBSIDIAN_VAULT_PATH=/root/HermesVault
```

Restart the Hermes process or gateway. Then confirm the Obsidian skill is available:

```bash
hermes skills list
```

## Mac Setup

On the Mac:

1. Install Obsidian.
2. Sign into the same Obsidian account.
3. Enable the Sync core plugin.
4. Open the same remote vault.
5. Wait for initial sync to finish.

## End-To-End Test

1. Send a messy note to Hermes through Telegram and ask it to save the note.
2. Confirm a Markdown file appears in `/root/HermesVault`.
3. Confirm it appears in Obsidian on the Mac.
4. Create a note on the Mac.
5. Confirm it appears on the VPS:

```bash
ls -la /root/HermesVault
```

The setup is complete only when both directions work.
