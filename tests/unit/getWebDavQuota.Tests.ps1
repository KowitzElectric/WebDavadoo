BeforeAll {
    #Import-Module WebDavadoo -Force

    . "$PSScriptRoot/../testHelpers.ps1"

    $TestCredential = New-Object System.Management.Automation.PSCredential(
        'testuser',
        (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
    )

    $WebDavUrl = 'https://example.com/webdav/'
}

Describe "Get-WebDavQuota" {

    BeforeEach {
        Mock Invoke-WebRequest {
            @{
                # content taken from a sample WebDAV quota response in nextcloud
                Content = @'
<?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns"><d:response><d:href>/remote.php/dav/files/userName/</d:href><d:propstat><d:prop><d:quota-used-bytes>104857600</d:quota-used-bytes><d:quota-available-bytes>524288000</d:quota-available-bytes></d:prop><d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response></d:multistatus>
'@
            }
        } -ModuleName WebDavadoo
    }

    It "returns used and available quota in MB" {

        InModuleScope WebDavadoo {

            $result = Get-WebDavQuota `
                -WebDavUrl $WebDavUrl `
                -CloudCredential $TestCredential `
                -SkipCertificateCheck

            Assert-MockCalled Invoke-WebRequest -Times 1 -ModuleName WebDavadoo

            $result.UsedMB      | Should -Be 100
            $result.AvailableMB | Should -Be 500
        }
    }
}
