<#
.SYNOPSIS
    Retrieves WebDAV item metadata (etag, last modified, size, etc.)

.PARAMETER WebDavUrl
    Full WebDAV URL of the file or directory.

.PARAMETER CloudCredential
    PSCredential for authentication.

.EXAMPLE
    $url = "https://webdav.example.com/remote.php/webdav/path/to/item.txt"
    Get-WebDavItemProperty -WebDavUrl $url -CloudCredential (Get-Credential)
    Retrieves and displays the properties of the specified WebDAV item.txt.
#>
function Get-WebDavItemProperty {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$WebDavUrl,

        [Parameter()]
        [System.Management.Automation.PSCredential]$CloudCredential = $script:WebDavCredential
    )

    process {
        try {
            Write-Verbose "Requesting WebDAV properties for $WebDavUrl"
            $resp = Invoke-WebRequest `
                -Uri $WebDavUrl `
                -CustomMethod PROPFIND `
                -Headers @{ Depth = "0" } `
                -Authentication Basic `
                -Credential $CloudCredential
        }
        catch {
            Write-Error "Failed to get item properties: $_"
            return
        }

        try {
            [xml]$xml = $resp.Content
            $prop = $xml.multistatus.response.propstat.prop

            [pscustomobject]@{
                Href            = $xml.multistatus.response.href
                ETag            = $prop.getetag
                LastModified    = [datetime]$prop.getlastmodified
                ContentType     = if ($prop.getcontenttype) { $prop.getcontenttype } else { "directory" }
                ContentLengthMB = if ($prop.'getcontentlength') {
                    [math]::Round($prop.'getcontentlength' / 1MB, 2)
                }
                else { $null }
            }
        }
        catch {
            Write-Error "Failed to parse WebDAV response: $_"
        }
    }# process {
    end {
    } # end {
} # function Get-WebDavItemProperty {