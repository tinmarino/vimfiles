---
description: "Static APK analysis — decompile, extract secrets, analyze manifest (AUTOMATED)"
---

# android-static — Static Analysis & Secret Extraction

Decompiles APK, extracts OAuth/AWS credentials, analyzes manifest, builds secrets inventory.

## When to Use

- APK downloaded (from `android-download` or manual)
- Need to extract hardcoded credentials
- First-pass analysis before dynamic testing
- Invoked automatically by `android-master`

## Prerequisites

**MUST HAVE**: `Apk/com.target.app.apk` exists

**Tools auto-installed**:
- `jadx` (Java decompiler)
- `apktool` (APK resource extractor)
- Python 3 with `requests`

## Arguments

```bash
Skill(skill="android-static", args="com.target.app")
```

## Workflow

### 1. Run Automated Analysis

```bash
python3 Script/apk_auto_analyze.py Apk/com.target.app.apk

# Creates:
# - Findings/APK-analysis/secrets.json (extracted secrets)
# - Findings/APK-analysis/decompiled/ (jadx output - Java source)
# - Findings/APK-analysis/raw/ (apktool output - resources)
```

### 2. Review Automated Findings

```bash
cat Findings/APK-analysis/secrets.json | jq '
{
  oauth: .oauth_credentials,
  aws: .aws_credentials,
  api_endpoints: (.api_endpoints | length),
  exported_activities: (.exported_components.activities | length),
  deeplinks: (.deeplinks | length)
}'
```

### 3. Manual Deep Dive (CRITICAL - Automation Misses 40-60%)

```bash
cd Findings/APK-analysis/decompiled/sources/

# OAuth credentials (HIGHEST PRIORITY)
grep -r "client_id\|client_secret\|CLIENT_ID" --include="*.java" \
  | grep -v "R.string" \
  | tee ../../oauth_manual_search.txt

# AWS credentials
grep -r "AKIA\|ASIA\|aws_access_key\|secretKey" --include="*.java" \
  | tee ../../aws_manual_search.txt

# API endpoints (mobile-only surface)
grep -rh "https://.*api\|BASE_URL\|API_URL" --include="*.java" \
  | grep -Eo 'https?://[a-zA-Z0-9./?=_-]*' \
  | sort -u \
  | tee ../../endpoints_manual.txt

# Hardcoded API keys/tokens
grep -r "X-API-Key\|api[-_]key\|token.*=" --include="*.java" \
  | grep -v "getString\|R.string" \
  | tee ../../api_keys_manual.txt
```

### 4. Check Config Files (Often Missed by Automation)

```bash
cd Findings/APK-analysis/raw/

# Firebase/backend config (JSON files in assets/)
find . -name "*.json" -path "*/assets/*" -exec cat {} \; | jq .

# Network security config
cat res/xml/network_security_config.xml 2>/dev/null

# Properties files
find . -name "*.properties" -exec cat {} \;
```

### 5. Analyze Native Libraries (.so files)

```bash
cd Findings/APK-analysis/raw/lib/

# List all .so files
find . -name "*.so" -ls

# Check for common vulns
for so in $(find . -name "*.so"); do
  echo "=== $so ==="
  strings "$so" | grep -i "http\|api\|key\|secret\|token" | head -20
done > ../../native_libs_analysis.txt
```

### 6. Document Analysis Progress

Create `Findings/APK-analysis/analysis-log.md`:

```markdown
# APK Static Analysis Log - com.target.app

## Session: $(date -I)

### Offset 0x0000 - BuildConfig.java
- ✅ CLIENT_ID found: "abc123..."
- ✅ BASE_URL: "https://api.target.com"
- ❌ No client_secret (likely server-generated)
- ❌ No AWS credentials

### Offset 0x1200 - ApiClient.java
- ✅ Hardcoded API key: "xyz789..." (apiKey field)
- ⚠️  Request signing uses HMAC-SHA256, NOT AWS SigV4
- 📝 Auth header format: "Authorization: Bearer {{token}}"

### Offset 0x2400 - AuthManager.java
- ❌ OAuth flow uses PKCE (no client_secret needed)
- ✅ redirect_uri whitelist: ["app://auth", "https://web.target.com/callback"]
- ⚠️  Potential open redirect if whitelist is lax

### Offset 0x3600 - NetworkModule.java
- ✅ Base URLs: api.target.com, api-staging.target.com
- ⚠️  Staging URL potentially vulnerable to takeover
- ✅ Certificate pinning ENABLED (will need Frida bypass for MITM)

## Key Findings

**HIGH VALUE:**
1. OAuth client_id: "abc123..." (unblocks all BFF endpoints)
2. Hardcoded API key: "xyz789..." (test for IDOR on /api/* endpoints)
3. Staging URL: api-staging.target.com (check DNS for takeover)

**MEDIUM VALUE:**
4. 17 exported activities (Intent injection surface)
5. Deeplink scheme: app://auth (test for parameter injection)

**INFO:**
6. Certificate pinning enabled (need Frida SSL bypass before MITM)
7. No AWS credentials found (not using AWS services)
```

## Outputs

**Automated** (`secrets.json`):
- `oauth_credentials[]` - OAuth client_id/secret
- `aws_credentials[]` - AWS access keys
- `api_endpoints[]` - Discovered endpoints
- `firebase_config{}` - Firebase project config
- `exported_components{}` - Activities, services, receivers, providers
- `deeplinks[]` - Custom URL schemes
- `permissions[]` - Declared permissions

**Manual**:
- `oauth_manual_search.txt` - Grep results for OAuth
- `aws_manual_search.txt` - AWS credential search
- `endpoints_manual.txt` - All discovered endpoints
- `api_keys_manual.txt` - Hardcoded API keys
- `native_libs_analysis.txt` - Strings from .so files
- `analysis-log.md` - Reverse engineering notes with offsets

**Decompiled Code**:
- `decompiled/sources/` - Java source (33K+ files typical)
- `raw/` - Resources, manifest, assets

## Decision Point: Dynamic Analysis Needed?

```bash
# Check if static found critical secrets
HAS_OAUTH=$(jq -r '.oauth_credentials | length' Findings/APK-analysis/secrets.json)
HAS_AWS=$(jq -r '.aws_credentials | length' Findings/APK-analysis/secrets.json)

if [ "$HAS_OAUTH" -eq 0 ] && [ "$HAS_AWS" -eq 0 ]; then
  echo "⚠️  No OAuth/AWS found - DYNAMIC ANALYSIS REQUIRED"
  echo "Run: Skill(skill=\"android-dynamic\", args=\"com.target.app\")"
else
  echo "✅ Secrets found - proceed to android-reverse"
  echo "Run: Skill(skill=\"android-reverse\", args=\"com.target.app\")"
fi
```

## Verification

```bash
# Confirm decompilation succeeded
test -d Findings/APK-analysis/decompiled/sources && echo "✅ Decompiled"

# Confirm secrets.json created
test -f Findings/APK-analysis/secrets.json && echo "✅ Secrets extracted"

# Count findings
jq '{
  oauth: (.oauth_credentials | length),
  aws: (.aws_credentials | length),
  endpoints: (.api_endpoints | length),
  exported: ((.exported_components.activities + .exported_components.services + .exported_components.receivers + .exported_components.providers) | length)
}' Findings/APK-analysis/secrets.json
```

## Troubleshooting

**"jadx failed to decompile"**  
→ Script auto-falls back to apktool. Analysis continues with smali instead of Java.

**"secrets.json shows empty arrays"**  
→ Secrets are obfuscated or runtime-generated. Run `android-dynamic` to extract from running app.

**"Too many .java files to grep manually"**  
→ Use automated script first, then search specific classes identified in analysis-log.md.

**"Certificate pinning will block dynamic analysis"**  
→ Normal. `android-dynamic` includes Frida bypass for pinning.

## Integration

Called by `android-master` after `android-download`.

Standalone:
```bash
Skill(skill="android-static", args="com.decathlon.app")
```

## Composes With

**Before**: `android-download` (provides APK)  
**After**: `android-reverse` (if secrets found) OR `android-dynamic` (if no secrets)  
**Parallel**: Can run while hunters test web endpoints (doesn't block)

## Tools Used

- `jadx` - Java decompiler (primary)
- `apktool` - Resource extraction (fallback)
- `jq` - JSON parsing
- `grep` - Secret extraction
- `strings` - Native library analysis
- `Script/apk_auto_analyze.py` - Automation wrapper
