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
            Position = 3)]
        #[securestring]
        [System.Management.Automation.PSCredential]$cloudCredential = $script:WebDavCredential
        
    )
    
    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            Write-Error "This script requires PowerShell 7+"
            exit 1
        } # if ($PSVersionTable.PSVersion.Major -lt 7) {

    } # begin {

    process {
        try {
            $response = Invoke-WebRequest `
                -Uri $WebDavUrlOfFile `
                -CustomMethod DELETE `
                -Authentication Basic `
                -Credential $cloudCredential
        } # try {
        catch {
            Write-Error "Failed to remove item: $_"
        } # catch {
        
    }
    
    end {
        if ($PSCmdlet.MyInvocation.BoundParameters.Verbose) {
            Write-Verbose ("Status: {0} {1}" -f $response.StatusCode, $response.StatusDescription)

            if ($response.Headers['X-Request-ID']) {
                Write-Verbose ("Request ID: {0}" -f $response.Headers['X-Request-ID'])
            }

            if ($response.Headers['OC-ETag']) {
                Write-Verbose ("ETag: {0}" -f $response.Headers['OC-ETag'])
            }
        }
        
    }
} # function Remove-WebDavItem