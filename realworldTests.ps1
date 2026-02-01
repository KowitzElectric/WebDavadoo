#region Setup WebDav Environments
#region Nextcloud Environment Setup

$nextCloudWebDavEnvironment = @{
    ServerUrl            = 'https://files.thekozanos.com/remote.php/dav/files/Lee'
    Password             = 'JHTC2-yEq56-MGxCD-ggfDG-6YEdX'
    Username             = 'Lee'
    TestFolder           = 'WebDavadoo'
    TestFile             = 'WebDavadooTest.txt'
    WebDavUrlOfDirectory = $NcServerUrl + '/' + $nctestfolder
    WebDavUrlOfFile      = $NcServerUrl + '/' + $nctestfolder + '/' + $ncTestFile
}
$NcUsername = $nextCloudWebDavEnvironment["Username"]
$NcPassword = $nextCloudWebDavEnvironment["Password"]
$NcServerUrl = $nextCloudWebDavEnvironment["ServerUrl"]
$ncPass = ConvertTo-SecureString -AsPlainText $NcPassword -Force
$ncCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $NcUsername, $ncPass
$nctestfolder = $nextCloudWebDavEnvironment["TestFolder"]
$ncTestFile = $nextCloudWebDavEnvironment["TestFile"]
$ncWebDavurlOfFile = $nextCloudWebDavEnvironment["WebDavUrlOfFile"]
$ncwebdavurloffolder = $nextCloudWebDavEnvironment["WebDavUrlOfDirectory"]
#endregion Nextcloud Environment Setup
#region IIS WebDav Environment Setup
$iisWebDavEnvironment = @{
    ServerUrl = 'https://192.168.122.160/'
    Password  = '909RosaParks!'
    Username  = 'administrator'
}

$iisUsername = $iisWebDavEnvironment["Username"]
$iisPassword = $iisWebDavEnvironment["Password"]
$iisServerUrl = $iisWebDavEnvironment["ServerUrl"]
$iisPass = ConvertTo-SecureString -AsPlainText $iisPassword -Force
$iisCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $iisUsername, $iisPass
#endregion IIS WebDav Environment Setup
#endregion Setup WebDav Environments

#region Nextcloud Tests
Import-Module /home/lee/Git/KowitzElectric/WebDavadoo/WebDavadoo/WebDavadoo.psm1 -Force
Set-WebDavCredential -Credential $ncCredential
<# 
#region Test Get-WebDavItem
$ncGetChildItemResult = Get-WebDavChildItem -WebDavUrl $ncWebDavurlOfFile -CloudCredential $ncCredential 
if ($ncGetChildItemResult.Length -gt 0) {
    Write-Host "Get-WebDavChildItem succeeded."
}
else {
    Write-Host "Get-WebDavChildItem failed."
}
#endregion Test Get-WebDavItem

#region Test Get-WebDavItemProperty
$ncGetWebDavItemPropertyResult = Get-WebDavItemProperty -WebDavUrl $ncWebDavurlOfFile -CloudCredential $ncCredential 
if ($ncGetWebDavItemPropertyResult.Href.Length -gt 0) {
    Write-Host "Get-WebDavItemProperty succeeded."
}
else {
    Write-Host "Get-WebDavItemProperty failed."
}
#endregion Test Get-WebDavItem

#region Test Get-WebDavQuota
$ncQuotaResult = Get-WebDavQuota -WebDavUrl $NcServerUrl -CloudCredential $ncCredential
if ($ncQuotaResult.UsedMB -ge 0 -and $ncQuotaResult.AvailableMB -gt 0) {
    Write-Host "Get-WebDavQuota succeeded."
}
else {
    Write-Host "Get-WebDavQuota failed."
}
#endregion Test Get-WebDavQuota

#region Test Measure-WebDavItem
$ncServerFolderUrl = $NcServerUrl + '/' + $nctestfolder
$ncMeasureResult = Measure-WebDavItem -WebDavUrl $ncServerFolderUrl -CloudCredential $ncCredential -Recurse
if ($ncMeasureResult.TotalBytes -ge 0 -and $ncMeasureResult.FileCount -ge 0) {
    Write-Host "Measure-WebDavItem succeeded."
}
else {
    Write-Host "Measure-WebDavItem failed."
}
#endregion Test Measure-WebDavItem

#region Test Copy-WebDavItem

$DestinationWebDavUrlOfFile = $ncWebDavurlOfFile + '_copy'
$ncCopyResult = Copy-WebDavItem -WebDavUrlOfFile $ncWebDavurlOfFile -DestinationWebDavUrlOfFile $DestinationWebDavUrlOfFile -Overwrite 'T' -CloudCredential $ncCredential
if ($ncCopyResult.success -eq 'True') {
    Write-Host "Copy-WebDavItem succeeded: $DestinationWebDavUrlOfFile"
}
else {
    Write-Host "Copy-WebDavItem failed."
}

#endregion Test Copy-WebDavItem

#region Test Remove-WebDavItem

$ncRemoveResult = Remove-WebDavItem -WebDavUrlOfFile $DestinationWebDavUrlOfFile -CloudCredential $ncCredential -ShowResult
if ($ncRemoveResult -match 'Removed item') {
    Write-Host "Remove-WebDavItem succeeded: $DestinationWebDavUrlOfFile"
}
else {
    Write-Host "Remove-WebDavItem failed: $DestinationWebDavUrlOfFile"
}

#endregion Test Remove-WebDavItem

#region Test Move-WebDavItem
$DestinationWebDavUrlOfFile = $ncWebDavurlOfFile + '_moved'
$moveResult = Move-WebDavItem -WebDavUrlOfFile $ncWebDavurlOfFile -DestinationWebDavUrlOfFile $DestinationWebDavUrlOfFile -Overwrite 'T' -CloudCredential $ncCredential -ShowResult
if ($moveResult -match 'Moved item') {
    Write-Host "Move-WebDavItem succeeded: $ncWebDavurlOfFile to $DestinationWebDavUrlOfFile"
}
else {
    Write-Host "Move-WebDavItem failed: $ncWebDavurlOfFile to $DestinationWebDavUrlOfFile"
}
# Move it back to original location
$moveBackResult = Move-WebDavItem -WebDavUrlOfFile $DestinationWebDavUrlOfFile -DestinationWebDavUrlOfFile $ncWebDavurlOfFile -Overwrite 'T' -CloudCredential $ncCredential -ShowResult
if ($moveBackResult -match 'Moved item') {
    Write-Host "Move-WebDavItem back succeeded: $DestinationWebDavUrlOfFile to $ncWebDavurlOfFile"
}
else {
    Write-Host "Move-WebDavItem back failed: $DestinationWebDavUrlOfFile to $ncWebDavurlOfFile"
}


#endregion Test Move-WebDavItem

#region Test New-WebDavDirectory
$newDirectoryName = "TestNewFolder"
$ncNewDirectoryResult = New-WebDavDirectory -webDavUrl $ncwebdavurloffolder -newDirectoryName $newDirectoryName -CloudCredential $ncCredential -ShowResult
if ($ncNewDirectoryResult -match 'Created directory') {
    Write-Host "New-WebDavDirectory succeeded: $newDirectoryName"
    # Clean up by removing the created directory
    $ncRemoveNewDirResult = Remove-WebDavItem -WebDavUrlOfFile ($ncwebdavurloffolder + '/' + $newDirectoryName) -CloudCredential $ncCredential -ShowResult
    if ($ncRemoveNewDirResult -match 'Removed item') {
        Write-Host "Cleanup of New-WebDavDirectory succeeded: $newDirectoryName"
    }
    else {
        Write-Host "Cleanup of New-WebDavDirectory failed: $newDirectoryName"
    }
}
#endregion Test New-WebDavDirectory
#>

#region Test Receive-WebDavFile


#endregion Test Receive-WebDavFile
#endregion Nextcloud Tests