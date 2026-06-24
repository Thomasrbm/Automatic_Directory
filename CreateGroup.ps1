# CreateGroup.ps1 - Cree un nouveau groupe de securite AD
# Parametres : GroupName, OrganisationUnit, GroupScope, Description
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Name  = Get-Input "Nom du groupe" "Groupe"
$OU    = Get-Input "Organizational Unit (ex: CN=Users,DC=domolia,DC=local)" "OU"
$Scope = Get-Input "Etendue (Global, Universal, DomainLocal)" "Scope" "Global"
$Desc  = Get-OptionalInput "Description du groupe" "Description"
New-ADGroup -Name $Name -GroupScope $Scope -GroupCategory Security -Path $OU -Description $Desc
Write-Host "Groupe '$Name' cree." -ForegroundColor Green
