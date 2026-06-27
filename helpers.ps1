# =============================================================
# helpers.ps1
# Description : Fonctions utilitaires communes a tous les scripts AD
#               A inclure avec : . "$PSScriptRoot\helpers.ps1"
# =============================================================

# Chargement de l'assembly pour les popups
Add-Type -AssemblyName Microsoft.VisualBasic

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

# Ajoute un compte aux permissions d'un dossier partage DEJA existant
# (acces SMB + droits NTFS Modify). Sert a donner acces a un dossier commun
# (ex: GenericFiles) a un utilisateur supplementaire, sans le recreer.
function Grant-FolderAccess($path, $shareName, $account) {
    # acces au partage SMB existant : Grant-SmbShareAccess (et non New-SmbShare)
    Grant-SmbShareAccess -Name $shareName -AccountName $account -AccessRight Full -Force | Out-Null
    # droits NTFS Modify (+ sous-dossiers + fichiers), comme dans New-WorkFolder
    $acl  = Get-Acl $path
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      $account, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($rule)
    Set-Acl $path $acl
    Write-Host "$account ajoute aux permissions de $shareName ($path)." -ForegroundColor Green
}

# Autorise un utilisateur de domaine NON-admin a ouvrir une session sur les DC
# (locale + Bureau a distance / RDP). Par defaut un DC refuse les users normaux.
# On modifie la Default Domain Controllers Policy (equivalent GUI : GPMC ->
# Attribution des droits utilisateur). La GPO se replique par SYSVOL aux 2 DC.
function Grant-DCLogon($username) {
    Assert-UserExists $username
    # SID de l'utilisateur, au format attendu par le fichier INF : *<SID>
    $Sid  = "*" + (Get-ADUser $username).SID.Value
    # Default Domain Controllers Policy : son GUID est fixe et identique partout
    $Dom  = (Get-ADDomain).DNSRoot
    $Guid = "{6AC1786C-016F-11D2-945F-00C04fB984F9}"
    $Inf  = "\\$Dom\SYSVOL\$Dom\Policies\$Guid\MACHINE\Microsoft\Windows NT\SecEdit\GptTmpl.inf"
    # Sauvegarde de securite avant toute modification
    Copy-Item $Inf "$Inf.bak" -Force
    # Droits a accorder. Si la ligne doit etre creee, on y met TOUJOURS les
    # Administrateurs (S-1-5-32-544) pour ne jamais se verrouiller hors du DC.
    #   SeInteractiveLogonRight       = Ouvrir une session localement
    #   SeRemoteInteractiveLogonRight = Ouvrir une session via Bureau a distance
    $Rights = @{
        "SeInteractiveLogonRight"       = "*S-1-5-32-544"
        "SeRemoteInteractiveLogonRight" = "*S-1-5-32-544"
    }
    $Lines = Get-Content $Inf
    foreach ($Right in $Rights.Keys) {
        # cherche la ligne "SeXxx = ..." dans le fichier
        $Idx = ($Lines | Select-String "^$Right\s*=").LineNumber
        if ($Idx) {
            # la ligne existe : on ajoute notre SID s'il n'y est pas deja
            $i = $Idx - 1
            if ($Lines[$i] -notmatch [regex]::Escape($Sid)) {
                $Lines[$i] = $Lines[$i].TrimEnd() + ",$Sid"
            }
        } else {
            # la ligne n'existe pas : on la cree (Administrateurs + notre user)
            # juste sous l'entete de section [Privilege Rights]
            $Sec   = ($Lines | Select-String "^\[Privilege Rights\]").LineNumber
            $New   = "$Right = $($Rights[$Right]),$Sid"
            $Lines = $Lines[0..($Sec-1)] + $New + $Lines[$Sec..($Lines.Count-1)]
        }
    }
    # GptTmpl.inf est encode en Unicode (UTF-16) : on conserve ce format
    Set-Content $Inf $Lines -Encoding Unicode
    # Incremente la version de la GPO (sinon les DC ne rejouent pas la strategie)
    # On ne prend QUE la ligne "Version=" (ancree en debut de ligne, 1 seule) pour
    # eviter un tableau qui ferait planter le cast [int].
    $Gpt  = "\\$Dom\SYSVOL\$Dom\Policies\$Guid\GPT.ini"
    $Line = Get-Content $Gpt | Where-Object { $_ -match '^Version=' } | Select-Object -First 1
    $Ver  = [int]($Line -replace '\D', '')
    (Get-Content $Gpt) -replace "Version=\d+", "Version=$($Ver + 1)" | Set-Content $Gpt
    # Applique tout de suite sur ce DC ; l'autre DC l'aura par replication SYSVOL
    gpupdate /force | Out-Null
    Write-Host "Droits de connexion (locale + RDP) accordes a $username sur les controleurs de domaine." -ForegroundColor Green
}

# Demarre et fiabilise les services AD (evite les blocages : service non demarre, heure desynchro)
# function Start-ADServices {
#     foreach ($s in "W32Time","Netlogon","NTDS","ADWS","DNS","Kdc") {
#         Set-Service   -Name $s -StartupType Automatic -ErrorAction SilentlyContinue
#         Start-Service -Name $s -ErrorAction SilentlyContinue
#     }
#     # resynchronise l'heure (Kerberos) pour eviter les blocages / boucles de replication
#     w32tm /resync /force 2>$null
# }
