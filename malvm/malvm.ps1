# Check for Administrator role
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host 'Please run as Administrator'
	Read-Host  'Press ANY key to continue...'
	exit
}

Write-Host 'Installing Boxstarter...'

# Invoke-Expression on boxstarter's installation script
iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'))

# Launch boostrapper installation script
Get-Boxstarter -Force

# Bootstrap system
Write-Host 'Bootstrap system...'
$rootPath = 'C:\malvm'
$pkgPath = Join-Path -Path $rootPath -ChildPath 'pkg.ps1'
Install-BoxstarterPackage -PackageName $pkgPath
