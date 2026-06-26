# =============================================================
# NetworkConfig_ClientWorkshop.ps1
# Description : Configure le reseau du CLIENT-WORKSHOP (workstation)
#               - Ethernet 1 (Internal) : IP fixe reseau workshop interne
#               - DNS : pointe vers SRV-ADMIN via reseau bridged du SRV-WORKSHOP
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

Write-Host "=== CONFIGURATION RESEAU CLIENT-WORKSHOP ===" -ForegroundColor Cyan

# --- ETHERNET 1 : Internal (reseau workshop interne) ---
Write-Host "`nConfiguration Ethernet 1 (Internal - reseau workshop)..." -ForegroundColor Yellow

$ClientIP           = Get-Input "IP fixe pour ce client (ex: 192.168.20.50)" "IP Client" "192.168.20.50"
$SrvWorkshopIP      = Get-Input "IP interne du SRV-WORKSHOP (ex: 192.168.20.1)" "IP SRV-WORKSHOP" "192.168.20.1"
$SrvAdminBridgedIP  = Get-Input "IP Bridged du SRV-ADMIN / DNS principal (ex: 10.12.200.163)" "DNS Principal" "10.12.200.163"

# Application de la config
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ClientIP -PrefixLength 24 -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $SrvAdminBridgedIP
Write-Host "Ethernet configure : $ClientIP (DNS -> $SrvAdminBridgedIP)" -ForegroundColor Green

# Renommage de la machine
$MachineName = Get-Input "Nom de la machine" "Nom" "CLIENT-WORKSHOP"
Rename-Computer -NewName $MachineName -Force

Write-Host "`n=== RESEAU CLIENT-WORKSHOP CONFIGURE ===" -ForegroundColor Green
Write-Host "Quand vous etes pret, lancez manuellement : Restart-Computer" -ForegroundColor Cyan
