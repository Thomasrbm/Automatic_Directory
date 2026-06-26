# =============================================================
# NetworkConfig_SrvWorkshop.ps1
# Description : Configure le reseau du SRV-WORKSHOP
#               - Ethernet 1 (Bridged)  : IP fixe sur le reseau de l'ecole
#               - Ethernet 2 (Internal) : IP fixe sur le reseau interne workshop
#               - DNS : pointe vers SRV-ADMIN (DC principal)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

Write-Host "=== CONFIGURATION RESEAU SRV-WORKSHOP ===" -ForegroundColor Cyan

# --- ETHERNET 1 : Bridged (reseau ecole) ---
Write-Host "`n[1/2] Configuration Ethernet 1 (Bridged - reseau ecole)..." -ForegroundColor Yellow

$BridgedIP      = Get-Input "IP fixe pour Ethernet 1 Bridged (ex: 10.12.200.164)" "IP Bridged" "10.12.200.164"
$BridgedMask    = Get-Input "Masque sous-reseau (ex: 255.0.0.0)" "Masque Bridged" "255.0.0.0"
$BridgedGW      = Get-Input "Passerelle par defaut (ex: 10.12.254.254)" "Passerelle" "10.12.254.254"
$AdminBridgedIP = Get-Input "IP Bridged du SRV-ADMIN (DNS principal, ex: 10.12.200.163)" "IP SRV-ADMIN" "10.12.200.163"

# Application de la config Bridged
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $BridgedIP -PrefixLength 8 -DefaultGateway $BridgedGW -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $AdminBridgedIP
Write-Host "Ethernet 1 configure : $BridgedIP (DNS -> $AdminBridgedIP)" -ForegroundColor Green

# --- ETHERNET 2 : Internal (reseau workshop interne) ---
Write-Host "`n[2/2] Configuration Ethernet 2 (Internal - reseau workshop)..." -ForegroundColor Yellow

$InternalIP     = Get-Input "IP fixe pour Ethernet 2 Internal (ex: 192.168.20.1)" "IP Internal" "192.168.20.1"

# Application de la config Internal
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress $InternalIP -PrefixLength 24 -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $AdminBridgedIP
Write-Host "Ethernet 2 configure : $InternalIP" -ForegroundColor Green

# Renommage du serveur
$ServerName = Get-Input "Nom du serveur" "Nom" "SRV-WORKSHOP"
Rename-Computer -NewName $ServerName -Force

Write-Host "`n=== RESEAU SRV-WORKSHOP CONFIGURE ===" -ForegroundColor Green
Write-Host "Verifiez la connectivite avant de redemarrer :" -ForegroundColor Yellow
Write-Host "   ping 8.8.8.8      (teste la passerelle / le routage)" -ForegroundColor Yellow
Write-Host "   ping google.com   (teste le DNS)" -ForegroundColor Yellow
Write-Host "Quand vous etes pret, lancez manuellement : Restart-Computer" -ForegroundColor Cyan
