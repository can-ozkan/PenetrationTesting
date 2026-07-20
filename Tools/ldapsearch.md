# ldapsearch

```
# Anonymous LDAP Enumeration
ldapsearch -x -H ldap://10.10.10.10
ldapsearch -h 10.10.10.10 -x -s base namingcontexts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" > ldap.txt

grep -i description ldap.txt
grep -i password ldap.txt
grep -i pwd ldap.txt
grep -i memberOf ldap.txt
grep -i servicePrincipalName ldap.txt
grep -i userPrincipalName ldap.txt
grep -i admin ldap.txt
grep -i delegation ldap.txt
grep -i managedby ldap.txt
grep -i sAMAccountName ldap.txt
grep -i dn ldap.txt // for more user enumeration

# Basic LDAP Query
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=*)"

# Authenticated LDAP Query
ldapsearch -x -H ldap://10.10.10.10 -D "cn=admin,dc=example,dc=com" -w password -b "dc=example,dc=com"

# LDAP Query with User Principal Name
ldapsearch -x -H ldap://10.10.10.10 -D "user@example.com" -w password -b "dc=example,dc=com"

# Enumerate Naming Contexts
ldapsearch -x -H ldap://10.10.10.10 -s base namingcontexts

# Enumerate All Objects
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=*)"

# Enumerate Users
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=user)"

# Enumerate Computers
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=computer)"

# Enumerate Groups
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=group)"

# Enumerate Domain Admins
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(cn=Domain Admins)"

# Enumerate Specific User
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(sAMAccountName=john)"

# Enumerate Description Fields
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(description=*)"

# Enumerate Service Accounts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(servicePrincipalName=*)"

# Enumerate Kerberoastable Accounts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(&(objectClass=user)(servicePrincipalName=*))"

# Enumerate ASREP Roastable Accounts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))"

# Enumerate Password Policy
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=domainDNS)"

# Enumerate Organizational Units
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=organizationalUnit)"

# Enumerate AdminCount=1 Objects
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(adminCount=1)"

# Enumerate Disabled Accounts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2))"

# Enumerate Enabled Accounts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(&(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"

# Enumerate Members of Group
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(memberOf=CN=Domain Admins,CN=Users,DC=example,DC=com)"

# Enumerate DNS Records
ldapsearch -x -H ldap://10.10.10.10 -b "dc=DomainDnsZones,dc=example,dc=com"

# Query Specific Attributes
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=user)" cn mail sAMAccountName

# LDAP over SSL (LDAPS)
ldapsearch -x -H ldaps://10.10.10.10 -b "dc=example,dc=com"

# Ignore Certificate Validation
LDAPTLS_REQCERT=never ldapsearch -x -H ldaps://10.10.10.10 -b "dc=example,dc=com"

# Query Global Catalog
ldapsearch -x -H ldap://10.10.10.10:3268 -b "dc=example,dc=com"

# Verbose Output
ldapsearch -x -H ldap://10.10.10.10 -v -b "dc=example,dc=com"

# Save Output to File
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" > ldap.txt

# Common OSCP Commands
ldapsearch -x -H ldap://10.10.10.10 -s base namingcontexts
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=user)"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(objectClass=group)"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(servicePrincipalName=*)"
ldapsearch -x -H ldap://10.10.10.10 -b "dc=example,dc=com" "(description=*)"
ldapsearch -x -H ldap://10.10.10.10 -D "user@example.com" -w password -b "dc=example,dc=com"
```
