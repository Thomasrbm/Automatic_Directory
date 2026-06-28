# ResetUserPassword.ps1 - Reinitialise le mot de passe d'un utilisateur AD
# Parametres : AccountName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$User = Get-Input "Nom du compte utilisateur" "Compte" "admin.test"
Assert-UserExists $User
$Pass = Read-Host "Nouveau mot de passe pour $User" -AsSecureString

# --- AVANT : etat du mot de passe avant la reinitialisation (preuve visuelle) ---
Write-Host "`n[AVANT] Etat du mot de passe avant reset :" -ForegroundColor Cyan
Get-ADUser -Identity $User -Properties PasswordLastSet, pwdLastSet |
    Select-Object SamAccountName, PasswordLastSet,
        @{ Name = "DoitChangerAuLogon"; Expression = { $_.pwdLastSet -eq 0 } } | Format-List

Set-ADAccountPassword -Identity $User -NewPassword $Pass -Reset
# On laisse le mot de passe utilisable directement (pas de changement force au logon)
# -> permet de se connecter avec le nouveau mdp pour prouver le changement (le NLA
#    bloquerait une connexion RDP si on forcait le changement au 1er logon).
Set-ADUser -Identity $User -ChangePasswordAtLogon $false
Write-Host "Mot de passe de $User reinitialise (utilisable immediatement)." -ForegroundColor Green

# --- APRES : on relit l'etat du mot de passe (on ne peut pas afficher le mdp) ---
# PasswordLastSet mis a jour (date recente) => le mot de passe a bien ete reinitialise
Write-Host "`n[APRES] Etat du mot de passe du compte :" -ForegroundColor Cyan
Get-ADUser -Identity $User -Properties PasswordLastSet, pwdLastSet |
    Select-Object SamAccountName, PasswordLastSet,
        @{ Name = "DoitChangerAuLogon"; Expression = { $_.pwdLastSet -eq 0 } } | Format-List
