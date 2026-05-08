# Gobuster Cheat Sheet

```
# Directory Enumeration
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt

# Directory Enumeration with Extensions
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -x php
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -x php,txt,html
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -x asp,aspx,jsp

# HTTPS Enumeration
gobuster dir -u https://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -k

# Specify Threads
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -t 50
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -t 100

# Add User-Agent
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -a "Mozilla/5.0"

# Add Cookies
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -c "PHPSESSID=test"

# Add Headers
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -H "Authorization: Bearer TOKEN"

# Follow Redirects
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -r

# Exclude Status Codes
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -b 404
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -b 403,404

# Include Status Codes
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -s 200,204,301,302,307,401,403

# Filter by Length
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt --exclude-length 1234
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt --exclude-length 1234,5678

# Recursive Enumeration
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -r

# Output to File
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -o results.txt

# Verbose Output
gobuster dir -u http://10.10.10.10 -w /usr/share/wordlists/dirb/common.txt -v

# DNS Subdomain Enumeration
gobuster dns -d example.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# DNS Enumeration with Resolver
gobuster dns -d example.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -r 8.8.8.8

# DNS Enumeration Show CNAME
gobuster dns -d example.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -c

# VHOST Enumeration
gobuster vhost -u http://10.10.10.10 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# VHOST Enumeration with Domain
gobuster vhost -u http://10.10.10.10 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --append-domain

# Fuzzing Mode
gobuster fuzz -u http://10.10.10.10/FUZZ -w /usr/share/wordlists/dirb/common.txt

# Fuzz GET Parameters
gobuster fuzz -u "http://10.10.10.10/index.php?FUZZ=test" -w /usr/share/wordlists/dirb/common.txt

# Fuzz POST Parameters
gobuster fuzz -u http://10.10.10.10/login.php -X POST -d "FUZZ=test" -w /usr/share/wordlists/dirb/common.txt

# Basic Auth
gobuster dir -u http://10.10.10.10 -U admin -P password -w /usr/share/wordlists/dirb/common.txt

# Ignore SSL Verification
gobuster dir -u https://10.10.10.10 -k -w /usr/share/wordlists/dirb/common.txt

# Proxy Support
gobuster dir -u http://10.10.10.10 -p http://127.0.0.1:8080 -w /usr/share/wordlists/dirb/common.txt

# Common OSCP Commands
gobuster dir -u http://10.10.10.10 -w /usr/share/seclists/Discovery/Web-Content/common.txt -x php,txt,html -t 50
gobuster dir -u https://10.10.10.10 -k -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt
gobuster vhost -u http://10.10.10.10 -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
gobuster dns -d example.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```
