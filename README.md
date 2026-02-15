# dashboard-security-audit-button

Reusable OpenClaw skill + patch script for adding a **Security Audit** button to the Gateway Dashboard.

## What it does

- Adds topbar **Security Audit** button (left of Backup now)
- Runs chat-driven `openclaw security audit --deep`
- Button states: `Running…` → `Posting to Chat` → `Posted to Chat` → `Security Audit`
- Neon pink button styling with black text

## Skill package

- `dist/dashboard-security-audit-button.skill`

## Source skill

- `dashboard-security-audit-button/SKILL.md`
- `dashboard-security-audit-button/scripts/apply_security_audit_button.sh`

## Apply manually

Run:

`dashboard-security-audit-button/scripts/apply_security_audit_button.sh`

Then hard refresh dashboard (`Cmd+Shift+R`).
