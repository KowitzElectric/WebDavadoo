BeforeAll {
    . "$PSScriptRoot/../testHelpers.ps1"
    $TestCredential = New-Object System.Management.Automation.PSCredential(
        'testuser',
        (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
    ) # New-Object PSCredential
} # BeforeAll {

Describe "Get-WebDavChildItem" {
    InModuleScope WebDavadoo {
        It "calls Invoke-WebRequest with PROPFIND" {
            Mock Invoke-WebRequest -ModuleName WebDavadoo {
                return @{
                    Content = @"
<multistatus xmlns="DAV:">
  <response>
    <href>/webdav/test/</href>
    <propstat>
      <prop>
        <getlastmodified>Mon, 01 Jan 2024 12:00:00 GMT</getlastmodified>
        <getcontentlength>0</getcontentlength>
        <resourcetype>
          <collection />
        </resourcetype>
        <getcontenttype>httpd/unix-directory</getcontenttype>
      </prop>
    </propstat>
  </response>
</multistatus>
"@
                } # return
            } # Mock Invoke-WebRequest

            Get-WebDavChildItem -WebDavUrl "https://example.com/webdav" -SkipCertificateCheck -CloudCredential $TestCredential

            Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
                $CustomMethod -eq 'PROPFIND'
            } # Assert-MockCalled Invoke-WebRequest
        }

        It "returns nothing for empty directories" {
            Mock Invoke-WebRequest -ModuleName WebDavadoo {
                return @{
                    Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Sun, 04 Jan 2026 05:30:25 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>webdav</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2026-01-04T05:30:25.905Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response></D:multistatus>
"@
                } # return
            } # Mock Invoke-WebRequest

            $result = Get-WebDavChildItem -WebDavUrl "https://example.com/webdav" -CloudCredential $TestCredential

            $result.Type | Should -Match 'Directory'
        } # It
    } # InModuleScope WebDavadoo
} # Describe
