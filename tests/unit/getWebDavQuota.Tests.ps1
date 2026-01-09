BeforeAll {
    Import-Module "$PSScriptRoot/../WebDavadoo.psm1" -Force

    $TestCredential = New-Object System.Management.Automation.PSCredential(
        'testuser',
        (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
    )

    $WebDavUrl = 'https://example.com/webdav/'
}

Describe "Get-WebDavQuota" {

    It "returns used and available quota in MB" {

        InModuleScope WebDavadoo {

            Mock Invoke-WebRequest {
                @{
                    Content = @'
<?xml version="1.0" encoding="utf-8"?>
<multistatus>
  <response>
    <propstat>
      <prop>
        <quota-used-bytes>104857600</quota-used-bytes>
        <quota-available-bytes>524288000</quota-available-bytes>
      </prop>
    </propstat>
  </response>
</multistatus>
'@
                }
            }

            $result = Get-WebDavQuota `
                -WebDavUrl $WebDavUrl `
                -CloudCredential $TestCredential `
                -SkipCertificateCheck

            Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
                $CustomMethod -eq 'PROPFIND' -and
                $Uri -eq $WebDavUrl
            }

            $result.UsedMB      | Should -Be 100
            $result.AvailableMB | Should -Be 500
        }
    }
}
