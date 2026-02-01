<#
.SYNOPSIS
    Retrieves WebDAV quota information (used and available space).

.PARAMETER WebDavUrl
    Full WebDAV URL of the root directory.

.PARAMETER SkipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended for production use.

.PARAMETER CloudCredential
    PSCredential for authentication.

.EXAMPLE
    $url = "https://webdav.example.com/remote.php/webdav/"
    Get-WebDavQuota -WebDavUrl $url -CloudCredential (Get-Credential)
    Retrieves and displays the quota information for the specified WebDAV root directory.
#>
function Get-WebDavQuota {
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $WebDavUrl,

        [Parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [switch]
        $skipCertificateCheck,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
    )
    begin {
        
    }
    
    process {

        <#         if ($skipCertificateCheck) {
            $resp = Invoke-WebRequest -Uri $WebDavUrl -CustomMethod PROPFIND -Headers @{ Depth = "0" } -Authentication Basic -Credential $CloudCredential -SkipCertificateCheck
        }
        else {
            $resp = Invoke-WebRequest -Uri $WebDavUrl -CustomMethod PROPFIND -Headers @{ Depth = "0" } -Authentication Basic -Credential $CloudCredential
        } #>
        
        $body = @'
<?xml version="1.0" encoding="utf-8" ?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    <D:quota-used-bytes />
    <D:quota-available-bytes />
  </D:prop>
</D:propfind>
'@
        if ($skipCertificateCheck) {
            try {
                $resp = Invoke-WebRequest `
                    -Uri $WebDavUrl `
                    -CustomMethod PROPFIND `
                    -Headers @{ Depth = "0" } `
                    -Body $body `
                    -ContentType 'application/xml' `
                    -Authentication Basic `
                    -Credential $CloudCredential `
                    -SkipCertificateCheck
            }
            catch {
                Write-Error "Error retrieving quota information: $_"
                return
            }
        }
        else {
            try {
                $resp = Invoke-WebRequest `
                    -Uri $WebDavUrl `
                    -CustomMethod PROPFIND `
                    -Headers @{ Depth = "0" } `
                    -Body $body `
                    -ContentType 'application/xml' `
                    -Authentication Basic `
                    -Credential $CloudCredential
            } # try
            catch {
                Write-Error "Error retrieving quota information: $_"
                return
            } # catch
        } # else

        [xml]$xml = $resp.Content
        $prop = $xml.multistatus.response.propstat.prop

        [pscustomobject]@{
            UsedMB      = [math]::Round([int64]$prop.'quota-used-bytes' / 1MB, 2)
            AvailableMB = [math]::Round([int64]$prop.'quota-available-bytes' / 1MB, 2)
        }   
    }
    
    end {
        
    }
} # function Get-WebDavQuota {