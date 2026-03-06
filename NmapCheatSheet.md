# Nmap Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured reference for Nmap usage** during **OSCP and GPEN exams**. Nmap is one of the most important tools for **network discovery, service enumeration, and vulnerability detection**.

Core methodology:

```
Host Discovery → Port Scanning → Service Enumeration → OS Detection → Script Scanning → Targeted Enumeration
```

---

# 1. Basic Nmap Scan

Scan a single host:

```bash
nmap TARGET_IP
```

Scan multiple hosts:

```bash
nmap TARGET_IP1 TARGET_IP2
```

Scan a subnet:

```bash
nmap 192.168.1.0/24
```

---

# 2. Host Discovery (Ping Sweep)

Discover live hosts:

```bash
nmap -sn 192.168.1.0/24
```

Disable host discovery (treat host as alive):

```bash
nmap -Pn TARGET_IP
```

Useful when ICMP is blocked.

---

# 3. Port Scanning

### Default Scan

```bash
nmap TARGET_IP
```

Scans **top 1000 ports**.

---

### Full Port Scan

Scan all ports:

```bash
nmap -p- TARGET_IP
```

Recommended during OSCP exams.

---

### Specific Ports

Scan specific ports:

```bash
nmap -p 21,22,80,443 TARGET_IP
```

Scan range:

```bash
nmap -p 1-1000 TARGET_IP
```

---

# 4. TCP Scan Types

### SYN Scan (Stealth Scan)

```bash
nmap -sS TARGET_IP
```

Requires root privileges.

---

### TCP Connect Scan

```bash
nmap -sT TARGET_IP
```

Used when not running as root.

---

### UDP Scan

```bash
nmap -sU TARGET_IP
```

Scan UDP ports.

Example:

```bash
nmap -sU -p 53,161 TARGET_IP
```

---

# 5. Service Detection

Detect service versions:

```bash
nmap -sV TARGET_IP
```

Example output:

```
22/tcp open  ssh  OpenSSH 7.6
```

---

# 6. OS Detection

Detect operating system:

```bash
nmap -O TARGET_IP
```

---

# 7. Aggressive Scan

Run multiple scans together:

```bash
nmap -A TARGET_IP
```

Includes:

```
OS detection
service detection
script scanning
traceroute
```

---

# 8. Default Scripts

Run default scripts:

```bash
nmap -sC TARGET_IP
```

Scripts include:

```
FTP anonymous login
HTTP enumeration
SSL checks
```

---

# 9. Recommended OSCP Scan

Typical enumeration scan:

```bash
nmap -p- -sC -sV -T4 TARGET_IP
```

Meaning:

```
-p-   → all ports
-sC   → default scripts
-sV   → version detection
-T4   → faster scan
```

---

# 10. Timing Options

Timing templates:

| Option | Speed |
|------|------|
| -T0 | paranoid |
| -T1 | sneaky |
| -T2 | polite |
| -T3 | normal |
| -T4 | aggressive |
| -T5 | insane |

Example:

```bash
nmap -T4 TARGET_IP
```

---

# 11. Output Options

Save results:

```bash
nmap -oN scan.txt TARGET_IP
```

XML output:

```bash
nmap -oX scan.xml TARGET_IP
```

All formats:

```bash
nmap -oA scan TARGET_IP
```

---

# 12. Scan Multiple Targets

Using file:

```bash
nmap -iL targets.txt
```

---

# 13. Exclude Hosts

Exclude IP:

```bash
nmap --exclude TARGET_IP
```

Exclude file:

```bash
nmap --excludefile blacklist.txt
```

---

# 14. Service Enumeration Scripts

Example:

### SMB scripts

```bash
nmap --script smb-enum-shares -p445 TARGET_IP
```

### HTTP scripts

```bash
nmap --script http-enum -p80 TARGET_IP
```

### FTP scripts

```bash
nmap --script ftp-anon -p21 TARGET_IP
```

---

# 15. Vulnerability Scanning

Run vulnerability scripts:

```bash
nmap --script vuln TARGET_IP
```

Example output:

```
smb-vuln-ms17-010
```

---

# 16. Banner Grabbing

Retrieve service banners:

```bash
nmap -sV TARGET_IP
```

Or:

```bash
nmap --script=banner TARGET_IP
```

---

# 17. NSE Script Categories

Categories include:

```
auth
broadcast
brute
default
discovery
exploit
external
fuzzer
intrusive
malware
safe
version
vuln
```

Example:

```bash
nmap --script discovery TARGET_IP
```

---

# 18. Script Help

List scripts:

```bash
ls /usr/share/nmap/scripts/
```

Script documentation:

```bash
nmap --script-help script_name
```

---

# 19. Firewall Evasion

Fragment packets:

```bash
nmap -f TARGET_IP
```

Decoy scan:

```bash
nmap -D RND:10 TARGET_IP
```

Spoof source port:

```bash
nmap --source-port 53 TARGET_IP
```

---

# 20. Scan Speed Optimization

Increase speed:

```bash
nmap --min-rate 1000 TARGET_IP
```

Limit retries:

```bash
nmap --max-retries 2 TARGET_IP
```

---

# 21. Detect Open Ports Only

Show open ports only:

```bash
nmap --open TARGET_IP
```

---

# 22. Detect Hosts on Network

ARP scan (local network):

```bash
nmap -PR 192.168.1.0/24
```

---

# 23. NSE Script Examples

### SMB enumeration

```bash
nmap --script smb-enum-users -p445 TARGET_IP
```

### SNMP enumeration

```bash
nmap --script snmp-info -p161 TARGET_IP
```

### HTTP directory discovery

```bash
nmap --script http-enum -p80 TARGET_IP
```

---

# 24. Useful Scan Examples

Full TCP scan:

```bash
nmap -p- -sS TARGET_IP
```

Service detection:

```bash
nmap -sV TARGET_IP
```

Vulnerability scan:

```bash
nmap --script vuln TARGET_IP
```

---

# 25. OSCP Enumeration Workflow

```
1. Discover hosts
2. Perform full port scan
3. Identify services
4. Run service scripts
5. Investigate each service
```

---

# 26. Common Ports to Focus On

```
21  FTP
22  SSH
23  Telnet
25  SMTP
53  DNS
80  HTTP
110 POP3
139 SMB
143 IMAP
443 HTTPS
445 SMB
3306 MySQL
3389 RDP
8080 HTTP proxy
```

---

# 27. Combining Scans

Example full scan:

```bash
nmap -p- -sS -sV -sC -T4 TARGET_IP
```

---

# 28. Quick Nmap Commands

Host discovery:

```bash
nmap -sn 192.168.1.0/24
```

Full scan:

```bash
nmap -p- TARGET_IP
```

Service detection:

```bash
nmap -sV TARGET_IP
```

Default scripts:

```bash
nmap -sC TARGET_IP
```

---

# 29. Troubleshooting Nmap

If host appears down:

```bash
nmap -Pn TARGET_IP
```

If scan too slow:

```bash
nmap -T4 TARGET_IP
```

---

# 30. Final Advice

During OSCP/GPEN exams:

```
Always perform a full port scan first.
```

Most exam machines hide services on **non-standard ports**, so missing them can delay exploitation.

Remember:

```
Enumeration wins the exam.
```
