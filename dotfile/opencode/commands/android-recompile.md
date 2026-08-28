---
description: "APK recompilation & patching — modify app, rebuild, re-sign (OPTIONAL, advanced)"
---

# android-recompile — APK Modification & Re-signing

Patches decompiled APK, rebuilds, signs, and reinstalls. Used for advanced testing scenarios.

## When to Use

- Need to disable certificate pinning permanently (vs Frida runtime bypass)
- Want to add debug logging to specific methods
- Testing requires modified app behavior
- Need to inject test hooks into native code

**RARELY NEEDED** - Most testing doesn't require recompilation. Use `android-dynamic` Frida hooks instead (faster, no rebuild).

## Prerequisites

**MUST HAVE**:
- `Findings/APK-analysis/decompiled/` (from `android-static`)
- Apktool installed
- `keytool` and `jarsigner` (Java SDK)

## Arguments

```bash
Skill(skill="android-recompile", args="com.target.app")
```

## Workflow

### Step 1: Decode APK with apktool

```bash
APK_PATH="Apk/com.target.app.apk"
OUTPUT_DIR="Findings/APK-analysis/decoded"

apktool d "$APK_PATH" -o "$OUTPUT_DIR" -f

echo "✅ Decoded to: $OUTPUT_DIR"
```

### Step 2: Apply Patches

**Common patches**:

#### Disable Certificate Pinning (Network Security Config)

```bash
# Create/modify network security config
cat > "$OUTPUT_DIR/res/xml/network_security_config.xml" << 'PINNING_PATCH'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
PINNING_PATCH

# Link in AndroidManifest.xml
sed -i 's|<application|<application android:networkSecurityConfig="@xml/network_security_config"|' \
  "$OUTPUT_DIR/AndroidManifest.xml"

echo "✅ Patched: Certificate pinning disabled"
```

#### Enable Debug Mode

```bash
# Set android:debuggable="true"
sed -i 's|<application|<application android:debuggable="true"|' \
  "$OUTPUT_DIR/AndroidManifest.xml"

echo "✅ Patched: Debug mode enabled"
```

#### Disable SSL Verification in Code (smali)

```bash
# Find OkHttp CertificatePinner usage
find "$OUTPUT_DIR/smali" -name "*.smali" -exec grep -l "CertificatePinner" {} \; | while read SMALI; do
  # Patch: return early from check() method
  sed -i '/\.method.*check/a\    return-void' "$SMALI"
done

echo "✅ Patched: OkHttp SSL checks bypassed"
```

### Step 3: Rebuild APK

```bash
OUTPUT_APK="Apk/com.target.app.patched.apk"

apktool b "$OUTPUT_DIR" -o "$OUTPUT_APK"

if [ $? -eq 0 ]; then
  echo "✅ Rebuilt APK: $OUTPUT_APK"
else
  echo "❌ Build failed. Check smali syntax errors."
  exit 1
fi
```

### Step 4: Sign APK

```bash
# Generate signing key (one-time)
KEYSTORE="$HOME/.android/debug.keystore"
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkey \
    -v \
    -keystore "$KEYSTORE" \
    -alias androiddebugkey \
    -storepass android \
    -keypass android \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US"
fi

# Align APK (required for signing)
zipalign -v 4 "$OUTPUT_APK" "${OUTPUT_APK%.apk}.aligned.apk"
mv "${OUTPUT_APK%.apk}.aligned.apk" "$OUTPUT_APK"

# Sign with debug key
jarsigner \
  -verbose \
  -sigalg SHA1withRSA \
  -digestalg SHA1 \
  -keystore "$KEYSTORE" \
  -storepass android \
  -keypass android \
  "$OUTPUT_APK" \
  androiddebugkey

# Verify signature
jarsigner -verify -verbose "$OUTPUT_APK" && echo "✅ APK signed successfully"
```

### Step 5: Install Patched APK

```bash
# Uninstall original app first
adb uninstall com.target.app 2>/dev/null

# Install patched version
adb install "$OUTPUT_APK"

if [ $? -eq 0 ]; then
  echo "✅ Patched app installed"
  
  # Launch app
  adb shell monkey -p com.target.app -c android.intent.category.LAUNCHER 1
else
  echo "❌ Installation failed. Check signature or device compatibility."
  exit 1
fi
```

### Step 6: Verify Patches

```bash
# Test MITM works (certificate pinning bypassed)
adb shell settings put global http_proxy "$HOST_IP:8080"

# Check app traffic in mitmproxy
echo "✅ Verification: Open app and check mitmproxy for HTTPS traffic"
echo "If traffic visible → Pinning bypass successful"
echo "If no traffic → Patch failed, use Frida instead"
```

## Outputs

- `Findings/APK-analysis/decoded/` - Decompiled smali code (editable)
- `Apk/com.target.app.patched.apk` - Rebuilt & signed APK
- `$HOME/.android/debug.keystore` - Debug signing key (reusable)

## Common Use Cases

### 1. Permanent SSL Pinning Bypass

For apps where Frida fails or is too slow:

```bash
Skill(skill="android-recompile", args="com.target.app")
# Applies network_security_config.xml patch automatically
```

### 2. Add Debug Logging to Auth Methods

```bash
# Edit decoded smali manually
nano Findings/APK-analysis/decoded/smali/com/target/app/AuthManager.smali

# Add logging:
#   const-string v0, "AUTH_DEBUG"
#   invoke-static {v0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

# Rebuild
apktool b Findings/APK-analysis/decoded/ -o Apk/com.target.app.patched.apk
# ... sign and install ...
```

### 3. Bypass Root Detection

```bash
# Find root detection code
grep -r "su\|Superuser\|root" Findings/APK-analysis/decoded/smali/

# Patch check methods to always return false
# ... edit smali ...
# Rebuild and install
```

## Troubleshooting

**"apktool build failed"**  
→ Check smali syntax errors in edited files  
→ Run: `apktool b -d` for detailed error output  
→ Restore original: `apktool d Apk/com.target.app.apk -o decoded/ -f`

**"Installation failed: INSTALL_PARSE_FAILED_NO_CERTIFICATES"**  
→ APK not signed. Re-run step 4 (signing).

**"Installation failed: INSTALL_FAILED_UPDATE_INCOMPATIBLE"**  
→ Signature mismatch. Uninstall original: `adb uninstall com.target.app`

**"Patched app crashes on launch"**  
→ Smali syntax error or incompatible patch  
→ Check logcat: `adb logcat | grep -i error`  
→ Revert to Frida runtime patching instead

## When NOT to Use

❌ **"Need to bypass SSL pinning"** → Use `android-dynamic` with Frida (faster, no rebuild)  
❌ **"Want to hook auth methods"** → Use Frida hooks (real-time, no recompilation)  
❌ **"Testing exported components"** → No recompilation needed (use adb shell am start)  

✅ **DO USE when**:
- Frida fails or app detects it
- Need persistent patches across app restarts
- Modifying native libraries (.so files)
- Injecting test infrastructure

## Integration

Optional skill - not invoked by `android-master` by default.

Manual invocation:
```bash
Skill(skill="android-recompile", args="com.decathlon.app")
```

## Composes With

**Before**: `android-static` (provides decompiled code to patch)  
**Alternative to**: `android-dynamic` Frida hooks (recompile is permanent, Frida is runtime)  
**After**: Continue with `android-dynamic` to test patched app

## Tools Required

- `apktool` (decode/rebuild APK)
- `zipalign` (Android SDK)
- `jarsigner` (Java SDK)
- `keytool` (Java SDK)
- `adb` (install patched APK)

## Security Note

**CRITICAL**: Only patch apps you own or have authorization to modify. Do NOT distribute patched APKs. Use only for authorized bug bounty testing on your own test devices.
