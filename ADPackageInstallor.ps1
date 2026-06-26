# ADPackageInstallor.ps1 - Installe AD DS et ses dependances
. "$PSScriptRoot\helpers.ps1"
Test-Admin
# ft windows  (commandlet (verbe + nom))   install une feature windows
# name = quelle fonction, ad - devient controlleur de domaine
# incluede ...  = pour avoir les outils de gestion (booleen), sinon peut rien manager
$ProgressPreference = 'SilentlyContinue'   # pas de barre de progression -> pas de "gel" (Ctrl+C)
$result = Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "AD DS installe (succes: $($result.Success), reboot requis: $($result.RestartNeeded))." -ForegroundColor Green
