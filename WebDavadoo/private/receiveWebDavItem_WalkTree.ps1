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
.PARAMETER Recurse
    If specified, download directories recursively.
.PARAMETER CloudCredential
    The credential used to authenticate with the WebDAV server.

#>
function ReceiveWebDavItem_WalkTree {
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $CurrentUrl,
        
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $CurrentLocalPath,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]
        $Recurse,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [switch]
        $SkipCertificateCheck = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
    )
    begin {
        # Normalize CurrentUrl for comparison.  This ensures it ends with a slash by removing any trailing slashes and adding one.
        $currentUrl = $CurrentUrl.TrimEnd('/') + '/'
        # Create a URI object for CurrentUrl
        $baseuri = [uri]$CurrentUrl
        $authorityUri = "{0}://{1}" -f $baseUri.Scheme, $baseUri.Authority
        
        if ($SkipCertificateCheck) {
            $items = Get-WebDavChildItem -WebDavUrl $CurrentUrl -SkipCertificateCheck
        }
        else {
            $items = Get-WebDavChildItem -WebDavUrl $CurrentUrl
        }
    } # begin{
    process {
        foreach ($item in $items) {
            # If an empty folder, then usually the first entry is the folder itself. Skip it.
            $itemHrefTrimmed = $item.Href.TrimEnd('/') + '/'
            $itemUrlHrefTrimmed = $authorityUri + $itemHrefTrimmed
            $CurrentUrlTrimmed = $CurrentUrl.TrimEnd('/') + '/'
            if ($itemUrlHrefTrimmed -eq $CurrentUrlTrimmed) {
                Write-Verbose "Skipping self directory entry: $itemUrlHrefTrimmed"
                continue
            }

            # Determine local target path
            $relativeHref = $item.Href.TrimEnd('/')
            $name = Split-Path $relativeHref -Leaf
            $localTarget = Join-Path $CurrentLocalPath $name
            
            # Determine if item is a directory
            $isDir = $item.Type -eq 'Directory'                
                
            if ($isDir) {
                $hrefTrimmed = $item.Href.TrimEnd('/') + '/';
                $dirUrl = $authorityUri + $hrefTrimmed
                Write-Verbose "Entering directory: $dirUrl" 
                if ($SkipCertificateCheck) {
                    Write-Verbose "Skipping certificate check for directory creation: $localTarget"
                    # Create directory locally with ReceiveWebDavItem_DownloadItem
                    ReceiveWebDavItem_DownloadItem -ItemUrl $dirUrl -TargetPath $localTarget -IsDirectory $true -CloudCredential $CloudCredential -SkipCertificateCheck
                }
                else {
                    # Create directory locally with ReceiveWebDavItem_DownloadItem -IsDirectory $true will check and then create if needed
                    Write-Verbose "Creating directory without skipping certificate check: $localTarget"
                    ReceiveWebDavItem_DownloadItem -ItemUrl $dirUrl -TargetPath $localTarget -IsDirectory $true -CloudCredential $CloudCredential
                }
            
                if ($Recurse) {
                    Write-Verbose "Recursing into directory: $dirUrl"
                    if ($SkipCertificateCheck) {
                        ReceiveWebDavItem_WalkTree -CurrentUrl $dirUrl -Recurse -CurrentLocalPath $localTarget -CloudCredential $CloudCredential -SkipCertificateCheck
                    }
                    else {
                        ReceiveWebDavItem_WalkTree -CurrentUrl $dirUrl -Recurse -CurrentLocalPath $localTarget -CloudCredential $CloudCredential
                    }
                } # if ($Recurse) {
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
                    Write-Verbose "Downloading file without skipping certificate check: $localTarget"
                    ReceiveWebDavItem_DownloadItem -ItemUrl $fileUrl -TargetPath $localTarget -IsDirectory $false -CloudCredential $CloudCredential
            
                }
            
            } # else {
        } # foreach ($item in $items) {
    } # process{
    end {}
} # function ReceiveWebDavItem_WalkTree {

ReceiveWebDavItem_WalkTree -CurrentUrl https://files.thekozanos.com/remote.php/dav/files/Lee/WebDavadoo/ -CurrentLocalPath /tmp/testWebDav/ -Recurse -Verbose