# =============================================================
# main_admin_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR ADMINISTRATEUR
#               A lancer apres le redemarrage suivant la creation de la foret
#               1. Cree le compte administrateur
#               2. Cree les dossiers partages (admin + generique)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$ScriptDir = "$PSScriptRoot"

Write-Host "=== CONFIGURATION POST-REBOOT SERVEUR ADMINISTRATEUR ===" -ForegroundColor Cyan

# Etape 1 : Creation du compte administrateur
Write-Host "`n[1/2] Creation du compte administrateur..." -ForegroundColor Yellow
& "$ScriptDir\UserCreation.ps1"

# Etape 2 : Creation des dossiers partages
Write-Host "`n[2/2] Creation des dossiers partages..." -ForegroundColor Yellow

# Dossier administratif
$AdminFolder = Get-Input "Chemin du dossier administratif (ex: C:\AdminFiles)" "Dossier admin" "C:\AdminFiles"
New-Item -ItemType Directory -Path $AdminFolder -Force | Out-Null
# Partage du dossier en reseau
New-SmbShare -Name "AdminFiles" -Path $AdminFolder -FullAccess "Domain Admins" -ReadAccess "Authenticated Users" -ErrorAction SilentlyContinue
Write-Host "Dossier admin cree et partage : $AdminFolder" -ForegroundColor Green

# Dossier generique
$GenericFolder = Get-Input "Chemin du dossier generique (ex: C:\GenericFiles)" "Dossier generique" "C:\GenericFiles"
New-Item -ItemType Directory -Path $GenericFolder -Force | Out-Null
New-SmbShare -Name "GenericFiles" -Path $GenericFolder -FullAccess "Domain Admins" -ReadAccess "Authenticated Users" -ErrorAction SilentlyContinue
Write-Host "Dossier generique cree et partage : $GenericFolder" -ForegroundColor Green

Write-Host "`n=== SERVEUR ADMINISTRATEUR CONFIGURE ===" -ForegroundColor Green
