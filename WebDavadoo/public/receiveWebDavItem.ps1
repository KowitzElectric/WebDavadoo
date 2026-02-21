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
        [switch]
        $ShowResult = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [switch]$SkipCertificateCheck = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 5)]
        [System.Management.Automation.PSCredential]
        $cloudCredential = $script:WebDavCredential
    )

    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Verbose "Starting Receive-WebDavItem for $WebDavUrl to $LocalPath"

        # dot source the helper functions
        . "$script:PSScriptRootPrivate\receiveWebDavItem_DownloadItem.ps1"
        . "$script:PSScriptRootPrivate\receiveWebDavItem_WalkTree.ps1"
        . "$script:PSScriptRootPrivate\receiveWebDavItem_ShowResult.ps1"
        . "$script:PSScriptRootPrivate\receiveWebDavItem_TestUri.ps1"

        # Ensure local root exists
        if (-not (Test-Path $LocalPath)) {
            Write-Verbose "Creating local directory: $LocalPath"
            New-Item -ItemType Directory -Path $LocalPath | Out-Null
        }
        else {
            Write-Verbose "Local directory already exists: $LocalPath"
        }

    } # begin {

    process {
        # If not receiving a directory, then just download the single file
        $paramsItemProps = @{
            WebDavUrl       = $WebDavUrl
            CloudCredential = $CloudCredential
        }
        if ($SkipCertificateCheck) {
            $paramsItemProps.Add("SkipCertificateCheck", $true)
        } # if ($SkipCertificateCheck) {
        
        Write-Verbose "Getting item properties for: $WebDavUrl"
        try {
            $itemProps = Get-WebDavItemProperty @paramsItemProps
        }
        catch {
            Write-Error "Failed to get item properties: $_"
            return
        } # catch {

        $isDirectory = $itemProps.ContentType -eq 'directory'
        if (-not $isDirectory) {
            Write-Verbose "Receiving single file: $WebDavUrl"
            $fileName = Split-Path $WebDavUrl -Leaf
            $target = Join-Path $LocalPath $fileName

            $paramsReceiveWebDavItem_DownloadItem = @{
                ItemUrl         = $WebDavUrl
                TargetPath      = $target
                IsDirectory     = $false
                CloudCredential = $CloudCredential
            }
            if ($SkipCertificateCheck) {
                $paramsReceiveWebDavItem_DownloadItem.Add("SkipCertificateCheck", $true)
            } # if ($SkipCertificateCheck) {
            if ($ShowResult) {
                $paramsReceiveWebDavItem_DownloadItem.Add("ShowResult", $true)
            } # if ($ShowResult) {

            try {
                ReceiveWebDavItem_DownloadItem @paramsReceiveWebDavItem_DownloadItem
            } # try {
            catch {
                Write-Error "Failed to receive item: $_"
            } # catch {
            return

        } # if(-not $isDirectory) { 

        # Otherwise, walk the tree
        Write-Verbose "Receiving directory tree from: $WebDavUrl"
        $paramsReceiveWebDavItem_WalkTree = @{
            CurrentUrl       = $WebDavUrl
            CurrentLocalPath = $LocalPath
            CloudCredential  = $CloudCredential
        }
        if ($Recurse) {
            $paramsReceiveWebDavItem_WalkTree.Add("Recurse", $true)
        } # if ($Recurse) {
        if ($SkipCertificateCheck) {
            $paramsReceiveWebDavItem_WalkTree.Add("SkipCertificateCheck", $true)
        } # if ($SkipCertificateCheck) {
        ReceiveWebDavItem_WalkTree @paramsReceiveWebDavItem_WalkTree

    } # process {

    end {
        <# if ($ShowResult) {
            Write-Verbose "ShowResult is set to: $ShowResult"
            ReceiveWebDavItem_ShowResult -WebDavUrl $WebDavUrl -LocalPath $LocalPath 
        } # if ($ShowResult) { #>
    }
} # function Receive-WebDavItem {