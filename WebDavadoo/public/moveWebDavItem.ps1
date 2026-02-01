<#
.SYNOPSIS
    Moves an item on a cloud file server using webdav.  You can use this to rename a file or move it to a different directory.
.DESCRIPTION
    Moves an item on a cloud file server using webdav.  You can use this to rename a file or move it to a different directory.
.PARAMETER WebDavUrlOfFile
    The webdav url down to the source file that you want to move. This should be the full path to the file and include the file name and extension.
.PARAMETER DestinationWebDavUrlOfFile
    The webdav url destination for the source file. This should be the full path to the destination file and include the file name and extension.
.PARAMETER CloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
    Move-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFile.txt" -DestinationWebDavUrlOfFile "https://example.com/webdav/MyFolder" -CloudCredential (Get-Credential)
    This will move the file 'MyFile.txt' to the directory 'MyFolder' on the cloud file server.
.EXAMPLE
    Move-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFile.txt" -DestinationWebDavUrlOfFile "https://example.com/webdav/MyFolder/MyRenamedFile.txt" -CloudCredential (Get-Credential)
    This will move the file 'MyFile.txt' to the directory 'MyFolder' on the cloud file server and rename it to 'MyRenamedFile.txt'.
.EXAMPLE
    Move-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFile.txt" -DestinationWebDavUrlOfFile "https://example.com/webdav/webdav/MyRenamedFile.txt" -skipCertificateCheck -CloudCredential (Get-Credential)
    This will rename the file 'MyFile.txt' to 'MyRenamedFile.txt', skipping SSL/TLS certificate validation.
#>
function Move-WebDavItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $WebDavUrlOfFile,
    
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $DestinationWebDavUrlOfFile,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [ValidateSet("T", "F")]
        [string]
        $Overwrite = "F",

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [switch]
        $ShowResult = $false,

        [Parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [switch]
        $skipCertificateCheck,

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
        $errorCount = 0
    } # begin {

    process {
        $params = @{
            Uri            = $WebDavUrlOfFile
            CustomMethod   = "MOVE"
            Headers        = @{ Destination = $DestinationWebDavUrlOfFile 
                "Overwrite"          = $Overwrite
            }
            Authentication = "Basic"
            Credential     = $cloudCredential
        } # $params = @{
        if ($SkipCertificateCheck) {
            $params.Add("SkipCertificateCheck", $true)
        } # if ($SkipCertificateCheck) {

        try {
            $response = Invoke-WebRequest @params
            Write-Verbose "Successfully moved: $WebDavUrlOfFile to $DestinationWebDavUrlOfFile"
        } # try {
        catch {
            Write-Error "Failed to move item: $_"
        } # catch {
    } # process {    
    end {
        $statusCode = $response.StatusCode
        $statusDescription = $response.StatusDescription

        if ($statusCode -eq 201 -and $statusDescription -eq "Created" -and $ShowResult) {
            Write-Output "Moved item: $WebDavUrlOfFile to $DestinationWebDavUrlOfFile"
        }
        else {
            Write-Output "Failed to move item: $WebDavUrlOfFile to $DestinationWebDavUrlOfFile. Status Code: $statusCode, Status Description: $statusDescription"
        }
    }
} # function Move-WebDavItem