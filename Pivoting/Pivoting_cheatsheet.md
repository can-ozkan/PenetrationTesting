# Pivoting & Tunneling Exam Cheat Sheet (OSCP / GPEN)

This cheat sheet summarizes **practical pivoting methodology** and **reliable commands** used during penetration testing exams when working with **segmented networks**.

The focus is on **methodology**, not scanning everything blindly.

---

# 1. Pivoting Mindset

Always ask:

```
Who can reach whom?
```

Typical exam scenario:

```
Kali (Attacker)
      |
      | reachable
      |
Pivot Machine
(dual-homed)
      |
      | internal network
      |
Internal Targets
```

Goal:

```
Route traffic through the pivot machine.
```

---

# 2. Identify Internal Networks

On the compromised pivot machine:

```bash
ip a
ip route
arp -a
```

Look for private networks:

```
192.168.x.x
10.x.x.x
172.16.x.x
```

Example:

```
eth0 → attacker network
eth1 → internal network
```

---

# 3. Verify Connectivity From Pivot

Before tunneling, confirm the pivot can reach internal targets.

```bash
ping TARGET
nc -nv TARGET PORT
curl http://TARGET
```

Example:

```bash
nc -nv 192.168.135.114 80
```

---

# 4. Pivoting Techniques

Four pivot methods commonly used in exams.

| Tool | Purpose |
|-----|------|
| SSH port forwarding | Simple pivot |
| SSH dynamic SOCKS | proxychains |
| sshuttle | VPN-like tunnel |
| Chisel | firewall bypass |

---

# 5. SSH Local Port Forwarding

Expose an internal service locally.

```bash
ssh -L LOCALPORT:TARGET:PORT user@pivot
```

Example:

```bash
ssh -L 8080:192.168.135.114:80 user@192.168.152.110
```

Access service:

```
http://localhost:8080
```

---

# 6. SSH Dynamic Port Forwarding (SOCKS Proxy)

Create a SOCKS proxy.

```bash
ssh -D 1080 user@pivot
```

Configure proxychains:

```
/etc/proxychains4.conf
```

Add:

```
socks5 127.0.0.1 1080
```

Use tools through proxy:

```bash
proxychains curl http://TARGET
proxychains nc TARGET PORT
proxychains ftp TARGET
```

---

# 7. Nmap Through SOCKS

Nmap behaves poorly through proxies.

Use only:

```
-sT
-Pn
-n
```

Example:

```bash
proxychains nmap -sT -Pn -n -p21,22,23,80,445 TARGET
```

Avoid:

```
-sS
-sn
ICMP scans
ARP scans
```

---

# 8. Discover Services Without Nmap

Use netcat instead.

```bash
proxychains nc -nv TARGET 21
proxychains nc -nv TARGET 22
proxychains nc -nv TARGET 445
```

Useful tools:

```
curl
ftp
ssh
smbclient
```

---

# 9. sshuttle (Best Pivot Tool)

Creates a VPN-like tunnel.

```bash
sudo sshuttle -r user@pivot INTERNAL_NETWORK
```

Example:

```bash
sudo sshuttle -r user@192.168.152.110 192.168.135.0/24
```

Now Kali behaves like it is inside the network.

Use tools normally:

```bash
nmap -sT 192.168.135.114
curl http://192.168.135.114
```

---

# 10. Chisel Pivot Overview

Chisel creates tunnels over HTTP.

Common use cases:

```
SOCKS proxy
port forwarding
firewall bypass
```

After creating SOCKS:

```
proxychains tools
```

---

# 11. Host Discovery Through Pivot

Ping and ICMP often fail.

Use:

```bash
nmap -sT -Pn -n NETWORK
```

or manually test hosts.

Example:

```bash
nc -nv 192.168.135.114 80
```

---

# 12. Service Enumeration Through Pivot

Examples:

### HTTP

```bash
proxychains curl http://TARGET
```

### SMB

```bash
proxychains smbclient -L //TARGET
```

### FTP

```bash
proxychains ftp TARGET
```

### SSH

```bash
proxychains ssh user@TARGET
```

---

# 13. Metasploit Through SOCKS

Configure proxy:

```bash
set Proxies socks5:127.0.0.1:1080
```

Then run exploits normally.

---

# 14. Typical Exam Workflow

1. Compromise pivot machine
2. Identify internal network
3. Verify pivot connectivity
4. Create tunnel
5. Enumerate services
6. Exploit internal hosts

---

# 15. Key Exam Lessons

Pivoting is not about scanning entire networks.

Focus on:

```
reach → enumerate → exploit
```

instead of:

```
scan everything
```

---

# 16. Troubleshooting Pivot Issues

### Cannot reach host

Check from pivot:

```bash
nc -nv TARGET PORT
```

### Proxychains failing

Verify config:

```
socks5 127.0.0.1 1080
```

### Nmap shows filtered

Use smaller port lists.

---

# 17. Fast Connectivity Tests

```bash
proxychains curl http://TARGET
proxychains nc TARGET PORT
```

If these work, pivot is functioning.

---

# 18. Quick Reference Commands

### SSH SOCKS

```bash
ssh -D 1080 user@pivot
```

### Proxychains scan

```bash
proxychains nmap -sT -Pn -n TARGET
```

### SSH local forward

```bash
ssh -L 8080:TARGET:80 user@pivot
```

### sshuttle

```bash
sudo sshuttle -r user@pivot NETWORK
```

---

# 19. Important Exam Advice

Do not waste time trying to make:

```
nmap -sn
nmap -sS
```

work through pivots.

Use application-layer tools instead.

---

# 20. Final Reminder

Pivoting success is measured by:

```
Can you reach the service?
```

If this works:

```bash
curl
nc
ftp
smbclient
```

then pivoting is successful.
