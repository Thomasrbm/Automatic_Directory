# LoadDataBase.ps1 - Charge une base de donnees depuis un fichier CSV
# Parametres : Path, Delimiter

. "$PSScriptRoot\helpers.ps1"

Test-Admin

$Path      = Get-Input "Chemin du fichier CSV a charger" "Chemin" "C:\AD_Backup.csv"

if (-not (Test-Path $Path)) { Write-Host "Fichier introuvable." -ForegroundColor Red; exit }


$Delimiter = Get-Input "Delimiteur CSV" "Delimiteur" ";"
$Password  = Read-Host "Mot de passe par defaut pour les utilisateurs importes" -AsSecureString

# sera mdp par defaut pour tous 


Import-Csv -Path $Path -Delimiter $Delimiter | ForEach-Object {
    # si exsite deja 
    if (Get-ADUser -Filter { SamAccountName -eq $_.SamAccountName } -ErrorAction SilentlyContinue) {
        Write-Host "$($_.SamAccountName) existe deja, ignore." -ForegroundColor Yellow
    } else {
        # Splatting : parametres regroupes dans un hashtable pour la lisibilite
        $UserParams = @{
            SamAccountName        = $_.SamAccountName
            GivenName             = $_.GivenName
            Surname               = $_.Surname
            EmailAddress          = $_.EmailAddress
            AccountPassword       = $Password
            Enabled               = $true
            ChangePasswordAtLogon = $true
        }
        New-ADUser @UserParams
        Write-Host "$($_.SamAccountName) cree." -ForegroundColor Green
    }
}



# --- VERIFICATION : combien de comptes du CSV sont effectivement presents dans AD ? ---
Write-Host "`n[VERIFICATION] Comptes du CSV presents dans AD :" -ForegroundColor Cyan
$total = 0; $ok = 0
Import-Csv -Path $Path -Delimiter $Delimiter | ForEach-Object {
    $total++
    # ajoute que ceux dans ok si present.
    if (Get-ADUser -Filter { SamAccountName -eq $_.SamAccountName } -ErrorAction SilentlyContinue) { $ok++ }
}


Write-Host "$ok / $total comptes du fichier sont presents dans AD." -ForegroundColor Green
