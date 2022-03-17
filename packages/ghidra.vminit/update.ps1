import-module au

$repo = 'NationalSecurityAgency/ghidra'
$releases = "https://api.github.com/repos/$repo/releases"

function global:au_SearchReplace {
    @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(-Url64bit\s*).+"       = "`$1'$($Latest.URL64)' ``"
            "(?i)(-Checksum64\s*).+"     = "`$1'$($Latest.Checksum64)' ``"
            "(?i)(-ChecksumType64\s*).+" = "`$1'$($Latest.ChecksumType64)' ``"
        }
    }
}

function global:au_BeforeUpdate() {
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.Url64
    $Latest.ChecksumType64 = 'sha256'
}

function global:au_GetLatest {
    $release = (Invoke-WebRequest -Uri "$releases/latest").Content | ConvertFrom-Json
    $url = $release.assets | Where-Object { $_.name -match 'ghidra.*.zip' } | Select-Object -First 1 -ExpandProperty browser_download_url
    @{
        URL64   = $url
        Version = $release.tag_name.Split('_')[1]
        ReleaseNotes = $release.html_url
    }
}

Update-Package -ChecksumFor None
