# Active Directory Attacks, Kerberos Attacks, and Related Attacks — Detailed Conceptual Guide

This guide explains **how common Active Directory (AD) and Kerberos attacks work**, **what they abuse**, **why they succeed**, **what prerequisites they require**, **what impact they have**, and **how defenders can detect and mitigate them**.

It is written as a **deep conceptual reference** for **OSCP, GPEN, and general AD security understanding**.

---

# 1. Why Active Directory Is Such a High-Value Target

Active Directory is often the **identity and authorization backbone** of a Windows enterprise. It controls:

- who can authenticate
- what systems they can access
- what privileges they have
- how policies are enforced
- which machines trust which identities

A successful compromise of AD can allow an attacker to move from:

```text
one low-privileged user
→ one workstation
→ one server
→ administrative access
→ domain-wide control
```

That is why AD attacks are usually not about a single exploit. They are usually about:

```text
misconfiguration
weak credentials
over-privileged accounts
credential exposure
trust abuse
poor delegation settings
insecure legacy protocols
```

In practice, most AD compromises are **graph problems**. The attacker is trying to discover the shortest path from a current foothold to a privileged identity such as:

- local administrator on a server
- server operator
- backup operator
- domain admin
- enterprise admin
- a machine account with strong delegated rights
- a service account with broad access

---

# 2. AD Attack Lifecycle

Most AD attack chains follow a pattern like this:

```text
Initial access
→ host enumeration
→ domain enumeration
→ credential discovery
→ privilege escalation
→ lateral movement
→ persistence
→ domain dominance
```

Different attacks fit into different phases.

| Phase | Typical Activity |
|---|---|
| Initial access | phishing, exposed service, VPN credentials, web compromise |
| Enumeration | identify users, groups, computers, SPNs, trusts, shares |
| Credential access | dump hashes, tickets, secrets, stored passwords |
| Lateral movement | remote admin protocols, token reuse, ticket reuse |
| Privilege escalation | ACL abuse, delegation abuse, service account compromise |
| Persistence | forged tickets, admin group membership, GPO abuse |

---

# 3. Core AD Concepts You Must Understand

Before the attacks make sense, several core concepts must be clear.

## 3.1 Domain

A domain is a centralized identity boundary containing:

- users
- computers
- groups
- policies
- service accounts
- access control relationships

## 3.2 Domain Controller (DC)

A DC is a server that:

- authenticates users
- stores AD database data
- issues Kerberos tickets
- enforces policy

Compromising a DC is often equivalent to compromising the domain.

## 3.3 Security Principals

A security principal is any identity that can be granted permissions, including:

- users
- computers
- groups
- managed service accounts

## 3.4 Groups

Groups are central to privilege management. Some especially important groups include:

- Domain Admins
- Enterprise Admins
- Administrators
- Account Operators
- Backup Operators
- Server Operators
- Print Operators
- DNS Admins

Many attacks are really about finding a path into one of these groups or abusing rights that are almost equivalent to them.

## 3.5 ACLs and ACEs

AD objects have **Access Control Lists**. These lists define who can do what to the object.

Important rights include:

- GenericAll
- GenericWrite
- WriteDACL
- WriteOwner
- ResetPassword
- AddMember
- ForceChangePassword
- ReadLAPSPassword
- WriteSPN

A huge portion of AD privilege escalation comes from abusing **permissions**, not from exploiting software bugs.

## 3.6 Authentication

AD commonly uses:

- Kerberos
- NTLM
- LDAP bind-based authentication
- certificates in some environments

Understanding Kerberos and NTLM is essential.

---

# 4. Kerberos: The Foundation Behind Many AD Attacks

Kerberos is a ticket-based authentication protocol. Instead of sending a password to every service, a user authenticates once to the Key Distribution Center (KDC), then uses tickets.

The important parts are:

- **AS-REQ / AS-REP**: initial authentication request and response
- **TGT**: Ticket Granting Ticket
- **TGS-REQ / TGS-REP**: request and receive service ticket
- **Service ticket**: used to access a specific service

In simplified form:

```text
User proves identity to DC
→ DC issues TGT
→ user asks DC for ticket to a service
→ DC issues service ticket
→ user presents service ticket to service
```

This design is efficient, but it creates opportunities for attack when:

- encryption choices are weak
- service account passwords are weak
- preauthentication is disabled
- tickets are stolen
- delegation is misconfigured
- attackers obtain KDC secrets

---

# 5. Broad Categories of AD Attacks

AD attacks can be grouped into several families.

## 5.1 Credential attacks

These try to obtain:

- cleartext passwords
- NTLM hashes
- Kerberos keys
- Kerberos tickets
- saved service secrets

Examples:

- password spraying
- Kerberoasting
- AS-REP roasting
- credential dumping
- pass-the-hash
- pass-the-ticket

## 5.2 Authorization abuse

These use legitimate but dangerous permissions.

Examples:

- ACL abuse
- group membership abuse
- GPO abuse
- delegation abuse
- RBCD abuse
- DCSync rights abuse

## 5.3 Trust abuse

These use:

- domain trusts
- forest trusts
- unconstrained delegation chains
- machine account trust assumptions

## 5.4 Persistence attacks

These ensure long-term access.

Examples:

- golden tickets
- silver tickets
- shadow credentials
- adminSDHolder abuse
- GPO startup scripts
- rogue SPNs or delegated rights

---

# 6. Password Spraying

## 6.1 What it is

Password spraying is the act of trying **one or a few common passwords across many accounts**, rather than trying many passwords against one account.

## 6.2 Why attackers use it

It avoids account lockouts more effectively than brute force.

Example logic:

```text
Try Winter2024! on 200 users
instead of
Try 200 passwords on one user
```

## 6.3 Why it works

It succeeds when:

- users choose predictable passwords
- the organization has weak password hygiene
- lockout thresholds are permissive
- there is no MFA or strong conditional access

## 6.4 Impact

Even one valid low-privileged account can be enough to begin domain enumeration and lateral movement.

## 6.5 Detection clues

- many failed logons using one password across many users
- attempts spread across protocols such as SMB, OWA, VPN, LDAP, Kerberos
- repeated failures followed by one success

## 6.6 Mitigation

- MFA
- banned password lists
- lockout policy tuned carefully
- monitoring for broad low-and-slow authentication attempts
- password hygiene training

---

# 7. Credential Dumping

## 7.1 What it is

Credential dumping is extracting secrets from a system, commonly:

- NTLM hashes
- cached credentials
- Kerberos tickets
- cleartext passwords from LSASS memory
- browser or application credentials

## 7.2 Why it matters

Once an attacker reaches a privileged workstation or server, it may contain credentials for:

- administrators
- service accounts
- domain admins
- helpdesk staff
- backup systems
- management software

## 7.3 Common sources

- LSASS process memory
- SAM database
- SECURITY hive
- NTDS.dit on DCs
- cached logons
- browser stores
- scripts and config files
- password managers
- scheduled tasks
- service definitions

## 7.4 Impact

Credential dumping is often the turning point between local compromise and domain compromise.

## 7.5 Mitigation

- Credential Guard
- LSASS protection
- restrict admin logons to hardened systems
- tiered admin model
- disable unnecessary credential caching
- monitor memory access and suspicious process behavior

---

# 8. Pass-the-Hash (PtH)

## 8.1 What it is

Pass-the-Hash uses an **NTLM hash directly** for authentication instead of needing the plaintext password.

## 8.2 Why it works

Some authentication flows, especially NTLM-based ones, effectively accept proof derived from the hash. If the attacker has the hash, they may not need the password.

## 8.3 Requirements

- possession of NTLM hash
- target service supports NTLM authentication
- account allowed to authenticate to the target
- no controls blocking hash-based lateral movement

## 8.4 Typical use

An attacker dumps a local administrator or domain account hash from one machine, then authenticates to another machine using that hash.

## 8.5 Impact

This can enable rapid lateral movement when:

- the same local admin password is reused
- privileged users log onto multiple machines
- NTLM remains widely enabled

## 8.6 Detection clues

- NTLM authentication where Kerberos would normally be expected
- unusual remote administration from compromised hosts
- authentication to many systems using one account in a short period

## 8.7 Mitigation

- reduce NTLM usage
- use unique local admin passwords via LAPS
- restrict lateral admin rights
- use Protected Users where appropriate
- privileged access workstations
- monitor NTLM usage

---

# 9. Pass-the-Ticket (PtT)

## 9.1 What it is

Pass-the-Ticket uses a **stolen Kerberos ticket** rather than a password or hash.

## 9.2 Why it works

If an attacker can access a valid TGT or service ticket in memory or exported from a host, they may inject or reuse it to authenticate as that principal.

## 9.3 Typical sources

- memory of logged-in users
- exported ticket caches
- compromised admin workstation
- unconstrained delegation host
- backup of credential material

## 9.4 Impact

An attacker can impersonate the ticket owner for as long as the ticket remains valid, and sometimes longer if renewable.

## 9.5 Mitigation

- reduce admin logon exposure
- ticket lifetime controls
- secure privileged workstations
- detect unusual ticket use patterns
- harden delegation

---

# 10. Kerberoasting

## 10.1 What it is

Kerberoasting targets **service accounts with SPNs**. An attacker requests a service ticket for a service account, then attempts to crack the encrypted part of that ticket offline.

## 10.2 Why it works

The service ticket is encrypted with material derived from the **service account’s password**. If that password is weak, the attacker may crack it offline.

## 10.3 Why this is attractive

It often requires only:

- a valid domain user account
- ability to request service tickets
- no special admin privileges

That makes Kerberoasting one of the most famous AD attacks.

## 10.4 Typical targets

Accounts running:

- SQL Server
- IIS app pools
- backup software
- custom services
- middleware
- legacy applications

## 10.5 Impact

If the cracked account is highly privileged, compromise can escalate quickly. Many service accounts have:

- local admin on servers
- access to databases
- delegated rights
- backup rights
- domain privileges in poorly designed environments

## 10.6 Why weak service accounts are common

Service accounts are often:

- old
- shared
- exempt from rotation
- set to never expire
- given long, complex-looking but predictable passwords
- reused across systems

## 10.7 Detection clues

- unusual bursts of service ticket requests for many SPNs
- requests from low-privileged users who normally would not use those services

## 10.8 Mitigation

- strong long random service account passwords
- group managed service accounts (gMSAs)
- minimize service account privileges
- monitor abnormal TGS requests
- audit SPNs regularly

---

# 11. AS-REP Roasting

## 11.1 What it is

AS-REP roasting targets users with **Kerberos preauthentication disabled**.

## 11.2 Why it works

Normally, Kerberos preauthentication forces the user to prove knowledge of the password before the DC returns encrypted material. If preauth is disabled, the DC may return data encrypted with the user’s secret without first verifying possession of that secret.

That lets an attacker capture material that can be cracked offline.

## 11.3 Why it exists

Preauthentication may be disabled for:

- legacy compatibility
- misconfiguration
- testing mistakes
- forgotten administrative changes

## 11.4 Impact

If the roasted account is valuable, this can quickly lead to lateral movement or privilege escalation.

## 11.5 Detection clues

- requests targeting accounts with disabled preauth
- unexpected AS-REQ patterns from unusual clients

## 11.6 Mitigation

- do not disable preauthentication unless absolutely necessary
- audit for such accounts
- enforce strong passwords
- monitor for enumeration of roastable principals

---

# 12. Silver Ticket Attack

## 12.1 What it is

A silver ticket is a **forged service ticket** for a specific service.

## 12.2 What the attacker needs

Usually:

- the service account secret or hash
- domain SID information
- target service details

## 12.3 Why it is powerful

The attacker can forge a ticket to one service without contacting the KDC for that service authentication step, depending on service validation behavior.

## 12.4 Scope

Silver tickets are more limited than golden tickets because they target one service type on one host or service identity, such as:

- CIFS
- HTTP
- MSSQLSvc
- HOST

## 12.5 Impact

If forged correctly, they can grant high access to the target service, often enough for lateral movement or persistence.

## 12.6 Detection and mitigation

- rotate service account secrets
- use gMSAs where possible
- service-side PAC validation and strong logging
- monitor unusual service ticket usage
- minimize powerful service accounts

---

# 13. Golden Ticket Attack

## 13.1 What it is

A golden ticket is a **forged TGT**. It is one of the most powerful AD persistence techniques.

## 13.2 What the attacker needs

Typically:

- the KRBTGT account secret
- domain SID
- domain details

## 13.3 Why it is so severe

The KRBTGT account is used by the KDC to sign/secure TGTs. If its secret is compromised, an attacker can forge TGTs for arbitrary users and groups.

That means the attacker can essentially mint domain-wide authentication tokens.

## 13.4 Impact

Potentially complete domain compromise and durable persistence.

## 13.5 Why defenders fear it

Because even if malware is removed, forged tickets may continue to work until the KRBTGT secret is reset properly, often twice in sequence due to password history behavior.

## 13.6 Mitigation

- protect DCs
- detect and stop DCSync and DC compromise early
- rotate KRBTGT after domain compromise response
- monitor impossible ticket patterns, unusual lifetimes, and anomalies in group claims

---

# 14. DCSync

## 14.1 What it is

DCSync is the abuse of directory replication privileges to request password data from a DC as if the attacker were a domain controller.

## 14.2 Why it works

Certain principals have rights such as:

- Replicating Directory Changes
- Replicating Directory Changes All
- sometimes related replication permissions

If an attacker controls such an account, they can ask the DC for password-related secrets, including high-value accounts.

## 14.3 Why it is devastating

It can expose:

- KRBTGT secret
- domain admin hashes
- service account secrets
- broad credential material

Without needing interactive DC logon.

## 14.4 Common ways attackers gain it

- direct compromise of privileged group
- ACL abuse
- delegated replication rights
- compromise of sync tools or service accounts

## 14.5 Detection clues

- replication-like requests from non-DC systems
- suspicious directory replication operations
- directory service access anomalies

## 14.6 Mitigation

- tightly restrict replication rights
- audit who holds them
- protect identity sync service accounts
- monitor replication operations from non-DC hosts

---

# 15. ACL Abuse

## 15.1 What it is

ACL abuse means leveraging AD object permissions to gain control over users, groups, computers, OUs, or domains.

## 15.2 Why it matters

An account does not need to be Domain Admin to become effectively equivalent to Domain Admin if it has the right permissions on the right object.

## 15.3 Dangerous rights

Examples include:

- GenericAll
- GenericWrite
- WriteOwner
- WriteDACL
- ResetPassword
- AddMember
- ForceChangePassword
- WriteSPN
- ability to modify delegation-related attributes

## 15.4 Example outcomes

ACL abuse can allow:

- resetting a privileged user’s password
- adding yourself to a privileged group
- modifying group membership
- assigning new rights
- enabling roastable conditions
- setting up delegation abuse
- establishing persistence

## 15.5 Why it is common

Because AD permissions become complex over time. Delegation is often added for convenience and never revisited.

## 15.6 Mitigation

- regular ACL audits
- BloodHound-style relationship reviews
- least privilege delegation
- change review for group and OU permissions

---

# 16. Group Membership Abuse

## 16.1 What it is

This is the direct or indirect abuse of group membership to gain privilege.

## 16.2 Important idea

Many groups are effectively privileged even when they are not named Domain Admins.

Examples:

- Account Operators
- Backup Operators
- Server Operators
- DNS Admins
- Print Operators in older risky contexts
- local administrators on key servers
- groups with GPO edit rights

## 16.3 Why it matters

A user added to the “wrong” group may gain a path to:

- DC access
- code execution on servers
- credential theft
- replication rights
- GPO abuse

---

# 17. GPO Abuse

## 17.1 What it is

Group Policy Objects control security settings and scripts across many machines.

## 17.2 Why they are dangerous

If an attacker can modify a GPO linked to important OUs, they may be able to:

- deploy startup or logon scripts
- change local admin group membership
- weaken security settings
- push scheduled tasks
- deploy persistence mechanisms

## 17.3 Impact

Potentially broad code execution or persistence across many systems at once.

## 17.4 Mitigation

- restrict GPO editing rights
- monitor GPO changes
- review delegation on OUs and GPOs
- tier GPO administration carefully

---

# 18. Delegation Attacks: High-Level View

Delegation lets one service act on behalf of a user to another service. It exists for convenience, but misconfigurations create major risk.

There are several forms.

---

# 19. Unconstrained Delegation

## 19.1 What it is

With unconstrained delegation, a service host can receive user TGT-related material and use it broadly on behalf of the user.

## 19.2 Why it is dangerous

If an attacker compromises a host configured for unconstrained delegation and can cause a privileged user to authenticate to it, the attacker may capture reusable Kerberos material.

## 19.3 Why it leads to escalation

If a domain admin authenticates to such a host, the attacker may reuse that admin’s ticket material.

## 19.4 Mitigation

- eliminate unconstrained delegation where possible
- mark privileged accounts as sensitive and not delegable
- do not allow admins to log on to risky systems
- monitor delegation-configured hosts

---

# 20. Constrained Delegation

## 20.1 What it is

Constrained delegation limits which services a delegated account can access on behalf of users.

## 20.2 Why it still matters

Even limited delegation can be abused if:

- the delegated account is compromised
- the allowed service path is powerful
- protocol transition is enabled
- target services expose escalation opportunities

## 20.3 Impact

Can enable impersonation to valuable services and lateral movement.

---

# 21. Resource-Based Constrained Delegation (RBCD)

## 21.1 What it is

RBCD shifts delegation control to the target resource. A machine can specify which principal is allowed to delegate to it.

## 21.2 Why attackers love it

If an attacker can modify the target computer object’s relevant attribute or create a computer account and grant it delegation rights, they may be able to impersonate users to that machine.

## 21.3 Why this is powerful

It often allows compromise chains that do not require Domain Admin but rely on:

- computer object control
- machine account creation rights
- ACL abuse on computer objects

## 21.4 Mitigation

- restrict machine account creation
- audit computer object ACLs
- monitor delegation attribute changes
- reduce unnecessary delegation

---

# 22. Shadow Credentials

## 22.1 What it is

Shadow credentials abuse key-based authentication support by adding alternate key material to an AD object, allowing certificate or key-based authentication as that object.

## 22.2 Why it works

If an attacker has enough rights over a user or computer object to write the relevant key credential attributes, they can establish a new authentication path without knowing the victim’s password.

## 22.3 Why it is dangerous

It can create stealthy persistence and facilitate privilege escalation.

## 22.4 Mitigation

- audit write permissions on user/computer objects
- monitor changes to key credential attributes
- minimize object-control rights

---

# 23. NTLM Relay

## 23.1 What it is

NTLM relay captures NTLM authentication from a victim and relays it to another service, authenticating as the victim without cracking a password.

## 23.2 Why it works

NTLM, unlike Kerberos, can be relayed in many circumstances if protections are absent.

## 23.3 Conditions that enable it

- signing not required
- relayable protocols exposed
- coerced or opportunistic authentication
- no channel binding or similar protections

## 23.4 Impact

Can lead to:

- remote code execution
- machine account abuse
- privilege escalation
- AD CS abuse in some environments
- configuration changes on the relayed target

## 23.5 Mitigation

- SMB signing where appropriate
- disable legacy and unnecessary NTLM paths
- LDAP signing and channel binding
- harden printers and coercion vectors
- reduce trust in inbound authentication

---

# 24. Coercion Attacks

## 24.1 What they are

Coercion attacks force a machine or service to authenticate to an attacker-controlled endpoint.

## 24.2 Why they matter

They are often paired with NTLM relay or credential capture.

## 24.3 Common theme

A service is tricked into reaching out to a remote location, and in doing so it automatically performs authentication.

## 24.4 Impact

- relay opportunities
- captured authentication attempts
- machine account abuse

## 24.5 Mitigation

- patch coercion vulnerabilities
- reduce exposed RPC paths
- restrict outbound authentication behavior
- require signing and secure channel protections

---

# 25. LLMNR/NBNS Poisoning and Related Legacy Name Abuse

## 25.1 What it is

When name resolution fails, some Windows environments fall back to legacy mechanisms like LLMNR or NBNS. Attackers can answer these requests and capture or relay authentication.

## 25.2 Why it works

Users or systems ask, “Who is FILESERVER?” and the attacker answers first.

## 25.3 Impact

- NTLM hash capture
- relay opportunities
- foothold expansion

## 25.4 Mitigation

- disable LLMNR/NBNS where possible
- enforce SMB signing
- reduce NTLM reliance
- DNS hygiene

---

# 26. Local Admin Reuse

## 26.1 What it is

The same local administrator password exists on many machines.

## 26.2 Why it matters

Compromise one system, dump one local admin secret, move to many other systems.

## 26.3 Why it is devastating

It turns one workstation compromise into broad lateral movement.

## 26.4 Mitigation

- LAPS or equivalent
- remove unnecessary local admin rights
- monitor remote admin activity

---

# 27. Admin Session Hunting

## 27.1 What it is

Attackers look for where privileged users are logged in.

## 27.2 Why it matters

If a domain admin is logged into a server and the attacker gains admin on that server, the attacker may be able to steal the admin’s tokens, hashes, or tickets.

## 27.3 Mitigation

- privileged access workstations
- no admin browsing or normal workstation usage
- logon restrictions for admins
- tiering of administration

---

# 28. Token Impersonation and SeImpersonate-Related Abuse

## 28.1 What it is

Some Windows privileges allow a process to impersonate another token under certain conditions.

## 28.2 Why it matters in AD

A local service or privileged process compromise can sometimes become SYSTEM, and SYSTEM on a domain-joined machine can expose valuable secrets and movement opportunities.

## 28.3 Impact

- local privilege escalation
- service abuse
- credential theft
- launch point for broader domain attacks

---

# 29. AD CS Abuse (Certificate Services)

## 29.1 Why certificates matter

If an organization uses Active Directory Certificate Services, misconfigured templates or enrollment rights can allow attackers to obtain certificates valid for authenticating as privileged users.

## 29.2 Why this is powerful

Certificate-based authentication can bypass password rotation concerns and enable persistent access.

## 29.3 Common risk themes

- overly permissive certificate templates
- enrollment rights granted too broadly
- dangerous EKUs
- SAN control issues
- relay paths to certificate enrollment services

## 29.4 Impact

Potential privilege escalation up to domain compromise.

## 29.5 Mitigation

- strict template review
- limited enrollment rights
- monitor certificate issuance anomalies
- harden enrollment endpoints

---

# 30. Related Attack: Trust Abuse

## 30.1 What it is

Domains and forests may trust each other. If those trusts are weakly controlled or if privileges cross them, compromise in one place may lead to compromise elsewhere.

## 30.2 Why it matters

Attackers do not always stop at one domain. Trusts can enlarge blast radius.

## 30.3 Mitigation

- review trust direction and scope
- selective authentication where appropriate
- monitor cross-trust admin activity

---

# 31. Related Attack: Machine Account Abuse

## 31.1 Why computer accounts matter

Computer accounts are principals too. They have passwords, tickets, SPNs, and ACL-relevant rights.

## 31.2 Common abuses

- abuse of machine account creation rights
- compromise of a machine account followed by delegation abuse
- using computer object control for RBCD
- extracting local system context leading to machine credential theft

---

# 32. Related Attack: Service Account Abuse

## 32.1 Why service accounts are special

They often combine:

- broad access
- weak password hygiene
- infrequent rotation
- unattended execution
- poor monitoring

## 32.2 Common outcomes

- Kerberoasting
- local admin on many systems
- database compromise
- backup system compromise
- access to cloud sync or AD integration tooling

---

# 33. Why “Enumeration” Is the Real AD Attack Engine

Most AD attacks do not begin with exploitation. They begin with discovery of:

- who is in which group
- where admins log in
- what SPNs exist
- which trusts exist
- which ACLs are unsafe
- which hosts are delegation-enabled
- which accounts have no preauth
- which systems accept NTLM
- where credentials are cached
- which shares reveal passwords, scripts, or deployment artifacts

That is why AD compromise often feels inevitable in poorly maintained environments: the attack graph is already present.

---

# 34. How These Attacks Chain Together

A realistic chain might look like this:

```text
Low-privileged user
→ password spraying finds one valid user
→ domain enumeration reveals SPNs
→ Kerberoasting cracks a service account
→ service account has local admin on an app server
→ admin logs into that server
→ attacker dumps admin ticket
→ pass-the-ticket to management server
→ DCSync rights found via ACL abuse
→ KRBTGT secret obtained
→ golden ticket
```

Another chain:

```text
Web server compromise
→ domain-joined host access
→ machine or service credentials found
→ LDAP/ACL enumeration reveals write rights to computer object
→ RBCD configured
→ impersonation to target server
→ admin session capture
→ lateral movement
→ domain compromise
```

The important lesson is that **AD attacks are composable**.

---

# 35. What Defenders Should Watch For

Even if you are studying offensively, understanding detection makes the attack logic clearer.

## 35.1 High-signal behaviors

- password spraying patterns
- unusual TGS requests across many SPNs
- non-DC replication behavior
- privileged logons from unusual hosts
- suspicious service creation or remote execution
- ticket anomalies
- sudden ACL changes on AD objects
- delegation attribute changes
- GPO changes
- certificate enrollment anomalies
- unusual NTLM usage

## 35.2 Strategic defensive controls

- MFA
- tiered admin model
- least privilege
- remove legacy protocols
- unique local admin passwords
- harden service accounts
- gMSAs
- eliminate unconstrained delegation
- audit ACLs and trusts
- protect DCs aggressively
- restrict admin logons
- strong monitoring on identity infrastructure

---

# 36. Mental Model for Exam Preparation

For OSCP, GPEN, and similar learning paths, the most useful mental model is:

```text
What do I know?
What identities do I control?
What can those identities read, modify, or request?
What secrets can I obtain offline?
What tickets or hashes can I reuse?
What permissions let me become something more powerful?
```

Think in layers:

## 36.1 Authentication layer
Can I get:
- password
- hash
- ticket
- key
- certificate

## 36.2 Authorization layer
Can I:
- reset password
- add group member
- modify ACL
- impersonate
- delegate
- replicate
- administer a machine

## 36.3 Reachability layer
Can I:
- connect to SMB
- use WinRM
- use WMI
- access LDAP
- reach DCs
- reach certificate services

---

# 37. High-Level Comparison of Major Attacks

| Attack | What it abuses | What attacker needs | Main impact |
|---|---|---|---|
| Password spraying | weak passwords | user list, auth path | initial access |
| Kerberoasting | weak service account passwords | any domain user | service account compromise |
| AS-REP roasting | preauth disabled | user discovery | offline cracking |
| Pass-the-Hash | NTLM reuse | NTLM hash | lateral movement |
| Pass-the-Ticket | Kerberos ticket reuse | stolen ticket | impersonation |
| Silver ticket | service key compromise | service secret | service-level forgery |
| Golden ticket | KRBTGT compromise | KRBTGT secret | domain-wide persistence |
| DCSync | replication rights | replication-capable account | credential extraction |
| ACL abuse | excessive permissions | object control rights | privilege escalation |
| Unconstrained delegation | ticket forwarding | host compromise + auth event | privileged ticket theft |
| RBCD | delegation misconfiguration | object control rights | impersonation to target |
| NTLM relay | unsigned/relayable auth | victim auth + relay target | remote access/escalation |
| AD CS abuse | weak certificate config | enrollment/control path | powerful auth bypass |

---

# 38. Final Takeaways

Active Directory attacks are not random tricks. They are the result of a few recurring truths:

1. **Identity is everything.**  
   In AD, whoever controls identity often controls the environment.

2. **Weak passwords become offline cracking opportunities.**  
   Kerberoasting and AS-REP roasting are famous because they turn authentication design into offline attack material.

3. **Permissions are as dangerous as passwords.**  
   ACL abuse, delegation abuse, and group abuse often matter more than memory corruption exploits.

4. **Credentials spread.**  
   Admins log into servers, service accounts run everywhere, and secrets get copied into scripts and configs.

5. **One foothold is usually enough if the environment is weakly governed.**  
   The rest is graph traversal.

6. **Defensive maturity is about reducing paths, not just stopping one exploit.**  
   Strong AD security means reducing trust, privilege, credential exposure, and legacy protocol abuse.

---

# 39. One-Sentence Summaries to Memorize

- **Kerberoasting**: request a service ticket, crack the service account offline.  
- **AS-REP roasting**: request roastable user material when preauth is disabled.  
- **Pass-the-Hash**: authenticate with an NTLM hash.  
- **Pass-the-Ticket**: authenticate with a stolen Kerberos ticket.  
- **Silver ticket**: forge a service ticket with a service secret.  
- **Golden ticket**: forge a TGT with the KRBTGT secret.  
- **DCSync**: ask the DC for secrets by abusing replication rights.  
- **ACL abuse**: use object permissions to become more powerful.  
- **RBCD**: abuse computer object delegation settings to impersonate users to a target.  
- **NTLM relay**: relay captured NTLM auth to another service.  
- **Password spraying**: try one password across many users carefully.  
- **Credential dumping**: extract secrets from memory, disk, or configuration.

---

# 40. Study Strategy

If you want to truly understand AD attacks, study them in this order:

1. AD objects, groups, ACLs, and trusts  
2. Kerberos authentication flow  
3. NTLM authentication basics  
4. Password spraying and account discovery  
5. Kerberoasting and AS-REP roasting  
6. credential dumping, PtH, PtT  
7. ACL abuse and delegation abuse  
8. DCSync, golden/silver tickets  
9. AD CS and advanced trust/persistence paths

That order helps the attack families make sense as one connected system rather than as isolated tricks.
