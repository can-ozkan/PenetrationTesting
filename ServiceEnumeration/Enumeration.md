# OSCP / GPEN Enumeration Cheat Sheet

This cheat sheet focuses on **normal enumeration when you have direct network access to a target** (no pivoting required).  
Enumeration is the **most important phase of a penetration test**. Most compromises occur because of thorough enumeration.

Core methodology:

```
Discover → Identify → Enumerate → Exploit
```

---

# 1. Host Discovery

## Ping sweep

```bash
nmap -sn 192.168.1.0/24
```

Alternative:

```bash
for i in {1..254}; do ping -c1 192.168.1.$i | grep "64 bytes"; done
```

---

# 2. Port Scanning

## Fast scan

```bash
nmap -T4 -p- 192.168.1.10
```

## Full TCP scan

```bash
nmap -p- -T4 192.168.1.10
```

## Service detection

```bash
nmap -sV -p- 192.168.1.10
```

## OS detection

```bash
nmap -O 192.168.1.10
```

## Default scripts

```bash
nmap -sC -sV 192.168.1.10
```

## Recommended full enumeration scan

```bash
nmap -p- -sC -sV -T4 -oN scan.txt 192.168.1.10
```

---

# 3. Service Enumeration

After identifying open ports, enumerate each service.

Example result:

```
21 FTP
22 SSH
80 HTTP
139 SMB
445 SMB
3306 MySQL
```

Then enumerate **each service individually**.

---

# 4. FTP Enumeration

Check version:

```bash
nmap -p21 -sV 192.168.1.10
```

Connect:

```bash
ftp 192.168.1.10
```

Try anonymous login:

```
anonymous
anonymous
```

List files:

```
ls
get file
```

---

# 5. SSH Enumeration

Check version:

```bash
nmap -p22 -sV 192.168.1.10
```

Check banner:

```bash
nc 192.168.1.10 22
```

Attempt login:

```bash
ssh user@192.168.1.10
```

If credentials exist:

```bash
ssh user@192.168.1.10
```

---

# 6. SMB Enumeration

Check SMB version:

```bash
nmap --script smb-protocols -p445 192.168.1.10
nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse MACHINE_IP
```

List shares:

```bash
smbclient -L //192.168.1.10
```

Anonymous access:

```bash
smbclient //192.168.1.10/share
```

Enumerate users:

```bash
enum4linux 192.168.1.10
```

SMB vulnerability scan:

```bash
nmap --script smb-vuln* -p445 192.168.1.10
```

---

# 7. HTTP Enumeration

Check web server:

```bash
curl http://192.168.1.10
```

Check headers:

```bash
curl -I http://192.168.1.10
```

Directory enumeration:

```bash
gobuster dir -u http://192.168.1.10 -w /usr/share/wordlists/dirb/common.txt
```

Alternative:

```bash
dirsearch -u http://192.168.1.10
```

Common directories:

```
/admin
/login
/backup
/config
/uploads
/dev
/test
/phpmyadmin
```

---

# 8. Web Application Enumeration

Identify technology:

```bash
whatweb http://192.168.1.10
```

Detect CMS:

```bash
wpscan --url http://192.168.1.10
```

Check for:

```
file upload
login panels
admin interfaces
API endpoints
```

---

# 9. SMTP Enumeration

Connect:

```bash
nc 192.168.1.10 25
```

Check commands:

```
HELO attacker
VRFY root
VRFY admin
VRFY user
```

Enumerate users:

```bash
smtp-user-enum -M VRFY -U users.txt -t 192.168.1.10
```

---

# 10. DNS Enumeration

Zone transfer:

```bash
dig axfr @192.168.1.10 domain.com
```

Lookup records:

```bash
dig domain.com
```

Subdomain enumeration:

```bash
dnsrecon -d domain.com
```

---

# 11. SNMP Enumeration

Check SNMP:

```bash
nmap -sU -p161 192.168.1.10
```

Enumerate:

```bash
snmpwalk -c public -v1 192.168.1.10
```

Try community strings:

```
public
private
manager
```

---

# 12. MySQL Enumeration

Connect:

```bash
mysql -h 192.168.1.10 -u root
```

Check version:

```bash
nc 192.168.1.10 3306
```

Try weak credentials:

```
root:root
root:password
```

---

# 13. RDP Enumeration

Check port:

```bash
nmap -p3389 192.168.1.10
```

Connect:

```bash
xfreerdp /v:192.168.1.10
```

---

# 14. NFS Enumeration

List shares:

```bash
showmount -e 192.168.1.10
```

Mount share:

```bash
mount -t nfs 192.168.1.10:/share /mnt
```

---

# 15. Password Attacks

SSH brute force:

```bash
hydra -l user -P passwords.txt ssh://192.168.1.10
```

FTP brute force:

```bash
hydra -l user -P passwords.txt ftp://192.168.1.10
```

SMB brute force:

```bash
hydra -L users.txt -P passwords.txt smb://192.168.1.10
```

---

# 16. Search for Exploits

Use searchsploit:

```bash
searchsploit service version
```

Example:

```bash
searchsploit vsftpd 2.3.4
```

---

# 17. Important Enumeration Principles

Always:

```
Enumerate every service
Read banners carefully
Check default credentials
Search exploit-db
```

---

# 18. Recommended Enumeration Workflow

1. Host discovery  
2. Full port scan  
3. Service detection  
4. Enumerate each service  
5. Identify vulnerabilities  
6. Attempt exploitation  

---

# 19. Quick Command Summary

Full scan

```bash
nmap -p- -sC -sV -T4 TARGET
```

Directory scan

```bash
gobuster dir -u http://TARGET -w /usr/share/wordlists/dirb/common.txt
```

SMB enumeration

```bash
enum4linux TARGET
```

FTP login

```bash
ftp TARGET
```

SMTP enumeration

```bash
smtp-user-enum -M VRFY -U users.txt -t TARGET
```

---

# 20. Final Advice

Enumeration wins exams.

Always remember:

```
The more you enumerate, the easier exploitation becomes.
```

Never rush exploitation before fully understanding the target.
