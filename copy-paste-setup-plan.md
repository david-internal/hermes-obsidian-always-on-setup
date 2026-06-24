# Copy-Paste Setup Plan

Use this when you want the practical setup from the video. Run commands on the VPS unless a step says Mac.

The goal is simple: Hermes writes notes into one VPS folder, `obsidian-headless` syncs that folder through Obsidian Sync, and the same vault appears on your Mac.

## 1. Connect To The VPS

```bash
ssh root@YOUR_VPS_IP
```

Need to confirm the SSH port after you are connected?

```bash
ss -tlnp | grep ssh
```

If you connected with plain `ssh root@YOUR_VPS_IP` and no `-p`, you are probably using the default SSH port, `22`. The `ss` command shows what the daemon is actually listening on. Look at the number after the colon, for example `0.0.0.0:22`.

## 2. Install Hermes Agent

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes setup
```

Pick your model provider during `hermes setup`. The video path used OpenRouter.

## 3. Prepare Obsidian Sync On Your Mac

On the Mac:

1. Download Obsidian from `https://obsidian.md/`.
2. Install it.
3. Create or open a vault.
4. Go to Settings -> Core plugins.
5. Turn on Sync.
6. Sign in to your Obsidian account.

Important: Obsidian Sync is a paid subscription. The account you use on both the Mac and the VPS must have active Sync access, or it must own or be shared into the remote vault. Confirm this in your account settings on `obsidian.md` before debugging the CLI.

## 4. Install Node 22, obsidian-headless, And Log In

Ubuntu's default `apt install npm` path often installs Node 18. `obsidian-headless` needs Node 22 or newer, so use NodeSource.

This one command installs Node 22, installs `obsidian-headless`, then starts the Obsidian login:

```bash
apt update && apt install -y curl && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs && npm install -g obsidian-headless && ob login
```

`ob login` asks for your Obsidian email, password, and 2FA if enabled.

Gotcha: if an agent or tutorial suggests `apt install npm`, do not use that path for this setup. It commonly leaves you on the wrong Node version.

If `ob login` says `Server overloaded, please try again later`, it may not be real load. It can be the generic failure when the account does not have active Obsidian Sync. Log into `obsidian.md` in a browser, confirm Sync is active on that account, then retry:

```bash
ob login
```

If `ob` is not found after install, npm's global bin is probably missing from `PATH`:

```bash
export PATH="$(npm prefix -g)/bin:$PATH"
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 5. Create Or Select The Remote Vault

Create a new Obsidian Sync remote vault:

```bash
ob sync-create-remote --name "Hermes Vault"
```

When it asks for an end-to-end encryption password, press Enter if you want standard encryption. It prints a Vault ID. Copy that ID.

Example Vault ID:

```text
917d8a0492fac011a8f633bb7fb7622e
```

If you already have a remote vault, list the remote vaults and copy the right Vault ID:

```bash
ob sync-list-remote
```

Gotcha: if `ob sync-list-remote` shows no vaults, the remote vault may not exist yet, or you may be logged into the wrong account. Create it with `ob sync-create-remote`, or turn on Sync for the vault on your Mac first, then retry.

## 6. Create A Dedicated VPS Folder First

This is the most important gotcha: `ob sync-setup` configures the folder you are currently standing in as the vault.

Do not run it from `/root`, or your whole root home folder becomes the vault.

```bash
mkdir -p /root/HermesVault
cd /root/HermesVault
ob sync-setup --vault "YOUR_VAULT_ID"
```

The output must say:

```text
Location: /root/HermesVault
```

If it says `Location: /root`, fix it before continuing:

```bash
mkdir -p /root/HermesVault
cd /root/HermesVault
ob sync-setup --vault "YOUR_VAULT_ID"
rm -rf /root/.obsidian
```

`OBSIDIAN_VAULT_PATH`, the systemd service, and `ob sync-setup` must all point to this same folder.

## 7. Test One Sync Manually

Run a one-off sync:

```bash
ob sync --path /root/HermesVault
```

You want a clean result, usually ending with something like `Fully synced`.

## 8. Make Sync Run Automatically And Forever

Do not rely on a bare continuous sync command:

```bash
ob sync --continuous
```

That runs in the foreground and dies when your SSH session closes. Install it as a systemd service so it survives disconnects and reboots.

If you cloned this repo, you can use the included installer:

```bash
bash skills/hermes-obsidian-setup/scripts/install_obsidian_sync_service.sh /root/HermesVault
```

Or create the service manually:

First confirm where `ob` is installed. The unit below assumes `/usr/bin/ob`; if this prints a different path, use that path in `ExecStart`.

```bash
command -v ob
```

```bash
cat > /etc/systemd/system/obsidian-sync.service <<'EOF'
[Unit]
Description=Obsidian headless continuous sync (HermesVault)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/root/HermesVault
ExecStart=/usr/bin/ob sync --continuous --path /root/HermesVault
Restart=always
RestartSec=5
User=root
Environment=HOME=/root

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start it:

```bash
systemctl daemon-reload && systemctl enable --now obsidian-sync
```

Verify it is live:

```bash
systemctl is-active obsidian-sync
systemctl is-enabled obsidian-sync
journalctl -u obsidian-sync -n 20
```

Expected:

- `systemctl is-active obsidian-sync` returns `active`.
- `systemctl is-enabled obsidian-sync` returns `enabled`.
- The logs end cleanly, ideally with `Fully synced`.

## 9. Point Hermes At The Same Folder

Edit Hermes' environment file:

```bash
nano ~/.hermes/.env
```

Add:

```bash
OBSIDIAN_VAULT_PATH=/root/HermesVault
```

Confirm the Obsidian or note-taking skill is available:

```bash
hermes skills list
```

Restart the Hermes gateway or process so it reloads `.env`.

Gotcha: `OBSIDIAN_VAULT_PATH` must equal the folder you used for `ob sync-setup`. If they differ, Hermes can save notes successfully but those notes will not sync to your Mac. If unset, Hermes may default to a local documents path that does not exist on a VPS.

## 10. Connect The Mac To The Same Remote Vault

On the Mac:

1. Open Obsidian.
2. Make sure Sync is enabled.
3. Sign into the same Obsidian account used by `ob login`.
4. Connect to the same remote vault, for example `Hermes Vault`.
5. Wait for the first sync to finish.

The Mac vault and `/root/HermesVault` should now be the same live vault.

## 11. Test The Full Loop

From Telegram on your phone, send Hermes a messy note, link, or PDF. Ask it to save it to your notes.

Verify:

- Hermes creates a clean Markdown note with a title, useful links, and tags.
- The note appears in `/root/HermesVault` on the VPS.
- `journalctl -u obsidian-sync -n 20` ends cleanly.
- The note appears in Obsidian on your Mac.
- The note looks organized enough to be useful in Obsidian, including graph view after several captures.

Then test the other direction:

1. Create a note on the Mac.
2. Wait for Sync.
3. Check the VPS:

```bash
ls -la /root/HermesVault
```

Seeing Mac-created files appear on the VPS proves the loop works both ways.

You are done only when Hermes-to-Mac and Mac-to-VPS both work.
