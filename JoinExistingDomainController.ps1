# JoinExistingDomainController.ps1 - Rejoint une foret AD existante (DC additionnel)
# Parametres : DomainAddress
. "$PSScriptRoot\helpers.ps1"
Test-Admin

$Domain = Get-Input "Adresse du domaine existant (ex: domolia.local)" "Domaine" "domolia.local"
$Creds  = Get-Credential -Message "Domain Admin de $Domain (ex: DOMOLIA\Administrateur)"
$DSRM   = Read-Host "Mot de passe DSRM (Safe Mode)" -AsSecureString

# Commande identique a celle generee par l'assistant GUI (Server Manager -> Afficher le script)
Write-Host "Promotion en cours (plusieurs minutes, le serveur redemarrera tout seul)..." -ForegroundColor Yellow
Import-Module ADDSDeployment
Install-ADDSDomainController `
    -DomainName $Domain `
    -Credential $Creds `
    -SafeModeAdministratorPassword $DSRM `
    -SiteName "Default-First-Site-Name" `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -NoGlobalCatalog:$false `
    -CreateDnsDelegation:$false `
    -CriticalReplicationOnly:$false `
    -InstallDns:$true `
    -NoRebootOnCompletion:$false `
    -Force:$true
