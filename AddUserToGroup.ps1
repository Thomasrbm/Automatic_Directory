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

# --- VERIFICATION : '$User' apparait-il bien dans la liste des membres ? ---
Write-Host "`n[VERIFICATION] Presence de '$User' dans '$Group' :" -ForegroundColor Cyan
if (Get-ADGroupMember -Identity $Group | Where-Object SamAccountName -eq $User) {
    Write-Host "OK : '$User' est bien membre de '$Group'." -ForegroundColor Green
} else {
    Write-Host "ECHEC : '$User' n'apparait pas dans '$Group'." -ForegroundColor Red
}
