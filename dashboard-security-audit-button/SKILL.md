---
name: dashboard-security-audit-button
description: Add or update a Gateway Dashboard topbar "Security Audit" button that runs `openclaw security audit --deep`, posts results to chat, and shows button-state feedback (Running → Posting to Chat → Posted to Chat). Use when customizing OpenClaw Control UI bundles under `~/.openclaw/workspace/openclaw-custom` and reapplying changes to hashed dashboard assets after updates.
---

# Dashboard Security Audit Button

Apply a reusable patch for the OpenClaw dashboard that adds a chat-driven Security Audit button with visible status transitions.

## Quick workflow

1. Run `scripts/apply_security_audit_button.sh`.
2. Hard refresh the dashboard (`Cmd+Shift+R`).
3. Click **Security Audit** and verify this flow:
   - `Running…`
   - `Posting to Chat`
   - `Posted to Chat`
   - `Security Audit`

## What this patch changes

- Adds a topbar **Security Audit** button (left of Backup now).
- Uses command text:
  - `Run \`openclaw security audit --deep\` on the host. Return the raw terminal output in plain text. If it fails, return the exact error output.`
- Keeps results in chat (no modal).
- Adds neon pink button styling with black text.

## Files touched

- `~/.openclaw/workspace/openclaw-custom/index-*.js`
- `~/.openclaw/workspace/openclaw-custom/index-*.css`
- Runs `~/.openclaw/workspace/openclaw-custom/reapply-dashboard-customizations.sh` (if present)

## Notes

- This is a bundle patch; if upstream minified code shape changes, rerun and adjust script matching.
- Keep this skill as the reusable source of truth, not one-off manual edits.
