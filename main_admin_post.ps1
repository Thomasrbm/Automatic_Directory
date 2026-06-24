# =============================================================
# main_admin_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR ADMINISTRATEUR
#               A lancer apres le redemarrage suivant la creation de la foret
#               1. Cree le compte administrateur
#               2. Cree les dossiers partages (admin + generique)
#               3. Configure les permissions NTFS et SMB pour l'utilisateur cree
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$ScriptDir = "$PSScriptRoot"

Write-Host "=== CONFIGURATION POST-REBOOT SERVEUR ADMINISTRATEUR ===" -ForegroundColor Cyan

# Etape 1 : Creation du compte administrateur
Write-Host "`n[1/3] Creation du compte administrateur..." -ForegroundColor Yellow
& "$ScriptDir\UserCreation.ps1"

# Recuperation du login cree (prenom.nom)
$UserLogin = Get-Input "Entrez le login du compte venant d'etre cree (ex: admin.test)" "Login cree"
$Domain = (Get-ADDomain).NetBIOSName

# Etape 2 : Creation des dossiers partages
Write-Host "`n[2/3] Creation des dossiers partages..." -ForegroundColor Yellow

# Dossier administratif
$AdminFolder = Get-Input "Chemin du dossier administratif" "Dossier admin" "C:\AdminFiles"
New-Item -ItemType Directory -Path $AdminFolder -Force | Out-Null
# Partage SMB avec l'utilisateur cree directement
New-SmbShare -Name "AdminFiles" -Path $AdminFolder -FullAccess "$Domain\$UserLogin" -ErrorAction SilentlyContinue
Write-Host "Dossier admin cree et partage : $AdminFolder" -ForegroundColor Green

# Dossier generique
$GenericFolder = Get-Input "Chemin du dossier generique" "Dossier generique" "C:\GenericFiles"
New-Item -ItemType Directory -Path $GenericFolder -Force | Out-Null
New-SmbShare -Name "GenericFiles" -Path $GenericFolder -FullAccess "$Domain\$UserLogin" -ErrorAction SilentlyContinue
Write-Host "Dossier generique cree et partage : $GenericFolder" -ForegroundColor Green

# Etape 3 : Permissions NTFS pour l'utilisateur cree
Write-Host "`n[3/3] Configuration des permissions NTFS pour $UserLogin..." -ForegroundColor Yellow

# Permissions sur AdminFiles (lecture + modification)
$Acl = Get-Acl $AdminFolder
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$Domain\$UserLogin","Modify","ContainerInherit,ObjectInherit","None","Allow")
$Acl.SetAccessRule($Rule)
Set-Acl $AdminFolder $Acl
Write-Host "Permissions AdminFiles configurees pour $UserLogin." -ForegroundColor Green

# Permissions sur GenericFiles (lecture + modification)
$Acl = Get-Acl $GenericFolder
$Acl.SetAccessRule($Rule)
Set-Acl $GenericFolder $Acl
Write-Host "Permissions GenericFiles configurees pour $UserLogin." -ForegroundColor Green

Write-Host "`n=== SERVEUR ADMINISTRATEUR CONFIGURE ===" -ForegroundColor Green