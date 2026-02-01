<#
.SYNOPSIS
    Creates a new directory on a cloud file server using webdav.
.DESCRIPTION
    This function creates a new directory on a cloud file server using webdav protocol. It uses the MKCOL method to create the directory at the specified location.
.PARAMETER webDavUrl
    The webdav url you can get from the settings of the cloud file server.
.PARAMETER newDirectoryName
    The name of the new directory you want to create.
.PARAMETER skipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended
.PARAMETER cloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
    New-WebDavDirectory -webDavUrl "https://example.com/webdav" -newDirectoryName "NewFolder" -cloudCredential (Get-Credential)
    "This will create a new directory called 'NewFolder' in the root of the cloud file server."
.EXAMPLE
    New-WebDavDirectory -webDavUrl "https://example.com/remote.php/dav/files/Jgalt/Folder1" -newDirectoryName 'SubFolder1' -cloudCredential (Get-Credential)
    "This will create a new directory called 'SubFolder1' in the 'Folder1' directory on the cloud file server."
#>
function New-WebDavDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $webDavUrl,
    
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [string]
        $newDirectoryName,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [switch]
        $ShowResult = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4)]
        [switch]$skipCertificateCheck,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 5)]
        [System.Management.Automation.PSCredential]$cloudCredential = $script:WebDavCredential
        
    )
    
    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {
        # This regex joins the path and ensures no double slashes exist after the protocol
        $fullUriPath = "$webDavUrl/$newDirectoryName" -replace '(?<!:)/+', '/'        
    }
    
    process {
        $params = @{
            Uri          = $fullUriPath
            CustomMethod = 'MKCOL'
            Credential   = $cloudCredential
        }

        if ($SkipCertificateCheck) {
            $params.Add("SkipCertificateCheck", $true)
        } # if ($SkipCertificateCheck) {

        
        try {
            $response = Invoke-WebRequest @params 
            Write-Verbose "Successfully created directory: $newDirectoryName at $webDavUrl"
        } # try {
        catch {
            Write-Error "Failed to create directory: $_"
        } # catch {
    }
    
    end {
        $statusCode = $response.StatusCode
        $statusDescription = $response.StatusDescription

        if ($statusCode -eq 201 -and $statusDescription -eq "Created" -and $ShowResult) {
            Write-Output "Created directory: $newDirectoryName at $webDavUrl"
        }
        else {
            Write-Output "Failed to create directory: $newDirectoryName at $webDavUrl. Status Code: $statusCode, Status Description: $statusDescription"
        }
    }
} # function New-WebDavDirectory {