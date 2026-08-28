---
description: "Master Android pentesting workflow — orchestrates APK analysis for bug bounty (INVOKE THIS FIRST)"
---

# android-master — Complete Android App Security Assessment

**THIS IS THE ENTRY POINT** for all Android/mobile testing. Orchestrates the full workflow from APK download through dynamic analysis.

## When to Use

- Bug bounty program includes Android/iOS apps in scope
- Mobile API endpoints blocked (need OAuth/Bearer tokens from APK)
- Starting mobile testing for the first time on an engagement
- **CRITICAL**: Run BEFORE testing any mobile API/BFF endpoints (60%+ of APIs need mobile auth)

## Arguments

```bash
Skill(skill="android-master", args="com.target.app")
# OR for multiple apps:
Skill(skill="android-master", args="com.target.app com.target.coach")
```

## Workflow (Fully Automated)

This skill automatically invokes sub-skills in the correct order:

### Phase 1: Acquisition (5-15 min)
```bash
Skill(skill="android-download", args="com.target.app")
```
Downloads APK to `Apk/com.target.app.apk`

### Phase 2: Static Analysis (30-60 min)
```bash
Skill(skill="android-static", args="com.target.app")
```
Decompiles, extracts secrets, analyzes manifest.
Output: `Findings/APK-analysis/secrets.json`

### Phase 3: Dynamic Analysis (1-2 hours) — OPTIONAL
```bash
# Only if static analysis didn't find OAuth/AWS creds
if [ ! -s Findings/APK-analysis/secrets.json ] || grep -q '\"oauth_credentials\": \[\]' Findings/APK-analysis/secrets.json; then
  Skill(skill="android-dynamic", args="com.target.app")
fi
```
VM setup, Frida instrumentation, runtime analysis.

### Phase 4: Systematic Reverse Engineering (ALWAYS)
```bash
Skill(skill="android-reverse", args="com.target.app")
```
Builds attack surface map, documents findings, queues derived tasks.

## Decision Tree

```
START
  │
  ├─> android-download (ALWAYS)
  │     └─> Success? → Continue
  │         Fail? → Manual download instructions
  │
  ├─> android-static (ALWAYS)
  │     └─> OAuth/AWS creds found? → Phase 4
  │         Not found? → Phase 3
  │
  ├─> android-dynamic (CONDITIONAL)
  │     └─> Only if static missed runtime-generated creds
  │         OR need to test login flow (no captcha)
  │         OR exported components need Intent fuzzing
  │
  └─> android-reverse (ALWAYS)
        └─> Creates attack surface map
            Queues hunter tasks
            Documents findings for future sessions
```

## Outputs

All outputs in engagement root:
- `Apk/com.target.app.apk` - Downloaded APK
- `Findings/APK-analysis/` - Full analysis results
  - `secrets.json` - Extracted credentials (OAuth, AWS, API keys)
  - `decompiled/` - Java source code (jadx output)
  - `raw/` - APK resources
  - `analysis-log.md` - Reverse engineering notes
  - `attack-surface.md` - Vulnerability map
- `Script/apk_*.py` - Generated analysis scripts

## Integration with /hunt

The `/hunt` skill automatically invokes `android-master` when:
1. Mobile app in scope (`scope.md` lists Android/iOS)
2. `Apk/` directory empty OR `Findings/APK-analysis/secrets.json` missing
3. Queue has mobile-recon tasks

**Manual invocation**:
```bash
Skill(skill="android-master", args="com.target.app")
```

## Skip Phases

To run only specific phases:

```bash
# Just download (if you have the APK already)
Skill(skill="android-static", args="com.target.app")

# Just dynamic (if static already done)
Skill(skill="android-dynamic", args="com.target.app")

# Just reverse engineering (refresh attack surface)
Skill(skill="android-reverse", args="com.target.app")
```

## Success Metrics

✅ `secrets.json` contains OAuth client_id OR AWS credentials  
✅ At least 5 derived hunter tasks queued  
✅ Attack surface map documents 10+ testable endpoints  
✅ Zero manual steps required (fully automated)  

## Typical ROI

**Time**: 2-4 hours (mostly automated, concurrent with other testing)  
**Findings**: 3-5 HIGH/CRITICAL per app  
**Money multiplier**: 3-5x vs web-only testing  
**Unblocks**: 60%+ of mobile API surface  

## Troubleshooting

**"APK download failed"**  
→ `android-download` will give manual instructions. Follow them, then continue with `android-static`.

**"No OAuth credentials found"**  
→ Run `android-dynamic` to extract runtime-generated tokens.

**"Frida won't connect"**  
→ Check `android-dynamic` troubleshooting section.

## Composes With

- `hunt` - Main loop invokes this automatically
- `bugbounty-high-yield-classes` rank 6 - Mobile-only API surface
- `http-async-rotate` - Uses extracted API keys for IDOR sweeps
- `pentest-findings-http` - Captures mobile API requests

## Anti-Patterns

❌ **"Skip APK analysis, test web APIs first"** → 60% blocked without mobile auth  
❌ **"Run static only, skip dynamic"** → Miss 40% of runtime-generated secrets  
❌ **"Don't document reverse engineering progress"** → Re-analyze same code every session  
✅ **DO THIS**: Full workflow (download → static → dynamic → reverse), document everything
