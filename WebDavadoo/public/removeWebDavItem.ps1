<#
.SYNOPSIS
    Removes an item on a cloud file server using webdav.
.DESCRIPTION
    Removes an item on a cloud file server using webdav.
.PARAMETER WebDavUrlOfFile
    The webdav url down to the source file that you want to remove. This should be the full path to the file and include the file name and extension.  Can remove a folder too, but it must be empty.
.PARAMETER ItemToDelete
    The item to delete on the cloud file server.
.PARAMETER CloudCredential
    Use this to log into the cloud server webdav.
.EXAMPLE
    Remove-WebDavItem -WebDavUrl "https://example.com/webdav/MyFile.txt" -CloudCredential (Get-Credential)
    This will remove the file 'MyFile.txt' from the cloud file server.
#>
function Remove-WebDavItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $WebDavUrlOfFile,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [switch]
        $ShowResult = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]
        $SkipCertificateCheck = $false,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3)]
        [System.Management.Automation.PSCredential]$cloudCredential = $script:WebDavCredential
        
    )
    
    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {

    } # begin {

    process {
        $params = @{
            Uri            = $WebDavUrlOfFile
            CustomMethod   = "DELETE"
            Authentication = "Basic"
            Credential     = $cloudCredential
        }
        if ($SkipCertificateCheck) {
            $params.Add("SkipCertificateCheck", $true)
        } # if ($SkipCertificateCheck) {
        
        try {
            $response = Invoke-WebRequest @params
            # If we reach here, the command didn't throw an error.
            Write-Verbose "Successfully deleted: $WebDavUrlOfFile"
            Write-Verbose "Status: $($response.StatusCode) $($response.StatusDescription)"

        } # try {
        catch {
            Write-Error "Failed to remove item: $_"
        } # catch {        
      
    } # process {
    
    end {

        if ($ShowResult) {
            Write-Output "Removed item: $WebDavUrlOfFile"
        }
        
        
    } # end {
} # function Remove-WebDavItem