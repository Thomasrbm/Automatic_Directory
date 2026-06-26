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

# Si le join a echoue (code de sortie != 0), on s'arrete : pas de reboot sur un serveur a moitie configure
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nLe join de la foret a echoue. Corrigez le probleme (DNS, credentials, reseau) puis relancez main_workshop.ps1." -ForegroundColor Red
    exit 1
}

# Relance automatique de main_workshop_post.ps1 apres le redemarrage (cle RunOnce)
# RunOnce est execute une seule fois a la prochaine ouverture de session.
# On relance PowerShell en elevation (-Verb RunAs) car le script post necessite les droits admin.
$PostScript = "$ScriptDir\main_workshop_post.ps1"
$RunOnceCmd = "powershell.exe -ExecutionPolicy Bypass -NoExit -Command `"Start-Process powershell.exe -Verb RunAs -ArgumentList '-ExecutionPolicy','Bypass','-NoExit','-File','$PostScript'`""
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "WorkshopPost" -Value $RunOnceCmd
Write-Host "Relance automatique de main_workshop_post.ps1 programmee apres le redemarrage." -ForegroundColor Green

Write-Host "`nLe serveur va redemarrer dans 10 secondes..." -ForegroundColor Magenta
Start-Sleep -Seconds 10
Restart-Computer -Force
