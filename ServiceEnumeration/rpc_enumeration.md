# RPC Enumeration Cheat Sheet (GPEN & OSCP)

> **Goal:** Enumerate Windows systems and Active Directory via MSRPC (TCP/135, SMB Named Pipes, Dynamic RPC Ports) to identify users, groups, shares, domain information, and potential attack paths.
querydispinfo enumerates the description field. So you can catch passwords

---

# 1. Identify RPC Services

## Nmap

```bash
nmap -Pn -sV -sC -p135,139,445 TARGET
```

---

## Full TCP Scan

```bash
nmap -Pn -p- TARGET
```

Look for:

- 135 (MSRPC)
- 139 (NetBIOS)
- 445 (SMB)
- 593 (RPC over HTTP)
- Dynamic Ports (49152-65535)

---

## Detect Dynamic RPC Ports

```bash
nmap -Pn -sV --script msrpc-enum TARGET
```

---

# 2. rpcclient Basics

Anonymous:

```bash
rpcclient -U "" -N TARGET
```

Authenticated:

```bash
rpcclient -U DOMAIN\\USER TARGET
```

Pass the password when prompted.

---

# 3. rpcclient Help

Inside rpcclient:

```text
help
```

or

```text
?
```

---

# 4. Domain Enumeration

## Domain Information

```text
querydominfo
```

---

## Domain SID

```text
lsaquery
```

Example:

```
Domain SID: S-1-5-21-XXXXXXXXXX
```

---

## Domain Controllers

```text
dsroledominfo
```

---

# 5. User Enumeration

## Enumerate Users

```text
enumdomusers
```

---

## Query User by RID

```text
queryuser RID
```

Example:

```text
queryuser 0x1f4
```

---

## Lookup RID

```text
lookupsids SID
```

Example:

```text
lookupsids S-1-5-21-XXXX-500
```

---

## Lookup Name

```text
lookupnames Administrator
```

---

## Get User Groups

```text
queryusergroups RID
```

---

## Password Policy

```text
getdompwinfo
```

---

# 6. Group Enumeration

## List Groups

```text
enumdomgroups
```

---

## Query Group

```text
querygroup RID
```

---

## Group Members

```text
querygroupmem RID
```

---

## Built-in Groups

```text
enumalsgroups builtin
```

---

## Local Groups

```text
enumalsgroups domain
```

---

# 7. SID Bruteforce

## Enumerate RIDs

Using Impacket:

```bash
lookupsid.py anonymous@TARGET
```

---

Using CrackMapExec:

```bash
crackmapexec smb TARGET --rid-brute
```

---

Using NetExec:

```bash
netexec smb TARGET --rid-brute
```

---

# 8. Shares

Using SMB:

```bash
smbclient -L //TARGET -N
```

---

Authenticated:

```bash
smbclient -L //TARGET -U USER
```

---

NetExec

```bash
netexec smb TARGET -u USER -p PASSWORD --shares
```

---

# 9. Sessions

```text
netsessenum
```

---

# 10. Workstations

```text
enumstations
```

---

# 11. Trusted Domains

```text
enumtrust
```

---

# 12. Password Policy

```text
getdompwinfo
```

Shows:

- Minimum password length
- Password history
- Lockout threshold
- Password age

---

# 13. Printer Enumeration

```text
enumprinters
```

---

# 14. Services

Using Impacket:

```bash
services.py DOMAIN/USER:PASSWORD@TARGET
```

---

Using smbclient

```bash
rpcclient -U USER TARGET
```

```text
enumservices
```

---

# 15. Scheduled Tasks

```bash
atexec.py DOMAIN/USER:PASSWORD@TARGET
```

---

# 16. SAMR Enumeration

Using rpcclient

```text
lsaquery
enumdomusers
enumdomgroups
queryuser
querygroup
```

---

Using enum4linux-ng

```bash
enum4linux-ng TARGET
```

---

# 17. Endpoint Mapper

Using rpcdump.py

```bash
rpcdump.py TARGET
```

Lists:

- Registered interfaces
- UUIDs
- Dynamic endpoints

---

# 18. SMB Named Pipes

Using rpcdump:

```bash
rpcdump.py TARGET
```

Interesting pipes:

- samr
- lsarpc
- srvsvc
- netlogon
- wkssvc
- spoolss
- eventlog

---

# 19. SMB Enumeration

Anonymous

```bash
smbclient -L //TARGET -N
```

---

Recursive Download

```bash
smbclient //TARGET/SHARE -N

recurse ON
prompt OFF
mget *
```

---

# 20. enum4linux-ng

Basic

```bash
enum4linux-ng TARGET
```

Everything

```bash
enum4linux-ng -A TARGET
```

---

# 21. NetExec (CrackMapExec Successor)

Anonymous

```bash
netexec smb TARGET
```

---

Authenticated

```bash
netexec smb TARGET -u USER -p PASSWORD
```

---

Users

```bash
netexec smb TARGET -u USER -p PASSWORD --users
```

---

Groups

```bash
netexec smb TARGET -u USER -p PASSWORD --groups
```

---

Shares

```bash
netexec smb TARGET -u USER -p PASSWORD --shares
```

---

Sessions

```bash
netexec smb TARGET -u USER -p PASSWORD --sessions
```

---

Logged-on Users

```bash
netexec smb TARGET -u USER -p PASSWORD --loggedon-users
```

---

Local Admin Check

```bash
netexec smb TARGET -u USER -p PASSWORD
```

Look for:

```
(Pwn3d!)
```

---

# 22. CrackMapExec (Legacy)

```bash
crackmapexec smb TARGET
```

---

RID Bruteforce

```bash
crackmapexec smb TARGET --rid-brute
```

---

Shares

```bash
crackmapexec smb TARGET --shares
```

---

Users

```bash
crackmapexec smb TARGET --users
```

---

# 23. Impacket Tools

rpcdump

```bash
rpcdump.py TARGET
```

---

lookupsid

```bash
lookupsid.py DOMAIN/USER:PASSWORD@TARGET
```

---

samrdump

```bash
samrdump.py TARGET
```

---

GetADUsers

```bash
GetADUsers.py DOMAIN/USER:PASSWORD
```

---

GetNPUsers

```bash
GetNPUsers.py DOMAIN/ -usersfile users.txt
```

---

GetUserSPNs

```bash
GetUserSPNs.py DOMAIN/USER:PASSWORD
```

---

# 24. Common Anonymous Enumeration

```bash
rpcclient -U "" -N TARGET
```

Try:

```text
lsaquery
querydominfo
enumdomusers
enumdomgroups
enumalsgroups builtin
getdompwinfo
```

---

# 25. Common Authenticated Enumeration

```bash
rpcclient -U DOMAIN\\USER TARGET
```

Run:

```text
lsaquery
querydominfo
enumdomusers
enumdomgroups
querygroup
querygroupmem
queryuser
getdompwinfo
enumtrust
```

---

# 26. Typical OSCP Enumeration Flow

1. Nmap
2. Check SMB
3. Check Anonymous SMB
4. rpcclient anonymous
5. enum4linux-ng
6. NetExec SMB
7. RID brute
8. Enumerate users
9. Enumerate groups
10. Enumerate shares
11. Download interesting files
12. Password spraying (if permitted)
13. BloodHound collection
14. Kerberoasting
15. Lateral movement

---

# 27. Typical GPEN Workflow

1. Nmap service detection
2. Endpoint mapper
3. RPC anonymous enumeration
4. SMB enumeration
5. Domain information
6. User enumeration
7. Group enumeration
8. SID brute force
9. Password policy
10. Share enumeration
11. BloodHound
12. Kerberos attacks
13. AD privilege escalation

---

# 28. High-Value rpcclient Commands

| Command | Description |
|----------|-------------|
| help | Show commands |
| lsaquery | Domain SID |
| querydominfo | Domain information |
| enumdomusers | Enumerate users |
| enumdomgroups | Enumerate groups |
| enumalsgroups builtin | Built-in groups |
| enumalsgroups domain | Local/domain alias groups |
| queryuser RID | User details |
| querygroup RID | Group details |
| querygroupmem RID | Group members |
| queryusergroups RID | User's groups |
| lookupnames NAME | Resolve name to SID |
| lookupsids SID | Resolve SID to name |
| getdompwinfo | Password policy |
| enumtrust | Trust relationships |
| dsroledominfo | Domain controller info |
| enumprinters | Printer enumeration |
| netsessenum | Active sessions |
| enumstations | Workstations |

---

# 29. Common RID Values

| RID | Account |
|------|----------|
| 500 | Administrator |
| 501 | Guest |
| 502 | KRBTGT |
| 512 | Domain Admins |
| 513 | Domain Users |
| 514 | Domain Guests |
| 515 | Domain Computers |
| 516 | Domain Controllers |
| 517 | Cert Publishers |
| 518 | Schema Admins |
| 519 | Enterprise Admins |
| 520 | Group Policy Creator Owners |

---

# 30. Exam Tips

- Always test anonymous RPC access before authenticating.
- Record the Domain SID early—it is useful for RID brute-forcing and SID resolution.
- Use `enum4linux-ng` for quick wins, but verify findings manually with `rpcclient`.
- Combine RPC results with SMB enumeration to locate sensitive files.
- Check password policy before password spraying.
- RID brute-force can reveal users even when LDAP enumeration is blocked.
- If valid credentials are obtained, immediately re-run authenticated RPC enumeration and collect BloodHound data.
- Document user, group, and trust relationships—they often reveal privilege escalation paths.
