# AddUserToGroup.ps1 - Ajoute un utilisateur a un groupe AD
# Bloque si l'utilisateur est inconnu
# Parametres : UserName, GroupName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$User  = Get-Input "Nom du compte utilisateur a ajouter" "Utilisateur" "admin.test"
Assert-UserExists $User
$Group = Get-Input "Nom du groupe" "Groupe" "IT"
Assert-GroupExists $Group
Add-ADGroupMember -Identity $Group -Members $User
Write-Host "'$User' ajoute au groupe '$Group'." -ForegroundColor Green
