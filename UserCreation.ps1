# UserCreation.ps1 - Cree un utilisateur AD
# Parametres : AccountName, OrganisationUnit, DesiredGroup
# Email : prenom.nom@domaine.com | UPN : email | MDP par defaut non stocke en clair
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$First  = Get-Input "Prenom" "Prenom"
$Last   = Get-Input "Nom de famille" "Nom"
$OU     = Get-Input "Organizational Unit (ex: CN=Users,DC=domolia,DC=local)" "OU"
$Group  = Get-OptionalInput "Groupe a rejoindre (optionnel)" "Groupe"
$Login  = "$($First.ToLower()).$($Last.ToLower())"
$Domain = (Get-ADDomain).DNSRoot
$Email  = "$Login@$Domain"
# Mot de passe par defaut encode (TotalyN0tSecure) - non stocke en clair
$Pass   = ConvertTo-SecureString ([System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String("VABvAHQAYQBsAHkATgAwAHQAUwBlAGMAdQByAGUA"))) -AsPlainText -Force
New-ADUser -SamAccountName $Login -GivenName $First -Surname $Last -Name "$First $Last" -DisplayName "$First $Last" -EmailAddress $Email -UserPrincipalName $Email -AccountPassword $Pass -ChangePasswordAtLogon $true -Enabled $true -Path $OU
Write-Host "Utilisateur $Login cree." -ForegroundColor Green
if ($Group) { Add-ADGroupMember -Identity $Group -Members $Login; Write-Host "Ajoute au groupe $Group." -ForegroundColor Green }
