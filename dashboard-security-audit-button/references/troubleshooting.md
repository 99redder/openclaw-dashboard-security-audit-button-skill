# Troubleshooting

## Button does not appear

- Run the apply script again.
- Confirm hard refresh (`Cmd+Shift+R`).
- Confirm the patch hit the active bundle via your reapply script output.

## Button appears but no chat output

- Verify gateway is connected in dashboard.
- Check browser console for RPC errors.
- Manually run `openclaw security audit --deep` in terminal to confirm command works.

## Text/state not updating as expected

- Upstream minified bundle changed; update matcher strings in `scripts/apply_security_audit_button.sh`.
