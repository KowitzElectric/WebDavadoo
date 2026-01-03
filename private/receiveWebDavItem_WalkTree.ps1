<#
.SYNOPSIS
    Recursively walks a WebDAV tree and downloads items.  This is a private function 
    and not available as a cmdlet.  It must be dot sourced and called from a public function.
.DESCRIPTION
    This function recursively walks a WebDAV tree starting from the specified URL,
    downloading files and creating directories as needed.
.PARAMETER CurrentUrl
    The current WebDAV URL to process.
.PARAMETER CurrentLocalPath
    The current local path to process.
.PARAMETER Recursive
    If specified, download directories recursively.
.PARAMETER CloudCredential
    The credential used to authenticate with the WebDAV server.

#>
function ReceiveWebDavItem_WalkTree {
    param(
        [string]$CurrentUrl,
        [string]$CurrentLocalPath,
        [bool]$Recursive,
        [switch]$SkipCertificateCheck = $false,
        [System.Management.Automation.PSCredential]$CloudCredential
    )

    if ($SkipCertificateCheck) {
        $items = Get-WebDavChildItem -WebDavUrl $CurrentUrl -SkipCertificateCheck
    }
    else {
        $items = Get-WebDavChildItem -WebDavUrl $CurrentUrl
    }
    
    foreach ($item in $items) {

        # If an empty folder, then usually the first entry is the folder itself. Skip it.
        if ($item.href -eq (New-Object System.Uri($CurrentUrl)).AbsolutePath -and $item.Length -eq 0) {
            Write-Verbose "Skipping empty directory entry: $($item.href)"
            continue
        }

        $name = $item.Name.Split('/') | Select-Object -Last 1; # Name: Jobs/Resumes
        $localTarget = Join-Path $CurrentLocalPath $name
        $isDir = $item.Length -eq 0 -and $item.Type -eq 'Directory'                
                
        if ($isDir) {
            $dirUrl = ($CurrentUrl.TrimEnd('/') + '/' + $name + '/')
            Write-Verbose "Entering directory: $dirUrl" 
            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check for directory creation: $localTarget"
                ReceiveWebDavItem_DownloadItem -ItemUrl $dirUrl -TargetPath $localTarget -IsDirectory $true -CloudCredential $CloudCredential -SkipCertificateCheck
            }
            else {
                ReceiveWebDavItem_DownloadItem -ItemUrl $dirUrl -TargetPath $localTarget -IsDirectory $true -CloudCredential $CloudCredential
            }
            
            if ($Recursive) {
                Write-Verbose "Recursing into directory: $dirUrl"
                if ($SkipCertificateCheck) {
                    ReceiveWebDavItem_WalkTree -CurrentUrl $dirUrl -CurrentLocalPath $localTarget -CloudCredential $CloudCredential -SkipCertificateCheck
                }
                else {
                    ReceiveWebDavItem_WalkTree -CurrentUrl $dirUrl -CurrentLocalPath $localTarget -CloudCredential $CloudCredential
                }
            } # if ($Recursive) {
        }
        else {
            Write-Verbose "Downloading file: $CurrentUrl"
            Write-Verbose "To local path: $localTarget"
            Write-Verbose "IsDirectory: $false"
            $fileUrl = ($CurrentUrl.TrimEnd('/') + '/' + $name)
            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check for file download: $localTarget"
                ReceiveWebDavItem_DownloadItem -ItemUrl $fileUrl -TargetPath $localTarget -IsDirectory $false -CloudCredential $CloudCredential -SkipCertificateCheck
            
            }
            else {
                ReceiveWebDavItem_DownloadItem -ItemUrl $fileUrl -TargetPath $localTarget -IsDirectory $false -CloudCredential $CloudCredential
            
            }
            
        } # else {
    } # foreach ($item in $items) {
} # function ReceiveWebDavItem_WalkTree {