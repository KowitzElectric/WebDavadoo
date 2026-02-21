function ReceiveWebDavItem_ShowResult {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WebDavUrl,
        [Parameter(Mandatory = $true)]
        [string]$LocalPath
    )
    
    begin {
        
    } # begin {
    
    process {
        #$downloadedFile = Join-Path $LocalPath (Split-Path $WebDavUrl -Leaf)
        Write-Verbose "Completed Receive-WebDavItem for $WebDavUrl to $LocalPath"
        $downloadStatus = Get-ChildItem -Path $LocalPath -ErrorAction SilentlyContinue
        Write-Verbose "Download status: $downloadStatus"
        if ($downloadStatus) {
            Write-Output "Downloaded $WebDavUrl to: $LocalPath"
        } # if ($downloadStatus) {
    } # process {
    
    end {
        
    } # end {
}