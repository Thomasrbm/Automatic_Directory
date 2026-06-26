# JoinExistingDomainController.ps1 - Rejoint une foret AD existante (DC additionnel)
# Parametres : DomainAddress
. "$PSScriptRoot\helpers.ps1"
Test-Admin

$Domain = Get-Input "Adresse du domaine existant (ex: domolia.local)" "Domaine" "domolia.local"

# --- Pre-flight 1 : un renommage de machine en attente bloque la promotion d'un DC ---
# On compare le nom actif (en cours) et le nom programme (apres reboot).
$active  = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -ErrorAction SilentlyContinue).ComputerName
$pending = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName"       -ErrorAction SilentlyContinue).ComputerName
if ($active -and $pending -and $active -ne $pending) {
    Write-Host "Renommage en attente de redemarrage ($active -> $pending)." -ForegroundColor Red
    Write-Host "Redemarrez la machine AVANT de promouvoir le DC, puis relancez main_workshop.ps1." -ForegroundColor Yellow
    exit 1
}

# --- Pre-flight 2 : le DNS doit pouvoir localiser un DC du domaine ---
# L'enregistrement SRV _ldap._tcp.dc._msdcs.<domaine> est celui que la promotion utilise.
Write-Host "Verification DNS : localisation d'un DC pour $Domain..." -ForegroundColor Yellow
$srv = Resolve-DnsName -Name "_ldap._tcp.dc._msdcs.$Domain" -Type SRV -ErrorAction SilentlyContinue
if (-not $srv) {
    Write-Host "Impossible de localiser un DC pour $Domain via DNS." -ForegroundColor Red
    Write-Host "Le DNS de ce serveur doit pointer vers SRV-ADMIN (le DC existant)." -ForegroundColor Yellow
    Write-Host "Verifiez : Get-DnsClientServerAddress   puis   ping $Domain" -ForegroundColor Yellow
    exit 1
}
Write-Host "DC localise pour $Domain." -ForegroundColor Green

# --- Credentials (annulation = abandon explicite, pas un faux succes) ---
$Creds = Get-Credential -Message "Domain Admin de $Domain (format : $Domain\Administrateur ou Administrateur@$Domain)"
if (-not $Creds) {
    Write-Host "Aucun credential fourni. Abandon." -ForegroundColor Red
    exit 1
}
$DSRM = Read-Host "Mot de passe DSRM (Safe Mode)" -AsSecureString

# -NoRebootOnCompletion : le reboot est gere explicitement par main_workshop.ps1 (seulement si succes)
# -ErrorAction Stop      : toute erreur devient une exception attrapable
try {
    Import-Module ADDSDeployment -ErrorAction SilentlyContinue
    $result = Install-ADDSDomainController -DomainName $Domain -Credential $Creds -SafeModeAdministratorPassword $DSRM -InstallDns -Force -NoRebootOnCompletion -ErrorAction Stop
    if ($result.Status -ne "Success") {
        Write-Host "Promotion echouee (status: $($result.Status)). Pas de redemarrage." -ForegroundColor Red
        exit 1
    }
    Write-Host "Promotion reussie." -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "Echec de la promotion : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
