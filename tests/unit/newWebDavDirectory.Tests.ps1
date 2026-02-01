Describe 'New-WebDavDirectory' {
    
    BeforeAll {
        . "$PSScriptRoot/../testHelpers.ps1"

        $TestCredential = New-Object System.Management.Automation.PSCredential(
            'testuser',
            (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
        )

        $WebDavUrl = 'https://webdavadooexample.com/webdav'
    }
    Context ' When creating a new WebDav directory' {
        
        It 'calls Invoke-WebRequest with MKCOL and the correct URI' {
            # Arrange
            Mock Invoke-WebRequest {} -ModuleName WebDavadoo   
            $newDirectoryName = 'NewFolder'        

            # Act
            New-WebDavDirectory `
                -webDavUrl $WebDavUrl `
                -newDirectoryName $newDirectoryName `
                -cloudCredential $TestCredential

            # Assert
            Assert-MockCalled Invoke-WebRequest -ModuleName WebDavadoo -Times 1 -ParameterFilter {
                $Uri -eq 'https://webdavadooexample.com/webdav/NewFolder' -and
                $CustomMethod -eq 'MKCOL'
            } # Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
        } # It 'calls Invoke-WebRequest with MKCOL and the correct URI' {
        
    } # Context ' When creating a new WebDav directory' {

    Context 'URL Handling and Sanitization' {
        $Cases = @(
            @{ URL = 'https://example.com/dav'; Name = 'NewFolder'; Expected = 'https://example.com/dav/NewFolder' }
            @{ URL = 'https://example.com/dav/'; Name = 'NewFolder'; Expected = 'https://example.com/dav/NewFolder' }
        )

        It "handles slashes correctly for: <URL>" -TestCases $Cases {
            param ($URL, $Name, $Expected)
            
            Mock Invoke-WebRequest {} -ModuleName WebDavadoo
            
            New-WebDavDirectory -webDavUrl $URL -newDirectoryName $Name -cloudCredential $TestCredential

            Assert-MockCalled Invoke-WebRequest -ModuleName WebDavadoo -ParameterFilter {
                $Uri -eq $Expected
            }
        } # It "handles slashes correctly for: <URL>" -TestCases $Cases {
    } # Context 'URL Handling and Sanitization' {
}
