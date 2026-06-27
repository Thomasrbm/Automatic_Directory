# =============================================================
# AllowUserLogonOnDC.ps1
# Description : Autorise un utilisateur de domaine NON-admin a ouvrir une
#               session sur les controleurs de domaine (locale + Bureau a
#               distance / RDP). Logique dans le helper Grant-DCLogon.
#               La GPO se replique par SYSVOL : a lancer UNE fois sur un DC.
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin

# Login de l'utilisateur a autoriser (doit deja exister dans l'AD)
$Login = Get-Input "Login de l'utilisateur a autoriser sur les DC (ex: admin.worker)" "Login" "admin.worker"
Grant-DCLogon $Login
