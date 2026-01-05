<#
.SYNOPSIS
    Get the child items of a directory on a cloud file server using WebDAV.  Answers: What is here?
.DESCRIPTION
    This function uses WebDAV to retrieve the child items (files and directories) of a specified directory on a cloud file server. It returns an array of custom objects, each representing a child item with properties such as Name, Type, LastWriteTime, and Length.
.PARAMETER WebDavUrl
    The WebDAV URL of the cloud file server.
.PARAMETER Path
    The directory on the cloud file server to retrieve the child items from.
.PARAMETER SkipCertificateCheck
    Switch to skip SSL/TLS certificate validation. This is just for testing purposes and not recommended for production use.
.PARAMETER CloudCredential
    The credentials to authenticate with the cloud file server.
.EXAMPLE
    Get-WebDavChildItem -WebDavUrl "https://example.com/webdav/" -Path "MyFolder" -CloudCredential (Get-Credential)
    This example retrieves the child items of the directory "MyFolder" on the cloud file server with the WebDAV URL "https://example.com/webdav/" using the provided credentials.
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
    
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]
        $Path = ".",

        [Parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]
        $skipCertificateCheck,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
        
    )
    
    begin {
        foreach ($p in $Path) {
            $WebDavUrl = if ($p -eq "." ) {
                $WebDavUrl.TrimEnd('/')
            }
            else {
                "$($WebDavUrl.TrimEnd('/'))/$p"
            }

            # PROPFIND against $uri
        } # foreach ($p in $Path) {    
        
    }
    
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
            [pscustomobject]@{
                HREF          = $_.href
                Name          = $_.href.Substring($basePath.Length).TrimEnd('/')
                Type          = if ($null -ne $_.propstat.prop.resourcetype.collection) { 'Directory' } else { 'File' }
                LastWriteTime = [datetime]$_.propstat.prop.getlastmodified
                Length        = [int64]$_.propstat.prop.getcontentlength
                ContentType   = $_.propstat.prop.getcontenttype
            }
        }
    } # process {
    
    end {
        
    }
} # function Get-WebDavChildItem {