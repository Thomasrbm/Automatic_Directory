# SaveDataBase.ps1 - Sauvegarde les utilisateurs et groupes AD en CSV
# Parametres : Path, Delimiter, proprietes supplementaires (optionnel)
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Path      = Get-Input "Chemin du fichier CSV de sortie" "Chemin" "C:\AD_Backup.csv"
$Delimiter = Get-Input "Delimiteur CSV" "Delimiteur" ";"
$Extra     = Get-OptionalInput "Proprietes supplementaires separees par des virgules (optionnel)" "Proprietes"
$Props     = @("SamAccountName","GivenName","Surname","EmailAddress","Enabled","DistinguishedName")
if ($Extra) { $Props += ($Extra -split "," | ForEach-Object { $_.Trim() }) }
Get-ADUser -Filter * -Properties $Props | Select-Object $Props | Export-Csv -Path $Path -Delimiter $Delimiter -NoTypeInformation -Encoding UTF8
Get-ADGroup -Filter * -Properties Name,GroupScope,GroupCategory,Description | Select-Object Name,GroupScope,GroupCategory,Description | Export-Csv -Path ($Path -replace "\.csv","_groups.csv") -Delimiter $Delimiter -NoTypeInformation -Encoding UTF8
Write-Host "Sauvegarde terminee : $Path" -ForegroundColor Green
