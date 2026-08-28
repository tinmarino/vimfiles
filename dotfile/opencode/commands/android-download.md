---
description: "APK download automation — tries multiple sources, falls back to manual instructions"
---

# android-download — APK Acquisition

Downloads APK from Google Play or mirrors. Tries automation first, provides manual instructions if blocked.

## When to Use

- Starting mobile testing (no APK yet)
- Need to update to latest app version
- Invoked automatically by `android-master`

## Prerequisites

NONE - this is usually the first step.

## Arguments

```bash
Skill(skill="android-download", args="com.target.app")
```

## Workflow

### 1. Check if APK Already Exists

```bash
APK_PATH="Apk/$(basename $1).apk"
if [ -f "$APK_PATH" ] && [ -s "$APK_PATH" ]; then
  echo "✅ APK already exists: $APK_PATH"
  file "$APK_PATH"  # Verify it's a valid Android package
  exit 0
fi
```

### 2. Try Automated Download

```bash
mkdir -p Apk/

# Method 1: apk_auto_download.sh (tries APKPure, APKCombo, Evozi)
if [ -x Script/apk_auto_download.sh ]; then
  ./Script/apk_auto_download.sh "$1"
  if [ -f "Apk/$1.apk" ]; then
    echo "✅ Downloaded via automation"
    exit 0
  fi
fi

# Method 2: Python downloader with session handling
if [ -x Script/apk_download_python.py ]; then
  python3 Script/apk_download_python.py "$1" Apk/
  if [ -f "Apk/$1.apk" ]; then
    echo "✅ Downloaded via Python"
    exit 0
  fi
fi

# Method 3: gplaycli (if installed)
if command -v gplaycli &> /dev/null; then
  gplaycli -d "$1" -f Apk/
  if [ -f "Apk/$1.apk" ]; then
    echo "✅ Downloaded via gplaycli"
    exit 0
  fi
fi
```

### 3. Automation Failed → Manual Instructions

```bash
cat << EOF

❌ Automated download blocked by anti-bot protection.

📥 MANUAL DOWNLOAD REQUIRED (5 minutes):

**Option 1: APKPure (RECOMMENDED)**
1. Visit: https://apkpure.com/search?q=$1
2. Click: First result
3. Click: "Download APK" button
4. Save file to: $(pwd)/Apk/$1.apk

**Option 2: APKMirror**
1. Visit: https://www.apkmirror.com/?s=$1
2. Find latest version
3. Download APK
4. Save to: $(pwd)/Apk/$1.apk

**Option 3: APKCombo**
1. Visit: https://apkcombo.com/$1/download/apk
2. Click download
3. Save to: $(pwd)/Apk/$1.apk

**After manual download, verify:**
\`\`\`bash
file Apk/$1.apk  # Should show: "Android application package"
ls -lh Apk/$1.apk  # Size should be >1 MB (typical apps 10-100 MB)
\`\`\`

**Then continue with:**
\`\`\`bash
Skill(skill="android-static", args="$1")
\`\`\`

EOF
exit 1
```

## Outputs

- **Success**: `Apk/com.target.app.apk` (valid Android package)
- **Failure**: Manual download instructions printed

## Verification

```bash
# Verify downloaded APK is valid
file Apk/com.target.app.apk
# Expected: "Android application package file"

# Check size (should be >1 MB for real apps)
du -h Apk/com.target.app.apk

# Extract package name to verify
aapt dump badging Apk/com.target.app.apk | grep package
# Expected: package: name='com.target.app'
```

## Troubleshooting

**"file command shows: Zip archive"**  
→ This is normal - APK is a ZIP. Check with `aapt` instead.

**"Downloaded file is 0 bytes"**  
→ Automation failed. Delete and use manual method.

**"Package name mismatch"**  
→ APK mirror gave you wrong app. Re-download from different source.

**"Google requires authentication"**  
→ Use APK mirrors (APKPure, APKMirror) - they don't need Google account.

## Integration

Invoked automatically by `android-master`. Can also run standalone:

```bash
Skill(skill="android-download", args="com.decathlon.app")
```

## Composes With

**Next**: `android-static` (always - decompiles the downloaded APK)  
**Alternative**: Manual placement of APK in `Apk/` directory (skip this skill entirely)

## Tools Required

Auto-installed or available:
- `file` (verify file type)
- `aapt` (Android Asset Packaging Tool - optional)
- `curl`/`wget` (download)
- Optional: `gplaycli`, `apkeep`

Scripts used:
- `Script/apk_auto_download.sh` (multi-source bash downloader)
- `Script/apk_download_python.py` (Python with session handling)

## Gmail Authentication (gplaycli fallback)

If APKPure API fails, gplaycli can authenticate with Gmail:

**Credentials:** Stored in `~/Secret/env.sh` (sourced by .bashrc)
- `$GMAIL_ACCOUNT` - Gmail address
- `$GMAIL_PASSWORD` - Gmail password

**Usage:**
```bash
gplaycli -a com.target.app -f Apk/ -y -u "$GMAIL_ACCOUNT" -p "$GMAIL_PASSWORD"
```

Never hardcode credentials in skills or scripts.
