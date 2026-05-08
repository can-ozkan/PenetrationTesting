# smbmap

```
# Enumerate SMB Shares
smbmap -H 10.10.10.10
smbmap -H 10.10.10.10 -u user -p password
smbmap -H 10.10.10.10 -u user -p ''
smbmap -H 10.10.10.10 -u '' -p ''

# Enumerate Shares with Domain
smbmap -H 10.10.10.10 -d DOMAIN -u user -p password

# Enumerate Shares Using NTLM Hash
smbmap -H 10.10.10.10 -u user --ntlm HASH
smbmap -H 10.10.10.10 -u user -p LMHASH:NTHASH

# List Files in Share
smbmap -H 10.10.10.10 -u user -p password -r
smbmap -H 10.10.10.10 -u user -p password -r SHARE

# Recursive Directory Listing
smbmap -H 10.10.10.10 -u user -p password -R SHARE

# Download File
smbmap -H 10.10.10.10 -u user -p password --download "SHARE\\file.txt"

# Upload File
smbmap -H 10.10.10.10 -u user -p password --upload local.txt "SHARE\\remote.txt"

# Delete File
smbmap -H 10.10.10.10 -u user -p password --delete "SHARE\\file.txt"

# Execute Command
smbmap -H 10.10.10.10 -u user -p password -x 'whoami'
smbmap -H 10.10.10.10 -u user -p password -x 'ipconfig'
smbmap -H 10.10.10.10 -u user -p password -x 'hostname'

# Execute PowerShell Command
smbmap -H 10.10.10.10 -u user -p password -x 'powershell -c "Get-Process"'

# Enumerate Writable Shares
smbmap -H 10.10.10.10 -u user -p password | grep WRITE

# Enumerate Admin Access
smbmap -H 10.10.10.10 -u user -p password | grep ADMIN

# Anonymous Enumeration
smbmap -H 10.10.10.10 -u anonymous -p ''
smbmap -H 10.10.10.10 -u '' -p ''

# Enumerate Specific Share
smbmap -H 10.10.10.10 -u user -p password -s SHARE

# Enumerate Specific Directory
smbmap -H 10.10.10.10 -u user -p password -r SHARE\\folder

# Check SMB Signing
smbmap -H 10.10.10.10 --signing

# Enumerate Multiple Targets
smbmap -H 10.10.10.0/24 -u user -p password

# Use Kerberos Authentication
smbmap -H 10.10.10.10 -k

# Specify SMB Port
smbmap -H 10.10.10.10 -P 445

# Verbose Mode
smbmap -H 10.10.10.10 -u user -p password -v

# Save Output
smbmap -H 10.10.10.10 -u user -p password > smbmap.txt

# Common OSCP Commands
smbmap -H 10.10.10.10
smbmap -H 10.10.10.10 -u guest -p ''
smbmap -H 10.10.10.10 -u user -p password
smbmap -H 10.10.10.10 -u user -p password -r
smbmap -H 10.10.10.10 -u user -p password -R SHARE
smbmap -H 10.10.10.10 -u user -p password -x 'whoami'
smbmap -H 10.10.10.10 -u user --ntlm HASH
```
