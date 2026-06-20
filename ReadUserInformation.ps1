# ReadUserInformation.ps1 - Recupere les informations d'un utilisateur AD
# Parametres : AccountName, Filter (optionnel)
. "$PSScriptRoot\helpers.ps1"
$User   = Get-Input "Nom du compte utilisateur" "Compte"
Assert-UserExists $User
$Filter = Get-OptionalInput "Attributs a recuperer separes par virgules (vide = tout)" "Filtre"
if ($Filter) {
    $Props = $Filter -split "," | ForEach-Object { $_.Trim() }
    Get-ADUser -Identity $User -Properties $Props | Select-Object $Props | Format-List
} else {
    Get-ADUser -Identity $User -Properties * | Format-List
}
