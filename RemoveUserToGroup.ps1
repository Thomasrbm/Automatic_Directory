# RemoveUserToGroup.ps1 - Retire un utilisateur d'un groupe AD
# Bloque si l'utilisateur est inconnu ou pas dans le groupe
# Parametres : UserName, GroupName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$User  = Get-Input "Nom du compte utilisateur a retirer" "Utilisateur"
Assert-UserExists $User
$Group = Get-Input "Nom du groupe" "Groupe"
Assert-GroupExists $Group
$Members = Get-ADGroupMember -Identity $Group | Select-Object -ExpandProperty SamAccountName
if ($Members -notcontains $User) { Write-Host "'$User' n'est pas dans le groupe '$Group'. Operation bloquee." -ForegroundColor Red; exit }
Remove-ADGroupMember -Identity $Group -Members $User -Confirm:$false
Write-Host "'$User' retire du groupe '$Group'." -ForegroundColor Green
