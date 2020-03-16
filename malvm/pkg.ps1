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

# Disable Windows Defender
Write-Host 'Disable Windows Defender...'
try {
	Get-Service WinDefend | Stop-Service -Force
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\WinDefend' -Name 'Start' -Value 4 -Type DWORD -Force
} catch {
	Write-Warning 'Failed to disable WinDefend service'
}
try {
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft' -Name 'Windows Defender' -Force -ea 0 | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -Value 1 -PropertyType DWORD -Force -ea 0 | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableRoutinelyTakingAction' -Value 1 -PropertyType DWORD -Force -ea 0 | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' -Name 'SpyNetReporting' -Value 0 -PropertyType DWORD -Force -ea 0 | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' -Name 'SubmitSamplesConsent' -Value 0 -PropertyType DWORD -Force -ea 0 | Out-Null
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\MRT' -Name 'DontReportInfectionInformation' -Value 1 -PropertyType DWORD -Force -ea 0 | Out-Null
	if (-Not ((Get-WmiObject -class Win32_OperatingSystem).Version -eq '6.1.7601')) {
		Set-MpPreference -DisableIntrusionPreventionSystem $true -DisableIOAVProtection $true -DisableRealtimeMonitoring $true -DisableScriptScanning $true -EnableControlledFolderAccess Disabled -EnableNetworkProtection AuditMode -Force -MAPSReporting Disabled -SubmitSamplesConsent NeverSend
	}
} catch {
	Write-Warning 'Failed to disable Windows Defender'
}


# Disable Action Center notifications
Write-Host 'Disable Action Center notifications...'
reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v HideSCAHealth /t REG_DWORD /d '0x1' /f

# PACKAGES

# Setup FlareVM repo
$fireeyeFeed = 'https://www.myget.org/F/fireeye/api/v2'
choco sources add -n=fireeye -s $fireeyeFeed --priority 1

$fireeyeToolListDir = Join-Path ${Env:ProgramData} 'Microsoft\Windows\Start Menu\Programs\FLARE'
Install-ChocolateyEnvironmentVariable -VariableName 'TOOL_LIST_DIR' -VariableValue $fireeyeToolListDir -VariableType 'Machine'
refreshenv

# Setup local repo
$rootPath = Join-Path ${Env:SystemDrive} 'malvm'
$pkgsPath = Join-Path $rootPath 'packages'
$malvmPath = Join-Path $rootPath 'malvmRepo'

New-Item -Path $malvmPath -ItemType directory -Force

foreach($d in (Get-ChildItem $pkgsPath -Include '*.nuspec' -Force -Recurse)) {
	choco pack $d
}
Move-Item -Path '*.nupkg' -Destination $malvmPath

# Setup Boxstarter's nuget sources
Set-BoxstarterConfig -NugetSources "https://chocolatey.org/api/v2;$malvmPath;$fireeyeFeed"

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
