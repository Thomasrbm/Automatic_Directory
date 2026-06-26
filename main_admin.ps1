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

# Etape 1 : Installation AD DS
& "$ScriptDir\ADPackageInstallor.ps1"

# Etape 2 : Creation de la foret
& "$ScriptDir\CreateNewForestDomainController.ps1"

Write-Host "Le serveur va redemarrer. Relancez main_admin_post.ps1 apres le redemarrage." -ForegroundColor Magenta
