# =============================================================
# DiagRdp.ps1
# Description : Diagnostic du droit RDP pour un utilisateur sur ce DC.
#               Compare ce que la GPO DIT (GptTmpl.inf) avec ce qui est
#               reellement APPLIQUE (export secedit). A lancer sur le DC.
# =============================================================
. "$PSScriptRoot\helpers.ps1"
Test-Admin

$Login = Get-Input "Login a diagnostiquer (ex: user.admin)" "Login" "user.admin"
$sid   = (Get-ADUser $Login).SID.Value
$Dom   = (Get-ADDomain).DNSRoot
$Guid  = "{6AC1786C-016F-11D2-945F-00C04fB984F9}"
$Inf   = "\\$Dom\SYSVOL\$Dom\Policies\$Guid\MACHINE\Microsoft\Windows NT\SecEdit\GptTmpl.inf"
$Gpt   = "\\$Dom\SYSVOL\$Dom\Policies\$Guid\GPT.ini"

Write-Host "`n=== SID de $Login ===" -ForegroundColor Cyan
Write-Host $sid

Write-Host "`n=== Version GPO (GPT.ini) ===" -ForegroundColor Cyan
(Get-Content $Gpt | Where-Object { $_ -match '^Version=' })

Write-Host "`n=== Ce que la GPO DIT (GptTmpl.inf) ===" -ForegroundColor Cyan
Select-String "SeRemoteInteractiveLogonRight|SeInteractiveLogonRight" $Inf | ForEach-Object { $_.Line }

Write-Host "`n=== Ce qui est APPLIQUE sur ce serveur (secedit) ===" -ForegroundColor Cyan
secedit /export /cfg C:\c.cfg /quiet
Select-String "SeRemoteInteractiveLogonRight|SeInteractiveLogonRight" C:\c.cfg | ForEach-Object { $_.Line }

Write-Host "`n--- Le SID doit apparaitre dans les 2 dernieres sections ---" -ForegroundColor Yellow
