---
name: hermes-obsidian-setup
description: Guide a user or agent through setting up Hermes Agent on a VPS with Obsidian Sync, obsidian-headless, a systemd continuous sync service, Telegram capture, and OBSIDIAN_VAULT_PATH. Use when someone wants the always-on Hermes and Obsidian setup from the video, needs copy-paste VPS commands, or needs to avoid sync gotchas.
---

# Hermes Obsidian Setup

## Overview

Guide the user through the exact always-on setup: Hermes runs on the VPS, Obsidian runs on the Mac, and both share one synced vault folder. Keep the focus on a real file loop, not controlling the Obsidian app.

## Operating Principle

Make one folder the source of truth on the VPS, then point both obsidian-headless and Hermes at that same folder.

Default path:

```bash
/root/HermesVault
```

If the user chooses a different path, use that exact same path everywhere.

## Workflow

1. Confirm prerequisites:
   - VPS shell access, preferably root on Ubuntu.
   - Active Obsidian Sync subscription on the same account used on the Mac and VPS.
   - Obsidian installed locally on the Mac.
   - Model provider ready for `hermes setup`.
   - Telegram integration only after the vault loop works.
2. Install Hermes:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes setup
```

3. Install Node 22 and obsidian-headless. Use NodeSource, not Ubuntu's default `npm` package.
4. Log in with `ob login`. If "server overloaded" appears repeatedly, ask the user to confirm the account has active Obsidian Sync in the web UI.
5. Create or select the remote vault.
6. Create the dedicated folder before running `ob sync-setup`:

```bash
mkdir -p /root/HermesVault
cd /root/HermesVault
ob sync-setup --vault "VAULT_ID"
```

7. Verify the setup output says `Location: /root/HermesVault`. If it says `/root`, stop and fix it before doing anything else.
8. Install the continuous sync service:

```bash
bash scripts/install_obsidian_sync_service.sh /root/HermesVault
```

9. Add this to `~/.hermes/.env`:

```bash
OBSIDIAN_VAULT_PATH=/root/HermesVault
```

10. Restart Hermes so it reloads `.env`.
11. Turn on Obsidian Sync on the Mac for the same remote vault.
12. Test both directions:
    - Telegram or Hermes creates a note, then the note appears on the Mac.
    - Mac creates a note, then the note appears in `/root/HermesVault`.

## Guardrails

- Never run `ob sync-setup` from `/root`; it can make the whole home directory the vault.
- Do not claim Obsidian adds agent intelligence by itself. Obsidian adds the human workspace; Hermes does the agent work.
- Do not demo fake "AI controls the app" behavior. Show the shared vault folder and the synced note in Obsidian.
- Do not store API keys, passwords, or private secrets in notes unless the user explicitly accepts that risk.
- Do not continue setup if Obsidian Sync is not active on the account.

## Resources

- Read `references/full-setup-runbook.md` when the user wants the full command-by-command process.
- Read `references/troubleshooting.md` when a command fails or notes do not sync.
- Run `scripts/check_vps_prereqs.sh` on the VPS before setup or while debugging.
- Run `scripts/install_obsidian_sync_service.sh /root/HermesVault` after `ob sync-setup` succeeds.

## Completion Criteria

Finish only when the user can create a note through Hermes or Telegram, see it on the VPS, see it in Obsidian on the Mac, and create a Mac note that appears back on the VPS.
