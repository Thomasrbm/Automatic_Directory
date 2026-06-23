# LoadDataBase.ps1 - Charge une base de donnees depuis un fichier CSV
# Parametres : Path, Delimiter
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Path      = Get-Input "Chemin du fichier CSV a charger" "Chemin" "C:\AD_Backup.csv"
if (-not (Test-Path $Path)) { Write-Host "Fichier introuvable." -ForegroundColor Red; exit }
$Delimiter = Get-Input "Delimiteur CSV" "Delimiteur" ";"
$Password  = Read-Host "Mot de passe par defaut pour les utilisateurs importes" -AsSecureString
Import-Csv -Path $Path -Delimiter $Delimiter | ForEach-Object {
    if (Get-ADUser -Filter { SamAccountName -eq $_.SamAccountName } -ErrorAction SilentlyContinue) {
        Write-Host "$($_.SamAccountName) existe deja, ignore." -ForegroundColor Yellow
    } else {
        New-ADUser -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.Surname -EmailAddress $_.EmailAddress -AccountPassword $Password -Enabled $true -ChangePasswordAtLogon $true
        Write-Host "$($_.SamAccountName) cree." -ForegroundColor Green
    }
}
