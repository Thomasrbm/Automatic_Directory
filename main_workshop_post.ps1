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

# Demarre les services AD (le DC doit etre operationnel avant de creer comptes/dossiers)
# Start-ADServices

Write-Host "Reponds aux fenetres popup au fur et a mesure (Alt+Tab si elles sont cachees)." -ForegroundColor Cyan

# Etape 1 : Creation du compte worker
& "$ScriptDir\UserCreation.ps1"

# Recuperation du login cree (prenom.nom) et du domaine
$UserLogin = Get-Input "Entrez le login du compte venant d'etre cree (ex: user.worker)" "Login cree" "user.worker"
$Account   = "DOMOLIA\$UserLogin"

# Etape 2 : Autorise ce user non-admin a ouvrir une session sur les DC (locale + RDP)
Grant-DCLogon $UserLogin

# Etape 3 & 4 : Dossier workshop + permissions SMB/NTFS (via le helper New-WorkFolder)
$WorkshopFolder = Get-Input "Chemin du dossier workshop" "Dossier workshop" "C:\WorkshopFiles"
New-WorkFolder $WorkshopFolder "WorkshopFiles" $Account

# Etape 3 : Acces au dossier generique sur le serveur admin
$SrvAdminIP = Get-Input "IP du SRV-ADMIN (ex: 10.0.0.4)" "IP SRV-ADMIN" "10.0.0.4"
Write-Host "Dossier generique accessible via : \\$SrvAdminIP\GenericFiles" -ForegroundColor Cyan
Write-Host "Sur SRV-ADMIN, lancer AddUserToGenericFiles.ps1 et saisir $UserLogin pour lui donner acces a GenericFiles." -ForegroundColor Yellow
