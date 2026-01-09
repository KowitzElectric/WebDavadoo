<#
.SYNOPSIS
    Tests the existence of a WebDAV item (file or directory).  Returns $true if the item exists, otherwise returns $false.
.DESCRIPTION
    Tests the existence of a WebDAV item (file or directory).  Returns $true if the item exists, otherwise returns $false.
.PARAMETER WebDavUrl
    Full WebDAV URL of the file or directory.
.PARAMETER SkipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended for production use.
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
        [switch]$SkipCertificateCheck,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
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
        if ($SkipCertificateCheck) {
            try {
                Invoke-WebRequest `
                    -Uri $WebDavUrl `
                    -Method Head `
                    -Authentication Basic `
                    -SkipCertificateCheck `
                    -Credential $CloudCredential `
                    -ErrorAction Stop | Out-Null
        
                Write-Verbose "HTTP 200 OK - item exists."
                return $true
            } # try {
            catch {
                $caughtException = $_.Exception

                # Certificate / TLS failure
                if (
                    $caughtException -is [System.Net.Http.HttpRequestException] -and
                    (
                        $caughtException.Message -match 'certificate' -or
                        $caughtException.Message -match 'SSL' -or
                        $caughtException.Message -match 'TLS'
                    )
                ) {
                    Write-Error -Category SecurityError -Message (
                        "Certificate validation failed while accessing '$WebDavUrl'. " +
                        "The existence of the item could not be determined."
                    )
                    return $false
                }

                # HTTP response present - real existence check
                if ($caughtException.Response) {
                    $statusCode = [int]$caughtException.Response.StatusCode
                    $statusDescription = $caughtException.Response.StatusDescription

                    Write-Verbose "HTTP $statusCode $statusDescription - item does NOT exist."
                    return $false
                }

                # Unknown failure
                Write-Error -Message "Unexpected error testing '$WebDavUrl': $($caughtException.Message)"
                return $false
            }

        } # if ($SkipCertificateCheck) {
        else {
            try {
                Invoke-WebRequest `
                    -Uri $WebDavUrl `
                    -Method Head `
                    -Authentication Basic `
                    -Credential $CloudCredential `
                    -ErrorAction Stop | Out-Null
            
                Write-Verbose "HTTP 200 OK - item exists."
                return $true
            } # try {
            catch {
                $caughtException = $_.Exception

                # Certificate / TLS failure
                if (
                    $caughtException -is [System.Net.Http.HttpRequestException] -and
                    (
                        $caughtException.Message -match 'certificate' -or
                        $caughtException.Message -match 'SSL' -or
                        $caughtException.Message -match 'TLS'
                    )
                ) {
                    Write-Error -Category SecurityError -Message (
                        "Certificate validation failed while accessing '$WebDavUrl'. " +
                        "The existence of the item could not be determined."
                    )
                    return $false
                }

                # HTTP response present - real existence check
                if ($caughtException.Response) {
                    $statusCode = [int]$caughtException.Response.StatusCode
                    $statusDescription = $caughtException.Response.StatusDescription

                    Write-Verbose "HTTP $statusCode $statusDescription - item does NOT exist."
                    return $false
                }

                # Unknown failure
                Write-Error -Message "Unexpected error testing '$WebDavUrl': $($caughtException.Message)"
                return $false
            }

        } # catch

    }
    end {
        
    }
} # function Test-WebDavItem {