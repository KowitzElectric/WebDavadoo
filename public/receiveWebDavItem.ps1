<#
.SYNOPSIS
   Download files from a WebDAV server.
.DESCRIPTION
    This function downloads files and directories from a WebDAV server to a local path.
.PARAMETER WebDavUrl
    The WebDAV URL of the directory to download.
.PARAMETER LocalPath
    The local path to download the files to.
.PARAMETER Recursive
    If specified, download directories recursively.
.PARAMETER CloudCredential
    The credential used to authenticate with the WebDAV server.
.EXAMPLE
   Receive-WebDavItem -WebDavUrl "https://cloud.example.com/ownext/remote.php/dav/files/jgalt/Folder1" -LocalPath "C:\temp\download"
#>
function Receive-WebDavItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$WebDavUrl,

        [Parameter(Mandatory)]
        [string]$LocalPath,

        [Parameter(Mandatory = $false)]
        [bool]$Recursive = $false,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
    )

    begin {
        if (-not $CloudCredential) {
            throw "No WebDAV credential found. Run Set-WebDavCredential first."
        }

        . "$script:PSScriptRootPrivate\receiveWebDavItem_DownloadItem.ps1"
        . "$script:PSScriptRootPrivate\receiveWebDavItem_WalkTree.ps1"

        # Ensure local root exists
        if (-not (Test-Path $LocalPath)) {
            Write-Verbose "Creating local directory: $LocalPath"
            New-Item -ItemType Directory -Path $LocalPath | Out-Null
        }

    } # begin {

    process {
        ReceiveWebDavItem_WalkTree -CurrentUrl $WebDavUrl -CurrentLocalPath $LocalPath -Recursive:$Recursive -CloudCredential $CloudCredential
    }

    end {
        Write-Verbose "Receive-WebDavItem completed"
    }
} # function Receive-WebDavItem {