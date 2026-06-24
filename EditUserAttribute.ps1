# EditUserAttribute.ps1 - Modifie un attribut d'un utilisateur AD
# Parametres : AccountName, AttributeName, DesiredValue
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$User  = Get-Input "Nom du compte utilisateur" "Compte" "admin.test"
Assert-UserExists $User
$Attr  = Get-Input "Attribut a modifier (ex: Title, Department)" "Attribut" "Title"
$Value = Get-Input "Nouvelle valeur pour '$Attr'" "Valeur" "Administrateur"
Set-ADUser -Identity $User -Replace @{ $Attr = $Value }
Write-Host "Attribut '$Attr' de $User mis a jour avec '$Value'." -ForegroundColor Green

# --- VERIFICATION : on relit l'attribut sur le compte pour prouver la valeur ---
Write-Host "`n[VERIFICATION] Valeur actuelle de '$Attr' sur le compte :" -ForegroundColor Cyan
Get-ADUser -Identity $User -Properties $Attr | Select-Object SamAccountName, $Attr | Format-List
