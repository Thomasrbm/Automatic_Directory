# JoinExistingDomainController.ps1 - Rejoint une foret AD existante
# Parametres : DomainAddress
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Domain = Get-Input "Adresse du domaine existant (ex: domolia.local)" "Domaine" "domolia.local"
$Creds  = Get-Credential -Message "Credentials du Domain Admin de $Domain"
$DSRM   = Read-Host "Mot de passe DSRM" -AsSecureString
Install-ADDSDomainController -DomainName $Domain -Credential $Creds -SafeModeAdministratorPassword $DSRM -InstallDns -Force
