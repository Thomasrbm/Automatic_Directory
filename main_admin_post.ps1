# =============================================================
# main_admin_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR ADMINISTRATEUR
#               A lancer apres le redemarrage suivant la creation de la foret
#               1. Cree le compte administrateur
#               2. Cree les dossiers partages (admin + generique)
#               3. Configure les permissions NTFS et SMB pour l'utilisateur cree
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$ScriptDir = "$PSScriptRoot"

Write-Host "=== CONFIGURATION POST-REBOOT SERVEUR ADMINISTRATEUR ===" -ForegroundColor Cyan

# Etape 1 : Creation du compte administrateur
Write-Host "`n[1/3] Creation du compte administrateur..." -ForegroundColor Yellow
& "$ScriptDir\UserCreation.ps1"

# Recuperation du login cree (prenom.nom) et du domaine
$UserLogin = Get-Input "Entrez le login du compte venant d'etre cree (ex: admin.test)" "Login cree"
$Account   = "$((Get-ADDomain).NetBIOSName)\$UserLogin"

# Etape 2 & 3 : Dossiers partages + permissions SMB/NTFS (via le helper New-WorkFolder)
Write-Host "`n[2/3] Creation des dossiers partages et des permissions..." -ForegroundColor Yellow
$AdminFolder   = Get-Input "Chemin du dossier administratif" "Dossier admin" "C:\AdminFiles"
$GenericFolder = Get-Input "Chemin du dossier generique" "Dossier generique" "C:\GenericFiles"
New-WorkFolder $AdminFolder   "AdminFiles"   $Account
New-WorkFolder $GenericFolder "GenericFiles" $Account

Write-Host "`n=== SERVEUR ADMINISTRATEUR CONFIGURE ===" -ForegroundColor Green
