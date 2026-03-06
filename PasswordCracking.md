# Password Cracking Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured methodology for password cracking** commonly required during **OSCP and GPEN exams**. It focuses on identifying hash types, selecting appropriate attacks, and using common cracking tools efficiently.

Core methodology:

```
Identify Hash → Select Attack Method → Use Wordlists/Rules → Crack Password → Reuse Credentials
```

Password cracking is often about **choosing the right tool and attack strategy**.

---

# 1. Identify Hash Type

Always identify the hash before cracking.

### Hash Identification Tools

```bash
hashid <hash>
```

```bash
hash-identifier
```

Example:

```
5f4dcc3b5aa765d61d8327deb882cf99
```

Likely:

```
MD5
```

---

# 2. Common Hash Types

| Hash Type | Example |
|----------|---------|
| MD5 | `5f4dcc3b5aa765d61d8327deb882cf99` |
| SHA1 | `356a192b7913b04c54574d18c28d46e6395428ab` |
| SHA256 | long 64-character hex |
| NTLM | Windows password hashes |
| bcrypt | `$2y$...` |
| Kerberos | `$krb5tgs$...` |

---

# 3. John the Ripper

### Basic usage

```bash
john hash.txt
```

### Specify format

```bash
john --format=nt hash.txt
```

### Show cracked passwords

```bash
john --show hash.txt
```

### Wordlist attack

```bash
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

---

# 4. Hashcat

Hashcat is the **fastest GPU-based cracker**.

### Basic syntax

```bash
hashcat -m <mode> -a <attack_mode> hash.txt wordlist.txt
```

Example:

```bash
hashcat -m 0 -a 0 hash.txt rockyou.txt
```

---

# 5. Hashcat Modes (Common)

| Mode | Hash |
|-----|------|
| 0 | MD5 |
| 100 | SHA1 |
| 1400 | SHA256 |
| 1000 | NTLM |
| 1800 | sha512crypt |
| 3200 | bcrypt |
| 13100 | Kerberos TGS |

---

# 6. Attack Types

| Attack | Mode |
|------|------|
| Dictionary | `-a 0` |
| Combination | `-a 1` |
| Brute force | `-a 3` |
| Hybrid | `-a 6` / `-a 7` |

---

# 7. Dictionary Attack

Use common password lists.

```bash
hashcat -m 1000 -a 0 hash.txt rockyou.txt
```

Common wordlists:

```
rockyou.txt
SecLists passwords
top1000
```

---

# 8. Rule-Based Attacks

Rules modify dictionary words.

Example:

```bash
hashcat -m 1000 -a 0 hash.txt rockyou.txt -r rules/best64.rule
```

Common rules:

```
best64.rule
rockyou-30000.rule
```

---

# 9. Mask Attacks (Brute Force)

Example:

```bash
hashcat -m 1000 -a 3 hash.txt ?d?d?d?d
```

Character sets:

```
?l = lowercase
?u = uppercase
?d = digits
?s = symbols
?a = all
```

Example:

```
Password pattern: Summer2023
Mask: ?u?l?l?l?l?l?d?d?d?d
```

---

# 10. Hybrid Attacks

Dictionary + mask.

Example:

```bash
hashcat -m 1000 -a 6 hash.txt rockyou.txt ?d?d
```

Example passwords:

```
password12
admin99
```

---

# 11. NTLM Hash Cracking

NTLM hashes appear in Windows systems.

Example:

```
aad3b435b51404eeaad3b435b51404ee:5f4dcc3b5aa765d61d8327deb882cf99
```

Crack using Hashcat:

```bash
hashcat -m 1000 -a 0 ntlm.txt rockyou.txt
```

---

# 12. Kerberos Hash Cracking (Kerberoasting)

Crack service ticket hashes.

Example:

```bash
hashcat -m 13100 hash.txt rockyou.txt
```

Or using John:

```bash
john --wordlist=rockyou.txt hash.txt
```

---

# 13. Zip Password Cracking

Extract hash:

```bash
zip2john file.zip > hash.txt
```

Crack:

```bash
john hash.txt
```

---

# 14. SSH Key Cracking

Convert key:

```bash
ssh2john id_rsa > hash.txt
```

Crack:

```bash
john hash.txt
```

---

# 15. Office Document Cracking

Extract hash:

```bash
office2john file.docx > hash.txt
```

Crack:

```bash
john hash.txt
```

---

# 16. PDF Password Cracking

Extract hash:

```bash
pdf2john file.pdf > hash.txt
```

Crack:

```bash
john hash.txt
```

---

# 17. Wordlist Generation

Generate custom wordlists.

### Crunch

```bash
crunch 6 8 abc123
```

### CeWL (website scraping)

```bash
cewl http://target -w wordlist.txt
```

---

# 18. Username-Based Passwords

Common patterns:

```
username123
username2023
companyname1
```

Generate list:

```bash
cupp -i
```

---

# 19. Password Reuse

Always test cracked passwords across services.

Example:

```
SSH
FTP
SMB
Web login
RDP
```

Tools:

```bash
crackmapexec
hydra
```

---

# 20. Hydra Password Attacks

Example:

```bash
hydra -l admin -P rockyou.txt ssh://TARGET
```

FTP:

```bash
hydra -l user -P rockyou.txt ftp://TARGET
```

---

# 21. CrackMapExec Credential Testing

Test credentials across network:

```bash
crackmapexec smb 192.168.1.0/24 -u users.txt -p passwords.txt
```

---

# 22. Important Wordlists

Common wordlists:

```
/usr/share/wordlists/rockyou.txt
SecLists
weakpass
top1000
```

---

# 23. Quick Password Cracking Workflow

```
1. Identify hash
2. Try dictionary attack
3. Try rule-based attack
4. Try hybrid attack
5. Try mask attack
6. Test cracked credentials
```

---

# 24. Fast Commands

Identify hash:

```bash
hashid hash.txt
```

Crack with John:

```bash
john --wordlist=rockyou.txt hash.txt
```

Crack with Hashcat:

```bash
hashcat -m 1000 -a 0 hash.txt rockyou.txt
```

---

# 25. Final Advice

Password cracking success often depends on **good wordlists and rules**, not brute force.

Always remember:

```
People reuse passwords.
People use predictable patterns.
```

Once you crack one password, **try it everywhere**.
