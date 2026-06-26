# JoinExistingDomainController.ps1 - Rejoint une foret AD existante (DC additionnel)
# Parametres : DomainAddress
. "$PSScriptRoot\helpers.ps1"
Test-Admin

# --- Journalisation : tout l'ecran est aussi ecrit dans un fichier log horodate ---
$LogFile = Join-Path $PSScriptRoot ("join_debug_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
try { Start-Transcript -Path $LogFile -Force | Out-Null } catch {}
Write-Host "Log de cette tentative : $LogFile" -ForegroundColor DarkGray

$Domain = Get-Input "Adresse du domaine existant (ex: domolia.local)" "Domaine" "domolia.local"

# Pre-flight : un renommage de machine en attente bloque la promotion d'un DC.
# (lecture registre instantanee, aucun risque de blocage)
$active  = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -ErrorAction SilentlyContinue).ComputerName
$pending = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"       -ErrorAction SilentlyContinue).ComputerName
if ($active -and $pending -and $active -ne $pending) {
    Write-Host "Renommage en attente de redemarrage ($active -> $pending)." -ForegroundColor Red
    Write-Host "Redemarrez la machine (Restart-Computer) AVANT de promouvoir, puis relancez main_workshop.ps1." -ForegroundColor Yellow
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}

# --- DIAGNOSTIC (informatif, ne bloque jamais) : etat avant la promotion ---
Write-Host "`n===== DIAGNOSTIC PRE-PROMOTION =====" -ForegroundColor Cyan
Write-Host ("Machine          : {0}" -f $env:COMPUTERNAME)
Write-Host ("Domaine cible    : {0}" -f $Domain)

Write-Host "`n-- Serveurs DNS configures --" -ForegroundColor Yellow
Get-DnsClientServerAddress -AddressFamily IPv4 | Format-Table InterfaceAlias, ServerAddresses -AutoSize | Out-Host

Write-Host "-- Resolution du domaine ($Domain) --" -ForegroundColor Yellow
$dom = Resolve-DnsName -Name $Domain -Type A -QuickTimeout -ErrorAction SilentlyContinue
if ($dom) {
    $dcIp = ($dom | Where-Object { $_.IPAddress }).IPAddress
    $dcIp | ForEach-Object { Write-Host ("  resolu -> {0}" -f $_) -ForegroundColor Green }
    foreach ($ip in $dcIp) {
        $ok = Test-Connection -ComputerName $ip -Count 2 -Quiet -ErrorAction SilentlyContinue
        Write-Host ("  ping {0} : {1}" -f $ip, ($(if ($ok) {'OK'} else {'KO'}))) -ForegroundColor $(if ($ok) {'Green'} else {'Red'})
    }
} else {
    Write-Host "  ECHEC : le domaine ne se resout pas (le DNS doit pointer vers SRV-ADMIN)." -ForegroundColor Red
}

Write-Host "-- Localisation d'un DC (nltest) --" -ForegroundColor Yellow
cmd /c "nltest /dsgetdc:$Domain" 2>&1 | Out-Host

Write-Host "-- Etat de l'horloge (Kerberos refuse un ecart > 5 min) --" -ForegroundColor Yellow
Write-Host ("  Heure locale : {0}" -f (Get-Date))
cmd /c "w32tm /query /status" 2>&1 | Out-Host
Write-Host "===== FIN DIAGNOSTIC =====`n" -ForegroundColor Cyan

# Credentials du Domain/Enterprise Admin (format : DOMOLIA\Administrateur ou Administrateur@domolia.local)
# Annulation -> abandon explicite (et non un faux succes vu par main_workshop.ps1)
$Creds = Get-Credential -Message "Domain Admin de $Domain (format : $Domain\Administrateur)"
if (-not $Creds) {
    Write-Host "Aucun credential fourni. Abandon." -ForegroundColor Red
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}
$DSRM = Read-Host "Mot de passe DSRM (Safe Mode)" -AsSecureString

# -ErrorAction Stop : toute erreur devient une exception attrapable
# Pas de -NoRebootOnCompletion : sur succes, la cmdlet redemarre le serveur elle-meme.
try {
    Import-Module ADDSDeployment -ErrorAction SilentlyContinue
    Write-Host "Lancement de la promotion (cela prend plusieurs minutes)..." -ForegroundColor Yellow
    Install-ADDSDomainController -DomainName $Domain -Credential $Creds -SafeModeAdministratorPassword $DSRM -InstallDns -Force -ErrorAction Stop
    # Atteint seulement si le redemarrage automatique n'est pas immediat : on signale le succes.
    Write-Host "Promotion reussie. Redemarrage automatique en cours..." -ForegroundColor Green
    try { Stop-Transcript | Out-Null } catch {}
    exit 0
}
catch {
    Write-Host "`n===== ECHEC DE LA PROMOTION =====" -ForegroundColor Red
    Write-Host ("Message : {0}" -f $_.Exception.Message) -ForegroundColor Red
    Write-Host "`nDetail complet de l'erreur :" -ForegroundColor DarkYellow
    $_ | Format-List * -Force | Out-Host
    Write-Host "Logs natifs dcpromo a consulter en cas de doute :" -ForegroundColor DarkYellow
    Write-Host "   C:\Windows\debug\dcpromoui.log" -ForegroundColor DarkYellow
    Write-Host "   C:\Windows\debug\dcpromo.log" -ForegroundColor DarkYellow
    Write-Host ("Tout est aussi enregistre dans : {0}" -f $LogFile) -ForegroundColor DarkYellow
    try { Stop-Transcript | Out-Null } catch {}
    exit 1
}
