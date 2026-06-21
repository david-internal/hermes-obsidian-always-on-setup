# Video /goal: Syncthing Vault Sync

Use this in a fresh branch or worktree when you want Codex to add a Syncthing-based sync path to the Hermes + Obsidian setup.

Paste the block below after `/goal`.

```markdown
**Objective:** Add an optional Syncthing-based vault sync path to this Hermes + Obsidian setup so a VPS and Mac can keep the same vault folder synchronized without requiring Obsidian Sync.
**Read first:** `README.md`, `copy-paste-setup-plan.md`, `skills/hermes-obsidian-setup/SKILL.md`, `skills/hermes-obsidian-setup/references/full-setup-runbook.md`, `skills/hermes-obsidian-setup/references/troubleshooting.md`, `https://github.com/syncthing/syncthing`
**Constraints:** Keep the existing Obsidian Sync setup working as the default path; add Syncthing as an optional alternative; do not include real device IDs, API keys, IPs, passwords, or private vault data; do not refactor unrelated docs/scripts; no new project dependencies; do not delete, skip, weaken, or narrow validation.
**Validate:** `bash -n skills/hermes-obsidian-setup/scripts/*.sh && rg -n "Syncthing|syncthing|OBSIDIAN_VAULT_PATH|HermesVault" README.md copy-paste-setup-plan.md skills/hermes-obsidian-setup`
**Checkpoints:** work in checkpoints and briefly log: repo/source scan, documentation changes, script/service changes, validation results
**Stop when:** the README/setup plan/runbook/troubleshooting docs include a clear optional Syncthing path, any added scripts pass shell syntax checks, the existing Obsidian Sync path still remains intact, and validation passes, OR when setup choices require a real device ID, private network details, or human confirmation.
```
