function receiveWebDavItem_TestUri {
    [CmdletBinding()]
    param (
        $uriString
    )
    
    begin {
        $uri = [uri]$uriString        
    }
    
    process {
        if ($uri.IsAbsoluteUri) {
            Write-Verbose "URI is absolute: $uriString"
            $isAbsoluteUri = $true
            $scheme = $uri.Scheme
            $authority = $uri.Authority
            $pathAndQuery = $uri.PathAndQuery

            [pscustomobject]@{
                Scheme        = $scheme
                Authority     = $authority
                PathAndQuery  = $pathAndQuery
                IsAbsoluteUri = $isAbsoluteUri
            }   
        }
        else {
            Write-Verbose "URI is not absolute: $uriString"
            $isAbsoluteUri = $false

            [pscustomobject]@{
                IsAbsoluteUri = $isAbsoluteUri
            }   
        }
    }
    end {
       
    }
}