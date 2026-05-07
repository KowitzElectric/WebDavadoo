<#
.SYNOPSIS
    Get the child items of a directory on a cloud file server using WebDAV.  Answers: What is here?
.DESCRIPTION
    This function uses WebDAV to retrieve the child items (files and directories) of a specified directory on a cloud file server. It returns an array of custom objects, each representing a child item with properties such as Name, Type, LastWriteTime, and Length.
.PARAMETER WebDavUrl
    The WebDAV URL of the cloud file server.
.PARAMETER SkipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended for production use.
.PARAMETER CloudCredential
    The credentials to authenticate with the cloud file server.
.EXAMPLE
    Get-WebDavChildItem -WebDavUrl "https://example.com/webdav/" 
    This example retrieves the child items of the directory located at the specified WebDAV URL.
.EXAMPLE
@([pscustomobject]@{'WebDavUrl' = 'https://example.com/webdav';}) | Get-WebDavChildItem -skipCertificateCheck

#>
function Get-WebDavChildItem {
    [CmdletBinding()]
    param (
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
 
    } # begin {
    
    process {
        $params = @{
            Uri            = $webDavUrl
            CustomMethod   = 'PROPFIND'
            Headers        = @{ Depth = "1" }
            Authentication = 'Basic'
            Credential     = $cloudCredential
        }
        if ($skipCertificateCheck) {
            Write-Verbose "Skipping certificate check for WebDAV request to '$webDavUrl'."
            $params['SkipCertificateCheck'] = $true
        }
        else {
            Write-Verbose "Performing WebDAV request to '$webDavUrl'."
        }

        $response = Invoke-RestMethod @params

        if (-not $response.multistatus -or -not $response.multistatus.response) {
            Write-Verbose "No child items returned for $WebDavUrl"
            return
        }

        $allResponses = @($response.multistatus.response)
        $selfHref     = $allResponses[0].href

        # Single file targeted directly — emit it with the same shape as directory children
        if ($allResponses.Count -eq 1 -and $null -eq $allResponses[0].propstat.prop.resourcetype.collection) {
            $entry           = $allResponses[0]
            $lastModifiedRaw = $entry.propstat.prop.getlastmodified
            $lengthRaw       = $entry.propstat.prop.getcontentlength
            return [pscustomobject]@{
                HREF          = $entry.href
                Name          = $selfHref.TrimEnd('/').Split('/')[-1]
                DisplayName   = $entry.propstat.prop.displayname
                Type          = 'File'
                LastWriteTime = if ($lastModifiedRaw) { [datetime]$lastModifiedRaw } else { $null }
                Length        = if ($lengthRaw) { [int64]$lengthRaw } else { 0 }
                ContentType   = $entry.propstat.prop.getcontenttype
            }
        }

        $basePath = ($selfHref -replace '/[^/]+/?$', '/')

        $allResponses |
        Where-Object { $_.href -ne $selfHref } |
        ForEach-Object {

            $lastModifiedRaw = $_.propstat.prop.getlastmodified
            $lengthRaw       = $_.propstat.prop.getcontentlength

            [pscustomobject]@{
                HREF          = $_.href
                Name          = if ($_.href.Length -gt $basePath.Length) { $_.href.Substring($basePath.Length).TrimEnd('/') } else { $_.href.TrimEnd('/') }
                DisplayName   = $_.propstat.prop.displayname
                Type          = if ($null -ne $_.propstat.prop.resourcetype.collection) { 'Directory' } else { 'File' }
                LastWriteTime = if ($lastModifiedRaw) { [datetime]$lastModifiedRaw } else { $null }
                Length        = if ($lengthRaw) { [int64]$lengthRaw } else { 0 }
                ContentType   = $_.propstat.prop.getcontenttype
            }
        } # ForEach-Object
    } # process {
    
    end {
        
    }
} # function Get-WebDavChildItem {