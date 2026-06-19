# CreateNewForestDomainController.ps1 - Cree une nouvelle foret AD
# Parametres : DomainAddress, NetbiosName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Domain  = Get-Input "Adresse du domaine (ex: domolia.local)" "Domaine"
$Netbios = Get-Input "Nom NetBIOS (ex: DOMOLIA)" "NetBIOS"
$DSRM    = Read-Host "Mot de passe DSRM" -AsSecureString
Install-ADDSForest -DomainName $Domain -DomainNetbiosName $Netbios -SafeModeAdministratorPassword $DSRM -InstallDns -Force
