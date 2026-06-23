# ResetUserPassword.ps1 - Reinitialise le mot de passe d'un utilisateur AD
# Parametres : AccountName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$User = Get-Input "Nom du compte utilisateur" "Compte"
Assert-UserExists $User
$Pass = Read-Host "Nouveau mot de passe pour $User" -AsSecureString
Set-ADAccountPassword -Identity $User -NewPassword $Pass -Reset
Set-ADUser -Identity $User -ChangePasswordAtLogon $true
Write-Host "Mot de passe de $User reinitialise." -ForegroundColor Green
