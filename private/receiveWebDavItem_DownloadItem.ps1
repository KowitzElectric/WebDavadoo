<#
.SYNOPSIS
   Downloads a WebDAV item (file or directory) to a local path. This is a private function 
   and not available as a cmdlet.  It must be dot sourced and called from a public function.
.DESCRIPTION
    This function downloads a file or creates a directory at the specified local path.
.PARAMETER ItemUrl
    The WebDAV URL of the item to download.
.PARAMETER TargetPath
    The local path to download the item to.
.PARAMETER IsDirectory
    Indicates whether the item is a directory.
.PARAMETER CloudCredential
    The credential used to authenticate with the WebDAV server.
#>
function ReceiveWebDavItem_DownloadItem {
    param(
        [string]$ItemUrl,
        [string]$TargetPath,
        [bool]$IsDirectory,
        [System.Management.Automation.PSCredential]$CloudCredential
    )

    if ($IsDirectory) {
        if (-not (Test-Path $TargetPath)) {
            Write-Verbose "Creating directory: $TargetPath"
            New-Item -ItemType Directory -Path $TargetPath | Out-Null
        }
    }
    else {
        Write-Verbose "Downloading $ItemUrl -> $TargetPath"

        try {
            Invoke-WebRequest `
                -Uri $ItemUrl `
                -OutFile $TargetPath `
                -Authentication Basic `
                -Credential $CloudCredential `
                -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to download file: $_"
        }
    }
} # function ReceiveWebDavItem_DownloadItem {