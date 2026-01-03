<#
.SYNOPSIS
    Retrieves WebDAV quota information (used and available space).

.PARAMETER WebDavUrl
    Full WebDAV URL of the root directory.

.PARAMETER CloudCredential
    PSCredential for authentication.

.EXAMPLE
    $url = "https://webdav.example.com/remote.php/webdav/"
    Get-WebDavQuota -WebDavUrl $url -CloudCredential (Get-Credential)
    Retrieves and displays the quota information for the specified WebDAV root directory.
#>
function Get-WebDavQuota {
    param(
        [Parameter(Mandatory)][string]$WebDavUrl,
        [Parameter(Mandatory = $false, Position = 1)][switch]$skipCertificateCheck,
        [Parameter()][System.Management.Automation.PSCredential]$CloudCredential = $script:WebDavCredential
    )
    begin {
        
    }
    
    process {

        if ($skipCertificateCheck) {
            $resp = Invoke-WebRequest -Uri $WebDavUrl -CustomMethod PROPFIND -Headers @{ Depth = "0" } -Authentication Basic -Credential $CloudCredential -SkipCertificateCheck
        }
        else {
            $resp = Invoke-WebRequest -Uri $WebDavUrl -CustomMethod PROPFIND -Headers @{ Depth = "0" } -Authentication Basic -Credential $CloudCredential
        }
        
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