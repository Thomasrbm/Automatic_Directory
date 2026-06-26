# =============================================================
# NetworkConfig_SrvAdmin.ps1
# Description : Configure le reseau du SRV-ADMIN (mono-carte, Reseau NAT VirtualBox 'ADLab')
#               - IP fixe sur 10.0.2.0/24
#               - DNS : pointe vers lui-meme (il est le DC principal)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$IP   = Get-Input "IP fixe de SRV-ADMIN" "IP" "10.0.2.10"
$GW   = Get-Input "Passerelle (NAT VirtualBox)" "Passerelle" "10.0.2.1"
$Name = Get-Input "Nom du serveur" "Nom" "SRV-ADMIN"

# SRV-ADMIN est son propre DNS (il heberge la zone AD)
Set-StaticNetwork $IP $GW $IP $Name
