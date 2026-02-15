# dashboard-security-audit-button

Reusable OpenClaw skill + patch script for adding a **Security Audit** button to the Gateway Dashboard.

## What it does

- Adds topbar **Security Audit** button (left of Backup now)
- Runs chat-driven `openclaw security audit --deep`
- Button states: `Running…` → `Posting to Chat` (blinks 4s) → `Audit Complete` (blinks 3s) → `Security Audit`
- Uses default dashboard button styling (customize however you want)
- You can fully style `.security-audit-btn` later in your own CSS/theme

## Quick setup

1. Make sure OpenClaw is installed and the Gateway dashboard is already working.
2. Clone your copy of this repo (or download ZIP from GitHub).
3. Enter the repo:
   - `cd openclaw-dashboard-security-audit-button-skill`
4. Run the patch script:
   - `./dashboard-security-audit-button/scripts/apply_security_audit_button.sh`
5. Hard refresh dashboard:
   - `Cmd+Shift+R` (macOS) or `Ctrl+Shift+R` (Windows/Linux)

## Verify

Click **Security Audit** and confirm this sequence:

- `Running…`
- `Posting to Chat` (blinks 4s)
- `Audit Complete` (blinks 3s)
- back to `Security Audit`

Then confirm audit output appears in chat.

## If their openclaw-custom path is different

Run with path override:

`OPENCLAW_CUSTOM_DIR=/path/to/openclaw-custom ./dashboard-security-audit-button/scripts/apply_security_audit_button.sh`

## Security notes

- No telemetry or external network calls are added by this patch script.
- No credential harvesting or token export logic is included.
- The script only patches local dashboard bundle files and runs local OpenClaw commands.
- Review the script before running in your environment (recommended for all patch tooling).

## Skill package

- `dist/dashboard-security-audit-button.skill`

## Source skill

- `dashboard-security-audit-button/SKILL.md`
- `dashboard-security-audit-button/scripts/apply_security_audit_button.sh`
- `dashboard-security-audit-button/references/troubleshooting.md`
