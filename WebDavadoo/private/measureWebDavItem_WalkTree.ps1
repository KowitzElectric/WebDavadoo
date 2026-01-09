function MeasureWebDavItem_WalkTree {
    param(
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]
        $Url,
        
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [switch]
        $Recurse = $false,
        
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]
        $SkipCertificateCheck = $false
    )
    begin {
        if ($SkipCertificateCheck) {
            $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential -SkipCertificateCheck
        }
        else {
            $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential 
        }
    } # begin{
    process {
        foreach ($item in $items) {
            $curr = [Uri]$Url
            $itemUri = [Uri]$item.HREF

            if ($itemUri.AbsoluteUri -eq $curr.AbsoluteUri) {
                continue
            } # if ($itemUri.AbsoluteUri -eq $curr.AbsoluteUri) {
            if ($item.Type -eq "Directory") {
                $stats.DirectoryCount++

                if ($Recurse) {
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
    } # process {
    end {}
} # function MeasureWebDavItem_WalkTree {