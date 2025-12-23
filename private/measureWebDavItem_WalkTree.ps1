function MeasureWebDavItem_WalkTree {
    param(
        [string]$Url,
        [switch]$Recurse = $false
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
                MeasureWebDavItem_WalkTree -Url $dirUrl
            } # if recurse
        } # if ($item.Type -eq "Directory")
        else {
            $stats.FileCount++
            $stats.TotalBytes += [int64]$item.Length
        } # else
    } # foreach ($item in $items)
} # function MeasureWebDavItem_WalkTree {