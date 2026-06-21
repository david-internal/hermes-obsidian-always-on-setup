# Copy-Paste Setup Plan

Use this when you want the shortest version of the setup from the video. Run commands on the VPS unless a step says Mac.

## 1. Connect To The VPS

```bash
ssh root@YOUR_VPS_IP
ss -tlnp | grep ssh
```

If you connected without `-p`, the SSH port is probably `22`. The `ss` command confirms what the server is listening on.

## 2. Install Hermes Agent

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes setup
```

Pick your model provider during `hermes setup`. The video notes used OpenRouter.

## 3. Install Node 22, obsidian-headless, And Log In

Do not use Ubuntu's default `apt install npm` path for this. It often installs an old Node version.

```bash
apt update && apt install -y curl && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs && npm install -g obsidian-headless && ob login
```

If `ob` is not found after install:

```bash
export PATH="$(npm prefix -g)/bin:$PATH"
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 4. Create Or Select The Remote Vault

Create a new Obsidian Sync remote vault:

```bash
ob sync-create-remote --name "Hermes Vault"
```

Copy the Vault ID it prints.

If you already have a remote vault:

```bash
ob sync-list-remote
```

## 5. Create A Dedicated VPS Folder First

This is the most important gotcha. Do not run `ob sync-setup` from `/root`.

```bash
mkdir -p /root/HermesVault
cd /root/HermesVault
ob sync-setup --vault "YOUR_VAULT_ID"
```

The output must say `Location: /root/HermesVault`. If it says `Location: /root`, stop and fix it before continuing.

## 6. Start Continuous Sync

From this bundle:

```bash
bash skills/hermes-obsidian-setup/scripts/install_obsidian_sync_service.sh /root/HermesVault
```

Or manually:

```bash
ob sync --path /root/HermesVault
systemctl is-active obsidian-sync
systemctl is-enabled obsidian-sync
journalctl -u obsidian-sync -n 20
```

## 7. Point Hermes At The Same Folder

```bash
nano ~/.hermes/.env
```

Add:

```bash
OBSIDIAN_VAULT_PATH=/root/HermesVault
```

Restart Hermes so it reloads `.env`.

## 8. Connect The Mac

On the Mac:

1. Install Obsidian.
2. Sign into the same Obsidian account.
3. Confirm Obsidian Sync is active.
4. Open or create the same remote vault, `Hermes Vault`.

## 9. Test The Loop

From Telegram, send Hermes a messy note and ask it to save it to your notes.

Verify:

- The note appears in `/root/HermesVault` on the VPS.
- `journalctl -u obsidian-sync -n 20` ends cleanly.
- The note appears in Obsidian on the Mac.
- A note created on the Mac appears on the VPS.
