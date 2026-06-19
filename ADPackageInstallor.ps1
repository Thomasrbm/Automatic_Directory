# ADPackageInstallor.ps1 - Installe AD DS et ses dependances
. "$PSScriptRoot\helpers.ps1"
Test-Admin
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "AD DS installe avec succes." -ForegroundColor Green
