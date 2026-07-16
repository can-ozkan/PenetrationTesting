# BloodHound Cheat Sheet (GPEN & OSCP)

> **Goal:** Quickly identify attack paths, privilege escalation opportunities, and lateral movement during Active Directory assessments.

---

# 1. Data Collection

## bloodhound-python (Linux)

### Basic Collection

```bash
bloodhound-python -u USER -p PASSWORD -d DOMAIN.LOCAL -ns DC_IP -c All
bloodhound-python -u USER -p PASSWORD -d DOMAIN.LOCAL -ns DC_IP -c All --zip
```

Example:

```bash
bloodhound-python -u svc_tgs -p 'Password123!' -d active.htb -ns 10.10.10.100 -c All
```

---

### Using Kerberos

```bash
bloodhound-python -u USER -k -no-pass -d DOMAIN.LOCAL -ns DC_IP -c All
```

---

### DNS Troubleshooting

```bash
bloodhound-python -u USER -p PASSWORD -d DOMAIN.LOCAL -dc dc.domain.local -ns DC_IP -c All
```

---

### Disable DNS TCP

Useful when DNS behaves strangely.

```bash
bloodhound-python -u USER -p PASSWORD -d DOMAIN.LOCAL -ns DC_IP --dns-tcp False -c All
```

---

## SharpHound (Windows)

### Collect Everything

```powershell
SharpHound.exe -c All
```

---

### Stealth Collection

```powershell
SharpHound.exe -c DCOnly
```

---

### Session Collection

```powershell
SharpHound.exe -c Session
```

---

### Logged-on Users

```powershell
SharpHound.exe -c LoggedOn
```

---

### ACL Collection

```powershell
SharpHound.exe -c ACL
```

---

## Compress Results

Upload the generated ZIP directly into BloodHound.

---

# 2. Initial BloodHound Workflow

After importing data:

1. Find Domain Admins
2. Find shortest path to Domain Admins
3. Find owned users
4. Find Kerberoastable users
5. Find AS-REP roastable users
6. Find local administrators
7. Find unconstrained delegation
8. Find constrained delegation
9. Find GPO abuse
10. Find DCSync rights

---

# 3. Essential Search Queries

## Find Domain Admins

```
MATCH (u:User)-[:MemberOf*1..]->(g:Group {name:"DOMAIN ADMINS@DOMAIN.LOCAL"})
RETURN u
```

---

## Find Domain Controllers

```
MATCH (c:Computer)
WHERE c.objectid ENDS WITH "-516"
RETURN c
```

---

## Find High Value Targets

```
MATCH (n)
WHERE n.highvalue=True
RETURN n
```

---

## Find Shortest Path to Domain Admins

Built-in Query:

```
Shortest Paths to Domain Admins
```

---

## Find Users with Sessions

```
MATCH (u:User)-[:HasSession]->(c:Computer)
RETURN u,c
```

---

## Find Computers with Sessions

```
MATCH (c:Computer)<-[:HasSession]-(u:User)
RETURN c,u
```

---

## Find Kerberoastable Users

```
MATCH (u:User)
WHERE u.hasspn=True
RETURN u
```

---

## Find AS-REP Roastable Users

```
MATCH (u:User)
WHERE u.dontreqpreauth=True
RETURN u
```

---

## Find Password Not Required

```
MATCH (u:User)
WHERE u.passwordnotreqd=True
RETURN u
```

---

## Find Users with Reversible Encryption

```
MATCH (u:User)
WHERE u.encryptedtextpwdallowed=True
RETURN u
```

---

## Find Disabled Accounts

```
MATCH (u:User)
WHERE u.enabled=False
RETURN u
```

---

## Find Enabled Accounts

```
MATCH (u:User)
WHERE u.enabled=True
RETURN u
```

---

# 4. Local Admin Enumeration

Find machines where a user is local admin.

```
MATCH (u:User)-[:AdminTo]->(c:Computer)
RETURN u,c
```

---

Find computers administered by a group.

```
MATCH (g:Group)-[:AdminTo]->(c:Computer)
RETURN g,c
```

---

# 5. ACL Abuse

Look for:

- GenericAll
- GenericWrite
- WriteOwner
- WriteDACL
- ForceChangePassword
- AddMember
- AllExtendedRights

Query:

```
MATCH p=()-[r]->()
WHERE type(r) IN [
"GenericAll",
"GenericWrite",
"WriteOwner",
"WriteDacl",
"AddMember",
"ForceChangePassword",
"AllExtendedRights"
]
RETURN p
```

---

# 6. DCSync Rights

Built-in Query:

```
Find Principals with DCSync Rights
```

Cypher:

```
MATCH p=()-[:GetChanges|GetChangesAll|GetChangesInFilteredSet]->()
RETURN p
```

---

# 7. Delegation

## Unconstrained Delegation

```
MATCH (c:Computer)
WHERE c.unconstraineddelegation=True
RETURN c
```

---

## Constrained Delegation

```
MATCH (c:Computer)
WHERE c.allowedtodelegate IS NOT NULL
RETURN c
```

---

## Resource-Based Constrained Delegation (RBCD)

```
MATCH p=()-[:AllowedToAct]->()
RETURN p
```

---

# 8. Interesting User Properties

## SPNs

```
MATCH (u:User)
WHERE u.hasspn=True
RETURN u
```

---

## Password Never Expires

```
MATCH (u:User)
WHERE u.pwdneverexpires=True
RETURN u
```

---

## AdminCount = 1

```
MATCH (u:User)
WHERE u.admincount=True
RETURN u
```

---

## Trusted for Delegation

```
MATCH (u:User)
WHERE u.trustedtoauth=True
RETURN u
```

---

# 9. Group Enumeration

## Largest Groups

```
MATCH (g:Group)
RETURN g.name,g.membercount
ORDER BY g.membercount DESC
```

---

## Empty Groups

```
MATCH (g:Group)
WHERE g.membercount=0
RETURN g
```

---

## Nested Groups

```
MATCH (g1:Group)-[:MemberOf]->(g2:Group)
RETURN g1,g2
```

---

# 10. Computer Enumeration

## SQL Servers

```
MATCH (c:Computer)
WHERE c.name CONTAINS "SQL"
RETURN c
```

---

## Exchange Servers

```
MATCH (c:Computer)
WHERE c.name CONTAINS "EXCH"
RETURN c
```

---

## Domain Controllers

```
MATCH (c:Computer)
WHERE c.objectid ENDS WITH "-516"
RETURN c
```

---

## Workstations

```
MATCH (c:Computer)
WHERE c.operatingsystem CONTAINS "Windows 10"
RETURN c
```

---

# 11. Common Attack Paths

Look for:

- User → GenericAll → User
- User → ForceChangePassword → User
- User → AddMember → Group
- User → AdminTo → Computer
- Computer → HasSession → DA
- User → Owns → GPO
- User → WriteDACL → Group
- User → WriteOwner → Group
- User → GenericWrite → Computer
- User → AllowedToAct → Computer

---

# 12. Built-in BloodHound Queries Worth Running

- Find Shortest Paths to Domain Admins
- Find Principals with DCSync Rights
- Find Computers where Domain Users are Local Admin
- Find Workstations Admins Can RDP To
- Find Servers where Users Can RDP
- Find Users with Foreign Group Membership
- Find Kerberoastable Users
- Find AS-REP Roastable Users
- Find High Value Targets
- Find Unconstrained Delegation Systems
- Find Constrained Delegation Systems
- Find GPOs that Affect High Value Targets

---

# 13. Typical OSCP Attack Flow

1. Enumerate SMB
2. Obtain credentials
3. Collect BloodHound
4. Import ZIP
5. Mark owned users
6. Run shortest path to Domain Admins
7. Look for:
   - GenericAll
   - GenericWrite
   - ForceChangePassword
   - AddMember
   - AdminTo
   - HasSession
   - DCSync
8. Escalate privileges
9. Lateral movement
10. Capture DA

---

# 14. Typical GPEN Workflow

1. Import SharpHound/BloodHound-Python ZIP
2. Mark owned principals
3. Identify high-value assets
4. Review attack paths
5. Review delegation
6. Review ACL abuse
7. Review GPO permissions
8. Review sessions
9. Review local admins
10. Review DCSync paths

---

# 15. Useful Keyboard Shortcuts

| Shortcut | Action |
|-----------|--------|
| Ctrl + Click | Multi-select nodes |
| Right Click | Expand node |
| Double Click | Center graph |
| Mouse Wheel | Zoom |
| Drag | Pan |
| Delete | Remove selected node |

---

# 16. Exam Tips

- Always mark compromised users as **Owned**.
- Re-run path analysis after marking new owned users.
- Follow the **shortest path** first.
- Prioritize ACL abuse over password spraying.
- Session information is often the fastest route to DA.
- Kerberoastable accounts are usually low-hanging fruit.
- Look for DCSync rights before attempting full DA.
- GenericAll almost always leads to privilege escalation.
- AdminTo edges usually indicate lateral movement opportunities.
- BloodHound shows *possible* attack paths—always verify permissions manually.

---

# 17. Most Important Edges to Recognize

| Edge | Meaning |
|------|---------|
| MemberOf | Group membership |
| AdminTo | Local administrator |
| HasSession | User logged into computer |
| GenericAll | Full control |
| GenericWrite | Write permissions |
| WriteOwner | Take ownership |
| WriteDACL | Modify ACL |
| AddMember | Add users to group |
| ForceChangePassword | Reset password |
| Owns | Object ownership |
| AllowedToAct | RBCD |
| CanRDP | Remote Desktop |
| ExecuteDCOM | DCOM execution |
| CanPSRemote | PowerShell Remoting |
| SQLAdmin | SQL administrator |
| ReadLAPSPassword | Read LAPS password |
| GetChanges | DCSync |
| GetChangesAll | DCSync |
| GetChangesInFilteredSet | DCSync |

---

# 18. Golden Rules for Exams

- **Always collect BloodHound as soon as you obtain valid domain credentials.**
- **Always mark compromised users/computers as Owned.**
- **Always investigate shortest paths before manually enumerating.**
- **Always inspect ACL edges (GenericAll, GenericWrite, WriteDACL, WriteOwner).**
- **Never ignore session edges—they often reveal easy lateral movement.**
- **Check for DCSync rights before pursuing Domain Admin membership.**
- **Validate BloodHound findings with native tools before exploitation.**
