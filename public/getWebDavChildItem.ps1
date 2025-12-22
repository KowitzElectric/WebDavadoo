<#
.SYNOPSIS
    Get the child items of a directory on a cloud file server using WebDAV.
.DESCRIPTION
    This function uses WebDAV to retrieve the child items (files and directories) of a specified directory on a cloud file server. It returns an array of custom objects, each representing a child item with properties such as Name, Type, LastWriteTime, and Length.
.PARAMETER WebDavUrl
    The WebDAV URL of the cloud file server.
.PARAMETER Path
    The directory on the cloud file server to retrieve the child items from.
.PARAMETER CloudCredential
    The credentials to authenticate with the cloud file server.
.EXAMPLE
    Get-WebDavChildItem -WebDavUrl "https://example.com/webdav/" -Path "MyFolder" -CloudCredential (Get-Credential)
    This example retrieves the child items of the directory "MyFolder" on the cloud file server with the WebDAV URL "https://example.com/webdav/" using the provided credentials.
#>
function Get-WebDavChildItem {
    [CmdletBinding()]
    param (
        # The webdav url you can get from the settings of the cloud file server.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $WebDavUrl,
    
        # The directory on the cloud file server to create the new directory in.
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$Path = ".",

        # Use this to log into the cloud server webdav.
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        #[securestring]
        [System.Management.Automation.PSCredential]$CloudCredential = $script:WebDavCredential
        
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
        $response = Invoke-WebRequest `
            -Uri $webDavUrl `
            -CustomMethod PROPFIND `
            -Headers @{ Depth = "1" } `
            -Authentication Basic `
            -Credential $cloudCredential

        [xml]$xml = $response.Content

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