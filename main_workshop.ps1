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

# Etape 1 : Desactivation du pare-feu (evite les blocages reseau : SMB, ping, replication)
Write-Host "[1/4] Desactivation du pare-feu..." -ForegroundColor Cyan
& "$ScriptDir\DisableFirewall.ps1"

# Etape 2 : DNS vers SRV-ADMIN (serveur DNS du domaine) pour resoudre et rejoindre la foret
Write-Host "[2/4] DNS vers SRV-ADMIN..." -ForegroundColor Cyan
$SrvAdminIP = Get-Input "IP du SRV-ADMIN (serveur DNS du domaine)" "IP SRV-ADMIN" "10.0.0.4"
Set-Dns $SrvAdminIP

# Etape 3 : Installation AD DS
Write-Host "[3/4] Installation AD DS..." -ForegroundColor Cyan
& "$ScriptDir\ADPackageInstallor.ps1"

# Etape 4 : Rejoindre la foret existante (la promotion redemarre le serveur elle-meme)
Write-Host "[4/4] Connexion a la foret (la promotion redemarre le serveur)..." -ForegroundColor Cyan
& "$ScriptDir\JoinExistingDomainController.ps1"
