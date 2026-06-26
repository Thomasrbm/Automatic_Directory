# JoinExistingDomainController.ps1 - Rejoint une foret AD existante (DC additionnel)
# Parametres : DomainAddress
. "$PSScriptRoot\helpers.ps1"
Test-Admin

$Domain = Get-Input "Adresse du domaine existant (ex: domolia.local)" "Domaine" "domolia.local"

# Pre-flight : un renommage de machine en attente bloque la promotion d'un DC.
# (lecture registre instantanee, aucun risque de blocage)
$active  = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -ErrorAction SilentlyContinue).ComputerName
$pending = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"       -ErrorAction SilentlyContinue).ComputerName
if ($active -and $pending -and $active -ne $pending) {
    Write-Host "Renommage en attente de redemarrage ($active -> $pending)." -ForegroundColor Red
    Write-Host "Redemarrez la machine (Restart-Computer) AVANT de promouvoir, puis relancez main_workshop.ps1." -ForegroundColor Yellow
    exit 1
}

# Credentials du Domain/Enterprise Admin (format : DOMOLIA\Administrateur ou Administrateur@domolia.local)
# Annulation -> abandon explicite (et non un faux succes vu par main_workshop.ps1)
$Creds = Get-Credential -Message "Domain Admin de $Domain (format : $Domain\Administrateur)"
if (-not $Creds) {
    Write-Host "Aucun credential fourni. Abandon." -ForegroundColor Red
    exit 1
}
$DSRM = Read-Host "Mot de passe DSRM (Safe Mode)" -AsSecureString

# -ErrorAction Stop : toute erreur devient une exception attrapable
# Pas de -NoRebootOnCompletion : sur succes, la cmdlet redemarre le serveur elle-meme.
try {
    Import-Module ADDSDeployment -ErrorAction SilentlyContinue
    Write-Host "Promotion en cours (plusieurs minutes, le serveur redemarrera tout seul)..." -ForegroundColor Yellow
    Install-ADDSDomainController -DomainName $Domain -Credential $Creds -SafeModeAdministratorPassword $DSRM -InstallDns -Force -ErrorAction Stop
    exit 0
}
catch {
    Write-Host "Echec de la promotion : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
