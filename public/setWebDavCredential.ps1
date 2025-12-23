<#
.SYNOPSIS
    Sets the WebDAV / Nextcloud credential for the current session.
.DESCRIPTION
    This function prompts the user for their WebDAV / Nextcloud credentials
    and stores them in a module-scoped variable for use by other cmdlets.
.PARAMETER Credential
    An optional PSCredential object. If not provided, the user will be prompted
    to enter their credentials.
.EXAMPLE
    Set-WebDavCredential
    Prompts the user to enter their WebDAV / Nextcloud credentials.
.EXAMPLE
    $cred = Get-Credential
    Set-WebDavCredential -Credential $cred
    Sets the WebDAV / Nextcloud credentials using the provided PSCredential object.
#>
function Set-WebDavCredential {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    if (-not $Credential) {
        $Credential = Get-Credential -Message "Enter your WebDAV / Nextcloud credentials"
    }

    if (-not $Credential) {
        Write-Error "No credential provided."
        return
    }
    $script:WebDavCredential = $Credential
    #return $script:WebDavCredential
} # function Set-WebDavCredential