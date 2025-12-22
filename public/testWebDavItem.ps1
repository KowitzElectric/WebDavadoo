<#
.SYNOPSIS
    Tests the existence of a WebDAV item (file or directory).  Returns $true if the item exists, otherwise returns $false.
.DESCRIPTION
    Tests the existence of a WebDAV item (file or directory).  Returns $true if the item exists, otherwise returns $false.
.PARAMETER WebDavUrl
    Full WebDAV URL of the file or directory.

.PARAMETER CloudCredential
    PSCredential for authentication.

.EXAMPLE
    $url = "https://example.com/webdav/MyFile.txt"
    Test-WebDavItem -WebDavUrl $url -CloudCredential (Get-Credential)
    This will test if the file 'MyFile.txt' exists on the cloud file server.
#>
function Test-WebDavItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]$WebDavUrl,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        #[securestring]
        [System.Management.Automation.PSCredential]$CloudCredential = $script:WebDavCredential
    )
    Begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {
        if (-not $CloudCredential) {
            if (-not $script:WebDavCredential) {
                throw "No credential available. Run Set-WebDavCredential first or supply -CloudCredential."
            }
            $CloudCredential = $script:WebDavCredential
        }
    } # begin {
    Process {
        try {
            Invoke-WebRequest `
                -Uri $WebDavUrl `
                -Method Head `
                -Authentication Basic `
                -Credential $CloudCredential `
                -ErrorAction Stop | Out-Null
        
            Write-Verbose "HTTP 200 OK - item exists."
            return $true
        }
        catch {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $statusDescription = $_.Exception.Response.StatusDescription

            Write-Verbose "HTTP $statusCode $statusDescription - item does NOT exist."
            return $false
        }
    }
    end {
        
    }
} # function Test-WebDavItem {