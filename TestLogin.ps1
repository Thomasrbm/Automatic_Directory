# =============================================================
# TestLogin.ps1
# Description : Teste un couple login / mot de passe DIRECTEMENT dans l'AD,
#               sans passer par RDP/Remmina. Permet d'isoler le probleme :
#               soit le compte/mdp est mauvais, soit c'est la config Remmina.
#               A lancer sur un DC.
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

$Login = Get-Input "Login a tester (ex: user.admin)" "Login" "user.admin"
$Pass  = Get-Input "Mot de passe a tester" "Mot de passe" "Bonjour123**"

$Dom = (Get-ADDomain).DNSRoot
$ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Domain', $Dom)
$ok  = $ctx.ValidateCredentials($Login, $Pass)

if ($ok) {
    Write-Host "OK : '$Login' / mot de passe est VALIDE cote AD." -ForegroundColor Green
    Write-Host "=> Le compte est bon. Le blocage est dans REMMINA (champ Domain a remplir : DOMOLIA)." -ForegroundColor Green
} else {
    Write-Host "ECHEC : mot de passe REFUSE pour '$Login'." -ForegroundColor Red
    Write-Host "=> Relance FixRdpUser.ps1 pour redefinir le mot de passe." -ForegroundColor Red
}
