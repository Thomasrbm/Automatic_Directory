# =============================================================
# NetworkConfig_ClientAdmin.ps1
# Description : Configure le reseau du CLIENT-ADMIN (workstation)
#               - Ethernet 1 (Internal) : IP fixe reseau admin interne
#               - DNS : pointe vers SRV-ADMIN via reseau interne
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

Write-Host "=== CONFIGURATION RESEAU CLIENT-ADMIN ===" -ForegroundColor Cyan

# --- ETHERNET 1 : Internal (reseau admin interne) ---
Write-Host "`nConfiguration Ethernet 1 (Internal - reseau admin)..." -ForegroundColor Yellow

$ClientIP       = Get-Input "IP fixe pour ce client (ex: 192.168.10.50)" "IP Client" "192.168.10.50"
$SrvAdminIP     = Get-Input "IP interne du SRV-ADMIN (ex: 192.168.10.1)" "IP SRV-ADMIN" "192.168.10.1"

# Application de la config
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $ClientIP -PrefixLength 24 -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $SrvAdminIP
Write-Host "Ethernet configure : $ClientIP (DNS -> $SrvAdminIP)" -ForegroundColor Green

# Renommage de la machine
$MachineName = Get-Input "Nom de la machine" "Nom" "CLIENT-ADMIN"
Rename-Computer -NewName $MachineName -Force

Write-Host "`n=== RESEAU CLIENT-ADMIN CONFIGURE ===" -ForegroundColor Green
Write-Host "Redemarrage automatique dans 10 secondes (necessaire apres le renommage)..." -ForegroundColor Magenta
Start-Sleep -Seconds 10
Restart-Computer -Force
