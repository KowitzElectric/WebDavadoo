<#
.SYNOPSIS
   Download files from a WebDAV server.
.DESCRIPTION
    This function downloads files and directories from a WebDAV server to a local path.
.PARAMETER WebDavUrl
    The WebDAV URL of the directory to download.
.PARAMETER LocalPath
    The local path to download the files to.
.PARAMETER Recursive
    If specified, download directories recursively.
.PARAMETER CloudCredential
    The credential used to authenticate with the WebDAV server.
.EXAMPLE
   Receive-WebDavItem -WebDavUrl "https://cloud.example.com/ownext/remote.php/dav/files/jgalt/Folder1" -LocalPath "C:\temp\download"
#>
function Receive-WebDavItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$WebDavUrl,

        [Parameter(Mandatory)]
        [string]$LocalPath,

        [Parameter(Mandatory = $false)]
        [bool]$Recursive = $false,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $CloudCredential = $script:WebDavCredential
    )

    begin {
        if (-not $CloudCredential) {
            throw "No WebDAV credential found. Run Set-WebDavCredential first."
        }

        . "$script:PSScriptRootPrivate\downloadWebDavItem.ps1"
        . "$script:PSScriptRootPrivate\walkWebDavTree.ps1"

        # Ensure local root exists
        if (-not (Test-Path $LocalPath)) {
            Write-Verbose "Creating local directory: $LocalPath"
            New-Item -ItemType Directory -Path $LocalPath | Out-Null
        }

        <#
        function DownloadWebDavItem {
            param(
                [string]$ItemUrl,
                [string]$TargetPath,
                [bool]$IsDirectory
            )

            if ($IsDirectory) {
                if (-not (Test-Path $TargetPath)) {
                    Write-Verbose "Creating directory: $TargetPath"
                    New-Item -ItemType Directory -Path $TargetPath | Out-Null
                }
            }
            else {
                Write-Verbose "Downloading $ItemUrl -> $TargetPath"

                try {
                    Invoke-WebRequest `
                        -Uri $ItemUrl `
                        -OutFile $TargetPath `
                        -Authentication Basic `
                        -Credential $CloudCredential `
                        -ErrorAction Stop
                }
                catch {
                    Write-Error "Failed to download file: $_"
                }
            }
        }

        function WalkWebDavTree {
            param(
                [string]$CurrentUrl,
                [string]$CurrentLocalPath
            )

            
            $items = Get-WebDavChildItem -WebDavUrl $CurrentUrl
            foreach ($item in $items) {

                # If an empty folder, then usually the first entry is the folder itself. Skip it.
                if ($item.href -eq (New-Object System.Uri($CurrentUrl)).AbsolutePath -and $item.Length -eq 0) {
                    Write-Verbose "Skipping empty directory entry: $($item.href)"
                    continue
                }

                $name = $item.Name.Split('/') | Select-Object -Last 1; # Name: Jobs/Resumes
                $localTarget = Join-Path $CurrentLocalPath $name
                $isDir = $item.Length -eq 0 -and $item.Type -eq 'Directory'                
                
                if ($isDir) {
                    Write-Verbose "Entering directory: $dirUrl"    
                    $dirUrl = ($CurrentUrl.TrimEnd('/') + '/' + $name + '/')
                    DownloadWebDavItem -ItemUrl $dirUrl -TargetPath $localTarget -IsDirectory $true -Verbose
                    if ($Recursive) {
                        Write-Verbose "Recursing into directory: $dirUrl"
                        WalkWebDavTree -CurrentUrl $dirUrl -CurrentLocalPath $localTarget
                    } # if ($Recursive) {
                }
                else {
                    Write-Verbose "Downloading file: $CurrentUrl"
                    Write-Verbose "To local path: $localTarget"
                    Write-Verbose "IsDirectory: $false"
                    DownloadWebDavItem -ItemUrl $CurrentUrl -TargetPath $localTarget -IsDirectory $false -Verbose
                } # else {
            } # foreach ($item in $items) {
        } # function WalkWebDavTree {
        #>
    } # begin {

    process {
        WalkWebDavTree -CurrentUrl $WebDavUrl -CurrentLocalPath $LocalPath -Recursive:$Recursive -CloudCredential $CloudCredential
    }

    end {
        Write-Verbose "Receive-WebDavItem completed"
    }
} # function Receive-WebDavItem {