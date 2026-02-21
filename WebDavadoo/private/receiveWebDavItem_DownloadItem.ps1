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
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $ItemUrl,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $TargetPath,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [bool]
        $IsDirectory,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [switch]
        $ShowResult = $false,
        
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [switch]
        $SkipCertificateCheck = $false,
        
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 5)]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
    )
    begin {
        Write-Verbose "Starting ReceiveWebDavItem_DownloadItem for $ItemUrl to $TargetPath. IsDirectory: $IsDirectory"
    }
    process {
        if ($IsDirectory) {
            if (-not (Test-Path $TargetPath)) {
                Write-Verbose "Creating directory: $TargetPath"
                New-Item -ItemType Directory -Path $TargetPath | Out-Null
            }
        }
        else {
            Write-Verbose "Downloading $ItemUrl -> $TargetPath"
            $paramsReceiveWebDavItem_DownloadItem = @{
                Uri            = $ItemUrl
                Outfile        = $TargetPath
                Authentication = 'Basic'
                Credential     = $CloudCredential
                ErrorAction    = 'Stop'
            }
            if ($SkipCertificateCheck) {
                $paramsReceiveWebDavItem_DownloadItem.Add("SkipCertificateCheck", $true)
            } # if ($SkipCertificateCheck) {

            try {
                Write-Verbose "Invoking web request with parameters: $($paramsReceiveWebDavItem_DownloadItem | Out-String) in ReceiveWebDavItem_DownloadItem"
                Invoke-WebRequest @paramsReceiveWebDavItem_DownloadItem
                Write-Verbose "Successfully downloaded file: $ItemUrl to $TargetPath"
            }
            catch {
                Write-Error "Failed to download file: $_"
            }
            #return
           
        }
    } # process{
    end {
        if ($ShowResult) {
            Write-Verbose "ShowResult is set to: $ShowResult in ReceiveWebDavItem_DownloadItem."
            ReceiveWebDavItem_ShowResult -WebDavUrl $ItemUrl -LocalPath $TargetPath 
        } # if ($ShowResult) {
    }
} # function ReceiveWebDavItem_DownloadItem {