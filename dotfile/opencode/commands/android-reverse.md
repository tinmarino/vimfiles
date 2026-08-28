---
description: "Systematic reverse engineering — builds attack surface map, tracks findings, queues hunter tasks"
---

# android-reverse — Systematic Analysis & Task Generation

Methodically analyzes APK findings, builds attack surface map, documents vulnerabilities, queues derived hunter tasks.

## When to Use

- After static OR dynamic analysis completes
- Need to build attack surface inventory
- Converting raw findings into testable hypotheses
- ALWAYS invoked by `android-master` (final phase)

## Prerequisites

**MUST HAVE**:
- `Findings/APK-analysis/secrets.json` (from static analysis)
- `Findings/APK-analysis/decompiled/` (decompiled code)

**OPTIONAL** (from dynamic):
- `Findings/APK-analysis/runtime-secrets.log`
- `Findings/APK-analysis/frida-auth-output.log`

## Arguments

```bash
Skill(skill="android-reverse", args="com.target.app")
```

## Workflow

### Step 1: Consolidate All Findings

```bash
cd Findings/APK-analysis/

# Merge static + dynamic secrets
cat secrets.json | jq . > consolidated-secrets.json

# If dynamic ran, add runtime findings
if [ -f runtime-secrets.log ]; then
  # Extract OAuth tokens from logs
  grep -oP 'access_token["\s:=]+\K[a-zA-Z0-9._-]+' runtime-secrets.log >> runtime-oauth.txt
  grep -oP 'bearer["\s:=]+\K[a-zA-Z0-9._-]+' runtime-secrets.log >> runtime-bearer.txt
  
  # Extract client_id/secret from logs
  grep -oP 'client_id["\s:=]+\K[a-zA-Z0-9._-]+' runtime-secrets.log >> runtime-client-id.txt
  grep -oP 'client_secret["\s:=]+\K[a-zA-Z0-9._-]+' runtime-secrets.log >> runtime-client-secret.txt
fi
```

### Step 2: Build Attack Surface Map

```bash
cat > Findings/APK-analysis/attack-surface.md << 'ATTACK_SURFACE'
# Attack Surface Map - com.target.app

## Last Updated: $(date -I)

---

## 1. OAuth/Authentication Flow

**Endpoint**: [extracted from secrets.json or logs]  
**Client ID**: [if found]  
**Client Secret**: [if found, or "NONE - uses PKCE"]  
**Redirect URI**: [from manifest deeplinks]  
**PKCE**: [YES/NO - check if code_challenge present]  
**State Parameter**: [YES/NO - check auth flow]

**Status**: 
- ✅ client_id found → Can authenticate to mobile APIs
- ⚠️ No PKCE → Code interception attack possible
- ⚠️ Redirect URI uses custom scheme → Test for hijacking

**Test Tasks**:
- Q### (EV 250): OAuth code interception via deeplink hijacking
- Q### (EV 200): Test redirect_uri validation (whitelist bypass)
- Q### (EV 150): PKCE bypass attempts

---

## 2. Mobile-Only API Endpoints

Endpoints found ONLY in APK (not in web app):

1. **[Endpoint 1]**: https://api.target.com/mobile/v1/user  
   - **Auth**: Requires Bearer token OR hardcoded API key: "xyz..."
   - **Methods**: GET, POST
   - **Status**: ⚠️ Test for IDOR on /user/{userId}
   - **Task**: Q### (EV 200) - IDOR testing with mobile API key

2. **[Endpoint 2]**: https://api-staging.target.com/...  
   - **Auth**: Same as prod
   - **Status**: 🔥 Staging endpoint → Potential subdomain takeover
   - **Task**: Q### (EV 180) - DNS takeover check

3. **[Continue for all endpoints...]**

---

## 3. Hardcoded API Keys / Secrets

| Secret Type | Value (first 8 chars) | Location | Risk | Task |
|-------------|----------------------|----------|------|------|
| API Key | "abc12345..." | BuildConfig.java:42 | MEDIUM | Q### - IDOR with key |
| AWS Access Key | NONE | - | - | - |
| Firebase API Key | "AIzaSy..." | google-services.json | LOW (public) | - |
| Staging URL | api-staging.* | ApiClient.java:120 | HIGH | Q### - Takeover |

---

## 4. Exported Android Components (Intent Injection)

### 4.1 Exported Activities

1. **LoginActivity** (exported=true)  
   - **Deeplink**: dktappmobile://auth  
   - **Parameters**: `?redirect=`, `?token=`  
   - **Risk**: ⚠️ redirect parameter may allow open redirect → token theft
   - **Task**: Q### (EV 150) - Deeplink parameter injection

2. **CheckoutActivity** (exported=true)  
   - **Deeplink**: dktappmobile://checkout  
   - **Parameters**: `?order_id=`, `?amount=`  
   - **Risk**: 🔥 amount parameter manipulation → price bypass
   - **Task**: Q### (EV 180) - Checkout price manipulation via Intent

### 4.2 Exported Services

[List each exported service with risk assessment]

### 4.3 Exported Receivers

[List broadcast receivers that accept external Intents]

---

## 5. No Rate Limiting Discovered

**Login Endpoint**: POST https://api.target.com/auth/login  
**Tested**: 50 requests, 0 rate limit responses  
**Status**: 🔥 CRITICAL - Credential stuffing viable  
**Evidence**: Findings/APK-analysis/rate-limit-test.log

**Test Tasks**:
- Q### (EV 220): Credential stuffing attack (if test data available)
- Q### (EV 180): Account enumeration via login timing

---

## 6. Certificate Pinning

**Status**: ENABLED (OkHttp3 CertificatePinner detected)  
**Bypassed**: ✅ YES (via Frida - see frida-auth-output.log)  
**Impact**: MITM possible after Frida bypass

---

## 7. Permissions Analysis

**Dangerous Permissions**:
- `ACCESS_FINE_LOCATION` - GPS tracking
- `CAMERA` - Photo capture
- `READ_EXTERNAL_STORAGE` - File access

**Implications**:
- Location permission → Test for location spoofing attacks
- Camera → Test for photo injection via malicious app

---

## 8. Network Security Config

**Status**: [Found/Not Found]  
**Cleartext Traffic**: [Allowed/Blocked]  
**User-Added CAs**: [Trusted/Not Trusted]

If cleartext allowed → Test for downgrade attacks

---

ATTACK_SURFACE
```

### Step 3: Queue Derived Hunter Tasks

For EVERY finding, queue a hunter task with huntq:

```bash
cd ~/Pawn/Platform/ClientName  # Or current engagement root

# OAuth findings
if grep -q "client_id" Findings/APK-analysis/consolidated-secrets.json; then
  python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root . add \
    --ev 250 --cls broken-auth \
    --target "OAuth flow with extracted client_id" \
    --hypo "Use client_id from APK to authenticate to mobile APIs → IDOR testing"
fi

# Hardcoded API keys
API_KEY=$(jq -r '.hardcoded_secrets[] | select(.name | contains("api")) | .value' Findings/APK-analysis/secrets.json | head -1)
if [ -n "$API_KEY" ]; then
  python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root . add \
    --ev 200 --cls idor \
    --target "Mobile endpoints with hardcoded API key" \
    --hypo "API key: ${API_KEY:0:12}... → IDOR on /api/user/{userId}"
fi

# Staging URLs
grep -i "staging\|dev\|test" Findings/APK-analysis/endpoints_manual.txt | while read URL; do
  python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root . add \
    --ev 180 --cls recon \
    --target "$URL" \
    --hypo "Staging endpoint → DNS takeover check, weaker auth, debug features"
done

# Exported components
jq -r '.exported_components.activities[] | .name' Findings/APK-analysis/secrets.json | while read ACTIVITY; do
  python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root . add \
    --ev 150 --cls mobile \
    --target "Exported activity: $ACTIVITY" \
    --hypo "Intent injection → parameter tampering, redirect hijacking"
done

# No rate limiting
if [ -f Findings/APK-analysis/rate-limit-test.log ] && ! grep -q "429" Findings/APK-analysis/rate-limit-test.log; then
  python3 ~/.claude/skills/hunt-hunter/bin/huntq.py --root . add \
    --ev 220 --cls broken-auth \
    --target "Login endpoint (no rate limit)" \
    --hypo "50 login attempts, 0 rate limit → credential stuffing viable"
fi

echo "✅ Derived tasks queued to hunt/QUEUE.md"
```

### Step 4: Update Analysis Log (Findings Persistence)

```bash
# Append to analysis log (never overwrite - track progress across sessions)
cat >> Findings/APK-analysis/analysis-log.md << LOG

---

## Session: $(date -Iseconds)

### Consolidated Findings

**OAuth Credentials**:
$(jq -r '.oauth_credentials[] | "- \(.type): \(.value[0:20])..."' Findings/APK-analysis/consolidated-secrets.json 2>/dev/null || echo "NONE")

**Hardcoded API Keys**:
$(jq -r '.hardcoded_secrets[] | select(.name | contains("key") or contains("api")) | "- \(.name): \(.value[0:16])... (source: \(.source))"' Findings/APK-analysis/secrets.json 2>/dev/null | head -5)

**High-Value Endpoints**:
$(grep -E "staging|admin|internal|debug" Findings/APK-analysis/endpoints_manual.txt 2>/dev/null | head -5 || echo "NONE")

### Derived Tasks Queued

Total tasks added: $(grep -c "^Q" hunt/QUEUE.md)

**Breakdown by class**:
- broken-auth: $(grep "broken-auth" hunt/QUEUE.md | wc -l)
- idor: $(grep "idor" hunt/QUEUE.md | wc -l)
- mobile: $(grep "mobile" hunt/QUEUE.md | wc -l)
- recon: $(grep "recon" hunt/QUEUE.md | wc -l)

### Next Steps

1. ✅ Attack surface map complete → Findings/APK-analysis/attack-surface.md
2. ✅ Derived tasks queued → hunt/QUEUE.md
3. ⏳ Hunters will claim tasks automatically
4. 📊 Expected findings: 3-5 HIGH/CRITICAL from mobile-specific vulnerabilities

LOG
```

### Step 5: Summary Report

```bash
cat << SUMMARY

═══════════════════════════════════════════════════════════
APK Reverse Engineering Complete - com.target.app
═══════════════════════════════════════════════════════════

✅ OUTPUTS:
  - Attack surface map: Findings/APK-analysis/attack-surface.md
  - Analysis log: Findings/APK-analysis/analysis-log.md
  - Secrets inventory: Findings/APK-analysis/consolidated-secrets.json

✅ FINDINGS:
  - OAuth credentials: $(jq -r '.oauth_credentials | length' Findings/APK-analysis/secrets.json)
  - Hardcoded API keys: $(jq -r '.hardcoded_secrets | length' Findings/APK-analysis/secrets.json)
  - Mobile-only endpoints: $(cat Findings/APK-analysis/endpoints_manual.txt 2>/dev/null | wc -l)
  - Exported components: $(jq -r '(.exported_components.activities + .exported_components.services + .exported_components.receivers) | length' Findings/APK-analysis/secrets.json)

✅ DERIVED TASKS:
  - Total queued: $(grep -c "^Q" hunt/QUEUE.md)
  - High-value (EV >150): $(awk -F'|' '\$3 > 150 {count++} END {print count}' hunt/QUEUE.md)

🎯 EXPECTED ROI:
  - Typical findings from mobile analysis: 3-5 HIGH/CRITICAL
  - Vulnerability classes: IDOR, broken auth, Intent injection, staging takeover
  - Money multiplier: 3-5x vs web-only testing

📋 NEXT:
  - Hunters will automatically claim and test queued tasks
  - Monitor: hunt/LOOP.md for results
  - Update attack surface map as new findings confirmed

═══════════════════════════════════════════════════════════

SUMMARY
```

## Outputs

**Attack Surface Map**: `Findings/APK-analysis/attack-surface.md`  
Comprehensive vulnerability inventory with:
- OAuth flow analysis (PKCE, redirect_uri, state)
- Mobile-only API endpoints
- Hardcoded secrets with risk ratings
- Exported components with attack vectors
- Rate limiting assessment
- Certificate pinning status

**Analysis Log**: `Findings/APK-analysis/analysis-log.md`  
Session-by-session reverse engineering notes:
- Offsets studied in decompiled code
- Secrets discovered per session
- Derived tasks queued
- Progress tracking across multiple sessions

**Consolidated Secrets**: `Findings/APK-analysis/consolidated-secrets.json`  
Merged static + dynamic findings

**Hunter Tasks**: `hunt/QUEUE.md`  
Automatically queued tasks for:
- OAuth flow testing
- IDOR with mobile API keys
- Staging endpoint takeover
- Exported component exploitation
- Rate limit bypass (credential stuffing)

## Verification

```bash
# Confirm attack surface map created
test -f Findings/APK-analysis/attack-surface.md && echo "✅ Attack surface mapped"

# Confirm tasks queued
TASK_COUNT=$(grep -c "^Q" hunt/QUEUE.md 2>/dev/null || echo 0)
echo "✅ Tasks queued: $TASK_COUNT"

# Confirm analysis log updated
tail -20 Findings/APK-analysis/analysis-log.md
```

## Integration

Final phase of `android-master`. Always runs after static OR dynamic.

Standalone:
```bash
Skill(skill="android-reverse", args="com.decathlon.app")
```

## Composes With

**Before**: `android-static` (provides secrets) AND/OR `android-dynamic` (provides runtime secrets)  
**After**: Hunters automatically test queued tasks  
**Updates**: `hunt/LOOP.md` (as hunters complete tasks)

## Methodology: Findings Persistence

**Key principle**: NEVER lose reverse engineering progress

1. **analysis-log.md** = append-only (never overwrite)
2. **Offset comments** = document what code paths already studied
3. **Session timestamps** = track when each secret discovered
4. **attack-surface.md** = living document (update as hunters confirm/refute hypotheses)

**Between waves**:
- Re-read analysis-log.md to avoid re-analyzing same classes
- Update attack-surface.md status when hunters return SAFE/VULN verdicts
- Add new offsets when new code paths discovered

## Tools Used

- `jq` - JSON parsing
- `grep` - Secret extraction
- `huntq.py` - Task queue management
- Engagement-specific: `hunt/QUEUE.md`, `hunt/LOOP.md`
