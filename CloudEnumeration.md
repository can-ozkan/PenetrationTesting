# Cloud Enumeration & Penetration Testing Cheat Sheet (OSCP / GPEN)

This cheat sheet provides a **structured methodology for enumerating and testing cloud environments** commonly encountered in **OSCP and GPEN-style exams and labs**. While many exams focus primarily on traditional infrastructure, cloud services (especially **AWS, Azure, and GCP**) increasingly appear in modern penetration testing environments.

Core methodology:

```
Discover Cloud Assets → Enumerate Services → Identify Misconfigurations → Exploit Access → Escalate Privileges
```

Cloud attacks are **misconfiguration-driven**, so careful enumeration is critical.

---

# 1. Identify Cloud Infrastructure

Determine if the target uses cloud infrastructure.

Check DNS records:

```bash
dig target.com
```

Look for cloud provider indicators:

```
amazonaws.com
cloudfront.net
azurewebsites.net
blob.core.windows.net
storage.googleapis.com
```

---

# 2. Subdomain Enumeration

Cloud services often appear as subdomains.

Tools:

```bash
amass enum -d target.com
```

```bash
sublist3r -d target.com
```

```bash
assetfinder target.com
```

Look for cloud-related subdomains:

```
dev.target.com
api.target.com
storage.target.com
cdn.target.com
```

---

# 3. Identify Cloud Storage Buckets

Search for exposed storage buckets.

### AWS S3 Buckets

Common naming patterns:

```
target
target-backup
target-dev
target-data
target-assets
```

Check bucket:

```bash
aws s3 ls s3://target
```

Anonymous access:

```bash
aws s3 ls s3://target --no-sign-request
```

Download contents:

```bash
aws s3 sync s3://target ./data --no-sign-request
```

---

# 4. Azure Blob Storage

Check Azure storage:

```
https://target.blob.core.windows.net
```

Use:

```bash
az storage blob list --container-name target
```

Anonymous access may expose files.

---

# 5. Google Cloud Storage

Check buckets:

```
https://storage.googleapis.com/target
```

Use tool:

```bash
gsutil ls gs://target
```

---

# 6. Enumerate Cloud Metadata

If you gain access to a cloud VM, check metadata services.

### AWS Metadata

```bash
curl http://169.254.169.254/latest/meta-data/
```

Retrieve credentials:

```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

---

### Azure Metadata

```bash
curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
```

---

### GCP Metadata

```bash
curl http://metadata.google.internal/computeMetadata/v1/
```

---

# 7. IAM Enumeration

List IAM users:

```bash
aws iam list-users
```

List roles:

```bash
aws iam list-roles
```

List policies:

```bash
aws iam list-policies
```

Check permissions.

---

# 8. Enumerate EC2 Instances

List instances:

```bash
aws ec2 describe-instances
```

Check security groups.

---

# 9. Security Group Enumeration

List security groups:

```bash
aws ec2 describe-security-groups
```

Look for misconfigured rules:

```
0.0.0.0/0
open ports
```

---

# 10. Enumerate Lambda Functions

List Lambda functions:

```bash
aws lambda list-functions
```

Check environment variables for secrets.

---

# 11. Cloud Database Enumeration

Check exposed databases.

Examples:

```
AWS RDS
Azure SQL
MongoDB Atlas
```

Scan ports:

```
3306
5432
27017
1433
```

---

# 12. API Enumeration

Cloud apps often expose APIs.

Test endpoints:

```
/api/
/v1/
/v2/
/admin/
```

Use:

```bash
curl http://target/api
```

---

# 13. Container Enumeration

Check Docker containers.

```bash
docker ps
```

Check images:

```bash
docker images
```

Check volumes:

```bash
docker inspect container
```

Look for secrets in environment variables.

---

# 14. Kubernetes Enumeration

Check cluster info:

```bash
kubectl cluster-info
```

List pods:

```bash
kubectl get pods
```

List namespaces:

```bash
kubectl get namespaces
```

Check secrets:

```bash
kubectl get secrets
```

---

# 15. Environment Variables

Cloud credentials often stored in environment variables.

```bash
env
```

Look for:

```
AWS_ACCESS_KEY
AWS_SECRET_KEY
DATABASE_PASSWORD
```

---

# 16. Configuration Files

Search for configuration files:

```
.env
config.json
settings.yaml
credentials.json
```

---

# 17. Cloud Credential Files

Common locations:

```
~/.aws/credentials
~/.aws/config
```

Check contents:

```bash
cat ~/.aws/credentials
```

---

# 18. Access Key Testing

Test AWS credentials:

```bash
aws sts get-caller-identity
```

List accessible resources.

---

# 19. Privilege Escalation

Check IAM permissions.

Example:

```
iam:PassRole
iam:AttachRolePolicy
```

Misconfigured roles can lead to privilege escalation.

---

# 20. Cloud Logging

Logs may contain sensitive information.

Examples:

```
CloudTrail
application logs
backup logs
```

Search logs for:

```
tokens
passwords
API keys
```

---

# 21. Exposed Git Repositories

Cloud deployments sometimes expose repositories.

Check:

```
/.git
/.env
/config
```

Download repo:

```bash
git-dumper http://target/.git
```

---

# 22. Backup Files

Look for backups in storage buckets.

Examples:

```
backup.zip
db_backup.sql
source_code.tar.gz
```

---

# 23. Credential Reuse

Cloud credentials often reused across services.

Test:

```
SSH
web admin panels
databases
CI/CD pipelines
```

---

# 24. Automated Enumeration Tools

Useful tools:

```
ScoutSuite
Pacu
CloudBrute
CloudMapper
```

Example:

```bash
scout aws
```

---

# 25. Quick Enumeration Commands

Run when cloud credentials discovered:

```bash
aws sts get-caller-identity
aws iam list-users
aws iam list-roles
aws ec2 describe-instances
aws s3 ls
```

---

# 26. Common Cloud Misconfigurations

Typical vulnerabilities:

```
Public S3 buckets
Exposed secrets
Overly permissive IAM roles
Open security groups
Public databases
```

---

# 27. Important Enumeration Questions

Always ask:

```
Where are credentials stored?
Which storage buckets are public?
Which roles have excessive permissions?
```

---

# 28. Cloud Attack Workflow

```
1. Identify cloud provider
2. Enumerate subdomains
3. Search for exposed storage
4. Enumerate metadata services
5. Identify credentials
6. Enumerate IAM permissions
7. Escalate privileges
```

---

# 29. Important Files to Inspect

Look for:

```
.env
credentials.json
aws_config
service_account.json
```

---

# 30. Final Advice

Cloud environments are **misconfiguration-heavy**.

Always remember:

```
Cloud breaches usually happen because something was exposed publicly.
```

Careful enumeration of **storage, IAM roles, and metadata services** usually leads to compromise.
