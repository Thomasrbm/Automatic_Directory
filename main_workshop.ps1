# =============================================================
# main_workshop.ps1
# Description : Script principal pour le SERVEUR WORKSHOP
#               Lance tous les scripts dans le bon ordre
#               1. Installe AD DS
#               2. Rejoint la foret existante
#               3. Cree le dossier partage workshop
#               4. Cree le compte worker
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$ScriptDir = "$PSScriptRoot"

Write-Host "=== INSTALLATION SERVEUR WORKSHOP ===" -ForegroundColor Cyan

# Etape 1 : Installation AD DS
Write-Host "`n[1/2] Installation AD DS..." -ForegroundColor Yellow
& "$ScriptDir\ADPackageInstallor.ps1"

# Etape 2 : Rejoindre la foret existante
Write-Host "`n[2/2] Connexion a la foret existante..." -ForegroundColor Yellow
& "$ScriptDir\JoinExistingDomainController.ps1"

Write-Host "`nLe serveur va redemarrer. Relancez main_workshop_post.ps1 apres le redemarrage." -ForegroundColor Magenta
