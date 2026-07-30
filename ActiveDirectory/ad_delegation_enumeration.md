# AD Kerberos Delegation Enumeration Commands

```bash
export DOMAIN="corp.local"
export USER="username"
export PASS='Password123!'
export NTLM="0123456789abcdef0123456789abcdef"
export DC_IP="10.10.10.10"
export DC_FQDN="dc01.corp.local"
export BASE_DN="DC=corp,DC=local"
```

## Impacket — All Delegation Types

```bash
impacket-findDelegation "$DOMAIN/$USER:$PASS" -dc-ip "$DC_IP"
impacket-findDelegation "$DOMAIN/$USER" -hashes ":$NTLM" -dc-ip "$DC_IP"
impacket-findDelegation -k -no-pass "$DOMAIN/$USER" -dc-ip "$DC_IP" -dc-host "$DC_FQDN"
findDelegation.py "$DOMAIN/$USER:$PASS" -dc-ip "$DC_IP"
findDelegation.py "$DOMAIN/$USER" -hashes ":$NTLM" -dc-ip "$DC_IP"
findDelegation.py -k -no-pass "$DOMAIN/$USER" -dc-ip "$DC_IP" -dc-host "$DC_FQDN"
```

## PowerView Setup

```powershell
Import-Module .\PowerView.ps1
$Domain = "corp.local"
```

## PowerView — Unconstrained Delegation

```powershell
Get-DomainComputer -Domain $Domain -Unconstrained -Properties samaccountname,dnshostname,useraccountcontrol
Get-DomainObject -Domain $Domain -LDAPFilter '(userAccountControl:1.2.840.113556.1.4.803:=524288)' -Properties samaccountname,dnshostname,distinguishedname,useraccountcontrol
Get-DomainObject -Domain $Domain -LDAPFilter '(&(userAccountControl:1.2.840.113556.1.4.803:=524288)(objectCategory=computer))' -Properties samaccountname,dnshostname,distinguishedname,useraccountcontrol
Get-DomainObject -Domain $Domain -LDAPFilter '(&(userAccountControl:1.2.840.113556.1.4.803:=524288)(objectCategory=person)(objectClass=user))' -Properties samaccountname,distinguishedname,useraccountcontrol
```

## PowerView — Constrained Delegation

```powershell
Get-DomainComputer -Domain $Domain -TrustedToAuth -Properties samaccountname,dnshostname,msds-allowedtodelegateto,useraccountcontrol
Get-DomainObject -Domain $Domain -LDAPFilter '(msDS-AllowedToDelegateTo=*)' -Properties samaccountname,dnshostname,distinguishedname,msds-allowedtodelegateto,useraccountcontrol
Get-DomainObject -Domain $Domain -LDAPFilter '(&(msDS-AllowedToDelegateTo=*)(userAccountControl:1.2.840.113556.1.4.803:=16777216))' -Properties samaccountname,dnshostname,distinguishedname,msds-allowedtodelegateto,useraccountcontrol
Get-DomainObject -Domain $Domain -LDAPFilter '(&(msDS-AllowedToDelegateTo=*)(!(userAccountControl:1.2.840.113556.1.4.803:=16777216)))' -Properties samaccountname,dnshostname,distinguishedname,msds-allowedtodelegateto,useraccountcontrol
```

## PowerView — Resource-Based Constrained Delegation

```powershell
Get-DomainObject -Domain $Domain -LDAPFilter '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' -Properties samaccountname,dnshostname,distinguishedname,msds-allowedtoactonbehalfofotheridentity
Get-DomainComputer -Domain $Domain -Properties samaccountname,dnshostname,distinguishedname,msds-allowedtoactonbehalfofotheridentity | Where-Object { $_.'msds-allowedtoactonbehalfofotheridentity' }
Get-DomainComputer -Domain $Domain -Properties samaccountname,dnshostname,msds-allowedtoactonbehalfofotheridentity | Where-Object { $_.'msds-allowedtoactonbehalfofotheridentity' } | ForEach-Object { $SD = New-Object Security.AccessControl.RawSecurityDescriptor($_.'msds-allowedtoactonbehalfofotheridentity',0); $SD.DiscretionaryAcl | ForEach-Object { ConvertFrom-SID $_.SecurityIdentifier.Value } }
```

## ActiveDirectory Module Setup

```powershell
Import-Module ActiveDirectory
$Server = "dc01.corp.local"
```

## ActiveDirectory Module — Unconstrained Delegation

```powershell
Get-ADComputer -Server $Server -Filter 'TrustedForDelegation -eq $true' -Properties TrustedForDelegation,userAccountControl,dNSHostName
Get-ADUser -Server $Server -Filter 'TrustedForDelegation -eq $true' -Properties TrustedForDelegation,userAccountControl
Get-ADObject -Server $Server -LDAPFilter '(userAccountControl:1.2.840.113556.1.4.803:=524288)' -Properties samAccountName,dNSHostName,userAccountControl
```

## ActiveDirectory Module — Constrained Delegation

```powershell
Get-ADObject -Server $Server -LDAPFilter '(msDS-AllowedToDelegateTo=*)' -Properties samAccountName,dNSHostName,msDS-AllowedToDelegateTo,userAccountControl
Get-ADComputer -Server $Server -Filter 'TrustedToAuthForDelegation -eq $true' -Properties TrustedToAuthForDelegation,msDS-AllowedToDelegateTo,userAccountControl,dNSHostName
Get-ADUser -Server $Server -Filter 'TrustedToAuthForDelegation -eq $true' -Properties TrustedToAuthForDelegation,msDS-AllowedToDelegateTo,userAccountControl
Get-ADObject -Server $Server -LDAPFilter '(&(msDS-AllowedToDelegateTo=*)(userAccountControl:1.2.840.113556.1.4.803:=16777216))' -Properties samAccountName,dNSHostName,msDS-AllowedToDelegateTo,userAccountControl
Get-ADObject -Server $Server -LDAPFilter '(&(msDS-AllowedToDelegateTo=*)(!(userAccountControl:1.2.840.113556.1.4.803:=16777216)))' -Properties samAccountName,dNSHostName,msDS-AllowedToDelegateTo,userAccountControl
```

## ActiveDirectory Module — Resource-Based Constrained Delegation

```powershell
Get-ADObject -Server $Server -LDAPFilter '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' -Properties samAccountName,dNSHostName,msDS-AllowedToActOnBehalfOfOtherIdentity
Get-ADComputer -Server $Server -LDAPFilter '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' -Properties dNSHostName,msDS-AllowedToActOnBehalfOfOtherIdentity
Get-ADComputer -Server $Server -LDAPFilter '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' -Properties dNSHostName,msDS-AllowedToActOnBehalfOfOtherIdentity | ForEach-Object { $SD = New-Object Security.AccessControl.RawSecurityDescriptor($_.'msDS-AllowedToActOnBehalfOfOtherIdentity',0); $SD.DiscretionaryAcl | ForEach-Object { Get-ADObject -Server $Server -Identity $_.SecurityIdentifier.Value -Properties samAccountName } }
```

## LDAPSearch — Unconstrained Delegation

```bash
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(userAccountControl:1.2.840.113556.1.4.803:=524288)' dn sAMAccountName dNSHostName userAccountControl
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=524288))' dn sAMAccountName dNSHostName userAccountControl
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=524288))' dn sAMAccountName userAccountControl
```

## LDAPSearch — Constrained Delegation

```bash
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(msDS-AllowedToDelegateTo=*)' dn sAMAccountName dNSHostName msDS-AllowedToDelegateTo userAccountControl
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(&(msDS-AllowedToDelegateTo=*)(userAccountControl:1.2.840.113556.1.4.803:=16777216))' dn sAMAccountName dNSHostName msDS-AllowedToDelegateTo userAccountControl
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(&(msDS-AllowedToDelegateTo=*)(!(userAccountControl:1.2.840.113556.1.4.803:=16777216)))' dn sAMAccountName dNSHostName msDS-AllowedToDelegateTo userAccountControl
```

## LDAPSearch — Resource-Based Constrained Delegation

```bash
ldapsearch -LLL -x -H "ldap://$DC_IP" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' dn sAMAccountName dNSHostName msDS-AllowedToActOnBehalfOfOtherIdentity
ldapsearch -LLL -x -H "ldaps://$DC_FQDN" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' dn sAMAccountName dNSHostName msDS-AllowedToActOnBehalfOfOtherIdentity
```

## Native PowerShell ADSI — Unconstrained Delegation

```powershell
$Root = New-Object DirectoryServices.DirectoryEntry("LDAP://DC=corp,DC=local")
$Searcher = New-Object DirectoryServices.DirectorySearcher($Root)
$Searcher.Filter = '(userAccountControl:1.2.840.113556.1.4.803:=524288)'
$Searcher.PropertiesToLoad.AddRange(@('samaccountname','dnshostname','distinguishedname','useraccountcontrol'))
$Searcher.FindAll() | ForEach-Object { $_.Properties }
```

## Native PowerShell ADSI — Constrained Delegation

```powershell
$Root = New-Object DirectoryServices.DirectoryEntry("LDAP://DC=corp,DC=local")
$Searcher = New-Object DirectoryServices.DirectorySearcher($Root)
$Searcher.Filter = '(msDS-AllowedToDelegateTo=*)'
$Searcher.PropertiesToLoad.AddRange(@('samaccountname','dnshostname','distinguishedname','msds-allowedtodelegateto','useraccountcontrol'))
$Searcher.FindAll() | ForEach-Object { $_.Properties }
```

## Native PowerShell ADSI — Resource-Based Constrained Delegation

```powershell
$Root = New-Object DirectoryServices.DirectoryEntry("LDAP://DC=corp,DC=local")
$Searcher = New-Object DirectoryServices.DirectorySearcher($Root)
$Searcher.Filter = '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)'
$Searcher.PropertiesToLoad.AddRange(@('samaccountname','dnshostname','distinguishedname','msds-allowedtoactonbehalfofotheridentity'))
$Searcher.FindAll() | ForEach-Object { $_.Properties }
```

## BloodHound Collection

```bash
bloodhound-python -u "$USER" -p "$PASS" -d "$DOMAIN" -ns "$DC_IP" -dc "$DC_FQDN" -c DCOnly
bloodhound-python -u "$USER" --hashes ":$NTLM" -d "$DOMAIN" -ns "$DC_IP" -dc "$DC_FQDN" -c DCOnly
bloodhound-python -k -no-pass -d "$DOMAIN" -ns "$DC_IP" -dc "$DC_FQDN" -c DCOnly
```

```powershell
.\SharpHound.exe -d corp.local -c DCOnly --zipfilename delegation.zip
.\SharpHound.exe -d corp.local -c All --zipfilename bloodhound-all.zip
```

## LDAPS Variants

```bash
ldapsearch -LLL -x -H "ldaps://$DC_FQDN" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(userAccountControl:1.2.840.113556.1.4.803:=524288)' dn sAMAccountName dNSHostName userAccountControl
ldapsearch -LLL -x -H "ldaps://$DC_FQDN" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(msDS-AllowedToDelegateTo=*)' dn sAMAccountName dNSHostName msDS-AllowedToDelegateTo userAccountControl
ldapsearch -LLL -x -H "ldaps://$DC_FQDN" -D "$USER@$DOMAIN" -w "$PASS" -b "$BASE_DN" '(msDS-AllowedToActOnBehalfOfOtherIdentity=*)' dn sAMAccountName dNSHostName msDS-AllowedToActOnBehalfOfOtherIdentity
```
