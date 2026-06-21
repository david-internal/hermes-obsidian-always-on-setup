# Troubleshooting

## `ob login` says "Server overloaded"

Likely causes:

- Obsidian Sync is not active on the account.
- The user logged into a different Obsidian account on the web than on the VPS.
- A browser login is required before the CLI login succeeds.

Fix:

1. Log into `obsidian.md` in a browser.
2. Confirm Sync is active for that account.
3. Retry `ob login`.

## `ob: command not found`

Cause: npm's global binary path is not on `PATH`.

Fix:

```bash
export PATH="$(npm prefix -g)/bin:$PATH"
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## `ob sync-list-remote` shows no vaults

Likely causes:

- No remote vault exists yet.
- The user is logged into the wrong account.
- The vault is shared with a different account.

Fix:

```bash
ob sync-create-remote --name "Hermes Vault"
```

Or create/enable Sync for the vault on the Mac, then retry.

## Notes Save On The VPS But Do Not Appear On The Mac

Check these in order:

1. `OBSIDIAN_VAULT_PATH` equals the folder used for `ob sync-setup`.
2. `systemctl is-active obsidian-sync` returns `active`.
3. `journalctl -u obsidian-sync -n 50` does not show repeated login or path errors.
4. The Mac is signed into the same Obsidian Sync account.
5. The Mac opened the same remote vault.

## The Service Dies After SSH Closes

Running this manually is not enough:

```bash
ob sync --continuous
```

It runs in the foreground and exits when the SSH session ends. Install the systemd service instead:

```bash
bash scripts/install_obsidian_sync_service.sh /root/HermesVault
```

## The Whole `/root` Folder Became The Vault

Cause: `ob sync-setup` was run from `/root`.

Fix:

```bash
mkdir -p /root/HermesVault
cd /root/HermesVault
ob sync-setup --vault "YOUR_VAULT_ID"
rm -rf /root/.obsidian
```

Then verify the setup output says:

```text
Location: /root/HermesVault
```

## Hermes Creates Notes In The Wrong Folder

Cause: `OBSIDIAN_VAULT_PATH` is missing or points somewhere else.

Fix:

```bash
nano ~/.hermes/.env
```

Set:

```bash
OBSIDIAN_VAULT_PATH=/root/HermesVault
```

Restart Hermes.
