BeforeAll {
    . "$PSScriptRoot/../testHelpers.ps1"
    $TestCredential = New-Object System.Management.Automation.PSCredential(
        'testuser',
        (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
    )
    
} # BeforeAll {

Describe 'Get-WebDavItemProperty' {

    It 'calls Invoke-WebRequest with PROPFIND and Depth 0' {
        InModuleScope WebDavadoo {
            $TestUrl = 'https://example.com/webdav/file.txt'
            Mock Invoke-WebRequest -ModuleName WebDavadoo {
                @{
                    Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav/file.txt</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>text/plain</D:getcontenttype><D:getlastmodified>Mon, 05 Jan 2026 07:20:43 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"985298cd137edc1:0"</D:getetag><D:displayname>file.txt</D:displayname><D:getcontentlanguage/><D:getcontentlength>3712</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2026-01-04T05:36:15.845Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response></D:multistatus>
"@
                }
            }

            $result = Get-WebDavItemProperty `
                -WebDavUrl $TestUrl `
                -CloudCredential $TestCredential

            Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
                $CustomMethod -eq 'PROPFIND' -and
                $Headers.Depth -eq '0' -and
                $Uri -eq $TestUrl
            }

            $result | Should -Not -BeNullOrEmpty
        }
    } # it 'calls Invoke-WebRequest with PROPFIND and Depth 0' {

    It 'returns parsed metadata for a file' {
        InModuleScope WebDavadoo {

            Mock Invoke-WebRequest {
                @{
                    Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav/file.txt</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>text/plain</D:getcontenttype><D:getlastmodified>Mon, 05 Jan 2026 07:20:43 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"985298cd137edc1:0"</D:getetag><D:displayname>file.txt</D:displayname><D:getcontentlanguage/><D:getcontentlength>3712</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2026-01-04T05:36:15.845Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response></D:multistatus>
"@
                }
            }

            $result = Get-WebDavItemProperty `
                -WebDavUrl $TestUrl `
                -CloudCredential $TestCredential

            $result.Href            | Should -Be 'https://example.com/webdav/file.txt'
            $result.ETag            | Should -Be '"985298cd137edc1:0"'
            $result.LastModified    | Should -Be ([datetime]'1/5/2026 1:20:43 AM')
            $result.ContentType     | Should -Be 'text/plain'
            $result.ContentLengthMB | Should -Be 0
        }
    } # it 'returns parsed metadata for a file' {

    It 'returns ContentType directory when getcontenttype is missing' {
        InModuleScope WebDavadoo {

            Mock Invoke-WebRequest {
                @{
                    Content = @"
<?xml version="1.0"?>
<multistatus>
  <response>
    <href>/webdav/folder/</href>
    <propstat>
      <prop>
        <getetag>"dir-etag"</getetag>
        <getlastmodified>Wed, 03 Jan 2024 10:00:00 GMT</getlastmodified>
      </prop>
    </propstat>
  </response>
</multistatus>
"@
                }
            }

            $result = Get-WebDavItemProperty `
                -WebDavUrl 'https://example.com/webdav/folder/' `
                -CloudCredential $TestCredential

            $result.ContentType     | Should -Be 'directory'
            $result.ContentLengthMB | Should -Be $null
        }
    } # it 'returns ContentType directory when getcontenttype is missing' {

    It 'accepts WebDavUrl from pipeline' {
        InModuleScope WebDavadoo {

            Mock Invoke-WebRequest {
                @{
                    Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav/file.txt</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>text/plain</D:getcontenttype><D:getlastmodified>Mon, 05 Jan 2026 07:20:43 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"985298cd137edc1:0"</D:getetag><D:displayname>file.txt</D:displayname><D:getcontentlanguage/><D:getcontentlength>3712</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2026-01-04T05:36:15.845Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response></D:multistatus>
"@
                }
            } # Mock Invoke-WebRequest {
            $inputObject = [pscustomobject]@{
                WebDavUrl = 'https://example.com/webdav/file.txt'
            }

            $result = $inputObject | Get-WebDavItemProperty

            Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
                $Uri -eq 'https://example.com/webdav/file.txt'
            }
            
            $result.Href            | Should -Be 'https://example.com/webdav/file.txt'
            $result.ETag            | Should -Be '"985298cd137edc1:0"'
            $result.LastModified    | Should -Be ([datetime]'1/5/2026 1:20:43 AM')
            $result.ContentType     | Should -Be 'text/plain'
            $result.ContentLengthMB | Should -Be 0
        } # InModuleScope WebDavadoo {
    } # It 'accepts WebDavUrl from pipeline' {
} # Describe 'Get-WebDavItemProperty' {
