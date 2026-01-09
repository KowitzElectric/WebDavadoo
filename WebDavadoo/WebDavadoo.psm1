[CmdletBinding()]
param()

# Load Public functions
$Public = Join-Path $PSScriptRoot "public"
Get-ChildItem $Public -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Private functions are dot sourced as needed within public functions.  Use PSSCriptRootPrivate for path.
# Module-scoped variables
$script:PSScriptRootPrivate = Join-Path $PSScriptRoot 'private'

Write-Information -Message "Private script root: $script:PSScriptRootPrivate" -InformationAction SilentlyContinue
Write-Information -Message "WebDavadoo module version $($MyInvocation.MyCommand.Module.Version) loaded." 
Write-Information -Message "Use 'Get-Help <cmdlet-name> -Full' to see detailed help for each cmdlet." 
Write-Information -Message "Use 'Get-Command -Module WebDavadoo' to see all available cmdlets." 
Write-Information -Message "" 
Write-Information -Message "Run Set-WebDavCredential to enter your WebDAV credentials." 
$script:WebDavCredential = $null