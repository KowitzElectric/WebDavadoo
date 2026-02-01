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
        # Get the Base Server URL (e.g., https://files.thekozanos.com)
        $uriObj = [Uri]$Url
        $baseUrl = "{0}://{1}" -f $uriObj.Scheme, $uriObj.Host

        if ($SkipCertificateCheck) {
            $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential -SkipCertificateCheck
        }
        else {
            $items = Get-WebDavChildItem -WebDavUrl $Url -CloudCredential $CloudCredential 
        }
    } # begin{
    process {
        foreach ($item in $items) {
            # Fix: If the HREF is relative (starts with /), prepend the base URL
            $fullItemUrl = $item.HREF
            Write-Verbose "Processing item HREF: $fullItemUrl"

            if ($fullItemUrl.StartsWith("/")) {
                $fullItemUrl = $baseUrl + $fullItemUrl
                Write-Verbose "Converted to full URL: $fullItemUrl"
            }

            $itemUri = [Uri]$fullItemUrl

            # Compare to avoid infinite loops if the server returns '.' or the parent
            if ($itemUri.AbsoluteUri.TrimEnd('/') -eq ([Uri]$Url).AbsoluteUri.TrimEnd('/')) {
                continue
            } # if ($itemUri.AbsoluteUri.TrimEnd('/') -eq ([Uri]$Url).AbsoluteUri.TrimEnd('/')) 
            
            if ($item.Type -eq "Directory") {
                $stats.DirectoryCount++

                if ($Recurse) {
                    
                    Write-Verbose "Recursing into directory: $fullItemUrl"
                    if ($SkipCertificateCheck) {
                        MeasureWebDavItem_WalkTree -Url $fullItemUrl -Recurse -SkipCertificateCheck
                    }
                    else {
                        MeasureWebDavItem_WalkTree -Url $fullItemUrl -Recurse
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