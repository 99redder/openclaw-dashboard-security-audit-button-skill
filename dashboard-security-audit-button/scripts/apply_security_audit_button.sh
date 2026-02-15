#!/usr/bin/env bash
set -euo pipefail

CUSTOM_DIR="${OPENCLAW_CUSTOM_DIR:-$HOME/.openclaw/workspace/openclaw-custom}"

if [[ ! -d "$CUSTOM_DIR" ]]; then
  echo "Missing openclaw-custom directory: $CUSTOM_DIR" >&2
  exit 1
fi

JS_FILE="$(ls -1 "$CUSTOM_DIR"/index-*.js 2>/dev/null | head -n1 || true)"
CSS_FILE="$(ls -1 "$CUSTOM_DIR"/index-*.css 2>/dev/null | head -n1 || true)"
if [[ -z "$JS_FILE" || -z "$CSS_FILE" ]]; then
  echo "Could not find index-*.js or index-*.css in $CUSTOM_DIR" >&2
  exit 1
fi

python3 - "$JS_FILE" <<'PY'
from pathlib import Path
import sys

p=Path(sys.argv[1])
s=p.read_text()

# 1) Ensure button markup exists and has status text/class logic
if 'security-audit-btn' not in s:
    old='<button class="btn btn--sm backup-now-btn" @click=${()=>e.handlePlannerExportBackup()}>Backup now</button>'
    new='<button class="btn btn--sm security-audit-btn ${e.securityAuditError?"is-error":e.securityAuditResult==="posted"?"is-posted":e.securityAuditResult==="complete"?"is-complete":e.securityAuditLoading?"is-running":e.securityAuditResult?"is-success":""}" @click=${()=>e.handleSecurityAuditDeep()}>${e.securityAuditResult==="complete"?"Audit Complete":e.securityAuditResult==="posted"?"Posting to Chat":e.securityAuditLoading?"Running…":"Security Audit"}</button>\n            <button class="btn btn--sm backup-now-btn" @click=${()=>e.handlePlannerExportBackup()}>Backup now</button>'
    if old not in s:
        raise SystemExit('Could not place Security Audit button near Backup now')
    s=s.replace(old,new,1)

# 2) Add state fields in constructor if missing
needle='this.plannerLookAheadOpen=!1,this.plannerLookAheadDays=7,this.plannerRescheduleTodoId=null,'
insert='this.plannerLookAheadOpen=!1,this.plannerLookAheadDays=7,this.plannerRescheduleTodoId=null,this.securityAuditLoading=!1,this.securityAuditResult="",this.securityAuditError=null,'
if 'this.securityAuditLoading=!1' not in s:
    if needle not in s:
        raise SystemExit('Could not insert security audit state fields')
    s=s.replace(needle,insert,1)

# 3) Add reactive decorators if missing
if '"securityAuditLoading"' not in s:
    old='x([w()],y.prototype,"plannerRescheduleTodoId",2);x([w()],y.prototype,"githubRepos",2);'
    new='x([w()],y.prototype,"plannerRescheduleTodoId",2);x([w()],y.prototype,"securityAuditLoading",2);x([w()],y.prototype,"securityAuditResult",2);x([w()],y.prototype,"securityAuditError",2);x([w()],y.prototype,"githubRepos",2);'
    if old not in s:
        raise SystemExit('Could not insert security audit decorators')
    s=s.replace(old,new,1)

# 4) Add handler method if missing
if 'async handleSecurityAuditDeep()' not in s:
    anchor='handlePlannerToggleLookAheadDays(){this.plannerLookAheadDays=this.plannerLookAheadDays===7?14:this.plannerLookAheadDays===14?30:7}'
    method='async handleSecurityAuditDeep(){if(!this.client||!this.connected||this.securityAuditLoading)return;this.securityAuditLoading=!0,this.securityAuditError=null,this.securityAuditResult="";const e=Date.now();try{await this.client.request("chat.send",{sessionKey:this.sessionKey,message:"Run `openclaw security audit --deep` on the host. Return the raw terminal output in plain text. If it fails, return the exact error output.",deliver:!1,idempotencyKey:`security-audit-${e}`});const t=Date.now()-e;t<1200&&await new Promise(n=>setTimeout(n,1200-t)),this.securityAuditLoading=!1,this.securityAuditResult="posted",setTimeout(()=>{this.securityAuditResult="complete",setTimeout(()=>{this.securityAuditResult="",this.securityAuditError=null},3e3)},4e3)}catch(t){this.securityAuditLoading=!1,this.securityAuditError=`Failed to run audit: ${String(t)}`,setTimeout(()=>{this.securityAuditResult="",this.securityAuditError=null},3e3)}}'
    if anchor not in s:
        raise SystemExit('Could not insert handleSecurityAuditDeep method')
    s=s.replace(anchor,anchor+method,1)

p.write_text(s)
print(f'Patched JS: {p}')
PY

python3 - "$CSS_FILE" <<'PY'
from pathlib import Path
import sys

p=Path(sys.argv[1])
s=p.read_text()
block='''.security-audit-btn.is-posted{animation:securityAuditPostedBlink .5s steps(1,end) 8}
.security-audit-btn.is-complete{animation:securityAuditCompleteBlink .5s steps(1,end) 6}
@keyframes securityAuditPostedBlink{0%,100%{opacity:1}50%{opacity:.35}}
@keyframes securityAuditCompleteBlink{0%,100%{opacity:1}50%{opacity:.35}}
'''
if '.security-audit-btn.is-posted' not in s:
    s += '\n' + block
    p.write_text(s)
print(f'Patched CSS: {p}')
PY

if command -v node >/dev/null 2>&1; then
  node --check "$JS_FILE"
fi

if [[ -x "$CUSTOM_DIR/reapply-dashboard-customizations.sh" ]]; then
  "$CUSTOM_DIR/reapply-dashboard-customizations.sh"
  echo "Reapplied dashboard customizations. Hard refresh your browser (Cmd+Shift+R)."
else
  echo "Patch complete. Reapply script not found at: $CUSTOM_DIR/reapply-dashboard-customizations.sh"
fi

echo "Note: This skill does not enforce custom colors/styles. You can style .security-audit-btn however you want in your dashboard CSS."