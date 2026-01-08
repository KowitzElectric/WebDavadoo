BeforeAll {
    . "$PSScriptRoot/../testHelpers.ps1"

    $TestCredential = New-Object System.Management.Automation.PSCredential(
        'testuser',
        (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
    )
} # BeforeAll {

Describe "Copy-WebDavItem" {

    It "Calls Invoke-WebRequest with COPY method" {

        InModuleScope WebDavadoo {
            $WebDavUrlOfFile = "https://example.com/webdav/file.txt"
            $DestinationWebDavUrlOfFile = "https://example.com/webdav/file-copy.txt"
            Mock Invoke-WebRequest {
                return @{
                    StatusCode        = 201
                    StatusDescription = "Created"
                } # return
            } # Mock Invoke-WebRequest

            $result = Copy-WebDavItem `
                -WebDavUrlOfFile $WebDavUrlOfFile `
                -DestinationWebDavUrlOfFile $DestinationWebDavUrlOfFile `
                -Overwrite T `
                -SkipCertificateCheck `
                -CloudCredential $TestCredential

            Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
                $CustomMethod -eq 'COPY' 
            } # Assert-MockCalled Invoke-WebRequest

            $result.Success     | Should -BeTrue
            $result.StatusCode  | Should -Be 201
            $result.Status      | Should -Be "Created"
            $result.Source      | Should -Be $WebDavUrlOfFile
            $result.Destination | Should -Be $DestinationWebDavUrlOfFile
        }
    }
}
