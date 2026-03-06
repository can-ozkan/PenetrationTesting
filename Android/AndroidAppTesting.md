# Android Application Enumeration, Reverse Engineering & Penetration Testing Cheat Sheet (GMOB / eMAPT)

This cheat sheet provides a **structured workflow for Android mobile application testing** commonly required for **GMOB (GIAC Mobile Device Security Analyst) and eMAPT (INE Mobile Application Penetration Tester)** exams.

Core methodology:

```
Recon → Static Analysis → Dynamic Analysis → Exploitation → Data Extraction
```

Mobile testing focuses heavily on:

```
APK analysis
API interaction
secure storage
authentication mechanisms
runtime protections
```

---

# 1. Lab Setup

Typical mobile testing environment:

```
Android Emulator / Rooted Device
Burp Suite
ADB
Frida
APKTool
MobSF
JADX
```

Start ADB:

```bash
adb devices
```

Connect to device shell:

```bash
adb shell
```

---

# 2. Extract APK from Device

List installed packages:

```bash
adb shell pm list packages
```

Find APK path:

```bash
adb shell pm path com.target.app
```

Pull APK:

```bash
adb pull /data/app/com.target.app/base.apk
```

---

# 3. APK Information

Check APK metadata:

```bash
aapt dump badging app.apk
```

Check package name:

```
package: name='com.target.app'
```

---

# 4. Decompile APK

### Using APKTool

```bash
apktool d app.apk
```

Produces:

```
smali code
resources
AndroidManifest.xml
```

---

# 5. Convert APK to Java

### Using JADX

```bash
jadx-gui app.apk
```

Look for:

```
API endpoints
hardcoded credentials
tokens
URLs
```

---

# 6. Android Manifest Analysis

Inspect:

```
AndroidManifest.xml
```

Check:

```
exported activities
services
permissions
deep links
```

Example:

```xml
android:exported="true"
```

Exported components may allow external interaction.

---

# 7. Identify Permissions

Check permissions in manifest:

```
INTERNET
READ_EXTERNAL_STORAGE
WRITE_EXTERNAL_STORAGE
ACCESS_FINE_LOCATION
```

Excessive permissions may indicate vulnerabilities.

---

# 8. Search for Secrets

Search decompiled code:

```bash
grep -r "password"
grep -r "token"
grep -r "apikey"
```

Look for:

```
API keys
database credentials
encryption keys
```

---

# 9. Network Traffic Analysis

Configure proxy on device:

```
Burp Suite
```

Set device proxy to:

```
BURP_IP:8080
```

Capture traffic.

---

# 10. SSL Pinning Detection

If traffic not visible in Burp:

Possible SSL pinning.

Indicators:

```
CertificatePinner
TrustManager
OkHttp pinning
```

---

# 11. Bypass SSL Pinning

Use Frida scripts.

Example:

```bash
frida -U -n com.target.app -l ssl-bypass.js
```

---

# 12. Frida Setup

Install Frida server on device.

Check connection:

```bash
frida-ps -U
```

Attach to app:

```bash
frida -U -n com.target.app
```

---

# 13. Hook Functions

Example hook:

```javascript
Java.perform(function() {
    console.log("Frida attached");
});
```

Hook authentication methods.

---

# 14. Dynamic Analysis

Monitor runtime behavior.

Check:

```
API requests
authentication tokens
data storage
```

---

# 15. File System Analysis

Access app storage:

```bash
adb shell
```

Navigate:

```
/data/data/com.target.app/
```

Look for:

```
shared_prefs
databases
files
```

---

# 16. Shared Preferences

Check stored preferences:

```
/data/data/com.target.app/shared_prefs/
```

Example:

```xml
<password>admin123</password>
```

Sensitive data should not be stored in plaintext.

---

# 17. SQLite Databases

List databases:

```
/data/data/com.target.app/databases/
```

Open database:

```bash
sqlite3 database.db
```

List tables:

```sql
.tables
```

---

# 18. Log Analysis

Check logs:

```bash
adb logcat
```

Look for:

```
tokens
authentication data
debug messages
```

---

# 19. Root Detection

Apps may detect rooted devices.

Look for code checking:

```
su binary
busybox
root apps
```

Example:

```java
if (new File("/system/xbin/su").exists())
```

---

# 20. Bypass Root Detection

Hook detection function using Frida.

Example:

```javascript
Java.perform(function() {
    var RootCheck = Java.use("com.target.RootCheck");
    RootCheck.isRooted.implementation = function() {
        return false;
    };
});
```

---

# 21. Intent Testing

Check exported activities.

Use:

```bash
adb shell am start -n com.target.app/.ActivityName
```

If activity is exported, attacker may launch it.

---

# 22. Deep Link Testing

Test deep links:

```
target://path
```

Example:

```bash
adb shell am start -a android.intent.action.VIEW -d "target://login"
```

---

# 23. WebView Testing

Check for insecure WebViews.

Look for:

```
setJavaScriptEnabled(true)
addJavascriptInterface
```

May allow JavaScript injection.

---

# 24. API Testing

Extract API endpoints.

Example:

```
https://api.target.com/login
```

Test with:

```bash
curl https://api.target.com
```

Check authentication logic.

---

# 25. Token Testing

Check token behavior:

```
JWT tokens
session tokens
API keys
```

Decode JWT:

```bash
jwt.io
```

---

# 26. Insecure Storage

Sensitive data should not be stored in:

```
SharedPreferences
SQLite
external storage
logs
```

---

# 27. Backup Extraction

Check if backup enabled.

Manifest entry:

```
android:allowBackup="true"
```

Extract backup:

```bash
adb backup -apk -shared -all -f backup.ab
```

---

# 28. Reverse Engineering Tools

Common tools:

```
APKTool
JADX
MobSF
Frida
Ghidra
Burp Suite
```

---

# 29. Automated Analysis

Use MobSF:

```bash
./run.sh
```

Upload APK.

MobSF performs:

```
static analysis
dynamic analysis
security checks
```

---

# 30. Quick Testing Workflow

```
1. Extract APK
2. Decompile APK
3. Analyze manifest
4. Search for secrets
5. Inspect network traffic
6. Bypass SSL pinning
7. Analyze storage
8. Test intents
9. Test APIs
10. Exploit vulnerabilities
```

---

# 31. Common Mobile Vulnerabilities

Typical exam vulnerabilities:

```
Hardcoded credentials
Insecure storage
Weak authentication
SSL pinning bypass
Exported components
Improper API authentication
```

---

# 32. Important Files to Inspect

Look for:

```
AndroidManifest.xml
strings.xml
network_security_config.xml
shared_prefs
SQLite databases
```

---

# 33. Final Advice

Mobile testing success depends heavily on **understanding how the application works internally**.

Always ask:

```
Where does the app store data?
How does it authenticate users?
What APIs does it call?
```

The more you analyze the app structure, the easier exploitation becomes.
