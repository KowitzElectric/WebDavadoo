<#
.SYNOPSIS
   Download files from a WebDAV server.
.DESCRIPTION
    This function downloads files and directories from a WebDAV server to a local path.
.PARAMETER WebDavUrl
    The WebDAV URL of the directory to download.
.PARAMETER LocalPath
    The local path to download the files to.
.PARAMETER Recurse
    If specified, download directories recursively.
.PARAMETER CloudCredential
    The credential used to authenticate with the WebDAV server.
.EXAMPLE
   Receive-WebDavItem -WebDavUrl "https://cloud.example.com/ownext/remote.php/dav/files/jgalt/Folder1" -LocalPath "C:\temp\download"
#>
function Receive-WebDavItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $WebDavUrl,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]$LocalPath,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]$Recurse = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [switch]$SkipCertificateCheck = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [System.Management.Automation.PSCredential]
        $cloudCredential = $script:WebDavCredential
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
        # If not a directory, just download the single file
        $itemProps = Get-WebDavItemProperty `
            -WebDavUrl $WebDavUrl `
            -SkipCertificateCheck:$SkipCertificateCheck `
            -CloudCredential $CloudCredential

        $isDirectory = $itemProps.ContentType -eq 'directory'
        if (-not $isDirectory) {
            $fileName = Split-Path $WebDavUrl -Leaf
            $target = Join-Path $LocalPath $fileName

            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check. Downloading file $WebDavUrl to $target"
                ReceiveWebDavItem_DownloadItem `
                    -ItemUrl $WebDavUrl `
                    -TargetPath $target `
                    -IsDirectory $false `
                    -CloudCredential $CloudCredential `
                    -SkipCertificateCheck:$SkipCertificateCheck

                return
            }
            else {
                Write-Verbose "Downloading file $WebDavUrl to $target"
                ReceiveWebDavItem_DownloadItem `
                    -ItemUrl $WebDavUrl `
                    -TargetPath $target `
                    -IsDirectory $false `
                    -CloudCredential $CloudCredential `

                return

            } # else {
        } # if(-not $isDirectory) {

        # Otherwise, walk the tree
        if ($SkipCertificateCheck) {
            Write-Verbose "Skipping certificate check. Receiving WebDAV items from $WebDavUrl to $LocalPath"
            if ($Recurse) {
                ReceiveWebDavItem_WalkTree -CurrentUrl $WebDavUrl -CurrentLocalPath $LocalPath -Recurse -CloudCredential $CloudCredential -SkipCertificateCheck
            }
            else {
                ReceiveWebDavItem_WalkTree -CurrentUrl $WebDavUrl -CurrentLocalPath $LocalPath -CloudCredential $CloudCredential -SkipCertificateCheck
            }
        } # if ($SkipCertificateCheck) {
        else {
            Write-Verbose "Receiving WebDAV items from $WebDavUrl to $LocalPath"
            if ($Recurse) {
                ReceiveWebDavItem_WalkTree -CurrentUrl $WebDavUrl -CurrentLocalPath $LocalPath -Recurse -CloudCredential $CloudCredential
            }
            else {
                ReceiveWebDavItem_WalkTree -CurrentUrl $WebDavUrl -CurrentLocalPath $LocalPath -CloudCredential $CloudCredential
            }
        } # else {
    }

    end {
        Write-Verbose "Receive-WebDavItem completed"
    }
} # function Receive-WebDavItem {