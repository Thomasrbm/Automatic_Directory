# =============================================================
# NetworkConfig_SrvAdmin.ps1
# Description : Configure le reseau du SRV-ADMIN
#               - Carte Bridged  : IP fixe sur le reseau de l'ecole (+ passerelle)
#               - Carte Internal : IP fixe sur le reseau interne admin (pas de passerelle)
#               - DNS : pointe vers lui-meme (il est le DC principal)
# =============================================================

. "$PSScriptRoot\helpers.ps1"
Test-Admin

Write-Host "=== CONFIGURATION RESEAU SRV-ADMIN ===" -ForegroundColor Cyan

# Affiche les cartes reelles pour eviter les erreurs de nom (avec 2 NIC l'ordre n'est pas garanti)
Write-Host "`nCartes reseau detectees :" -ForegroundColor Yellow
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed -AutoSize | Out-Host

# --- CARTE BRIDGED (reseau ecole) ---
Write-Host "`n[1/2] Configuration carte Bridged (reseau ecole)..." -ForegroundColor Yellow
$BridgedNic = Get-Input "Nom EXACT de la carte Bridged (voir liste ci-dessus)" "Carte Bridged" "Ethernet"
$BridgedIP  = Get-Input "IP fixe Bridged (ex: 10.12.200.163)" "IP Bridged" "10.12.200.163"
$BridgedPfx = [int](Get-Input "Prefixe sous-reseau en bits (8=255.0.0.0, 16=255.255.0.0, 24=255.255.255.0)" "Prefixe Bridged" "16")
$BridgedGW  = Get-Input "Passerelle par defaut (ex: 10.12.254.254)" "Passerelle" "10.12.254.254"

# Nettoyage de l'ancienne config (DHCP / IP / route par defaut) pour repartir propre
Set-NetIPInterface  -InterfaceAlias $BridgedNic -Dhcp Disabled -ErrorAction SilentlyContinue
Remove-NetRoute     -InterfaceAlias $BridgedNic -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetIPAddress -InterfaceAlias $BridgedNic -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue

# Application (pas de SilentlyContinue : on veut voir une vraie erreur si ca echoue)
# Le SRV-ADMIN est son propre DNS (il heberge la zone AD)
New-NetIPAddress -InterfaceAlias $BridgedNic -IPAddress $BridgedIP -PrefixLength $BridgedPfx -DefaultGateway $BridgedGW
Set-DnsClientServerAddress -InterfaceAlias $BridgedNic -ServerAddresses $BridgedIP
Write-Host "Bridged configure : $BridgedIP/$BridgedPfx  GW $BridgedGW  (DNS -> lui-meme)" -ForegroundColor Green

# --- CARTE INTERNAL (reseau admin interne) ---
Write-Host "`n[2/2] Configuration carte Internal (reseau admin)..." -ForegroundColor Yellow
$InternalNic = Get-Input "Nom EXACT de la carte Internal (voir liste ci-dessus)" "Carte Internal" "Ethernet 2"
$InternalIP  = Get-Input "IP fixe Internal (ex: 192.168.10.1)" "IP Internal" "192.168.10.1"

Set-NetIPInterface  -InterfaceAlias $InternalNic -Dhcp Disabled -ErrorAction SilentlyContinue
Remove-NetIPAddress -InterfaceAlias $InternalNic -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
# IMPORTANT : pas de -DefaultGateway sur la carte interne (2 passerelles = routage casse)
New-NetIPAddress -InterfaceAlias $InternalNic -IPAddress $InternalIP -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias $InternalNic -ServerAddresses $BridgedIP
# DC multi-homed : on EMPECHE la carte interne de s'enregistrer dans le DNS.
# Sinon son IP 192.168.x (injoignable depuis l'autre site) est annoncee dans le DNS
# et la replication AD tombe dessus -> promotion/replication qui se bloque.
Set-DnsClient -InterfaceAlias $InternalNic -RegisterThisConnectionsAddress $false -ErrorAction SilentlyContinue
Write-Host "Internal configure : $InternalIP/24 (pas d'enregistrement DNS sur cette carte)" -ForegroundColor Green

# --- Verification connectivite immediate ---
Write-Host "`nTest de la passerelle ($BridgedGW)..." -ForegroundColor Yellow
if (Test-Connection -ComputerName $BridgedGW -Count 2 -Quiet) {
    Write-Host "Passerelle joignable." -ForegroundColor Green
} else {
    Write-Host "Passerelle INJOIGNABLE." -ForegroundColor Red
    Write-Host "Verifiez : nom de carte Bridged, IP, prefixe ($BridgedPfx) et que $BridgedGW est la vraie passerelle." -ForegroundColor Yellow
}

# Renommage du serveur
$ServerName = Get-Input "Nom du serveur" "Nom" "SRV-ADMIN"
Rename-Computer -NewName $ServerName -Force

Write-Host "`n=== RESEAU SRV-ADMIN CONFIGURE ===" -ForegroundColor Green
Write-Host "Redemarrage automatique dans 10 secondes (necessaire apres le renommage)..." -ForegroundColor Magenta
Start-Sleep -Seconds 10
Restart-Computer -Force
