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
        [switch]
        $skipCertificateCheck,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [System.Management.Automation.PSCredential]
        $cloudCredential = $script:WebDavCredential
        
    )
    
    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {

    } # begin {

    process {
        if ($skipCertificateCheck) {
            try {
                $response = Invoke-WebRequest `
                    -Uri $WebDavUrlOfFile `
                    -CustomMethod MOVE `
                    -Headers @{ Destination = $DestinationWebDavUrlOfFile } `
                    -Authentication Basic `
                    -Credential $cloudCredential `
                    -SkipCertificateCheck
            } # try {
            catch {
                Write-Error "Failed to move item: $_"
            } # catch {
        } # if ($skipCertificateCheck) {
        else {
            try {
                $response = Invoke-WebRequest `
                    -Uri $WebDavUrlOfFile `
                    -CustomMethod MOVE `
                    -Headers @{ Destination = $DestinationWebDavUrlOfFile } `
                    -Authentication Basic `
                    -Credential $cloudCredential
            } # try {
            catch {
                Write-Error "Failed to move item: $_"
            } # catch {
        } # else {
        
    }
    
    end {
        if ($PSCmdlet.MyInvocation.BoundParameters.Verbose) {
            Write-Verbose ("Status: {0} {1}" -f $response.StatusCode, $response.StatusDescription)
            Write-Verbose ("OC-FileId: {0}" -f $response.Headers['OC-FileId'])
            Write-Verbose ("ETag: {0}" -f $response.Headers['OC-ETag'])
            Write-Verbose ("Moved → {0}" -f $Destination)
        }
        
    }
} # function Move-WebDavItem