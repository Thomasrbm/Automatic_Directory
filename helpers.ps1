# =============================================================
# helpers.ps1
# Description : Fonctions utilitaires communes a tous les scripts AD
#               A inclure avec : . "$PSScriptRoot\helpers.ps1"
# =============================================================

# Chargement de l'assembly pour les popups
Add-Type -AssemblyName Microsoft.VisualBasic

# Desactive la barre de progression : sinon Install-WindowsFeature / promotions AD /
# Invoke-WebRequest "gelent" l'affichage (surtout dans PowerShell ISE) et on doit faire Ctrl+C.
# Le travail se fait quand meme ; on supprime juste le rendu qui bloque.
$ProgressPreference = 'SilentlyContinue'

# Verifie que le script est lance en tant qu'administrateur
function Test-Admin {
    # [] un type ,  Securiy.  ...  chemin vers la classe,  :: methode
    # getcurrent => renvoit obj windowidentity (compte, nom groupe)  
    # IsInRole  = methode de WindowsPrincipal  => verif si admin
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Droits administrateur requis." -ForegroundColor Red
        exit
    }
}

# Affiche un popup et retourne la valeur saisie (obligatoire)
# 3 param dont default non obligatoire et vaut "" par defaut
function Get-Input($message, $title, $default = "") {
    # result stock,  input ouvre boite , message = question, title = titre window, default = si champs par defaut
    $result = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, $default)
    if ([string]::IsNullOrWhiteSpace($result)) {
        Write-Host "Champ '$title' requis. Abandon." -ForegroundColor Red
        exit
    }
    return $result
}

# Affiche un popup et retourne la valeur saisie (optionnelle)
# peut etre vide, pas de if vide
function Get-OptionalInput($message, $title, $default = "") {
    return [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, $default)
}

# Verifie qu'un utilisateur AD existe, quitte sinon
function Assert-UserExists($username) {
    # cherche user dans ad
    # -filter critere de recherceh comme Where en sql
    # Sam = nom de connexion
    # -eq egale a 
    # ne pas planter en cas d etteur 
    if (-not (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue)) {
        Write-Host "Utilisateur '$username' introuvable. Operation bloquee." -ForegroundColor Red
        exit
    }
}



# Verifie qu'un groupe AD existe, quitte sinon
function Assert-GroupExists($groupname) {
    if (-not (Get-ADGroup -Filter { Name -eq $groupname } -ErrorAction SilentlyContinue)) {
        Write-Host "Groupe '$groupname' introuvable. Operation bloquee." -ForegroundColor Red
        exit
    }
}

# Cree un dossier, le partage en SMB et accorde les droits NTFS "Modify" a un compte

# path ou on cree : C:\AdminFiles par ex
# nom du dossier : AdminFiles ex
# account avec droit : admin ex
function New-WorkFolder($path, $shareName, $account) {
    # cree,  type  directory,  le fonction renvoit du text => out null l ignore, force ne plante pas si existe deja 
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    # New-SmbShare = partage reseau,  fullacces pour le compte 
    # dans page shared
    New-SmbShare -Name $shareName -Path $path -FullAccess $account -ErrorAction SilentlyContinue | Out-Null
    # ACL = Access Control List = la liste des permissions d'un dossier ,    get = lit les permistion 
    # sera modif et reappliquer
    $acl  = Get-Acl $path
    # dams page security (double verrou)
    # nouvel obj, class access rule de security
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      $account,                          # QUI    → DOMOLIA\admin
      "Modify",                          # QUOI   → droit de modifier
      "ContainerInherit,ObjectInherit",  # OÙ     → + sous-dossiers + fichiers
      "None",                            # (propagation) → rien de spécial
      "Allow")                           # SENS   → autoriser (pas interdire)
    # applique modif sur la version ram en memoire (run time)
    $acl.SetAccessRule($rule)
    # applique sur le disque
    Set-Acl $path $acl
    Write-Host "Dossier '$path' cree, partage ($shareName) et droits Modify accordes a $account." -ForegroundColor Green
}

# Configure la carte reseau (Reseau NAT), applique l'IP statique, renomme la machine et redemarre
function Set-StaticNetwork($IP, $Gateway, $Dns, $NewName) {
    # Une seule carte (Reseau NAT) : detection automatique
    $Nic = (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1).Name
    if (-not $Nic) { $Nic = (Get-NetAdapter | Select-Object -First 1).Name }

    # Nettoyage de l'ancienne config (DHCP / IP / route) puis application
    Set-NetIPInterface  -InterfaceAlias $Nic -Dhcp Disabled -ErrorAction SilentlyContinue
    Remove-NetRoute     -InterfaceAlias $Nic -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetIPAddress -InterfaceAlias $Nic -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue

    New-NetIPAddress -InterfaceAlias $Nic -IPAddress $IP -PrefixLength 24 -DefaultGateway $Gateway
    Set-DnsClientServerAddress -InterfaceAlias $Nic -ServerAddresses $Dns

    Rename-Computer -NewName $NewName -Force
    Restart-Computer -Force
}
