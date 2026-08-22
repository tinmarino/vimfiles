---
name: mobile-hacking-frida
description: Use when testing an Android app in an authorized engagement — pulling an APK off a device (including App Bundle splits), decompiling with apktool/jadx, injecting the Frida Gadget (libfg.so + libfg.config.so) and rebuilding/zipaligning/signing, running frida-server on a rooted AVD, bypassing TLS certificate pinning and root/anti-tamper checks (JailMonkey, RootBeer, Conscrypt TrustManagerImpl), and logging intercepted plaintext HTTP to Burp-pasteable files or to a proxy on a port other than 8080/8081. Triggers on "apk", "apktool", "jadx", "frida", "frida-gadget", "certificate pinning", "SSL unpinning", "hook the app", "intercept app traffic", "okhttp logger", "reflutter", "mitmproxy on android", "hackear la app", "sacar el apk", "descompilar el apk", "parchar el apk", "inyectar frida", "saltar el pinning", "quitar el pinning", "deteccion de root", "interceptar el trafico de la app", "loguear las requests de la app".
---

# Android app hacking with Frida

Engagement root is `~/Pawn/<client>/`; every path below is relative to it. Placeholders: package `target.cl`, host `target.example.com`.

## 0. House rules (non-negotiable)

- `export ADB=~/Android/Sdk/platform-tools/adb` and put it first in `PATH` (`export PATH=~/Android/Sdk/platform-tools:$PATH`); every `adb` below means that binary. Never `/usr/bin/adb` (old server, mismatches the emulator).
- **Ports 8080 and 8081 are the operator's Burp and are reserved.** Every listener, `adb reverse`, `http_proxy` setting and DNAT target in this skill uses **8083**. Never bind, forward or point the device at 8080/8081 from a script.
- Gadget ports: one per app, from 27042 upward; record the app↔port mapping in `MEMORY.md`. Long-lived processes (emulator, frida runner, mitmdump, log tail) run under `systemd-run --user --unit=<name> --collect`, never `nohup ... &`.
- Layout: scripts in `Script/`, throwaway experiments in `Script/wave<NNN>/`, captures in `Findings/`, APK snapshots in dated dirs `Apk/YYYY-MM/` — never overwrite a snapshot.

## 1. Pull the APK (App Bundles ship splits)

```bash
adb shell pm list packages | grep -i target ; mkdir -p Apk/2026-08/splits
for p in $(adb shell pm path target.cl | sed 's/^package://' | tr -d '\r'); do adb pull "$p" Apk/2026-08/splits/; done
cp Apk/2026-08/splits/base.apk Apk/2026-08/target.cl.apk
```

The native `.so` libraries live in `split_config.arm64_v8a.apk`, **not** in `base.apk` — always pull every split.

## 2. Static triage

```bash
apktool d -f -o Apk/2026-08/apktool/ Apk/2026-08/target.cl.apk      # smali you will PATCH
jadx -d Apk/2026-08/jadx/ --no-res Apk/2026-08/target.cl.apk        # readable Java; minutes, backgroundable
unzip -l Apk/2026-08/target.cl.apk | grep -E 'libflutter|libapp\.so|libreactnative|libhermes|index\.android\.bundle'
strings -n 12 Apk/2026-08/apktool/lib/arm64-v8a/libapp.so | grep -iE '^https?://|secret|token|api[-_]?key|bearer'
```

Framework decides strategy: OkHttp/Java → hook Java; Flutter → `libapp.so` strings + BoringSSL hooks (URLs and secrets are in the native payload, not the Java); React Native → OkHttp underneath, never native hooks. Never run `apkleaks` on an 80MB+ APK — it OOMs; pre-filter with `unzip -p APK | grep`.

Exported components — parse the decoded manifest with Python (`xml.etree`, ns `{http://schemas.android.com/apk/res/android}`): for each `activity|activity-alias|service|receiver|provider` under `<application>`, print it when `android:exported == "true"` or `exported` is unset **and** it has an `<intent-filter>`; print its `android:permission` too.

## 3. Patch in the Gadget (rooted emulator? skip to §6 and use frida-server instead)

Physical or unrooted device, or RASP that greps `/proc/self/maps` for `frida`/`gum` → Gadget repack, library named neutrally `libfg.so`. In `Apk/2026-08/apktool/smali/target/cl/MainActivity.smali` (better: the `<clinit>` of the class named by `android:name` on `<application>`, wrapped in `try/catch Ljava/lang/Throwable;`; synthesize an Application class if none is declared — its `<clinit>` runs before every ContentProvider and any anti-tamper engine):

```diff
 .method public constructor <init>()V
-    .locals 0
+    .locals 1
+    const-string v0, "fg"
+    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
```

Register gotcha: `.locals N` allocates `v0..v(N-1)`; touching `p0` before `super.<init>` gives `VerifyError: Expected initialization on uninitialized reference` — use `v0` with `.locals 1`. Then drop the Gadget (https://github.com/frida/frida/releases, `frida-gadget-<ver>-android-arm64.so.xz`) and — the file everyone forgets — its config, named **exactly** `libfg.config.so` (plain JSON despite the suffix; a mismatched name is silently ignored):

```bash
cd Apk/2026-08/apktool && mkdir -p lib/arm64-v8a && cp ~/Iso/Jar/libfg.so lib/arm64-v8a/
cat > lib/arm64-v8a/libfg.config.so <<'JSON'
{"interaction": {"type": "listen", "address": "127.0.0.1", "port": 27042, "on_load": "wait"}}
JSON
unzip -j -o ../splits/split_config.arm64_v8a.apk 'lib/arm64-v8a/*.so' -d lib/arm64-v8a/
```

`on_load: "wait"` blocks in `JNI_OnLoad` until a client attaches and resumes — that lands your hooks before the app does anything; the frozen splash is expected. A listen-mode Gadget accepts one client per process start, so restart the app for each session. Skipping the split restore gives `SoLoaderDSONotFoundError: couldn't find DSO to load: libreactnative.so`. apktool gotcha: put the target device's `framework-res.apk` at `~/.local/share/apktool/framework/1.apk`, else aapt2 silently writes a corrupt manifest.

Manifest edits on the decoded base `AndroidManifest.xml`: delete `android:requiredSplitTypes` / `android:splitTypes` / `android:isSplitRequired` (else `INSTALL_FAILED_MISSING_SPLIT`) and set `android:extractNativeLibs="true"` (else `Failed to extract native libraries, res=-2`; it also unpacks the libs where the Gadget can read its own config). Android reads this flag from the base manifest only.

## 4. Rebuild → align → sign → install (order is load-bearing)

```bash
apktool b Apk/2026-08/apktool -o Apk/2026-08/target.cl_mod.apk
zipalign -p -f 4 Apk/2026-08/target.cl_mod.apk Apk/2026-08/target.cl_aligned.apk   # ALWAYS before signing
apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android --key-pass pass:android \
  --ks-key-alias androiddebugkey --out Apk/2026-08/target.cl_signed.apk Apk/2026-08/target.cl_aligned.apk
apksigner verify --verbose Apk/2026-08/target.cl_signed.apk
adb uninstall target.cl        # debug key != dev key; WIPES app data
adb install --no-incremental Apk/2026-08/target.cl_signed.apk
```

One-time keystore: `keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"`. Aligning *after* signing invalidates the v2/v3 signature. Keep one known-good patched APK as the stable baseline; never overwrite it.

## 5. Attach and load scripts in order

```bash
adb forward tcp:27042 tcp:27042
frida-ps -H 127.0.0.1:27042 && frida -H 127.0.0.1:27042 -n Gadget -l Script/frida/hook.js  # must list: Gadget
```

`Script/frida/session.sh` — `cd` to the engagement root, `adb shell am force-stop target.cl`, re-`adb forward tcp:27042 tcp:27042`, relaunch with `adb shell monkey -p target.cl -c android.intent.category.LAUNCHER 1`, poll `frida-ps -H 127.0.0.1:27042 | grep -q Gadget` up to 45 s, then `exec python3 -u Script/frida/attach-multi.py 127.0.0.1:27042 "$@"` defaulting to `antitamper-bypass.js okhttp-logger.js`.

`Script/frida/attach-multi.py` — **anti-tamper bypass first**, everything loaded before resume:

```python
#!/usr/bin/env python3
"""Attach to a Frida Gadget over TCP, load N scripts in order, dump their output."""
from sys import argv
from time import sleep
import frida

device = frida.get_device_manager().add_remote_device(argv[1])
process = device.enumerate_processes()[0]          # the Gadget is the only process
session = device.attach(process.pid)
for path in argv[2:]:
    script = session.create_script(open(path).read())
    script.on('message', lambda m, d: print(m.get('payload', m), flush=True))
    script.load()
device.resume(process.pid)      # required with on_load "wait"; wrap in try/except otherwise
while True:
    sleep(3600)
```

Frida 17 removed static `Module.findExportByName` and the built-in `Java` bridge for Python-loaded scripts: prepend a shim built on `Process.findModuleByName(...).findExportByName(...)`, or `import Java from 'frida-java-bridge'` and `frida-compile agent.js -o agent.bundle.js`. A client/Gadget version mismatch shows only as `Failed to load script: the connection is closed` — check with `strings libfg.so | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'`, then `pip install --break-system-packages frida==<version> frida-tools`.

## 6. frida-server (rooted AVD)

```bash
adb push frida-server /data/local/tmp/frida-server
adb shell "su -c 'chmod 755 /data/local/tmp/frida-server; /data/local/tmp/frida-server &'"
frida -U -f target.cl -l Script/frida/hook.js --runtime=v8      # spawn paused; -n to attach
```

Use a `google_apis` (non-Play) system image — the Play image blocks `adb root`. Boot with `-writable-system -gpu swiftshader_indirect -no-window` under `systemd-run --user`. Magisk denies `su` until "[SharedUID] Shell" is toggled in its Superuser tab.

## 7. Anti-tamper bypass — load FIRST (`Script/frida/antitamper-bypass.js`)

```javascript
function forceReturn(cls, method, value) {           // no-ops if the class/method is absent
    try {
        const target = Java.use(cls)[method];
        if (target === undefined) return send('[-] no ' + cls + '.' + method);
        target.overloads.forEach(ov => { ov.implementation = () => value; });
        send('[+] ' + cls + '.' + method + ' -> ' + value);
    } catch (e) { send('[-] ' + e.message); }
}
Java.perform(function () {
    const JM = 'com.gantix.JailMonkey.';
    [[JM + 'Rooted.RootedCheck', 'isJailBroken'], [JM + 'HookDetection.HookDetectionCheck', 'hookDetected'],
     [JM + 'AdbEnabled.AdbEnabled', 'AdbEnabled'], [JM + 'MockLocation.MockLocationCheck', 'isMockLocationOn'],
     ['com.scottyab.rootbeer.RootBeer', 'isRooted'], ['com.dynatrace.agent.util.RootDetector', 'isRooted'],
     ['com.scottyab.rootbeer.RootBeer', 'isRootedWithoutBusyBoxCheck']].forEach(([c, m]) => forceReturn(c, m, false));
});
```

Also override `JailMonkeyModule.getConstants` to `map.put(k, Java.use('java.lang.Boolean').valueOf(false))` for `isJailBroken`, `hookDetected`, `canMockLocation`, `isOnExternalStorage`, `AdbEnabled`, `development_settings_enabled` — the bridge hands that map straight to JS.

With the in-process Gadget, root/process scans for `frida-server` never fire; what still betrays you on a real handset is `AdbEnabled` (USB debugging) — force it regardless.

## 8. Pinning bypass — pick the cheapest layer that yields plaintext

1. OkHttp present → hook OkHttp (§9.2). No CA, no proxy, no pinning bypass at all.
2. WebView present → hook `loadUrl` / `loadDataWithBaseURL` / `shouldInterceptRequest` / `addJavascriptInterface` (log the bridge name and `obj.getClass().getName()`) before guessing at deep links.
3. App ignores the system proxy or pins → hook `SSL_read`/`SSL_write` (§9.3). Flutter with stripped BoringSSL symbols → `reflutter <apk>` (re-sign, install), rooted DNAT + trusted CA, or a per-build `libflutter.so` offset.
4. Secrets in Keystore / Flutter Secure Storage → disk holds ciphertext only; hook the crypto sinks (§11).

Default first move — the HTTPToolkit unpinning bundle (edit its `config.js`: `PROXY_HOST='127.0.0.1'`, `PROXY_PORT=8083`, `CERT_PEM=<Burp CA>`):

```bash
adb reverse tcp:8083 tcp:8083     # device localhost:8083 -> host listener on 8083; beats exposing it on the LAN
cd ~/Program/frida-interception-and-unpinning && frida -H 127.0.0.1:27042 -n Gadget -l config.js \
  -l android/android-proxy-override.js -l android/android-system-certificate-injection.js \
  -l android/android-certificate-unpinning.js -l android/android-certificate-unpinning-fallback.js
```

Leave the REPL attached: hooks die with the session. On React Native (Hermes/JSI) never load `native-connect-hook.js` / `native-tls-hook.js`: both SIGSEGV the `mqt_v_js` thread. If the error is `Unrecognized TLS error - this must be patched manually`, the stack is Conscrypt (the bundle only patches public `X509TrustManager` overloads). Patch the public entrypoint yourself: `Java.use('com.android.org.conscrypt.TrustManagerImpl').checkServerTrusted.overloads.forEach(m => m.implementation = function () { return m.returnType.className === 'java.util.List' ? Java.use('java.util.Arrays').asList(arguments[0]) : undefined; })`.

## 9. Log intercepted traffic to file

### 9.1 Format, naming and destination

One file per round-trip so it pastes straight into Burp Repeater: `# Request <ISO8601>` / request / blank line / `# Response <ISO8601>` / response / `---`. Filename `<seq>-<ts>-<host>-<sanitized-path>.txt` (`[^A-Za-z0-9.-]+` → `-`, truncated ~60 chars) under `Findings/http-capture/split/`, plus an aggregate `Findings/http-capture/_all.md` and a `.jsonl` telemetry stream. On-device write targets, first one that passes a write probe: `/sdcard/Lot/Http/Frida`, `/data/data/target.cl/cache/Lot/Http/Frida`, `/data/data/target.cl/files/http-dump.jsonl` (`/Lot` at filesystem root is not writable on Android 11+). Pull with `adb shell run-as target.cl tar -C cache/Lot/Http/Frida -cf - . | tar -C Findings/http-capture/cache-frida -xf -`. Prefer writing on the **host**: the agent `send()`s structured events, a Python runner renders the files. In a non-Java process (Flutter/Gadget) there is no Java bridge — use libc via `NativeFunction` (`mkdir`, `fopen`, `fwrite`, `fclose`, `strlen`), mkdir'ing each path prefix and ignoring EEXIST.

### 9.2 OkHttp logger — cheapest path (`Script/frida/okhttp-logger.js`)

Hook `okhttp3.internal.http.BridgeInterceptor.intercept`: exactly once per request (unlike `RealInterceptorChain.proceed`, which duplicates a line per interceptor), with final headers and an already-decrypted Response.

```javascript
Java.perform(function () {
    const Bridge = Java.use('okhttp3.internal.http.BridgeInterceptor');
    const hdrs = h => { const o = {}; for (let i = 0; i < h.size(); i++) o[h.name(i)] = h.value(i); return o; };
    Bridge.intercept.implementation = function (chain) {
        const req = chain.request(), resp = this.intercept(chain);
        let reqBody = null, respBody = null;   // clone the buffer: never consume a stream the app needs
        try { const b = req.body(); if (b) { const k = Java.use('okio.Buffer').$new(); b.writeTo(k); reqBody = k.readUtf8(); } } catch (e) {}
        try { const b = resp.body(); if (b) { const s = b.source(); s.request(1048576);
              respBody = (s.getBuffer ? s.getBuffer() : s.buffer()).clone().readUtf8(); } } catch (e) {}
        send(JSON.stringify({ ts: Date.now(), url: req.url().toString(), method: req.method(),
            reqHeaders: hdrs(req.headers()), reqBody, code: resp.code(), respHeaders: hdrs(resp.headers()), respBody }));
        return resp;
    };
});
```

`Response.peekBody(n)` is the alternative non-consuming read; when body dumping is over-collection for the engagement, ship the metadata-only variant (URL, method, header *names*, status, timing).

### 9.3 SSL_write/SSL_read pairing logger — defeats pinning entirely

Hook BoringSSL in the TLS-owning module (`libflutter.so`, `libssl.so`, `libconscrypt_jni.so`, `libreactnative.so`), key buffers by the `SSL*` pointer, one Burp-paste file per round-trip:

```javascript
const mod = Process.getModuleByName('libflutter.so');
Interceptor.attach(mod.findExportByName('SSL_write'), { onEnter(args) {
    const key = args[0].toString();
    if (states[key] === 'READING') emit(key);                    // flush the previous transaction
    appendBytes(writeBufs, key, new Uint8Array(args[1].readByteArray(args[2].toInt32())));
    states[key] = 'WRITING';
}});
Interceptor.attach(mod.findExportByName('SSL_read'), {
    onEnter(args) { this.key = args[0].toString(); this.buf = args[1]; },
    onLeave(ret) { const n = ret.toInt32();                      // return value = bytes decrypted
        if (n > 0) appendBytes(readBufs, this.key, new Uint8Array(this.buf.readByteArray(n)));
        states[this.key] = 'READING'; }
});
```

Drop anything not matching `/^(GET|POST|PUT|DELETE|PATCH|HEAD|OPTIONS) \S+ HTTP\/1\.\d/` — HTTP/2 frames and handshake fragments do not paste into Burp, and HTTP/2 multiplexing is not parsed at all. A stripped Flutter build needs `Process.getModuleByName('libflutter.so').base.add(0x<offset>)` (the static `Module.getBaseAddress` was removed in Frida 17), **per-build, never universal**. The last in-flight transaction only flushes on the next request for the same `SSL*` — export `flushAll()` via `rpc.exports` or drive one dummy request after the PoC.

## 10. Proxy path (port 8083)

```bash
adb shell settings put global http_proxy 10.0.2.2:8083      # emulator -> host listener on 8083
adb shell settings put global http_proxy :0                 # ALWAYS tear down
mitmdump --listen-port 8083 --set ssl_insecure=true -s Script/mitm-live-burp.py \
  --set burp_out=Findings/http-capture/live.md --set burp_split=Findings/http-capture/split/
python3 Script/mitm-to-burp.py capture.mitm --host-filter 'target\.cl|api\.' --out-dir Findings/burp-from-mitm
```

mitmproxy addon shape: declare options in `load(self, loader)` via `loader.add_option(...)`, resolve in `configure()`, write in `response()`, export `addons = [BurpLogger()]`. Per-app DNAT on a rooted device keeps Firebase/SDK traffic working, unlike a global proxy: read `uid` from `/proc/$(adb shell pidof target.cl)/status`, then `adb shell "iptables -t nat -A OUTPUT -p tcp --dport 443 -m owner --uid-owner ${uid} -j DNAT --to-destination 10.0.2.2:8083"`; tear down with `iptables -t nat -F OUTPUT`. Install the Burp CA into both the legacy store and the Conscrypt APEX store on Android 14 rooted images.

## 11. Crypto sinks and app data

```bash
frida-trace -U -f target.cl -j 'javax.crypto.Cipher!*' -j 'java.security.KeyStore!*' --runtime=v8
frida-trace -U -n target.cl -i 'SSL_*' -i 'EVP_*' -i 'HMAC_*'
adb exec-out run-as target.cl tar czf - -C /data/data/target.cl . > Findings/app-data/target-cl-data.tar.gz
```

`frida-trace` writes one editable stub per matched function under `__handlers__/`; add `Thread.backtrace(this.context, Backtracer.ACCURATE)` to walk sink→source. On Flutter, dumping PointyCastle `HMac` `(key, message, output)` triples cracks the request-signing algorithm. Pull app data as one tarball and analyze locally — never loop `sqlite3`/`grep` over `adb shell`.

**adb quick reference**: `adb shell dumpsys package target.cl | grep -E 'versionName|versionCode|userId'` · `adb logcat -c && adb logcat --pid "$(adb shell pidof target.cl | tr -d '\r')" -v time` · `adb exec-out screencap -p > screen.png` · `adb shell uiautomator dump /sdcard/window.xml && adb pull /sdcard/window.xml .` · `adb shell input tap 540 1200` · `adb shell pm clear target.cl`. Spawn-paused trick: `frida -U -f target.cl`, then `adb shell input keyevent KEYCODE_WAKEUP` in another terminal, then `%resume`.

## Anti-patterns

- Binding, reversing or pointing the device at 8080/8081 (they are the operator's Burp, reserved), leaving `http_proxy` set after a capture, or putting `-http-proxy` permanently in the emulator launch script (it blackholes all connectivity when the proxy is down, and Flutter ignores it anyway).
- `nohup ... &` for the emulator/runner instead of `systemd-run --user --unit=... --collect`.
- `zipalign` after `apksigner` (invalidates v2/v3), rebuilding `base.apk` without restoring the ABI split's `.so` files, or naming the config anything but `libfg.config.so` (a mismatch is silently ignored).
- Loading the RN native TLS hooks (SIGSEGV), or `apkleaks` on a huge APK (OOM).
- Hooking `RealInterceptorChain.proceed` (duplicate lines) instead of `BridgeInterceptor.intercept`, consuming a response stream the app still needs, or publishing a per-build `libflutter.so` offset as if it were universal.
- Overwriting a dated `Apk/YYYY-MM/` snapshot or the known-good patched APK.

## Composes with

`pentest-router` / `pentest-scope-gate` (confirm the package id and technique are authorised before the first packet) → `pentest-engagement-init` (repo skeleton, finding IDs) → this skill → `pentest-findings-http` (save the captured flows as evidence) → `pentest-endpoint-summary` (register each endpoint + verdict) → `vuln-reproducer` → `vuln-reporter` (CyScope finding in Spanish) → `pentest-report-package` (assemble `Report/<PREFIX><NNN>/` + adversary pass) → `pentest-memory-feedback` / `write-feedback`. Also: `burp-history-reader` when the traffic already reached Burp; `pentest-js-recon` for the webview/SPA surface the app loads; `pentest-burp-to-script` to turn a captured flow into a repeatable requester; `pentest-authz-matrix`, `pentest-graphql-hunt`, `pentest-lot-idor` + `http-async-rotate` to exploit and scale an endpoint found here; `bugbounty-report-en` when the target is a bounty program; `python-writer` for any `Script/*.py`; `rat-c2-tmux` when a PoC needs an external callback; `persistent-terminal-control` for long interactive device sessions.
