# SYSTEM SETTINGS

# Set up Chocolatey
Write-Host 'Setup Chocolatey parameters...'
choco feature enable -n allowGlobalConfirmation

# System configuration
Write-Host 'Show hidden files...'
Set-WindowsExplorerOptions -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives

Write-Host 'Disable Bing Search...'
Disable-BingSearch

Write-Host 'Disable UAC...'
Disable-UAC

Write-Host 'Disable Microsoft Update...'
Disable-MicrosoftUpdate

# Disable OpenSSH and clean info wallpaper in microsoft-edge VMs
if (Test-Path 'C:\BGinfo\build.cfg' -PathType Leaf) {
	Write-Host 'Disable OpenSSHd...'
	cmd.exe /c sc config OpenSSHd start= disabled
	cmd.exe /c sc stop OpenSSHd

	Write-Host 'Clean wallpaper info...'
	reg delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' /v 'bginfo' /f
}

# Kill Windows Defender
Write-Host 'Kill Windows Defender...'
try {
	Set-MpPreference -DisableRealtimeMonitoring $true
	choco install disabledefender-winconfig
} catch {
	Write-Host 'Cannot kill Windows Defender'
}

# Disable Action Center notifications
Write-Host 'Disable Action Center notifications...'
reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v HideSCAHealth /t REG_DWORD /d '0x1' /f

# PACKAGES

# Setup FlareVM repo
$flareFeed = 'https://www.myget.org/F/flare/api/v2'
choco sources add -n=flare -s $flareFeed --priority 1

$flareStart = Join-Path ${Env:ProgramData} 'Microsoft\Windows\Start Menu\Programs'
Install-ChocolateyEnvironmentVariable -VariableName 'FLARE_START' -VariableValue $flareStart -VariableType 'Machine'
refreshenv

# Setup local repo
$rootPath = 'C:\malvm'
$pkgsPath = Join-Path -Path $rootPath -ChildPath 'packages'
$malvmPath = Join-Path -Path $rootPath -ChildPath 'malvmRepo'

New-Item -Path $malvmPath -ItemType directory -Force

foreach($d in (Get-ChildItem $pkgsPath -Include '*.nuspec' -Force -Recurse)) {
	choco pack $d
}
Move-Item -Path '*.nupkg' -Destination $malvmPath

# Setup Boxstarter's nuget sources
Set-BoxstarterConfig -NugetSources "https://chocolatey.org/api/v2;$malvmPath;$flareFeed"

# Install chocolatey packages
choco install vcredist-all
choco install dotnet4.7.2

choco install python2
choco install python3
choco install notepadplusplus
choco install 7zip

choco install hxd
choco install die
choco install explorersuite
choco install sysinternals
choco install ilspy
choco install dex2jar

# Install local packages
choco install ghidra.malvm

# Install FlareVM packages
choco install peid.flare
choco install x64dbg.flare
choco install jd-gui.flare
