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

# Si le join a echoue (code de sortie != 0), on s'arrete : pas de promotion = pas de reboot
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nLe join de la foret a echoue. Corrigez le probleme (renommage en attente, credentials, DNS) puis relancez main_workshop.ps1." -ForegroundColor Red
    exit 1
}

# Succes : Install-ADDSDomainController redemarre le serveur lui-meme (pas de Restart-Computer ici).
# Apres le redemarrage, lancez manuellement main_workshop_post.ps1 (comme pour le serveur admin).
Write-Host "`nPromotion lancee : le serveur va redemarrer automatiquement." -ForegroundColor Green
Write-Host "Apres le redemarrage, lancez : .\main_workshop_post.ps1" -ForegroundColor Cyan
