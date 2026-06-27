# CreateNewForestDomainController.ps1 - Cree une nouvelle foret AD
# Parametres : DomainAddress, NetbiosName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Domain  = Get-Input "Adresse du domaine (ex: domolia.local)" "Domaine" "domolia.local"
$Netbios = Get-Input "Nom NetBIOS (ex: DOMOLIA)" "NetBIOS" "DOMOLIA"
# a windows, on voit pas ce qu on ecrit
# met das le terminal
$DSRM    = Read-Host "Mot de passe DSRM" -AsSecureString

# windows,  install la foret,  netbios = nom court, dns pour traduire les nom dans l ad (ip)
# Commande identique a celle generee par l'assistant GUI (Server Manager -> Afficher le script)
Write-Host "Creation de la foret en cours (plusieurs minutes, le serveur redemarrera tout seul)..." -ForegroundColor Yellow
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainName $Domain `
    -DomainNetbiosName $Netbios `
    -SafeModeAdministratorPassword $DSRM `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -CreateDnsDelegation:$false `
    -InstallDns:$true `
    -NoRebootOnCompletion:$false `
    -Force:$true
