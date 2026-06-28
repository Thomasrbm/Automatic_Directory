# =============================================================
# FixReplication.ps1
# Description : Corrige l'erreur 1749 / event 2513 "Attempting to set the
#               desired authentication protocol failed" pendant la promotion
#               (la replication RPC entre les 2 DC echoue).
#               Cause = couche reseau RPC corrompue en VM : offloads de la
#               carte reseau + fragmentation UDP des gros tickets Kerberos.
#               -> desactive les offloads + force Kerberos sur TCP.
#               A LANCER SUR LES 2 VM (SRV-ADMIN + worker), puis REDEMARRER
#               les deux, AVANT de relancer le join.
#               NB : l'Accelerated Networking se desactive cote Azure
#               (deallocate + az network nic update), pas depuis l'OS.
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin

# 1. Offloads de la carte reseau (corrompent les paquets RPC en VM)
Write-Host "Desactivation des offloads de la carte reseau..." -ForegroundColor Cyan
Disable-NetAdapterLso             -Name * -ErrorAction SilentlyContinue
Disable-NetAdapterChecksumOffload -Name * -ErrorAction SilentlyContinue
Disable-NetAdapterRsc             -Name * -ErrorAction SilentlyContinue

# 2. Offloads globaux TCP (chimney / rss / auto-tuning)
netsh int tcp set global chimney=disabled         | Out-Null
netsh int tcp set global rss=disabled             | Out-Null
netsh int tcp set global autotuninglevel=disabled | Out-Null

# 3. Desactive le task offload globalement (effet apres reboot)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableTaskOffload /t REG_DWORD /d 1 /f | Out-Null

# 4. Force Kerberos sur TCP (evite la fragmentation UDP des gros tickets -> 1749)
Write-Host "Forcage de Kerberos sur TCP..." -ForegroundColor Cyan
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" /v MaxPacketSize /t REG_DWORD /d 1 /f | Out-Null

# --- VERIFICATION : etat des offloads ---
Write-Host "`n[VERIFICATION] Offloads (Enabled doit etre False) :" -ForegroundColor Cyan
Get-NetAdapterLso | Select-Object Name, Enabled | Format-Table -AutoSize

Write-Host "Corrections appliquees." -ForegroundColor Green
Write-Host ">> REDEMARRE cette VM, fais pareil sur l'autre, puis relance le join." -ForegroundColor Yellow
Write-Host ">> Si le 1749 persiste : desactive l'Accelerated Networking cote Azure sur les 2 NIC." -ForegroundColor Yellow
