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
        if ($skipCertificateCheck) {
            Write-Verbose "Skipping certificate check for WebDAV request to '$webDavUrl'."
            $response = Invoke-WebRequest `
                -Uri $webDavUrl `
                -CustomMethod PROPFIND `
                -Headers @{ Depth = "1" } `
                -Authentication Basic `
                -Credential $cloudCredential `
                -SkipCertificateCheck
        }
        else {
            Write-Verbose "Performing WebDAV request to '$webDavUrl'."
            $response = Invoke-WebRequest `
                -Uri $webDavUrl `
                -CustomMethod PROPFIND `
                -Headers @{ Depth = "1" } `
                -Authentication Basic `
                -Credential $cloudCredential
        }

        [xml]$xml = $response.Content

        if (-not $xml.multistatus -or -not $xml.multistatus.response) {
            Write-Verbose "No child items returned for $WebDavUrl"
            return
        }

        $basePath = ($xml.multistatus.response[0].href -replace '/[^/]+/?$', '/')

        $xml.multistatus.response |
        Where-Object { $_.href -ne $xml.multistatus.response[0].href } |
        ForEach-Object {

            $lastModifiedRaw = $_.propstat.prop.getlastmodified;
            $lengthRaw = $_.propstat.prop.getcontentlength;

            [pscustomobject]@{
                HREF          = $_.href
                #Name          = $_.href.Substring($basePath.Length).TrimEnd('/')
                Name          = if ($_.href.Length -gt $basePath.Length) { $_.href.Substring($basePath.Length).TrimEnd('/') }else { $_.href.TrimEnd('/') }
                DisplayName   = $_.propstat.prop.displayname
                Type          = if ($null -ne $_.propstat.prop.resourcetype.collection) { 'Directory' } else { 'File' }
                LastWriteTime = if ($lastModifiedRaw) { [datetime]$lastModifiedRaw } else { $null }
                Length        = if ($lengthRaw) { [int64]$lengthRaw } else { 0 }
                ContentType   = $_.propstat.prop.getcontenttype
            } # pscustomobject
        } # ForEach-Object
    } # process {
    
    end {
        
    }
} # function Get-WebDavChildItem {