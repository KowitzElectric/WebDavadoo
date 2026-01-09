BeforeAll {
  . "$PSScriptRoot/../testHelpers.ps1"
  $TestCredential = New-Object System.Management.Automation.PSCredential(
    'testuser',
    (ConvertTo-SecureString 'testpass' -AsPlainText -Force)
  ) # New-Object PSCredential
} # BeforeAll {

Describe "Get-WebDavChildItem" {
  It "calls Invoke-WebRequest with PROPFIND" { # real xml taken from invoke-webrequest, minimal, not empty directory.  has testfile.txt
    InModuleScope WebDavadoo {
      Mock Invoke-WebRequest -ModuleName WebDavadoo {
        return @{
          Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav2/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Wed, 07 Jan 2026 04:40:13 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>webdav2</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2026-01-07T04:40:05.875Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response><D:response><D:href>https://example.com/webdav2/testfile.txt</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>text/plain</D:getcontenttype><D:getlastmodified>Mon, 05 Jan 2026 07:20:43 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"985298cd137edc1:0"</D:getetag><D:displayname>testfile.txt</D:displayname><D:getcontentlanguage/><D:getcontentlength>3712</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2026-01-07T04:40:13.895Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response></D:multistatus>
"@
        } # return
      } # Mock Invoke-WebRequest

      Get-WebDavChildItem -WebDavUrl "https://example.com/webdav2" -SkipCertificateCheck -CloudCredential $TestCredential

      Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
        $CustomMethod -eq 'PROPFIND'
      } # Assert-MockCalled Invoke-WebRequest
    }
  } # It "calls Invoke-WebRequest with PROPFIND" {

  It "returns nothing for empty directories" { # Real empty directory xml from iis webdav server
    Mock Invoke-WebRequest -ModuleName WebDavadoo {
      return @{
        # Content below is real propfind response for an empty directory in iis webdav server
        Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Sun, 04 Jan 2026 05:30:25 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>webdav</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2026-01-04T05:30:25.905Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response></D:multistatus>
"@
      } # return
    } # Mock Invoke-WebRequest

    $result = Get-WebDavChildItem -WebDavUrl "https://example.com/webdav" -CloudCredential $TestCredential

    $result.Type | Should -Match 'Directory'
  } # It

  It "returns items for non-empty directories" {
    Mock Invoke-WebRequest -ModuleName WebDavadoo {
      return @{
        # content below is real propfind response for a non-empty directory in iis webdav server.  The directory has one file: file.txt and one subdirectory: subdir.
        Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Wed, 07 Jan 2026 04:50:34 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>webdav3</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2026-01-07T04:49:55.71Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response><D:response><D:href>https://example.com/webdav/file.txt</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>text/plain</D:getcontenttype><D:getlastmodified>Wed, 07 Jan 2026 04:50:23 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"ac05022917fdc1:0"</D:getetag><D:displayname>file.txt</D:displayname><D:getcontentlanguage/><D:getcontentlength>38880</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2026-01-07T04:50:03.571Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response><D:response><D:href>https://example.com/webdav/subdir/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Wed, 07 Jan 2026 04:50:32 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>subdir</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2026-01-07T04:50:32.478Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response></D:multistatus>
"@        
      } # return
    } # Mock Invoke-WebRequest

    $result = Get-WebDavChildItem -WebDavUrl "https://example.com/webdav" -SkipCertificateCheck -CloudCredential $TestCredential

    # Should return 2 items (excluding the parent directory itself)
    $result.Count | Should -Be 2
    $result | Where-Object { $_.Type -eq 'File' } | Should -HaveCount 1
    $result | Where-Object { $_.Type -eq 'Directory' } | Should -HaveCount 1

    ($result | Where-Object { $_.Type -eq 'File' }).Displayname | Should -Be 'file.txt'
    ($result | Where-Object { $_.Type -eq 'Directory' }).Displayname | Should -Be 'subdir'
  } # It "returns items for non-empty directories" {

  It 'accepts WebDavUrl from pipeline' {
    InModuleScope WebDavadoo {
      Mock Invoke-WebRequest -ModuleName WebDavadoo {
        @{
          Content = @"
<?xml version="1.0" encoding="utf-8"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>https://example.com/webdav2/</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype/><D:getlastmodified>Wed, 07 Jan 2026 04:40:13 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag/><D:displayname>webdav2</D:displayname><D:getcontentlanguage/><D:getcontentlength>0</D:getcontentlength><D:iscollection>1</D:iscollection><D:creationdate>2026-01-07T04:40:05.875Z</D:creationdate><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat></D:response><D:response><D:href>https://example.com/webdav2/testfile.txt</D:href><D:propstat><D:status>HTTP/1.1 200 OK</D:status><D:prop><D:getcontenttype>text/plain</D:getcontenttype><D:getlastmodified>Mon, 05 Jan 2026 07:20:43 GMT</D:getlastmodified><D:lockdiscovery/><D:ishidden>0</D:ishidden><D:supportedlock><D:lockentry><D:lockscope><D:exclusive/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry><D:lockentry><D:lockscope><D:shared/></D:lockscope><D:locktype><D:write/></D:locktype></D:lockentry></D:supportedlock><D:getetag>"985298cd137edc1:0"</D:getetag><D:displayname>testfile.txt</D:displayname><D:getcontentlanguage/><D:getcontentlength>3712</D:getcontentlength><D:iscollection>0</D:iscollection><D:creationdate>2026-01-07T04:40:13.895Z</D:creationdate><D:resourcetype/></D:prop></D:propstat></D:response></D:multistatus>
"@
        }
      } # Mock Invoke-WebRequest {
      $inputObject = [pscustomobject]@{
        WebDavUrl = 'https://example.com/webdav2/'
      }

      $result = $inputObject | Get-WebDavChildItem

      Assert-MockCalled Invoke-WebRequest -Times 1 -ParameterFilter {
        $Uri -eq 'https://example.com/webdav2/'
      }

      $result.Href          | Should -Be 'https://example.com/webdav2/testfile.txt'
      $result.Name          | Should -Be 'webdav2/testfile.txt'
      $result.DisplayName   | Should -Be 'testfile.txt'
      $result.Type          | Should -Be 'File'
      $result.LastWriteTime | Should -Be ([datetime]'1/5/2026 1:20:43 AM')
      $result.Length        | Should -Be 3712
      $result.ContentType   | Should -Be 'text/plain'
    } # InModuleScope WebDavadoo {
  } # It 'accepts WebDavUrl from pipeline' {
} # Describe
