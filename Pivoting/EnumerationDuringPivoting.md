# Internal Network Enumeration Cheat Sheet (OSCP / GPEN)

This cheat sheet is designed for **pivot scenarios where Nmap does not work reliably** (e.g., ProxyChains + SOCKS tunnel).  
In those situations, you must rely on **manual enumeration** using application-layer tools.

The methodology is based on:

```
Reach → Identify Service → Enumerate → Exploit
```

---

# 1. Identify Internal Hosts

If Nmap discovery does not work:

### Try connecting manually

```bash
proxychains nc -nv TARGET_IP 80
proxychains nc -nv TARGET_IP 445
proxychains nc -nv TARGET_IP 21
```

Example:

```bash
proxychains nc -nv 192.168.135.114 80
```

### Check routing

```bash
ip route
arp -a
```

### If pivot access is available

Run from the pivot host:

```bash
arp -a
ip neigh
```

---

# 2. Identify Open Ports (Manual Port Scanning)

When Nmap fails, manually test common ports.

```bash
proxychains nc -nv TARGET 21
proxychains nc -nv TARGET 22
proxychains nc -nv TARGET 23
proxychains nc -nv TARGET 25
proxychains nc -nv TARGET 80
proxychains nc -nv TARGET 139
proxychains nc -nv TARGET 445
proxychains nc -nv TARGET 3306
```

Quick loop example:

```bash
for p in 21 22 23 25 80 139 445 3306; do proxychains nc -nv TARGET $p; done
```

---

# 3. HTTP Enumeration

### Retrieve page

```bash
proxychains curl http://TARGET
```

### View headers

```bash
proxychains curl -I http://TARGET
```

### Directory enumeration

```bash
proxychains gobuster dir -u http://TARGET -w /usr/share/wordlists/dirb/common.txt
```

### Check common paths

```
/admin
/login
/phpmyadmin
/dev
/test
/backup
/config
```

---

# 4. FTP Enumeration

### Connect

```bash
proxychains ftp TARGET
```

Try anonymous login:

```
anonymous
anonymous
```

### List files

```
ls
get file
```

### Check banner

```bash
proxychains nc TARGET 21
```

Example vulnerable versions:

```
vsftpd 2.3.4
ProFTPD
```

---

# 5. SSH Enumeration

Check version:

```bash
proxychains nc TARGET 22
```

Attempt login:

```bash
proxychains ssh user@TARGET
```

If credentials discovered:

```bash
ssh user@TARGET
```

---

# 6. SMB Enumeration

List shares:

```bash
proxychains smbclient -L //TARGET
```

Connect to share:

```bash
proxychains smbclient //TARGET/share
```

Enumerate users:

```bash
proxychains enum4linux TARGET
```

Check SMB version:

```bash
proxychains nmap -p445 --script smb-protocols TARGET
```

---

# 7. Telnet Enumeration

Connect:

```bash
proxychains telnet TARGET
```

Look for login prompt.

Example:

```
login:
password:
```

---

# 8. SMTP Enumeration

Connect:

```bash
proxychains nc TARGET 25
```

Check commands:

```
HELO attacker
VRFY root
VRFY admin
VRFY user
```

Try enumeration:

```bash
proxychains smtp-user-enum -M VRFY -U users.txt -t TARGET
```

---

# 9. MySQL Enumeration

Connect:

```bash
proxychains mysql -h TARGET -u root
```

Check version:

```bash
proxychains nc TARGET 3306
```

---

# 10. SNMP Enumeration

Check port:

```bash
proxychains nc TARGET 161
```

Enumerate:

```bash
proxychains snmpwalk -c public -v1 TARGET
```

---

# 11. Web Application Enumeration

Look for:

```
login panels
file upload
admin dashboards
API endpoints
```

Tools:

```bash
proxychains gobuster
proxychains curl
```

---

# 12. Credential Testing

If credentials are discovered:

### SSH

```bash
proxychains ssh user@TARGET
```

### SMB

```bash
proxychains smbclient -U user //TARGET/share
```

### FTP

```bash
proxychains ftp TARGET
```

---

# 13. Quick Service Identification

Use netcat to detect banners:

```bash
proxychains nc TARGET 21
proxychains nc TARGET 22
proxychains nc TARGET 25
proxychains nc TARGET 80
```

Example banner:

```
220 (vsFTPd 2.3.4)
```

---

# 14. Web App Targets (Common on Exams)

Check:

```
DVWA
Mutillidae
phpMyAdmin
Joomla
WordPress
Drupal
```

Enumerate versions:

```bash
proxychains curl http://TARGET
```

---

# 15. Pivot Enumeration Workflow

Step-by-step:

1. Identify internal network
2. Verify pivot connectivity
3. Identify host
4. Identify open ports
5. Enumerate services
6. Identify vulnerabilities
7. Exploit

---

# 16. Fast Enumeration Strategy

If scanning is unreliable:

```
1 host → test 10 common ports → enumerate services
```

Example:

```bash
proxychains nc TARGET 21
proxychains nc TARGET 22
proxychains nc TARGET 23
proxychains nc TARGET 25
proxychains nc TARGET 80
proxychains nc TARGET 445
```

---

# 17. Common Exam Targets

Typical vulnerable services:

```
FTP (vsftpd)
SMB
Telnet
Apache
Tomcat
MySQL
```

---

# 18. Troubleshooting

### Proxy not working

Check:

```
proxychains curl http://TARGET
```

### Pivot connectivity

Verify from pivot machine:

```bash
nc -nv TARGET PORT
```

---

# 19. Quick Command Reference

HTTP

```bash
proxychains curl http://TARGET
```

FTP

```bash
proxychains ftp TARGET
```

SMB

```bash
proxychains smbclient -L //TARGET
```

SSH

```bash
proxychains ssh user@TARGET
```

SMTP

```bash
proxychains nc TARGET 25
```

---

# 20. Final Exam Advice

When pivoting:

```
Do not rely on Nmap.
```

Focus on:

```
manual enumeration
service interaction
application-layer tools
```

If you can **reach the service**, you can **enumerate and exploit it**.
