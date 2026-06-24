# =============================================================
# main_workshop_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR WORKSHOP
#               A lancer apres le redemarrage suivant le join de la foret
#               1. Cree le compte worker
#               2. Cree le dossier partage workshop
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$ScriptDir = "$PSScriptRoot"

Write-Host "=== CONFIGURATION POST-REBOOT SERVEUR WORKSHOP ===" -ForegroundColor Cyan

# Etape 1 : Creation du compte worker
Write-Host "`n[1/2] Creation du compte worker..." -ForegroundColor Yellow
& "$ScriptDir\UserCreation.ps1"

# Etape 2 : Creation du dossier partage workshop
Write-Host "`n[2/2] Creation du dossier workshop..." -ForegroundColor Yellow

$WorkshopFolder = Get-Input "Chemin du dossier workshop (ex: C:\WorkshopFiles)" "Dossier workshop" "C:\WorkshopFiles"
New-Item -ItemType Directory -Path $WorkshopFolder -Force | Out-Null
New-SmbShare -Name "WorkshopFiles" -Path $WorkshopFolder -FullAccess "Domain Admins" -ReadAccess "Authenticated Users" -ErrorAction SilentlyContinue
Write-Host "Dossier workshop cree et partage : $WorkshopFolder" -ForegroundColor Green

Write-Host "`n=== SERVEUR WORKSHOP CONFIGURE ===" -ForegroundColor Green
