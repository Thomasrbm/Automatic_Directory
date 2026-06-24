# =============================================================
# main_workshop_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR WORKSHOP
#               A lancer apres le redemarrage suivant le join de la foret
#               1. Cree le compte worker
#               2. Cree le dossier partage workshop
#               3. Configure les permissions NTFS et SMB pour l'utilisateur cree
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$ScriptDir = "$PSScriptRoot"

Write-Host "=== CONFIGURATION POST-REBOOT SERVEUR WORKSHOP ===" -ForegroundColor Cyan

# Etape 1 : Creation du compte worker
Write-Host "`n[1/3] Creation du compte worker..." -ForegroundColor Yellow
& "$ScriptDir\UserCreation.ps1"

# Recuperation du login cree (prenom.nom)
$UserLogin = Get-Input "Entrez le login du compte venant d'etre cree (ex: john.doe)" "Login cree"
$Domain = (Get-ADDomain).NetBIOSName

# Etape 2 : Creation du dossier partage workshop
Write-Host "`n[2/3] Creation du dossier workshop..." -ForegroundColor Yellow

$WorkshopFolder = Get-Input "Chemin du dossier workshop" "Dossier workshop" "C:\WorkshopFiles"
New-Item -ItemType Directory -Path $WorkshopFolder -Force | Out-Null
# Partage SMB avec l'utilisateur cree directement
New-SmbShare -Name "WorkshopFiles" -Path $WorkshopFolder -FullAccess "$Domain\$UserLogin" -ErrorAction SilentlyContinue
Write-Host "Dossier workshop cree et partage : $WorkshopFolder" -ForegroundColor Green

# Etape 3 : Permissions NTFS pour l'utilisateur cree
Write-Host "`n[3/3] Configuration des permissions NTFS pour $UserLogin..." -ForegroundColor Yellow

# Permissions sur WorkshopFiles (lecture + modification)
$Acl = Get-Acl $WorkshopFolder
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$Domain\$UserLogin","Modify","ContainerInherit,ObjectInherit","None","Allow")
$Acl.SetAccessRule($Rule)
Set-Acl $WorkshopFolder $Acl
Write-Host "Permissions WorkshopFiles configurees pour $UserLogin." -ForegroundColor Green

# Acces au dossier generique sur le serveur admin
Write-Host "`nConfiguration acces dossier generique sur SRV-ADMIN..." -ForegroundColor Yellow
$SrvAdminIP = Get-Input "IP du SRV-ADMIN (ex: 10.12.200.163)" "IP SRV-ADMIN"
Write-Host "Le dossier generique est accessible via : \\$SrvAdminIP\GenericFiles" -ForegroundColor Cyan
Write-Host "L'administrateur SRV-ADMIN doit ajouter $UserLogin aux permissions de GenericFiles." -ForegroundColor Yellow

Write-Host "`n=== SERVEUR WORKSHOP CONFIGURE ===" -ForegroundColor Green