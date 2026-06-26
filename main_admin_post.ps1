# =============================================================
# main_admin_post.ps1
# Description : Script principal POST-REBOOT pour le SERVEUR ADMINISTRATEUR
#               A lancer apres le redemarrage suivant la creation de la foret
#               1. Cree le compte administrateur
#               2. Cree les dossiers partages (admin + generique)
#               3. Configure les permissions NTFS et SMB pour l'utilisateur cree
# =============================================================

# recup les ft
$ScriptDir = "$PSScriptRoot"
. "$ScriptDir\helpers.ps1"
Test-Admin

Write-Host "Reponds aux fenetres popup au fur et a mesure (Alt+Tab si elles sont cachees)." -ForegroundColor Cyan

# Etape 1 : Configuration des forwarders DNS (resolution des noms externes -> internet)
# Le DC est serveur DNS pour tout le domaine. Sans forwarder il ne resout pas
# les noms publics (google.com...), ce qui donne l'impression de "plus d'internet".
$Forwarder = Get-Input "DNS forwarder externe (DNS de l'ecole ou public, ex: 8.8.8.8)" "DNS Forwarder" "8.8.8.8"
Add-DnsServerForwarder -IPAddress $Forwarder -ErrorAction SilentlyContinue

# Etape 2 : Creation du compte administrateur
& "$ScriptDir\UserCreation.ps1"

# Recuperation du login cree (prenom.nom) et du domaine
$UserLogin = Get-Input "Entrez le login du compte venant d'etre cree (ex: admin.test)" "Login cree" "admin.test"
$Account   = "$((Get-ADDomain).NetBIOSName)\$UserLogin"

# Etape 3 & 4 : Dossiers partages + permissions SMB/NTFS (via le helper New-WorkFolder)
$AdminFolder   = Get-Input "Chemin du dossier administratif" "Dossier admin" "C:\AdminFiles"
$GenericFolder = Get-Input "Chemin du dossier generique" "Dossier generique" "C:\GenericFiles"
New-WorkFolder $AdminFolder   "AdminFiles"   $Account
New-WorkFolder $GenericFolder "GenericFiles" $Account
