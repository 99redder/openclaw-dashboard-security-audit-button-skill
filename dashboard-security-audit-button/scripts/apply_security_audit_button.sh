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

# 1) Ensure button markup exists and has status text logic
if 'security-audit-btn' not in s:
    old='<button class="btn btn--sm backup-now-btn" @click=${()=>e.handlePlannerExportBackup()}>Backup now</button>'
    new='<button class="btn btn--sm security-audit-btn ${e.securityAuditLoading?"is-running":e.securityAuditError?"is-error":e.securityAuditResult?"is-success":""}" @click=${()=>e.handleSecurityAuditDeep()}>${e.securityAuditLoading?"Running…":e.securityAuditResult==="posted"?"Posted to Chat":e.securityAuditResult==="posting"?"Posting to Chat":"Security Audit"}</button>\n            <button class="btn btn--sm backup-now-btn" @click=${()=>e.handlePlannerExportBackup()}>Backup now</button>'
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
    method='async handleSecurityAuditDeep(){if(!this.client||!this.connected||this.securityAuditLoading)return;this.securityAuditLoading=!0,this.securityAuditError=null,this.securityAuditResult="";const e=Date.now();try{await this.client.request("chat.send",{sessionKey:this.sessionKey,message:"Run `openclaw security audit --deep` on the host. Return the raw terminal output in plain text. If it fails, return the exact error output.",deliver:!1,idempotencyKey:`security-audit-${e}`}),this.securityAuditResult="posting";const t=Date.now()+18e4;let n="";for(;Date.now()<t&&!n;){const s=await this.client.request("chat.history",{sessionKey:this.sessionKey,limit:40}),i=Array.isArray(s?.messages)?s.messages:[],a=i.filter(l=>l?.role==="assistant"&&Number(l?.timestamp||0)>=e);if(a.length>0){const l=a[a.length-1]?.content,c=Array.isArray(l)?l.map(u=>typeof u?.text==="string"?u.text:typeof u==="string"?u:"").filter(Boolean).join("\\n\\n"):typeof l==="string"?l:"";n=(c||"").trim(),this.securityAuditResult="posted";break}await new Promise(l=>setTimeout(l,2e3))}}catch(t){this.securityAuditError=`Failed to run audit: ${String(t)}`}finally{this.securityAuditLoading=!1,setTimeout(()=>{this.securityAuditResult="",this.securityAuditError=null},2200)}}'
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
block='''.security-audit-btn{background:#ff2bd6!important;border-color:#ff2bd6!important;color:#000!important}
.security-audit-btn:hover{background:#ff6fe7!important;border-color:#ff6fe7!important;color:#000!important}
'''
if '.security-audit-btn{' not in s:
    if '.backup-now-btn{' in s:
        s=s.replace('.backup-now-btn{', block + '.backup-now-btn{', 1)
    else:
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
