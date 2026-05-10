# PowerView.md

```
# Import PowerView
Import-Module .\PowerView.ps1
. .\PowerView.ps1

# Domain Information
Get-Domain
Get-DomainPolicy
Get-DomainSID
Get-DomainController
Get-Forest
Get-ForestDomain
Get-ForestGlobalCatalog

# Domain Users
Get-DomainUser
Get-DomainUser -Identity administrator
Get-DomainUser -Properties samaccountname,description
Get-DomainUser -SPN
Get-DomainUser -PreauthNotRequired
Get-DomainUser -AdminCount
Get-DomainUser -LDAPFilter "(description=*)"
Get-DomainUser *admin*

# Domain Computers
Get-DomainComputer
Get-DomainComputer -OperatingSystem "*Server*"
Get-DomainComputer -Ping
Get-DomainComputer -Unconstrained
Get-DomainComputer -TrustedToAuth
Get-DomainComputer -Properties dnshostname

# Domain Groups
Get-DomainGroup
Get-DomainGroup -Identity "Domain Admins"
Get-DomainGroup -AdminCount
Get-DomainGroupMember -Identity "Domain Admins"
Get-DomainGroupMember -Identity "Enterprise Admins"
Get-DomainGroupMember -Recurse -Identity "Administrators"
Get-DomainGroup "*admin*"

# Organizational Units
Get-DomainOU
Get-DomainOU -Identity "Servers"

# Domain Trusts
Get-DomainTrust
Get-ForestTrust

# Group Policy Objects
Get-DomainGPO
Get-DomainGPO | select displayname
Get-DomainGPOUserLocalGroupMapping

# ACL Enumeration
Get-DomainObjectAcl -Identity "Domain Admins"
Get-DomainObjectAcl -Identity user
Find-InterestingDomainAcl

# Local Admin Access
Find-LocalAdminAccess
Find-WMILocalAdminAccess
Find-PSRemotingLocalAdminAccess

# Logged-On Users
Get-NetLoggedon -ComputerName DC01
Get-NetSession -ComputerName DC01
Get-RegLoggedOn -ComputerName DC01

# Shares
Find-DomainShare
Find-DomainShare -CheckShareAccess
Get-NetShare -ComputerName DC01

# Files
Find-InterestingDomainShareFile
Find-InterestingFile -Path \\server\share\

# SPN Enumeration
Get-DomainUser -SPN
Get-DomainComputer -SPN

# Kerberoast Enumeration
Get-DomainUser -SPN | select samaccountname,serviceprincipalname

# ASREP Roast Enumeration
Get-DomainUser -PreauthNotRequired

# Delegation Enumeration
Get-DomainUser -TrustedToAuth
Get-DomainComputer -TrustedToAuth
Get-DomainComputer -Unconstrained

# DNS Enumeration
Get-DomainDNSZone
Get-DomainDNSRecord

# Enumerate Domain Admins
Get-DomainGroupMember "Domain Admins"

# Enumerate Enterprise Admins
Get-DomainGroupMember "Enterprise Admins"

# Enumerate Schema Admins
Get-DomainGroupMember "Schema Admins"

# Enumerate Backup Operators
Get-DomainGroupMember "Backup Operators"

# Enumerate Account Operators
Get-DomainGroupMember "Account Operators"

# Enumerate Remote Desktop Users
Get-DomainGroupMember "Remote Desktop Users"

# Enumerate SQL Servers
Get-DomainComputer | ? {$_.serviceprincipalname -like "*MSSQL*"}

# Enumerate Exchange Servers
Get-DomainComputer | ? {$_.name -like "*EXCH*"}

# Enumerate Disabled Users
Get-DomainUser -UACFilter ACCOUNTDISABLE

# Enumerate Locked Accounts
Get-DomainUser -LDAPFilter "(lockoutTime>=1)"

# Enumerate Password Policies
Get-DomainPolicy
(Get-DomainPolicy)."System Access"

# Enumerate Fine-Grained Password Policies
Get-DomainFineGrainedPasswordPolicy

# Enumerate LAPS
Get-DomainOU
Get-DomainComputer | Get-ADObject -Properties ms-Mcs-AdmPwd

# Enumerate BitLocker Keys
Get-DomainObject -LDAPFilter '(objectclass=msFVE-RecoveryInformation)'

# Enumerate RDP Sessions
Get-NetRDPSession -ComputerName DC01

# Enumerate Processes
Get-NetProcess -ComputerName DC01

# Enumerate Services
Get-NetService -ComputerName DC01

# Enumerate Local Groups
Get-NetLocalGroup -ComputerName DC01
Get-NetLocalGroupMember -ComputerName DC01 -GroupName Administrators

# Enumerate Current User
Get-DomainUser -Identity $env:USERNAME

# Enumerate Current Domain
Get-Domain

# Enumerate Current Forest
Get-Forest

# Search Description Fields
Get-DomainUser -LDAPFilter "(description=*)" | select samaccountname,description

# Search for Passwords
Get-DomainUser -Properties description | ? {$_.description -like "*pass*"}

# BloodHound Collection
Invoke-BloodHound -CollectionMethod All
Invoke-BloodHound -CollectionMethod Session
Invoke-BloodHound -CollectionMethod ACL
Invoke-BloodHound -CollectionMethod LocalAdmin

# Export Results
Get-DomainUser > users.txt
Get-DomainComputer > computers.txt

# Common OSCP Commands
Get-Domain
Get-DomainController
Get-DomainUser
Get-DomainComputer
Get-DomainGroup
Get-DomainGroupMember "Domain Admins"
Get-DomainUser -SPN
Get-DomainUser -PreauthNotRequired
Find-LocalAdminAccess
Find-DomainShare
Find-InterestingDomainShareFile
Get-DomainTrust
Find-InterestingDomainAcl
Invoke-BloodHound -CollectionMethod All
```
