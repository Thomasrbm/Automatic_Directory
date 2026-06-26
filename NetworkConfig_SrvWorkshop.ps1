# =============================================================
# NetworkConfig_SrvWorkshop.ps1
# Description : Configure le reseau du SRV-WORKSHOP (mono-carte, Reseau NAT VirtualBox 'ADLab')
#               - IP fixe sur 10.0.2.0/24
#               - DNS : pointe vers SRV-ADMIN (DC principal)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$IP   = Get-Input "IP fixe de SRV-WORKSHOP" "IP" "10.0.2.11"
$GW   = Get-Input "Passerelle (NAT VirtualBox)" "Passerelle" "10.0.2.1"
$DNS  = Get-Input "DNS = IP du SRV-ADMIN" "DNS (SRV-ADMIN)" "10.0.2.10"
$Name = Get-Input "Nom du serveur" "Nom" "SRV-WORKSHOP"

Set-StaticNetwork $IP $GW $DNS $Name
