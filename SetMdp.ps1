# =============================================================
# SetMdp.ps1
# Description : Definit un mot de passe connu pour un utilisateur et
#               desactive l'obligation de le changer a la connexion.
#               Evite le blocage RDP/NLA (un compte "doit changer son mdp"
#               ne peut pas s'authentifier via NLA -> Remmina coupe la co).
#               A lancer sur un DC (ex: SRV-ADMIN).
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin

# Utilisateur cible (doit deja exister dans l'AD)
$Login = Get-Input "Login de l'utilisateur (ex: user.admin)" "Login" "user.admin"
Assert-UserExists $Login

# Nouveau mot de passe : sans symbole = pas de souci de clavier AZERTY/QWERTY en RDP
$Pass = Get-Input "Nouveau mot de passe (majuscule + minuscules + chiffres)" "Mot de passe" "Bonjour123**"

# Reinitialise le mot de passe et enleve le changement force a la connexion
Set-ADAccountPassword -Identity $Login -Reset -NewPassword (ConvertTo-SecureString $Pass -AsPlainText -Force)
Set-ADUser -Identity $Login -ChangePasswordAtLogon $false

Write-Host "Mot de passe defini pour $Login et changement a la connexion desactive." -ForegroundColor Green
