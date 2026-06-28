# =============================================================
# DisableFirewall.ps1
# Description : Desactive le pare-feu Windows sur les 3 profils
#               (Domain, Public, Private). Pratique en lab pour eviter
#               les blocages reseau (SMB, ping, replication). A eviter
#               en production (securite). A lancer en administrateur.
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin

# Coupe les 3 profils d'un coup
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
Write-Host "Pare-feu desactive (Domain, Public, Private)." -ForegroundColor Green

# --- VERIFICATION : etat de chaque profil ---
Write-Host "`n[VERIFICATION] Etat des profils :" -ForegroundColor Cyan
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -AutoSize
