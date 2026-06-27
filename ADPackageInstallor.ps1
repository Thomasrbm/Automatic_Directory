# ADPackageInstallor.ps1 - Installe AD DS et ses dependances
. "$PSScriptRoot\helpers.ps1"


Test-Admin
# ft windows  (commandlet (verbe + nom))   install une feature windows
# name = quelle fonction, ad - devient controlleur de domaine
# incluede ...  = pour avoir les outils de gestion (booleen), sinon peut rien manager
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
