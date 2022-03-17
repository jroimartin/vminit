# Setup local repo
$rootPath = Join-Path ${Env:SystemDrive} 'malvm'
$pkgsPath = Join-Path $rootPath 'packages'
$malvmPath = Join-Path $rootPath 'malvmRepo'

New-Item -Path $malvmPath -ItemType directory -Force

foreach($d in (Get-ChildItem $pkgsPath -Include '*.nuspec' -Force -Recurse)) {
	choco pack $d
}
Move-Item -Path '*.nupkg' -Destination $malvmPath

choco sources add -n=malvm -s $malvmPath --priority 1

# Setup FlareVM repo
$fireeyeVmCommonDir = Join-Path ${Env:ProgramData} 'FEVM'
$fireeyeToolListDir = Join-Path ${Env:ProgramData} 'Microsoft\Windows\Start Menu\Programs\FLARE'
$fireeyeToolListShortcut = Join-Path ${Env:UserProfile} 'Desktop\FLARE.lnk'
$fireeyeRawToolsDir = Join-Path ${Env:SystemDrive} 'Tools'
Install-ChocolateyEnvironmentVariable -VariableName 'VM_COMMON_DIR' -VariableValue $fireeyeVmCommonDir -VariableType 'Machine'
Install-ChocolateyEnvironmentVariable -VariableName 'TOOL_LIST_DIR' -VariableValue $fireeyeToolListDir -VariableType 'Machine'
Install-ChocolateyEnvironmentVariable -VariableName 'TOOL_LIST_SHORTCUT' -VariableValue $fireeyeToolListShortcut -VariableType 'Machine'
Install-ChocolateyEnvironmentVariable -VariableName 'RAW_TOOLS_DIR' -VariableValue $fireeyeRawToolsDir -VariableType 'Machine'
refreshenv

$fireeyeFeed = 'https://www.myget.org/F/fireeye/api/v2'
choco sources add -n=fireeye -s $fireeyeFeed --priority 2

# Setup Boxstarter's nuget sources
Set-BoxstarterConfig -NugetSources "$malvmPath;$fireeyeFeed;https://chocolatey.org/api/v2"

# Install chocolatey packages
choco install vcredist-all
choco install dotnet4.7.2

choco install python2
choco install python3
choco install notepadplusplus
choco install 7zip
choco install googlechrome

choco install hxd
choco install die
choco install explorersuite
choco install --ignore-checksum sysinternals
choco install ilspy
choco install dex2jar

# Install local packages
choco install ghidra.vminit

# Install FlareVM packages
choco install peid.flare
choco install x64dbg.flare
choco install jd-gui.flare
