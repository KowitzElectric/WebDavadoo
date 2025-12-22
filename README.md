# WebDavadoo

WebDavadoo (pronounced similarly to yabba-dabba-do) is a PowerShell module for working with WebDAV from the command line.  
It is designed to feel like native filesystem cmdlets while supporting authentication, recursion, folders, files, quotas, and more.

Developed and tested primarily against **Nextcloud WebDAV**, but should work with other compliant WebDAV servers.

---

## Features

- Authenticate once per session and reuse credentials
- Browse WebDAV directories like a filesystem
- Upload files and folders
- Download files and folders (optionally recursive)
- Create and remove directories
- Move and copy items
- Test for existence without throwing exceptions
- Retrieve storage quota information
- Designed to behave similar to PowerShell filesystem cmdlets

---

## Requirements

- PowerShell 7 or later
- WebDAV enabled on your cloud provider (Nextcloud is what WebDavadoo was tested against)

---

## Installation

Clone or download the repository and place the module in a PowerShell module path. For example:

```powershell
git clone https://github.com/<your-account>/WebDavadoo.git
cd WebDavadoo
Import-Module ./WebDavadoo.psm1
```

---

## Nextcloud Setup

1. Login to your Nextcloud instance
2. Go to Profile -> Security
3. Create a new App Password
4. Copy the generated username and password
5. Use this when prompted by the module

## WebDavaDonts

- Do not use Powershell 5. Several of the commands in the module are not available in Powershell 5.
