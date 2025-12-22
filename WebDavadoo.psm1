# Load Public functions
$Public = Join-Path $PSScriptRoot "public"
Get-ChildItem $Public -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Private functions are dot sourced as needed within public functions.  Use PSSCriptRootPrivate for path.
# Module-scoped variables

$script:PSScriptRootPrivate = Join-Path $PSScriptRoot 'private'
Write-Host "Private script root: $script:PSScriptRootPrivate"

write-host "WebDavadoo module version $($MyInvocation.MyCommand.Module.Version) loaded."
Write-Host "Use 'Get-Help <cmdlet-name> -Full' to see detailed help for each cmdlet."
Write-Host "Use 'Get-Command -Module WebDavadoo' to see all available cmdlets."
Write-Host ""
Write-Host "Enter your WebDAV / Nextcloud credentials below"
# Module-scoped credential storage
# Module-scope variable for session credential
$script:WebDavCredential = $null
$script:WebDavCredential = Set-WebDavCredential