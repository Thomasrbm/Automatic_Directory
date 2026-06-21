# ModifyGroup.ps1 - Modifie un attribut d'un groupe AD
# Parametres : GroupName, AttributeName, NewValue
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Group = Get-Input "Nom du groupe" "Groupe"
Assert-GroupExists $Group
$Attr  = Get-Input "Attribut a modifier (ex: Description, DisplayName)" "Attribut"
$Value = Get-Input "Nouvelle valeur pour '$Attr'" "Valeur"
Set-ADGroup -Identity $Group -Replace @{ $Attr = $Value }
Write-Host "Attribut '$Attr' du groupe '$Group' mis a jour." -ForegroundColor Green
