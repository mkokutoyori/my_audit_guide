<#
.SYNOPSIS
    Script d'Audit de Sécurité pour Windows Server 2022
    Version 2.0 - Style "From Zero to Hero"

.DESCRIPTION
    Ce script audite automatiquement la sécurité d'un serveur Windows Server 2022
    selon les recommandations du CIS Benchmark, Microsoft Security Baseline, et ANSSI.

    Il génère un rapport détaillé avec un score de sécurité global.

.NOTES
    Auteur: Script d'Audit Automatisé
    Version: 2.0
    Date: 2025
    Nécessite: PowerShell 5.1+ et droits Administrateur

.EXAMPLE
    .\audit-windows-server-2022.ps1

.EXAMPLE
    .\audit-windows-server-2022.ps1 -OutputFile "C:\audit-report.txt"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = ".\audit-windows-server-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
)

# Vérification des droits administrateur
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ ERREUR : Ce script doit être exécuté en tant qu'Administrateur !" -ForegroundColor Red
    Write-Host ""
    Write-Host "Comment faire :" -ForegroundColor Yellow
    Write-Host "1. Fais un clic droit sur PowerShell" -ForegroundColor Cyan
    Write-Host "2. Choisis 'Exécuter en tant qu'administrateur'" -ForegroundColor Cyan
    Write-Host "3. Relance ce script" -ForegroundColor Cyan
    exit 1
}

# Variables globales
$script:TotalChecks = 0
$script:PassedChecks = 0
$script:FailedChecks = 0
$script:WarningChecks = 0
$script:Results = @()

# Fonction pour écrire dans le rapport
function Write-Report {
    param(
        [string]$Message,
        [string]$Color = "White"
    )

    $Message | Out-File -FilePath $OutputFile -Append -Encoding UTF8
    Write-Host $Message -ForegroundColor $Color
}

# Fonction pour effectuer un check
function Invoke-Check {
    param(
        [string]$Name,
        [scriptblock]$Check,
        [string]$Expected,
        [string]$Severity = "HIGH" # HIGH, MEDIUM, LOW
    )

    $script:TotalChecks++

    try {
        $result = & $Check
        $status = ""
        $color = "White"

        if ($result -eq $true) {
            $script:PassedChecks++
            $status = "✅ PASS"
            $color = "Green"
        } elseif ($result -eq "WARNING") {
            $script:WarningChecks++
            $status = "⚠️  WARN"
            $color = "Yellow"
        } else {
            $script:FailedChecks++
            $status = "❌ FAIL"
            $color = "Red"
        }

        $checkResult = [PSCustomObject]@{
            Name = $Name
            Status = $status
            Expected = $Expected
            Severity = $Severity
        }

        $script:Results += $checkResult

        Write-Host "$status - $Name" -ForegroundColor $color
        "$status - $Name" | Out-File -FilePath $OutputFile -Append -Encoding UTF8

    } catch {
        $script:FailedChecks++
        Write-Host "❌ FAIL - $Name (Erreur: $($_.Exception.Message))" -ForegroundColor Red
        "❌ FAIL - $Name (Erreur: $($_.Exception.Message))" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
    }
}

# ==============================================================================
# DÉBUT DU SCRIPT D'AUDIT
# ==============================================================================

Clear-Host

Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🪟 AUDIT DE SÉCURITÉ - WINDOWS SERVER 2022" -ForegroundColor Cyan
Write-Host "  Version 2.0 - Style 'From Zero to Hero'" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Initialiser le fichier de rapport
"═══════════════════════════════════════════════════════════════════" | Out-File -FilePath $OutputFile -Encoding UTF8
"  🪟 AUDIT DE SÉCURITÉ - WINDOWS SERVER 2022" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
"  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
"  Serveur: $env:COMPUTERNAME" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
"═══════════════════════════════════════════════════════════════════" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
"" | Out-File -FilePath $OutputFile -Append -Encoding UTF8

Write-Report "🔍 Démarrage de l'audit de sécurité..." "Yellow"
Write-Report "📝 Rapport généré dans: $OutputFile" "Cyan"
Write-Report ""

# ==============================================================================
# PARTIE 1 : MISES À JOUR WINDOWS
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "📦 PARTIE 1 : MISES À JOUR WINDOWS" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 1.1 : Mises à jour récentes installées
Invoke-Check -Name "Mises à jour récentes (< 30 jours)" -Severity "HIGH" -Expected "Au moins une mise à jour installée dans les 30 derniers jours" -Check {
    $recentUpdates = Get-HotFix | Where-Object { $_.InstalledOn -gt (Get-Date).AddDays(-30) }
    if ($recentUpdates) { return $true } else { return $false }
}

# Check 1.2 : Service Windows Update en cours d'exécution
Invoke-Check -Name "Service Windows Update (wuauserv) actif" -Severity "HIGH" -Expected "Service démarré automatiquement" -Check {
    $service = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    if ($service -and $service.StartType -in @('Automatic', 'Manual')) { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 2 : COMPTES UTILISATEURS
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "👤 PARTIE 2 : COMPTES UTILISATEURS" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 2.1 : Longueur minimale du mot de passe >= 14
Invoke-Check -Name "Longueur minimale mot de passe >= 14" -Severity "HIGH" -Expected "MinimumPasswordLength >= 14" -Check {
    $result = net accounts | Select-String "Minimum password length"
    if ($result -match "(\d+)") {
        $length = [int]$matches[1]
        if ($length -ge 14) { return $true } else { return $false }
    } else { return $false }
}

# Check 2.2 : Historique des mots de passe >= 24
Invoke-Check -Name "Historique mots de passe >= 24" -Severity "MEDIUM" -Expected "PasswordHistorySize >= 24" -Check {
    $result = net accounts | Select-String "Length of password history maintained"
    if ($result -match "(\d+)") {
        $history = [int]$matches[1]
        if ($history -ge 24) { return $true } else { return $false }
    } else { return $false }
}

# Check 2.3 : Compte Guest désactivé
Invoke-Check -Name "Compte Guest désactivé" -Severity "HIGH" -Expected "Guest account disabled" -Check {
    $guest = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
    if ($guest -and -not $guest.Enabled) { return $true } else { return $false }
}

# Check 2.4 : Compte Administrator renommé ou désactivé
Invoke-Check -Name "Compte Administrator sécurisé" -Severity "MEDIUM" -Expected "Administrator renommé OU désactivé" -Check {
    $admin = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
    if (-not $admin) {
        return $true # Renommé
    } elseif ($admin -and -not $admin.Enabled) {
        return $true # Désactivé
    } else {
        return $false
    }
}

# Check 2.5 : Seuil de verrouillage de compte configuré
Invoke-Check -Name "Seuil de verrouillage de compte <= 5" -Severity "HIGH" -Expected "Lockout threshold <= 5" -Check {
    $result = net accounts | Select-String "Lockout threshold"
    if ($result -match "(\d+)") {
        $threshold = [int]$matches[1]
        if ($threshold -gt 0 -and $threshold -le 5) { return $true } else { return $false }
    } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 3 : RDP (REMOTE DESKTOP)
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🖥️  PARTIE 3 : RDP (REMOTE DESKTOP)" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 3.1 : NLA (Network Level Authentication) activé
Invoke-Check -Name "NLA (Network Level Authentication) activé" -Severity "HIGH" -Expected "UserAuthentication = 1" -Check {
    $nla = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -ErrorAction SilentlyContinue
    if ($nla -and $nla.UserAuthentication -eq 1) { return $true } else { return $false }
}

# Check 3.2 : Niveau de chiffrement élevé (128-bit)
Invoke-Check -Name "Chiffrement RDP >= 128-bit" -Severity "HIGH" -Expected "MinEncryptionLevel >= 3" -Check {
    $encryption = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel" -ErrorAction SilentlyContinue
    if ($encryption -and $encryption.MinEncryptionLevel -ge 3) { return $true } else { return $false }
}

# Check 3.3 : SSL/TLS forcé (SecurityLayer)
Invoke-Check -Name "SSL/TLS forcé pour RDP" -Severity "HIGH" -Expected "SecurityLayer = 2" -Check {
    $ssl = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -ErrorAction SilentlyContinue
    if ($ssl -and $ssl.SecurityLayer -eq 2) { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 4 : PARE-FEU WINDOWS DEFENDER
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🔥 PARTIE 4 : PARE-FEU WINDOWS DEFENDER" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 4.1 : Pare-feu activé sur tous les profils
Invoke-Check -Name "Pare-feu activé (Domain)" -Severity "HIGH" -Expected "Enabled = True" -Check {
    $fw = Get-NetFirewallProfile -Name Domain
    if ($fw.Enabled -eq $true) { return $true } else { return $false }
}

Invoke-Check -Name "Pare-feu activé (Private)" -Severity "HIGH" -Expected "Enabled = True" -Check {
    $fw = Get-NetFirewallProfile -Name Private
    if ($fw.Enabled -eq $true) { return $true } else { return $false }
}

Invoke-Check -Name "Pare-feu activé (Public)" -Severity "HIGH" -Expected "Enabled = True" -Check {
    $fw = Get-NetFirewallProfile -Name Public
    if ($fw.Enabled -eq $true) { return $true } else { return $false }
}

# Check 4.2 : Politique par défaut (Block inbound, Allow outbound)
Invoke-Check -Name "Politique par défaut - Block Inbound (Public)" -Severity "HIGH" -Expected "DefaultInboundAction = Block" -Check {
    $fw = Get-NetFirewallProfile -Name Public
    if ($fw.DefaultInboundAction -eq 'Block') { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 5 : WINDOWS DEFENDER ANTIVIRUS
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🛡️  PARTIE 5 : WINDOWS DEFENDER ANTIVIRUS" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 5.1 : Windows Defender activé
Invoke-Check -Name "Windows Defender activé" -Severity "HIGH" -Expected "AntivirusEnabled = True" -Check {
    $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($defender -and $defender.AntivirusEnabled -eq $true) { return $true } else { return $false }
}

# Check 5.2 : Protection en temps réel active
Invoke-Check -Name "Protection en temps réel active" -Severity "HIGH" -Expected "RealTimeProtectionEnabled = True" -Check {
    $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($defender -and $defender.RealTimeProtectionEnabled -eq $true) { return $true } else { return $false }
}

# Check 5.3 : Signatures à jour (< 7 jours)
Invoke-Check -Name "Signatures antivirus à jour (< 7 jours)" -Severity "HIGH" -Expected "Dernière mise à jour < 7 jours" -Check {
    $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($defender -and $defender.AntivirusSignatureLastUpdated) {
        $daysSinceUpdate = (Get-Date) - $defender.AntivirusSignatureLastUpdated
        if ($daysSinceUpdate.Days -le 7) { return $true } else { return $false }
    } else { return $false }
}

# Check 5.4 : Cloud Protection activé
Invoke-Check -Name "Cloud Protection (MAPS) activé" -Severity "MEDIUM" -Expected "MAPSReporting = Advanced (2)" -Check {
    $prefs = Get-MpPreference -ErrorAction SilentlyContinue
    if ($prefs -and $prefs.MAPSReporting -eq 2) { return $true } elseif ($prefs -and $prefs.MAPSReporting -eq 1) { return "WARNING" } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 6 : AUDIT ET JOURNALISATION
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "📊 PARTIE 6 : AUDIT ET JOURNALISATION" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 6.1 : Taille du journal Security >= 512 MB
Invoke-Check -Name "Taille journal Security >= 512 MB" -Severity "MEDIUM" -Expected "MaximumSizeInBytes >= 512 MB" -Check {
    $logSize = (Get-WinEvent -ListLog Security).MaximumSizeInBytes
    if ($logSize -ge 512MB) { return $true } else { return $false }
}

# Check 6.2 : Audit des connexions réussies activé
Invoke-Check -Name "Audit Logon - Success activé" -Severity "HIGH" -Expected "Logon Success audit enabled" -Check {
    $audit = auditpol /get /subcategory:"Logon" 2>$null
    if ($audit -match "Success") { return $true } else { return $false }
}

# Check 6.3 : Audit des connexions échouées activé
Invoke-Check -Name "Audit Logon - Failure activé" -Severity "HIGH" -Expected "Logon Failure audit enabled" -Check {
    $audit = auditpol /get /subcategory:"Logon" 2>$null
    if ($audit -match "Failure") { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 7 : SERVICES WINDOWS
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🛠️  PARTIE 7 : SERVICES WINDOWS" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 7.1 : Print Spooler désactivé (si pas d'imprimantes)
Invoke-Check -Name "Print Spooler désactivé (recommandé)" -Severity "HIGH" -Expected "Service Spooler = Disabled" -Check {
    $spooler = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue
    if ($spooler -and $spooler.StartType -eq 'Disabled') { return $true } else { return "WARNING" }
}

# Check 7.2 : Remote Registry désactivé
Invoke-Check -Name "Remote Registry désactivé" -Severity "HIGH" -Expected "RemoteRegistry = Disabled" -Check {
    $remoteReg = Get-Service -Name "RemoteRegistry" -ErrorAction SilentlyContinue
    if ($remoteReg -and $remoteReg.StartType -eq 'Disabled') { return $true } else { return $false }
}

# Check 7.3 : SNMP désactivé (si présent)
Invoke-Check -Name "SNMP désactivé (si installé)" -Severity "MEDIUM" -Expected "SNMP = Disabled ou non installé" -Check {
    $snmp = Get-Service -Name "SNMP" -ErrorAction SilentlyContinue
    if (-not $snmp) { return $true } # Non installé = OK
    if ($snmp.StartType -eq 'Disabled') { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 8 : PARTAGES RÉSEAU (SMB)
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🌐 PARTIE 8 : PARTAGES RÉSEAU (SMB)" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 8.1 : SMBv1 désactivé
Invoke-Check -Name "SMBv1 DÉSACTIVÉ (CRITIQUE)" -Severity "HIGH" -Expected "SMB1Protocol = Disabled" -Check {
    $smb1 = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
    if ($smb1 -and $smb1.State -eq 'Disabled') { return $true } else { return $false }
}

# Check 8.2 : SMB Signing activé et requis
Invoke-Check -Name "SMB Signing requis" -Severity "HIGH" -Expected "RequireSecuritySignature = True" -Check {
    $smbConfig = Get-SmbServerConfiguration
    if ($smbConfig.RequireSecuritySignature -eq $true) { return $true } else { return $false }
}

# Check 8.3 : Chiffrement SMB3 activé
Invoke-Check -Name "Chiffrement SMB3 activé" -Severity "MEDIUM" -Expected "EncryptData = True" -Check {
    $smbConfig = Get-SmbServerConfiguration
    if ($smbConfig.EncryptData -eq $true) { return $true } else { return "WARNING" }
}

# Check 8.4 : Aucun partage avec "Everyone : Full"
Invoke-Check -Name "Aucun partage avec 'Everyone : Full'" -Severity "HIGH" -Expected "Pas de partages dangereux" -Check {
    $shares = Get-SmbShare | Where-Object { $_.Name -notlike '*$' } # Exclure les partages admin
    $dangerous = $false
    foreach ($share in $shares) {
        $access = Get-SmbShareAccess -Name $share.Name -ErrorAction SilentlyContinue
        $everyoneFull = $access | Where-Object { $_.AccountName -eq "Everyone" -and $_.AccessRight -eq "Full" }
        if ($everyoneFull) { $dangerous = $true; break }
    }
    if (-not $dangerous) { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 9 : USER ACCOUNT CONTROL (UAC)
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🛡️  PARTIE 9 : USER ACCOUNT CONTROL (UAC)" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 9.1 : UAC activé
Invoke-Check -Name "UAC activé (EnableLUA)" -Severity "HIGH" -Expected "EnableLUA = 1" -Check {
    $uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction SilentlyContinue
    if ($uac -and $uac.EnableLUA -eq 1) { return $true } else { return $false }
}

# Check 9.2 : Prompt de consentement pour admins activé
Invoke-Check -Name "UAC Prompt pour admins activé" -Severity "HIGH" -Expected "ConsentPromptBehaviorAdmin >= 2" -Check {
    $prompt = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue
    if ($prompt -and $prompt.ConsentPromptBehaviorAdmin -ge 2) { return $true } else { return $false }
}

# Check 9.3 : Bureau sécurisé activé
Invoke-Check -Name "UAC Bureau sécurisé activé" -Severity "MEDIUM" -Expected "PromptOnSecureDesktop = 1" -Check {
    $desktop = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -ErrorAction SilentlyContinue
    if ($desktop -and $desktop.PromptOnSecureDesktop -eq 1) { return $true } else { return $false }
}

Write-Report ""

# ==============================================================================
# PARTIE 10 : SÉCURITÉ RÉSEAU ET PROTOCOLES
# ==============================================================================

Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report "🌍 PARTIE 10 : SÉCURITÉ RÉSEAU ET PROTOCOLES" "Cyan"
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"
Write-Report ""

# Check 10.1 : Niveau de compatibilité LM = 5
Invoke-Check -Name "LmCompatibilityLevel = 5 (NTLMv2 uniquement)" -Severity "HIGH" -Expected "LmCompatibilityLevel = 5" -Check {
    $lm = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -ErrorAction SilentlyContinue
    if ($lm -and $lm.LmCompatibilityLevel -eq 5) { return $true } else { return $false }
}

# Check 10.2 : Hash LM désactivés
Invoke-Check -Name "Hash LM désactivés (NoLMHash)" -Severity "HIGH" -Expected "NoLMHash = 1" -Check {
    $noLM = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash" -ErrorAction SilentlyContinue
    if ($noLM -and $noLM.NoLMHash -eq 1) { return $true } else { return $false }
}

# Check 10.3 : Kerberos AES uniquement (valeur 24)
Invoke-Check -Name "Kerberos AES uniquement (SupportedEncryptionTypes)" -Severity "MEDIUM" -Expected "SupportedEncryptionTypes = 24 (AES-128 + AES-256)" -Check {
    $kerb = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" -Name "SupportedEncryptionTypes" -ErrorAction SilentlyContinue
    if ($kerb -and $kerb.SupportedEncryptionTypes -eq 24) { return $true } else { return "WARNING" }
}

Write-Report ""

# ==============================================================================
# RÉSUMÉ ET SCORE FINAL
# ==============================================================================

Write-Report "═══════════════════════════════════════════════════════════════════" "Cyan"
Write-Report "📊 RÉSUMÉ DE L'AUDIT" "Cyan"
Write-Report "═══════════════════════════════════════════════════════════════════" "Cyan"
Write-Report ""

$scorePercentage = if ($script:TotalChecks -gt 0) {
    [math]::Round(($script:PassedChecks / $script:TotalChecks) * 100, 1)
} else {
    0
}

Write-Report "Total de vérifications    : $script:TotalChecks" "White"
Write-Report "✅ Réussies (PASS)        : $script:PassedChecks" "Green"
Write-Report "⚠️  Avertissements (WARN) : $script:WarningChecks" "Yellow"
Write-Report "❌ Échecs (FAIL)          : $script:FailedChecks" "Red"
Write-Report ""
Write-Report "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Cyan"

# Déterminer le niveau de sécurité
$securityLevel = ""
$levelColor = "White"

if ($scorePercentage -ge 90) {
    $securityLevel = "🏆 EXCELLENT - Serveur très sécurisé !"
    $levelColor = "Green"
} elseif ($scorePercentage -ge 75) {
    $securityLevel = "✅ BON - Quelques améliorations possibles"
    $levelColor = "Cyan"
} elseif ($scorePercentage -ge 60) {
    $securityLevel = "⚠️  MOYEN - Plusieurs problèmes à corriger"
    $levelColor = "Yellow"
} elseif ($scorePercentage -ge 40) {
    $securityLevel = "🟠 FAIBLE - Nombreux problèmes de sécurité"
    $levelColor = "DarkYellow"
} else {
    $securityLevel = "🔴 CRITIQUE - Serveur très vulnérable !"
    $levelColor = "Red"
}

Write-Report "🎯 SCORE DE SÉCURITÉ : $scorePercentage%" "Cyan"
Write-Report "📈 NIVEAU            : $securityLevel" $levelColor
Write-Report ""

Write-Report "═══════════════════════════════════════════════════════════════════" "Cyan"
Write-Report "📝 Rapport complet sauvegardé dans :" "White"
Write-Report "   $OutputFile" "Cyan"
Write-Report "═══════════════════════════════════════════════════════════════════" "Cyan"
Write-Report ""

# Recommandations selon le score
if ($scorePercentage -lt 90) {
    Write-Report "💡 RECOMMANDATIONS :" "Yellow"
    Write-Report ""

    if ($script:FailedChecks -gt 0) {
        Write-Report "1. Consulte le guide détaillé 'windows-server-2022.md'" "Cyan"
        Write-Report "2. Priorise la correction des checks ❌ FAIL (surtout SEVERITY: HIGH)" "Cyan"
        Write-Report "3. Reteste avec ce script après corrections" "Cyan"
    }

    if ($script:WarningChecks -gt 0) {
        Write-Report "4. Examine les checks ⚠️  WARN pour optimisation" "Cyan"
    }

    Write-Report ""
    Write-Report "📚 Pour chaque check échoué, le guide 'windows-server-2022.md' contient :" "White"
    Write-Report "   - L'explication du risque" "White"
    Write-Report "   - Les commandes PowerShell de correction" "White"
    Write-Report "   - Des exemples concrets" "White"
    Write-Report ""
}

Write-Report "🎓 Bravo d'avoir audité ton serveur !" "Green"
Write-Report "   La sécurité, c'est un processus continu, pas une destination ! 🚀" "Green"
Write-Report ""

# Retourner le code de sortie basé sur le score
if ($scorePercentage -ge 75) {
    exit 0
} else {
    exit 1
}
