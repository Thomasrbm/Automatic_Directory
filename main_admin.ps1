# =============================================================
# main_admin.ps1
# Description : Script principal pour le SERVEUR ADMINISTRATEUR
#               Lance tous les scripts dans le bon ordre
#               1. Installe AD DS
#               2. Cree la foret
#               3. Cree les dossiers partages
#               4. Cree le compte administrateur
# =============================================================

$ScriptDir = "$PSScriptRoot"

Write-Host "=== INSTALLATION SERVEUR ADMINISTRATEUR ===" -ForegroundColor Cyan

# Etape 1 : Installation AD DS
Write-Host "`n[1/4] Installation AD DS..." -ForegroundColor Yellow
& "$ScriptDir\ADPackageInstallor.ps1"

# Etape 2 : Creation de la foret
Write-Host "`n[2/4] Creation de la foret AD..." -ForegroundColor Yellow
& "$ScriptDir\CreateNewForestDomainController.ps1"

Write-Host "`nLe serveur va redemarrer. Relancez main_admin_post.ps1 apres le redemarrage." -ForegroundColor Magenta
