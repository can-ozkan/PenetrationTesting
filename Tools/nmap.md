# Nmap Cheat Sheet

```
# Host Discovery
nmap -sn 192.168.1.0/24
nmap -Pn 10.10.10.10
nmap -PR 192.168.1.0/24
nmap -PE 10.10.10.10
nmap -PP 10.10.10.10
nmap -PM 10.10.10.10

# Basic Scans
nmap 10.10.10.10
nmap -F 10.10.10.10
nmap -p- 10.10.10.10
nmap -p 80,443,445 10.10.10.10
nmap -p 1-65535 10.10.10.10

# TCP Scans
nmap -sS 10.10.10.10
nmap -sT 10.10.10.10
nmap -sA 10.10.10.10
nmap -sW 10.10.10.10
nmap -sM 10.10.10.10
nmap -sN 10.10.10.10
nmap -sF 10.10.10.10
nmap -sX 10.10.10.10

# UDP Scans
nmap -sU 10.10.10.10
nmap -sU -p 53,67,68,69,123,161 10.10.10.10

# Service and Version Detection
nmap -sV 10.10.10.10
nmap -sV --version-light 10.10.10.10
nmap -sV --version-all 10.10.10.10
nmap -A 10.10.10.10

# OS Detection
nmap -O 10.10.10.10
nmap -O --osscan-guess 10.10.10.10

# Aggressive Scan
nmap -A 10.10.10.10
nmap -A -T4 10.10.10.10

# Timing
nmap -T0 10.10.10.10
nmap -T1 10.10.10.10
nmap -T2 10.10.10.10
nmap -T3 10.10.10.10
nmap -T4 10.10.10.10
nmap -T5 10.10.10.10

# NSE Scripts
nmap --script default 10.10.10.10
nmap --script vuln 10.10.10.10
nmap --script safe 10.10.10.10
nmap --script auth 10.10.10.10
nmap --script discovery 10.10.10.10
nmap --script smb-os-discovery 10.10.10.10
nmap --script smb-enum-shares 10.10.10.10
nmap --script smb-enum-users 10.10.10.10
nmap --script ftp-anon -p21 10.10.10.10
nmap --script http-title -p80 10.10.10.10
nmap --script http-enum -p80 10.10.10.10
nmap --script http-methods -p80 10.10.10.10
nmap --script ssl-cert -p443 10.10.10.10
nmap --script dns-brute 10.10.10.10
nmap --script=vuln 10.10.10.10

# SMB Enumeration
nmap -p445 --script smb-os-discovery 10.10.10.10
nmap -p445 --script smb-enum-shares 10.10.10.10
nmap -p445 --script smb-enum-users 10.10.10.10
nmap -p445 --script smb-protocols 10.10.10.10

# FTP Enumeration
nmap -p21 --script ftp-anon 10.10.10.10
nmap -p21 --script ftp-bounce 10.10.10.10

# HTTP Enumeration
nmap -p80,443 --script http-title 10.10.10.10
nmap -p80,443 --script http-enum 10.10.10.10
nmap -p80,443 --script http-methods 10.10.10.10
nmap -p80,443 --script http-headers 10.10.10.10

# DNS Enumeration
nmap --script dns-brute example.com
nmap -sU -p53 --script dns-recursion 10.10.10.10

# SNMP Enumeration
nmap -sU -p161 --script snmp-info 10.10.10.10
nmap -sU -p161 --script snmp-brute 10.10.10.10

# LDAP Enumeration
nmap -p389 --script ldap-rootdse 10.10.10.10
nmap -p389 --script ldap-search 10.10.10.10

# RDP Enumeration
nmap -p3389 --script rdp-enum-encryption 10.10.10.10

# SSH Enumeration
nmap -p22 --script ssh-auth-methods 10.10.10.10
nmap -p22 --script ssh2-enum-algos 10.10.10.10

# MySQL Enumeration
nmap -p3306 --script mysql-info 10.10.10.10
nmap -p3306 --script mysql-empty-password 10.10.10.10

# MSSQL Enumeration
nmap -p1433 --script ms-sql-info 10.10.10.10
nmap -p1433 --script ms-sql-empty-password 10.10.10.10

# SMTP Enumeration
nmap -p25 --script smtp-commands 10.10.10.10
nmap -p25 --script smtp-open-relay 10.10.10.10

# Output Formats
nmap -oN scan.txt 10.10.10.10
nmap -oX scan.xml 10.10.10.10
nmap -oG scan.gnmap 10.10.10.10
nmap -oA scan 10.10.10.10

# Input Targets
nmap -iL targets.txt
nmap 10.10.10.10 10.10.10.11
nmap 10.10.10.0/24

# Evasion
nmap -f 10.10.10.10
nmap --mtu 8 10.10.10.10
nmap -D RND:10 10.10.10.10
nmap -S SPOOFED_IP 10.10.10.10
nmap --source-port 53 10.10.10.10
nmap --data-length 200 10.10.10.10

# Rate Control
nmap --min-rate 1000 10.10.10.10
nmap --max-rate 5000 10.10.10.10
nmap --max-retries 2 10.10.10.10

# IPv6
nmap -6 ::1
nmap -6 2001:db8::/64

# Common OSCP Commands
nmap -Pn -p- --min-rate 1000 -T4 10.10.10.10
nmap -Pn -sC -sV -O -pPORTS 10.10.10.10
nmap -sC -sV -oA scan 10.10.10.10
nmap -Pn -A 10.10.10.10
```
