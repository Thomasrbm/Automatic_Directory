# CreateNewForestDomainController.ps1 - Cree une nouvelle foret AD


# Parametres : DomainAddress, NetbiosName
. "$PSScriptRoot\helpers.ps1"


Test-Admin


$Domain  = Get-Input "Adresse du domaine (ex: domolia.local)" "Domaine" "domolia.local"
$Netbios = Get-Input "Nom NetBIOS (ex: DOMOLIA)" "NetBIOS" "DOMOLIA"



# a windows, on voit pas ce qu on ecrit
# met das le terminal

# DSRM = Directory Services Restore Mode  (mdp de sauvetage)
$DSRM    = Read-Host "Mot de passe DSRM" -AsSecureString




# windows,  install la foret,  netbios = nom court, dns pour traduire les nom dans l ad (ip)
# Commande identique a celle generee par l'assistant GUI (Server Manager -> Afficher le script)
Write-Host "Creation de la foret en cours (plusieurs minutes, le serveur redemarrera tout seul)..." -ForegroundColor Yellow


Import-Module ADDSDeployment # import les cmdlet d install

Install-ADDSForest `
    -DomainName $Domain `
    -DomainNetbiosName $Netbios ` # nom court
    -SafeModeAdministratorPassword $DSRM `
    -ForestMode "WinThreshold" ` # derniere maj des foret windows avec features  ( 2016 )
    -DomainMode "WinThreshold" `
    -DatabasePath "C:\Windows\NTDS" ` # NT Directory Services Database
    -LogPath "C:\Windows\NTDS" ` # pour la synchro ecrit d abord dans log NTDS puis maj
    -SysvolPath "C:\Windows\SYSVOL" ` # dossier partager entre les DC de base : les gpo, scripts logon qui seront repliques
    -CreateDnsDelegation:$false ` # ne redirige pas les domaine vers un sous domaine 
    -InstallDns:$true `
    -NoRebootOnCompletion:$false ` # rebootera
    -Force:$true
