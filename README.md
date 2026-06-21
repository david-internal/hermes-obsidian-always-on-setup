# Bundle 1: Always-On Setup

This bundle gets the viewer from "I watched the video" to "Hermes is running on a VPS and writing into the same Obsidian vault I use on my Mac."

## Included

- `skills/hermes-obsidian-setup`: an agent skill that guides the full setup.
- `skills/hermes-obsidian-setup/references/full-setup-runbook.md`: the long-form setup path.
- `skills/hermes-obsidian-setup/references/troubleshooting.md`: fixes for the common failure modes from the video notes.
- `skills/hermes-obsidian-setup/scripts/check_vps_prereqs.sh`: checks the VPS before setup.
- `skills/hermes-obsidian-setup/scripts/install_obsidian_sync_service.sh`: installs the continuous sync systemd service.
- `copy-paste-setup-plan.md`: concise viewer-facing command sequence.

## Why It Is Valuable

The hard part is not knowing that Hermes can write Markdown. The hard part is making the always-on VPS, Obsidian Sync, headless client, and Hermes vault path all point at the same folder. This bundle removes those setup traps.

## Recommended Use

1. SSH into the VPS.
2. Run the prerequisite checker.
3. Follow `copy-paste-setup-plan.md`.
4. Use the skill with an agent when the viewer wants guided setup or gets stuck.
5. Use the troubleshooting reference if notes are created but do not appear on the Mac.
