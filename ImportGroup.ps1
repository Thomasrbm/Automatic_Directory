# ImportGroup.ps1 - Importe les membres d'un groupe dans un autre
# Parametres : OriginGroupName, DestinationGroupName
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Origin = Get-Input "Groupe source (dont importer les membres)" "Groupe source"
Assert-GroupExists $Origin
$Dest   = Get-Input "Groupe de destination" "Groupe destination"
Assert-GroupExists $Dest
$Members = Get-ADGroupMember -Identity $Origin
if ($Members.Count -eq 0) { Write-Host "Aucun membre dans '$Origin'." -ForegroundColor Yellow; exit }
$Members | ForEach-Object {
    try { Add-ADGroupMember -Identity $Dest -Members $_.SamAccountName; Write-Host "$($_.SamAccountName) ajoute." -ForegroundColor Green }
    catch { Write-Host "$($_.SamAccountName) deja present ou erreur." -ForegroundColor Yellow }
}
Write-Host "Importation terminee : $($Members.Count) membres traites." -ForegroundColor Green
