# Check for Administrator role
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host 'Please run as Administrator'
	Read-Host  'Press ANY key to continue...'
	exit
}

# Install Boxstarter
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))
Get-Boxstarter -Force

# System configuration
Set-WindowsExplorerOptions -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives
Disable-BingSearch

# Fix Chocolatey's bug: "The specified path, file name, or both are too long"
choco config set cacheLocation ${Env:TEMP}

# Install packages
$rootPath = Join-Path ${Env:SystemDrive} 'malvm'
$pkgPath = Join-Path $rootPath 'pkg.ps1'
Install-BoxstarterPackage -PackageName $pkgPath -DisableReboots
