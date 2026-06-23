# CreateDistributionGroup.ps1 - Cree un groupe de distribution AD
# Parametres : GroupName, OrganisationUnit, GroupScope, Description
. "$PSScriptRoot\helpers.ps1"
Test-Admin
$Name  = Get-Input "Nom du groupe de distribution" "Groupe"
$OU    = Get-Input "Organizational Unit (ex: OU=Workshop,DC=domolia,DC=local)" "OU"
$Scope = Get-Input "Etendue (Global, Universal, DomainLocal)" "Scope" "Universal"
$Desc  = Get-OptionalInput "Description du groupe" "Description"
New-ADGroup -Name $Name -GroupScope $Scope -GroupCategory Distribution -Path $OU -Description $Desc
Write-Host "Groupe de distribution '$Name' cree." -ForegroundColor Green
