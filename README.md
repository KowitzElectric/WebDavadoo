# WebDavadoo

WebDavadoo (pronounced with the same prosodic pattern as 'yabba-dabba-doo') is a PowerShell module for working with WebDAV from the command line. It is designed to feel like native filesystem cmdlets while supporting authentication, recursion, folders, files, quotas, and more.

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

## Goals

WebDavadoo is built with a few simple goals:

1. Be useful to real admins- Practical tools, not toys
2. Be script-friendly- Works in automation as well as interactively
3. Be predictable- Functions behave like familiar PowerShell cmdlets
4. Be transparent- Verbose logging where helpful
5. Respect user control- You choose when to recurse, overwrite, etc.

---

## Requirements

- PowerShell 7 or later
- WebDAV enabled on your website (Nextcloud and IIS are what WebDavadoo was tested against)

---

## Installation

Clone or download the repository and place the module in a PowerShell module path. For example:

```powershell
git clone https://github.com/<your-account>/WebDavadoo.git
cd WebDavadoo
Import-Module ./WebDavadoo.psm1
```

---

## Web server setup

### Nextcloud Setup

1. Login to your Nextcloud instance
2. Go to Profile -> Security
3. Create a new App Password
4. Copy the generated username and password
5. Use this when prompted by the module after running Set-WebDavCredential

### IIS Setup

---

## Credential Setup

You can store your credentials in memory for your sesions so you only enter them once: Set-WebDavCredential.

You'll be prompted for your username and app password. They are stored for the duration of the Powershell session.

---

## Common Usage

Browse remote directory contents:  
Get-WebDavChildItem -WebDavUrl "https://cloud.example.com/remote.php/dav/files/user/"

Download a file:
Receive-WebDavItem -WebDavUrl "https://cloud.example.com/.../Folder1" -LocalPath "C:\Temp"

Upload a file:
Send-ToWebDav -LocalPath "/home/jgalt/Documents/Lexico-ProsodicConvergenceandAcousticIdentity.docx" -WebDavUrl "https://cloud.example.com/.../Docs"

Move a file:
Move-WebDavItem -WebDavUrlOfFile https://cloud.example.com/remote.php/dav/files/jgalt/newfile.md -DestinationWebDavUrlOfFile https://files.thekozanos.com/remote.php/dav/files/jgalt/TextFile5.md

---

## Contributions

- Open issues for bugs, questions, or feature requests
- Submit PRs with improvements
- Share ideas on workflows that make WebDAV easier in PowerShell
- Please try to follow PowerShell style best practices where possible

---

## License

[LICENSE](https://github.com/KowitzElectric/WebDavadoo/blob/main/LICENSE)

---

## WebDavaDonts

- Do not use any version of Powershell below 7. Several of the commands in the module are not available until Powershell 7.
- Do not treat WebDAV paths like normal file system paths. WebDAV URLs behave differently than local paths. Case sensitivity, trailing slashes, and encoding matter.
- Do not store your credentials in scripts or repos Use Set-WebDavCredential interactively or secure vault solutions. Plain-text credentials are bad. Very bad.
- Do not forget to check your quota first. Upload failures often come from quota exhaustion. Run Get-WebDavQuota before massive syncs.
- Do not rely on this module as a backup strategy (yet). It’s a convenience tool, not a validated disaster-recovery platform. Verify your data integrity independently.
