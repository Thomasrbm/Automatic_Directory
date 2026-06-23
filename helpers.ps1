# =============================================================
# helpers.ps1
# Description : Fonctions utilitaires communes a tous les scripts AD
#               A inclure avec : . "$PSScriptRoot\helpers.ps1"
# =============================================================

# Chargement de l'assembly pour les popups
Add-Type -AssemblyName Microsoft.VisualBasic

# Verifie que le script est lance en tant qu'administrateur
function Test-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Droits administrateur requis." -ForegroundColor Red
        exit
    }
}

# Affiche un popup et retourne la valeur saisie (obligatoire)
function Get-Input($message, $title, $default = "") {
    $result = [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, $default)
    if ([string]::IsNullOrWhiteSpace($result)) {
        Write-Host "Champ '$title' requis. Abandon." -ForegroundColor Red
        exit
    }
    return $result
}

# Affiche un popup et retourne la valeur saisie (optionnelle)
function Get-OptionalInput($message, $title, $default = "") {
    return [Microsoft.VisualBasic.Interaction]::InputBox($message, $title, $default)
}

# Verifie qu'un utilisateur AD existe, quitte sinon
function Assert-UserExists($username) {
    if (-not (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue)) {
        Write-Host "Utilisateur '$username' introuvable. Operation bloquee." -ForegroundColor Red
        exit
    }
}

# Verifie qu'un groupe AD existe, quitte sinon
function Assert-GroupExists($groupname) {
    if (-not (Get-ADGroup -Filter { Name -eq $groupname } -ErrorAction SilentlyContinue)) {
        Write-Host "Groupe '$groupname' introuvable. Operation bloquee." -ForegroundColor Red
        exit
    }
}
