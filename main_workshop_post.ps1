# =============================================================
# main_workshop_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR WORKSHOP
#               A lancer apres le redemarrage suivant le join de la foret
#               1. Cree le compte worker
#               2. Cree le dossier partage workshop
#               3. Configure les permissions NTFS et SMB pour l'utilisateur cree
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$ScriptDir = "$PSScriptRoot"

Write-Host "=== CONFIGURATION POST-REBOOT SERVEUR WORKSHOP ===" -ForegroundColor Cyan

# Etape 1 : Creation du compte worker
Write-Host "`n[1/3] Creation du compte worker..." -ForegroundColor Yellow
& "$ScriptDir\UserCreation.ps1"

# Recuperation du login cree (prenom.nom) et du domaine
$UserLogin = Get-Input "Entrez le login du compte venant d'etre cree (ex: john.doe)" "Login cree"
$Account   = "$((Get-ADDomain).NetBIOSName)\$UserLogin"

# Etape 2 & 3 : Dossier workshop + permissions SMB/NTFS (via le helper New-WorkFolder)
Write-Host "`n[2/3] Creation du dossier workshop et des permissions..." -ForegroundColor Yellow
$WorkshopFolder = Get-Input "Chemin du dossier workshop" "Dossier workshop" "C:\WorkshopFiles"
New-WorkFolder $WorkshopFolder "WorkshopFiles" $Account

# Etape 3 : Acces au dossier generique sur le serveur admin
Write-Host "`n[3/3] Acces au dossier generique sur SRV-ADMIN..." -ForegroundColor Yellow
$SrvAdminIP = Get-Input "IP du SRV-ADMIN (ex: 10.12.200.163)" "IP SRV-ADMIN"
Write-Host "Dossier generique accessible via : \\$SrvAdminIP\GenericFiles" -ForegroundColor Cyan
Write-Host "L'administrateur SRV-ADMIN doit ajouter $UserLogin aux permissions de GenericFiles." -ForegroundColor Yellow

Write-Host "`n=== SERVEUR WORKSHOP CONFIGURE ===" -ForegroundColor Green
