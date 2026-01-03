function Measure-WebDavItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WebDavUrl,

        [Parameter()]
        [switch]$Recurse,

        # Parameter help description
        [Parameter()]
        [switch]
        $SkipCertificateCheck, 

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
    )

    begin {
        if (-not $CloudCredential) {
            throw "No WebDAV credential found. Run Set-WebDavCredential first."
        }

        . "$script:PSScriptRootPrivate\measureWebDavItem_WalkTree.ps1"

        $stats = [pscustomobject]@{
            Path           = $WebDavUrl
            FileCount      = 0
            DirectoryCount = 0
            TotalBytes     = [int64]0
        }

        <# function Walk-WebDav {
            param(
                [string]$Url
            )

            $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential

            foreach ($item in $items) {

                # Skip the self-reference entry if present
                if ($item.HREF -eq (New-Object System.Uri($Url)).AbsolutePath) {
                    continue
                } # if ($item.HREF -eq (New-Object System.Uri($Url)).AbsolutePath)

                if ($item.Type -eq "Directory") {
                    $stats.DirectoryCount++

                    if ($Recurse) {
                        $dirUrl = ($Url.TrimEnd('/') + '/' + $item.Name.TrimEnd('/') + '/')
                        Walk-WebDav -Url $dirUrl
                    } # if recurse
                } # if ($item.Type -eq "Directory")
                else {
                    $stats.FileCount++
                    $stats.TotalBytes += [int64]$item.Length
                } # else
            } # foreach ($item in $items)
        } # function Walk-WebDav { #>
    }

    process {
        if ($Recurse) {
            Write-Verbose "Measuring WebDAV item at '$WebDavUrl' recursively."
            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check for recursive WebDAV measurement."
                MeasureWebDavItem_WalkTree -Url $WebDavUrl -Recurse:$true -SkipCertificateCheck
            }
            else {
                MeasureWebDavItem_WalkTree -Url $WebDavUrl -Recurse:$true
            }
        }
        else {
            Write-Verbose "Measuring WebDAV item at '$WebDavUrl' (non-recursive)."
            if ($SkipCertificateCheck) {
                Write-Verbose "Skipping certificate check for WebDAV measurement."
                MeasureWebDavItem_WalkTree -Url $WebDavUrl -SkipCertificateCheck
            }
            else {
                MeasureWebDavItem_WalkTree -Url $WebDavUrl
            }
        }
        
    } # process

    end {
        $stats | Add-Member -NotePropertyName SizeMB -NotePropertyValue ([math]::Round($stats.TotalBytes / 1MB, 2))
        $stats | Add-Member -NotePropertyName SizeGB -NotePropertyValue ([math]::Round($stats.TotalBytes / 1GB, 2))
        $stats
    } # end
} # function Measure-WebDavItem {