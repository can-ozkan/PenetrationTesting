# AD Enumeration

# Enumeration through Microsoft Management Console

Install: RSAT: Active Directory Domain Services and Lightweight Directory Tools 

```
xfreerdp /u:<username>@za.tryhackme.com /p:'Erzk9490' /v:thmjmp1.za.tryhackme.com /cert:ignore
```
Search for 'Active Directory Users and Computers' and look at organizational units, etc, etc.

---


# 🧠 Active Directory Enumeration (CMD) — Cheat Sheet

```
net user /domain
net user zoe.marshall /domain
net group /domain
net group "Tier 1 Admins" /domain
net accounts /domain
```

```
whoami
whoami /all
whoami /priv
whoami /groups
```

## 👤 User Enumeration

```cmd
net user /domain
net user <username> /domain
net user /domain | findstr /i "admin svc backup"
```

---

## 👥 Group Enumeration

```cmd
net group /domain
net group "Domain Admins" /domain
net group "Enterprise Admins" /domain
net group "Administrators" /domain
net group "Backup Operators" /domain
net group "Tier 1 Admins" /domain
```

---

## 🧑‍🤝‍🧑 Group Membership

```cmd
net group "Domain Admins" /domain
net group "Administrators" /domain
net user <username> /domain
```

---

## 🏢 Domain Information

```cmd
net accounts /domain
nltest /dsgetdc:za.tryhackme.com
nltest /domain_trusts
echo %USERDOMAIN%
```

---

## 🖥 Computer Enumeration

```cmd
net view /domain
net view \\thmdc
net view \\<hostname>
```

---

## 📂 Share Enumeration

```cmd
net share
net view \\<hostname>
```

---

## 🌐 Network Enumeration

```cmd
ipconfig /all
arp -a
route print
netstat -ano
```

---

## 🔐 Credential Hunting

```cmd
cmdkey /list
```

---

## 🔍 File Search (Passwords)

```cmd
dir C:\ /s /b | findstr /i "password"
findstr /si password *.txt *.xml *.ini *.config
```

---

## ⚙️ System Enumeration

```cmd
whoami
whoami /all
whoami /priv
whoami /groups
hostname
systeminfo
```

---

## 🔗 Sessions

```cmd
query user
query session
```

---

## ⚡ Quick High-Value Commands

```cmd
whoami /all
net user /domain
net group "Domain Admins" /domain
nltest /dsgetdc:za.tryhackme.com
net view \\thmdc
cmdkey /list
```

```

# Enumeration through PowerShell

```
Get-ADUser -Identity gordon.stevens -Server za.tryhackme.com -Properties *
Get-ADUser -Filter 'Name -like "*stevens"' -Server za.tryhackme.com | Format-Table Name,SamAccountName -A
Get-ADGroup -Identity Administrators -Server za.tryhackme.com
Get-ADGroupMember -Identity Administrators -Server za.tryhackme.com
Get-ADDomain -Server za.tryhackme.com

```

# 🧠 Active Directory Enumeration (PowerShell) — Cheat Sheet

## 👤 User Enumeration

```powershell
Get-ADUser -Filter * -Server za.tryhackme.com
Get-ADUser -Identity <user> -Server za.tryhackme.com -Properties *
Get-ADUser -Filter 'Name -like "*stevens"' -Server za.tryhackme.com | Format-Table Name,SamAccountName -A
Get-ADUser -Filter * -Server za.tryhackme.com -Properties DisplayName,EmailAddress,LastLogonDate | Select Name,SamAccountName,EmailAddress,LastLogonDate
Get-ADUser -Filter {ServicePrincipalName -ne "$null"} -Server za.tryhackme.com -Properties ServicePrincipalName
Get-ADUser -Filter {Enabled -eq $false} -Server za.tryhackme.com
Get-ADUser -Filter {PasswordNeverExpires -eq $true} -Server za.tryhackme.com
Get-ADUser -Filter * -Server za.tryhackme.com -Properties LastLogonDate | Sort LastLogonDate -Descending
```

---

## 👥 Group Enumeration

```powershell
Get-ADGroup -Filter * -Server za.tryhackme.com
Get-ADGroup -Identity "Administrators" -Server za.tryhackme.com
Get-ADGroup -Identity "Domain Admins" -Server za.tryhackme.com
Get-ADGroup -Identity "Enterprise Admins" -Server za.tryhackme.com
Get-ADGroupMember -Identity "Administrators" -Server za.tryhackme.com
Get-ADGroupMember -Identity "Domain Admins" -Recursive -Server za.tryhackme.com
Get-ADPrincipalGroupMembership <user> -Server za.tryhackme.com
```

---

## 🖥 Computer Enumeration

```powershell
Get-ADComputer -Filter * -Server za.tryhackme.com
Get-ADComputer -Filter * -Server za.tryhackme.com -Properties OperatingSystem,LastLogonDate | Select Name,OperatingSystem,LastLogonDate
Get-ADDomainController -Filter * -Server za.tryhackme.com
```

---

## 🌐 Domain & Forest Enumeration

```powershell
Get-ADDomain -Server za.tryhackme.com
Get-ADForest -Server za.tryhackme.com
Get-ADTrust -Filter * -Server za.tryhackme.com
```

---

## 🔐 Credential & Attack Surface Enumeration

```powershell
Get-ADUser -Filter {TrustedForDelegation -eq $true} -Server za.tryhackme.com
Get-ADUser -Filter {msDS-AllowedToDelegateTo -ne "$null"} -Server za.tryhackme.com -Properties msDS-AllowedToDelegateTo
Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Server za.tryhackme.com
```

---

## 🗂 Organizational Units

```powershell
Get-ADOrganizationalUnit -Filter * -Server za.tryhackme.com
```

---

## 📂 GPO Enumeration

```powershell
Get-GPO -All
Get-GPOReport -All -ReportType Html -Path gpo.html
```

---

## 🧾 LDAP / Object Enumeration

```powershell
Get-ADObject -Filter * -Server za.tryhackme.com
```

---

## ⚡ Quick High-Value Commands

```powershell
Get-ADUser -Filter * -Server za.tryhackme.com
Get-ADGroup -Filter * -Server za.tryhackme.com
Get-ADGroupMember "Domain Admins" -Server za.tryhackme.com
Get-ADComputer -Filter * -Server za.tryhackme.com
Get-ADDomainController -Filter * -Server za.tryhackme.com
```
