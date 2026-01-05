function MeasureWebDavItem_WalkTree {
    param(
        [string]$Url,
        [switch]$Recurse = $false,
        [switch]$SkipCertificateCheck = $false
    )

    if ($SkipCertificateCheck) {
        $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential -SkipCertificateCheck
    }
    else {
        $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential 
    }

    foreach ($item in $items) {

        # Skip the self-reference entry if present
        <# if ($item.HREF -eq (New-Object System.Uri($Url)).AbsolutePath) {
            continue
        } # if ($item.HREF -eq (New-Object System.Uri($Url)).AbsolutePath) #>
        $curr = [Uri]$Url
        $itemUri = [Uri]$item.HREF

        if ($itemUri.AbsoluteUri -eq $curr.AbsoluteUri) {
            continue
        }


        if ($item.Type -eq "Directory") {
            $stats.DirectoryCount++

            if ($Recurse) {
                #$dirUrl = ($Url.TrimEnd('/') + '/' + $item.Name.TrimEnd('/') + '/')
                $dirUrl = $item.HREF;
                if ($SkipCertificateCheck) {
                    MeasureWebDavItem_WalkTree -Url $dirUrl -Recurse -SkipCertificateCheck
                }
                else {
                    MeasureWebDavItem_WalkTree -Url $dirUrl -Recurse
                }
            } # if recurse
        } # if ($item.Type -eq "Directory")
        else {
            $stats.FileCount++
            $stats.TotalBytes += [int64]$item.Length
        } # else
    } # foreach ($item in $items)
} # function MeasureWebDavItem_WalkTree {