<#
.SYNOPSIS
    Copies an item on a cloud file server using webdav.  You can use this to rename a file or copy it to a different directory.
.DESCRIPTION
    Copies an item on a cloud file server using webdav.  You can use this to rename a file or copy it to a different directory.
.PARAMETER WebDavUrlOfFile
    The webdav url down to the source file that you want to copy. This should be the full path to the file and include the file name and extension.
.PARAMETER DestinationWebDavUrlOfFile
    The webdav url destination for the source file. This should be the full path to the destination file and include the file name and extension.
.PARAMETER Overwrite
    This is a boolean value that determines whether to overwrite the file if it already exists at the destination.  Use "T" for true and "F" for false.
.PARAMETER SkipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended for production use.
.PARAMETER CloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
    Copy-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFile.txt" -DestinationWebDavUrlOfFile "https://example.com/webdav/MyFolder" 
    This will copy the file 'MyFile.txt' to the directory 'MyFolder' on the cloud file server.
.EXAMPLE
    Copy-WebDavItem -WebDavUrlOfFile "https://example.com/webdav/MyFile.txt" -DestinationWebDavUrlOfFile "https://example.com/webdav/MyFolder/MyRenamedFile.txt" -Overwrite "T" -skipCertificateCheck
    This will copy the file 'MyFile.txt' to the directory 'MyFolder' on the cloud file server and rename it to 'MyRenamedFile.txt'. If 'MyRenamedFile.txt' already exists, it will be overwritten.
#>
function Copy-WebDavItem {
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
                # invoke-webrequest to copy the file.  skip http error check to always get the data in $response
                $response = Invoke-WebRequest `
                    -Uri $WebDavUrlOfFile `
                    -CustomMethod COPY `
                    -Headers @{ Destination = $DestinationWebDavUrlOfFile 
                    "Overwrite"             = $Overwrite
                } `
                    -Authentication Basic `
                    -Credential $cloudCredential `
                    -SkipCertificateCheck
            } # try {
            catch {
                Write-Error "Failed to copy item: $_"
                return $null
            } # catch {
        } # if ($skipCertificateCheck) {
        else {
            try {
                # invoke-webrequest to copy the file.  skip http error check to always get the data in $response
                $response = Invoke-WebRequest `
                    -Uri $WebDavUrlOfFile `
                    -CustomMethod COPY `
                    -Headers @{ Destination = $DestinationWebDavUrlOfFile 
                    "Overwrite"             = $Overwrite
                } `
                    -Authentication Basic `
                    -Credential $cloudCredential `
            
            } # try {
            catch {
                Write-Error "Failed to copy item: $_"
                return $null
            } # catch {
        }
        $statusCode = $response.StatusCode
        $statusDescription = $response.StatusDescription
        
    } # process {
    
    end {

        if ($PSBoundParameters.Verbose) {
            switch -wildcard ($statusCode) {
                409 { Write-Verbose "Conflict Error: $statusCode $statusDescription - Check if destination path is valid."; break } # Conflict
                507 { Write-Verbose "Insufficient Storage: $statusCode $statusDescription"; break } # Insufficient Storage
                412 { Write-Verbose "Precondition Failed: $statusCode $statusDescription - Check if file exists or set Overwrite parameter."; break } # Precondition Failed
                423 { Write-Verbose "Locked: $statusCode $statusDescription - Check if file is locked by another process."; break } # Locked
                "2*" { Write-Verbose "Copy Success: $statusCode $statusDescription" } # Success
                "3*" { Write-Verbose "Redirection: $statusCode $statusDescription" } # Redirection
                "4*" { Write-Verbose "Client Error: $statusCode $statusDescription" } # Client Error
                "5*" { Write-Verbose "Server Error: $statusCode $statusDescription" } # Server Error
                Default {}
            }
        }

        # Return results to pipeline
        $results
    }
} # function Copy-WebDavItem