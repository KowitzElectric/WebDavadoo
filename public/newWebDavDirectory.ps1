<#
.SYNOPSIS
    Creates a new directory on a cloud file server using webdav.
.DESCRIPTION
    Creates a new directory on a cloud file server using webdav.
.PARAMETER webDavUrl
    The webdav url you can get from the settings of the cloud file server.
.PARAMETER directory
    The directory on the cloud file server to create the new directory in.  If no directory is specified it will create the new directory in the root of the cloud file server.
.PARAMETER newDirectoryName
    The name of the new directory you want to create.
.PARAMETER cloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
    New-WebDavDirectory -webDavUrl "https://example.com/webdav" -directory "MyFolder" -newDirectoryName "NewFolder" -cloudCredential (Get-Credential)
    "This will create a new directory called 'NewFolder' in the 'MyFolder' directory on the cloud file server."
.EXAMPLE
    New-WebDavDirectory -webDavUrl "https://example.com/remote.php/dav/files/Jgalt" -newDirectoryName 'fromFunction4' -directory fromFunction2/fromFunction3 -cloudCredential (Get-Credential)
    "This will create a new directory called 'fromFunction4' in the 'fromFunction2/fromFunction3' directory on the cloud file server.  fromFunction2 and fromFunction3 must already exist, and
    fromFunction2 is off of the root directory."
#>
function New-WebDavDirectory {
    [CmdletBinding()]
    param (
        # The webdav url you can get from the settings of the cloud file server.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $webDavUrl,
    
        # The directory on the cloud file server to create the new directory in.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string]
        $directory,

        # The name of the new directory you want to create.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [string]
        $newDirectoryName,

        # Use this to log into the cloud server webdav.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        #[securestring]
        [System.Management.Automation.PSCredential]$cloudCredential = $script:WebDavCredential
        
    )
    
    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {
        if ($directory) {
            $fullUriPath = "$webDavUrl/$directory/$newDirectoryName"
        } # if ($directory) {
        else {
            $fullUriPath = "$webDavUrl/$newDirectoryName"
        } # else {
        
    }
    
    process {
        try {
            Invoke-RestMethod -Uri $fullUriPath -CustomMethod MKCOL -Credential $cloudCredential
        } # try {
        catch {
            Write-Error "Failed to create directory: $_"
        } # catch {
        
    }
    
    end {
        
    }
} # function New-WebDavDirectory {