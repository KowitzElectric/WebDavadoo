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

    return $Credential
} # function Set-WebDavCredential