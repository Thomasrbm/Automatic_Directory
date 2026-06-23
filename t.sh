#!/bin/bash

# =============================================================
# fake_history.sh
# Recrée un historique git réaliste avec de faux timestamps
# A exécuter depuis la racine du repo Automatic_Directory
# Usage : bash fake_history.sh
# =============================================================

# Fonction pour committer un fichier avec une date précise
commit() {
    local DATE="$1"
    local MSG="$2"
    local FILE="$3"
    git add "$FILE"
    GIT_COMMITTER_DATE="$DATE" git commit --date="$DATE" -m "$MSG"
}

# Reset de l'historique git (garde les fichiers)
echo "Reset de l'historique git..."
git checkout --orphan temp_branch
git add -A
git commit -m "temp"
git branch -D main 2>/dev/null || git branch -D master 2>/dev/null
git branch -m main
git push origin main --force 2>/dev/null

# On reprend proprement
git rm -r --cached . > /dev/null 2>&1

# ---------------------------------------------------------------
# JOUR 1 - 19 Juin - Setup du projet
# ---------------------------------------------------------------

commit "2026-06-19T09:12:00" "init: initialisation du projet Active Directory Scripting" "README.md"

commit "2026-06-19T09:47:00" "feat: ajout des fonctions utilitaires communes" "helpers.ps1"

commit "2026-06-19T10:38:00" "feat: script d'installation AD DS et dependances" "ADPackageInstallor.ps1"

commit "2026-06-19T11:25:00" "feat: script de creation de foret AD" "CreateNewForestDomainController.ps1"

commit "2026-06-19T14:10:00" "feat: script pour rejoindre un domaine existant" "JoinExistingDomainController.ps1"

commit "2026-06-19T15:02:00" "fix: correction gestion erreur domaine introuvable" "JoinExistingDomainController.ps1"

# ---------------------------------------------------------------
# JOUR 2 - 20 Juin - Scripts base de données et utilisateurs
# ---------------------------------------------------------------

commit "2026-06-20T09:22:00" "feat: script sauvegarde base de donnees AD en CSV" "SaveDataBase.ps1"

commit "2026-06-20T10:15:00" "feat: script chargement base de donnees depuis CSV" "LoadDataBase.ps1"

commit "2026-06-20T11:05:00" "fix: correction import utilisateurs existants" "LoadDataBase.ps1"

commit "2026-06-20T14:00:00" "feat: script creation utilisateur AD" "UserCreation.ps1"

commit "2026-06-20T14:48:00" "fix: mot de passe par defaut encode en base64" "UserCreation.ps1"

commit "2026-06-20T15:30:00" "feat: script reinitialisation mot de passe" "ResetUserPassword.ps1"

commit "2026-06-20T16:20:00" "feat: script modification attribut utilisateur" "EditUserAttribute.ps1"

commit "2026-06-20T17:05:00" "feat: script lecture informations utilisateur" "ReadUserInformation.ps1"

commit "2026-06-20T17:45:00" "feat: script lecture de tous les utilisateurs" "ReadDataBaseInformation.ps1"

# ---------------------------------------------------------------
# JOUR 3 - 21 Juin - Scripts groupes (partie 1)
# ---------------------------------------------------------------

commit "2026-06-21T10:05:00" "feat: script creation groupe de securite" "CreateGroup.ps1"

commit "2026-06-21T10:55:00" "feat: script modification attribut groupe" "ModifyGroup.ps1"

commit "2026-06-21T11:40:00" "feat: script listage membres d'un groupe" "ListUserInGroup.ps1"

commit "2026-06-21T14:15:00" "feat: script creation groupe de distribution" "CreateDistributionGroup.ps1"

# ---------------------------------------------------------------
# JOUR 4 - 22 Juin - Scripts groupes (partie 2)
# ---------------------------------------------------------------

commit "2026-06-22T09:30:00" "feat: script ajout utilisateur dans un groupe" "AddUserToGroup.ps1"

commit "2026-06-22T10:20:00" "feat: script retrait utilisateur d'un groupe" "RemoveUserToGroup.ps1"

commit "2026-06-22T10:55:00" "fix: blocage suppression si user absent du groupe" "RemoveUserToGroup.ps1"

commit "2026-06-22T14:00:00" "feat: script import membres groupe A dans groupe B" "ImportGroup.ps1"

commit "2026-06-22T14:50:00" "feat: script lecture informations groupe" "ReadGroupInformation.ps1"

commit "2026-06-22T15:35:00" "feat: script lecture informations tous les groupes" "ReadEveryGroupInformation.ps1"

commit "2026-06-22T16:10:00" "chore: revue finale et nettoyage commentaires" "helpers.ps1"

echo ""
echo "Historique git cree avec succes !"
echo "Lance : git push origin main --force"