<#
.SYNOPSIS
    Measure the size and count of files and directories at a WebDAV URL.
.DESCRIPTION
    Measure the size and count of files and directories at a WebDAV URL.
.PARAMETER WebDavUrlOfFile
    The webdav url down to the file or directory that you want to measure. This should be the full path to the file or directory.
.PARAMETER Recurse
    Switch to indicate whether to measure recursively through subdirectories.
.PARAMETER SkipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended for production use.
.PARAMETER CloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
    Measure-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFolder" -Recurse
    This will measure the size and count of files and directories in 'MyFolder' and all its subdirectories on the cloud file server.
.EXAMPLE
    Measure-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFolder/MyFile.txt" -skipCertificateCheck
    This will measure the size of the file 'MyFile.txt' on the cloud file server, skipping certificate validation.
#>
function Measure-WebDavItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $WebDavUrlOfFile,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [switch]$Recurse,

        [Parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]
        $skipCertificateCheck, 

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [System.Management.Automation.PSCredential]
        $cloudCredential = $script:WebDavCredential
    )

    begin {
        if (-not $CloudCredential) {
            throw "No WebDAV credential found. Run Set-WebDavCredential first."
        } # if (-not $CloudCredential) {

        . "$script:PSScriptRootPrivate\measureWebDavItem_WalkTree.ps1"

        $stats = [pscustomobject]@{
            Path           = $WebDavUrl
            FileCount      = 0
            DirectoryCount = 0
            TotalBytes     = [int64]0
        } # $stats = [pscustomobject]@{ ...
    } # begin {

    process {
        if ($Recurse) {
            Write-Verbose "Measuring WebDAV item at '$WebDavUrl' recursively."
            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check for recursive WebDAV measurement."
                MeasureWebDavItem_WalkTree -Url $WebDavUrl -Recurse:$true -SkipCertificateCheck
            }
            else {
                MeasureWebDavItem_WalkTree -Url $WebDavUrl -Recurse:$true
            }
        }
        else {
            Write-Verbose "Measuring WebDAV item at '$WebDavUrl' (non-recursive)."
            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check for WebDAV measurement."
                MeasureWebDavItem_WalkTree -Url $WebDavUrl -SkipCertificateCheck
            }
            else {
                MeasureWebDavItem_WalkTree -Url $WebDavUrl
            }
        }
        
    } # process

    end {
        $stats | Add-Member -NotePropertyName SizeMB -NotePropertyValue ([math]::Round($stats.TotalBytes / 1MB, 2))
        $stats | Add-Member -NotePropertyName SizeGB -NotePropertyValue ([math]::Round($stats.TotalBytes / 1GB, 2))
        $stats
    } # end
} # function Measure-WebDavItem {