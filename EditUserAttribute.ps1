# EditUserAttribute.ps1 - Modifie un attribut d'un utilisateur AD
# Parametres : AccountName, AttributeName, DesiredValue
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$User  = Get-Input "Nom du compte utilisateur" "Compte"
Assert-UserExists $User
$Attr  = Get-Input "Attribut a modifier (ex: Title, Department)" "Attribut"
$Value = Get-Input "Nouvelle valeur pour '$Attr'" "Valeur"
Set-ADUser -Identity $User -Replace @{ $Attr = $Value }
Write-Host "Attribut '$Attr' de $User mis a jour avec '$Value'." -ForegroundColor Green
