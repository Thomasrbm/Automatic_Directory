# =============================================================
# RenameMachine.ps1
# Description : Renomme la machine (ne touche PAS au reseau / IP) puis redemarre.
#               A lancer en TOUT PREMIER, avant main_admin / main_workshop,
#               pour que le renommage soit valide avant la promotion.
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$Name = Get-Input "Nouveau nom de la machine (ex: SRV-ADMIN / SRV-WORKSHOP)" "Nom" "SRV-ADMIN"

# Renomme + redemarre (le reboot valide le nom avant toute promotion)
Rename-Computer -NewName $Name -Force -Restart
