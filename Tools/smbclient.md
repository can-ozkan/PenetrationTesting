# Smbclient

```
# List SMB Shares
smbclient -L //10.10.10.10
smbclient -L //10.10.10.10 -N
smbclient -L //10.10.10.10 -U user
smbclient -L //10.10.10.10 -U user%password

# Connect to SMB Share
smbclient //10.10.10.10/share
smbclient //10.10.10.10/share -N
smbclient //10.10.10.10/share -U user
smbclient //10.10.10.10/share -U user%password

# Specify SMB Version
smbclient //10.10.10.10/share -m SMB2
smbclient //10.10.10.10/share -m SMB3

# Connect Using Domain Credentials
smbclient //10.10.10.10/share -U DOMAIN/user%password

# Connect Using NTLM Hash
smbclient //10.10.10.10/share --pw-nt-hash -U user%AAD3B435B51404EEAAD3B435B51404EE:HASH

# Recursive File Download
smbclient //10.10.10.10/share -U user%password
recurse ON
prompt OFF
mget *

# Download Single File
smbclient //10.10.10.10/share -U user%password
get file.txt

# Upload Single File
smbclient //10.10.10.10/share -U user%password
put shell.exe

# Download Multiple Files
smbclient //10.10.10.10/share -U user%password
mget *.txt

# Upload Multiple Files
smbclient //10.10.10.10/share -U user%password
mput *.txt

# Navigate Directories
ls
dir
cd folder
pwd

# Create Directory
mkdir test

# Remove Directory
rmdir test

# Delete File
del file.txt
rm file.txt

# Rename File
rename old.txt new.txt

# Execute SMB Commands Non-Interactively
smbclient //10.10.10.10/share -U user%password -c 'ls'
smbclient //10.10.10.10/share -U user%password -c 'recurse ON;prompt OFF;mget *'

# Anonymous Login
smbclient //10.10.10.10/share -N

# Null Session Enumeration
smbclient -L //10.10.10.10 -N

# Mount SMB Share (Linux)
mount -t cifs //10.10.10.10/share /mnt/share -o username=user,password=password
mount -t cifs //10.10.10.10/share /mnt/share -o guest

# Download Entire Share
smbclient //10.10.10.10/share -N -c 'recurse;prompt OFF;mget *'

# Tar Backup from SMB
smbclient //10.10.10.10/share -U user%password -Tc backup.tar .

# Read Specific File
smbclient //10.10.10.10/share -U user%password -c 'get config.xml'

# Upload Reverse Shell
smbclient //10.10.10.10/share -U user%password -c 'put shell.exe'

# Enumerate Shares Quickly
smbclient -L //10.10.10.10 -N | grep Disk

# Test Credentials
smbclient //10.10.10.10/share -U user%password -c 'exit'

# Connect via IP and Port
smbclient //10.10.10.10/share -p 445

# Debug Mode
smbclient //10.10.10.10/share -d 3

# Common OSCP Commands
smbclient -L //10.10.10.10 -N
smbclient //10.10.10.10/share -N
smbclient //10.10.10.10/share -U user%password
smbclient //10.10.10.10/share -N -c 'recurse;prompt OFF;mget *'
smbclient //10.10.10.10/share -U DOMAIN/user%password
```

