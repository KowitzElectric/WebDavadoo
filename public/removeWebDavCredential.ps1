<#
.SYNOPSIS
    Remove the stored WebDAV credential.
.DESCRIPTION
    Remove the stored WebDAV credential from the session.
.EXAMPLE
    Remove-WebDavCredential
#>
function Remove-WebDavCredential {
    [CmdletBinding()]
    param()
    $script:WebDavCredential = $null
}