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
Write-Host "Creation de la foret en cours (plusieurs minutes, le serveur redemarrera tout seul)..." -ForegroundColor Yellow
Install-ADDSForest -DomainName $Domain -DomainNetbiosName $Netbios -SafeModeAdministratorPassword $DSRM -InstallDns -Force
