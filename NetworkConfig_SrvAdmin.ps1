# =============================================================
# NetworkConfig_SrvAdmin.ps1
# Description : Configure le reseau du SRV-ADMIN (mono-carte, Reseau NAT VirtualBox 'ADLab')
#               - IP fixe sur 10.0.2.0/24
#               - DNS : pointe vers lui-meme (il est le DC principal)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

Write-Host "=== CONFIGURATION RESEAU SRV-ADMIN ===" -ForegroundColor Cyan

# Une seule carte, branchee sur le Reseau NAT 'ADLab'
Write-Host "`nCartes reseau detectees :" -ForegroundColor Yellow
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status -AutoSize | Out-Host
$DefaultNic = (Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1).Name
$Nic = Get-Input "Nom de la carte reseau (NAT)" "Carte" $DefaultNic

$IP  = Get-Input "IP fixe de SRV-ADMIN" "IP" "10.0.2.10"
$GW  = Get-Input "Passerelle (NAT VirtualBox)" "Passerelle" "10.0.2.1"

# Nettoyage de l'ancienne config (DHCP / IP / route) puis application
Set-NetIPInterface  -InterfaceAlias $Nic -Dhcp Disabled -ErrorAction SilentlyContinue
Remove-NetRoute     -InterfaceAlias $Nic -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetIPAddress -InterfaceAlias $Nic -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue

New-NetIPAddress -InterfaceAlias $Nic -IPAddress $IP -PrefixLength 24 -DefaultGateway $GW
# SRV-ADMIN est son propre DNS (il heberge la zone AD)
Set-DnsClientServerAddress -InterfaceAlias $Nic -ServerAddresses $IP
Write-Host "Configure : $IP/24  GW $GW  DNS -> lui-meme" -ForegroundColor Green

# Test internet (via NAT)
Write-Host "`nTest internet (8.8.8.8)..." -ForegroundColor Yellow
if (Test-Connection 8.8.8.8 -Count 2 -Quiet) {
    Write-Host "Internet OK." -ForegroundColor Green
} else {
    Write-Host "Pas de reponse de 8.8.8.8. Verifie que la VM est bien sur le Reseau NAT 'ADLab'." -ForegroundColor Red
}

# Renommage + redemarrage automatique
$ServerName = Get-Input "Nom du serveur" "Nom" "SRV-ADMIN"
Rename-Computer -NewName $ServerName -Force

Write-Host "`n=== RESEAU SRV-ADMIN CONFIGURE ===" -ForegroundColor Green
Write-Host "Redemarrage automatique dans 10 secondes (necessaire apres le renommage)..." -ForegroundColor Magenta
Start-Sleep -Seconds 10
Restart-Computer -Force
