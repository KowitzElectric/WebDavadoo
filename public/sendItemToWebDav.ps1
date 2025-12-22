<#
.Synopsis
   Upload files to a file server with WebDav support.
.DESCRIPTION
    This function uploads files to a cloud file server using WebDav.
.PARAMETER webDavUrl
    The webdav url you can get from the settings of the cloud file server.
.PARAMETER directory
    The directory on the cloud file server to upload to.
.PARAMETER inputFilePath
    The path to the file you want to upload.
.PARAMETER cloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
Send-ItemToWedDav -webDavUrl https://cloud.example.com/ownext/remote.php/dav/files/jgalt/ -inputFilePath C:\path\to\file.ps1 -directory Folder1/subFolder2
.EXAMPLE
   PS Y:\> Send-ItemToWedDav -webDavUrl "https://cloud.example.com/ownext/remote.php/dav/files/jgalt" -inputFilePath C:\temp\testfile.txt -Verbose

.EXAMPLE
   PS C:\CustomScripts\dmca-backend> Send-ItemToWedDav -webDavUrl 'https://cloud.example.com/ownext/remote.php/dav/files/jgalt/AppTroubleshooting' -inputFilePath C:\Users\ausername\Documents\ApplicationEventLog.evtx
#>
function Send-ItemToWedDav {
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
    
        # The directory on the cloud file server to upload to.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $directory,

        # The path to the file you want to upload.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [string]
        $inputFilePath,

        # Use this to log into the cloud server webdav.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        #[securestring]
        [System.Management.Automation.PSCredential]$cloudCredential = $script:WebDavCredential
    )

    Begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {

        $inputFileItem = Get-ChildItem -Path $inputFilePath;
        $fileName = $inputFileItem.Name;
        $directoryPlusBase = $webDavUrl + $directory
        $uri = $directoryPlusBase + "/" + $fileName
        Write-Verbose "URI: $uri"
    }
    Process {
        $response = Invoke-WebRequest -uri $uri -CustomMethod MKCOL -Infile $inputFilePath -Credential $cloudCredential
        $statusCode = $response.statusCode
    } # Process
    End {
        if ($statusCode -eq '201') {
            Write-Verbose "File: $inputFilePath uploaded successfully to $uri"
        }
    } # End
}