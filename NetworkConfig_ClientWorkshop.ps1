# =============================================================
# NetworkConfig_ClientWorkshop.ps1
# Description : Configure le reseau du CLIENT-WORKSHOP (mono-carte, Reseau NAT VirtualBox 'ADLab')
#               - IP fixe sur 10.0.2.0/24
#               - DNS : pointe vers SRV-ADMIN (indispensable pour rejoindre le domaine)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

$IP   = Get-Input "IP fixe de ce client" "IP" "10.0.2.51"
$GW   = Get-Input "Passerelle (NAT VirtualBox)" "Passerelle" "10.0.2.1"
$DNS  = Get-Input "DNS = IP du SRV-ADMIN" "DNS (SRV-ADMIN)" "10.0.2.10"
$Name = Get-Input "Nom de la machine" "Nom" "CLIENT-WORKSHOP"

Set-StaticNetwork $IP $GW $DNS $Name
