# ADPackageInstallor.ps1 - Installe AD DS et ses dependances
. "$PSScriptRoot\helpers.ps1"


Test-Admin
# ft windows  (commandlet (verbe + nom))   install une feature windows
# name = quelle fonction, ad - devient controlleur de domaine
# incluede ...  = pour avoir les outils de gestion (booleen), sinon peut rien manager
Write-Host "Installation d'AD DS en cours... (1 a 3 min sur une VM B-series, ne ferme pas la fenetre)" -ForegroundColor Yellow
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "Installation AD DS terminee." -ForegroundColor Green

# --- VERIFICATION : la fonctionnalite AD DS est-elle bien installee ? ---
Write-Host "`n[VERIFICATION] Etat de la fonctionnalite AD DS :" -ForegroundColor Cyan
Get-WindowsFeature AD-Domain-Services | Select-Object Name, InstallState | Format-Table -AutoSize
