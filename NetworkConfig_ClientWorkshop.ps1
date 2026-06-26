# =============================================================
# NetworkConfig_ClientWorkshop.ps1
# Description : Configure le reseau du CLIENT-WORKSHOP (mono-carte, Reseau NAT VirtualBox 'ADLab')
#               - IP fixe sur 10.0.2.0/24
#               - DNS : pointe vers SRV-ADMIN (indispensable pour rejoindre le domaine)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

Write-Host "=== CONFIGURATION RESEAU CLIENT-WORKSHOP ===" -ForegroundColor Cyan

# Une seule carte, branchee sur le Reseau NAT 'ADLab'
Write-Host "`nCartes reseau detectees :" -ForegroundColor Yellow
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status -AutoSize | Out-Host
$DefaultNic = (Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1).Name
$Nic = Get-Input "Nom de la carte reseau (NAT)" "Carte" $DefaultNic

$IP    = Get-Input "IP fixe de ce client" "IP" "10.0.2.51"
$GW    = Get-Input "Passerelle (NAT VirtualBox)" "Passerelle" "10.0.2.1"
$DNS   = Get-Input "DNS = IP du SRV-ADMIN" "DNS (SRV-ADMIN)" "10.0.2.10"

# Nettoyage de l'ancienne config (DHCP / IP / route) puis application
Set-NetIPInterface  -InterfaceAlias $Nic -Dhcp Disabled -ErrorAction SilentlyContinue
Remove-NetRoute     -InterfaceAlias $Nic -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetIPAddress -InterfaceAlias $Nic -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue

New-NetIPAddress -InterfaceAlias $Nic -IPAddress $IP -PrefixLength 24 -DefaultGateway $GW
Set-DnsClientServerAddress -InterfaceAlias $Nic -ServerAddresses $DNS
Write-Host "Configure : $IP/24  GW $GW  DNS $DNS" -ForegroundColor Green

# Test internet + joignabilite du DC admin (qui resout le domaine)
Write-Host "`nTest internet (8.8.8.8) et SRV-ADMIN ($DNS)..." -ForegroundColor Yellow
if (Test-Connection 8.8.8.8 -Count 2 -Quiet) { Write-Host "Internet OK." -ForegroundColor Green }
else { Write-Host "Pas de reponse de 8.8.8.8. Verifie le Reseau NAT 'ADLab'." -ForegroundColor Red }
if (Test-Connection $DNS -Count 2 -Quiet) { Write-Host "SRV-ADMIN joignable." -ForegroundColor Green }
else { Write-Host "SRV-ADMIN injoignable : demarre-le et verifie son IP ($DNS)." -ForegroundColor Red }

# Renommage + redemarrage automatique
$MachineName = Get-Input "Nom de la machine" "Nom" "CLIENT-WORKSHOP"
Rename-Computer -NewName $MachineName -Force

Write-Host "`n=== RESEAU CLIENT-WORKSHOP CONFIGURE ===" -ForegroundColor Green
Write-Host "Redemarrage automatique dans 10 secondes (necessaire apres le renommage)..." -ForegroundColor Magenta
Start-Sleep -Seconds 10
Restart-Computer -Force
