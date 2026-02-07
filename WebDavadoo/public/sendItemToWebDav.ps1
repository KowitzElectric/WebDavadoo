<#
.Synopsis
   Upload files to a file server with WebDav support.
.DESCRIPTION
    This function uploads files to a cloud file server using WebDav.
.PARAMETER webDavUrl
    The webdav url you can get from the settings of the cloud file server.

.PARAMETER inputFilePath
    The path to the file you want to upload.
.PARAMETER cloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
Send-ItemToWebDav -webDavUrl "https://cloud.example.com/ownext/remote.php/dav/files/jgalt" -inputFilePath C:\temp\testfile.txt -Verbose
Sends the file testfile.txt to the root directory of the cloud file server with verbose output.
.EXAMPLE
Send-ItemToWebDav -webDavUrl 'https://cloud.example.com/ownext/remote.php/dav/files/jgalt/AppTroubleshooting' -inputFilePath C:\Users\ausername\Documents\ApplicationEventLog.evtx

#>
function Send-ItemToWebDav {
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # The webdav url you can get from the settings of the cloud file server.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $webDavUrl,

        # The path to the file you want to upload.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [string]
        $inputFilePath,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [switch]
        $ShowResult = $false,

        # Skip certificate check.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [switch]
        $skipCertificateCheck,

        # Use this to log into the cloud server webdav.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 5)]
        #[securestring]
        [System.Management.Automation.PSCredential]$cloudCredential = $script:WebDavCredential
    )

    Begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Verbose "Starting Send-ItemToWebDav for $inputFilePath to $webDavUrl"
        # always ensure the webdav url ends with a slash to avoid confusion between file and directory urls
        $webDavUrl = $webDavUrl.TrimEnd('/') + '/'

        $inputFileItem = Get-ChildItem -Path $inputFilePath;
        $fileName = $inputFileItem.Name;
        #$directoryPlusBase = $webDavUrl + $directory
        $uri = $webDavUrl + $fileName
        Write-Verbose "URI: $uri"
    }
    Process {
        $paramsSendItemToWebDav = @{
            Uri        = $uri
            InFile     = $inputFilePath
            Credential = $cloudCredential
            Method     = 'Put'
        }
        if ($skipCertificateCheck) {
            $paramsSendItemToWebDav.Add("SkipCertificateCheck", $true)
        } # if ($skipCertificateCheck) {
        try {
            $response = Invoke-WebRequest @paramsSendItemToWebDav
            Write-Verbose "Successfully uploaded file: $inputFilePath to $uri"
        }
        catch {
            Write-Error "Failed to upload file: $_"
        }

        $statusCode = $response.statusCode
        
    } # Process
    End {
        if ($statusCode -eq '201' -and $ShowResult) {
            Write-Output "Upload successful:  File: $inputFilePath uploaded to $uri"
        }
        elseif ($statusCode -ne '201' -and $ShowResult) {
            Write-Error "Upload failed with status code: $statusCode"
        }
    } # End
}