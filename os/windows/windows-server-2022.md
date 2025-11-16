# Guide d'Audit Technique - Windows Server 2022

## 📋 Vue d'ensemble

Ce guide vous permet d'effectuer un audit de sécurité complet d'un serveur Windows Server 2022. Il est basé sur les standards suivants :
- **CIS Benchmark for Microsoft Windows Server 2022** (v4.0.0 - Janvier 2025)
- **Microsoft Security Baseline for Windows Server 2022**
- **DISA STIG (Security Technical Implementation Guide)**
- **NIST SP 800-53**

### Version du guide
- **Dernière mise à jour** : Janvier 2025
- **Système couvert** : Windows Server 2022 (toutes éditions)
- **Type d'audit** : Sécurité et conformité
- **Configurations** : Member Server et Domain Controller

---

## 🎯 Objectifs de l'audit

- Évaluer la posture de sécurité du serveur Windows
- Identifier les configurations non conformes aux bonnes pratiques Microsoft
- Détecter les vulnérabilités et failles de sécurité
- Vérifier la conformité aux standards CIS et STIG
- Produire un rapport d'audit actionnable

---

## 📚 Prérequis

### Connaissances requises
- Administration Windows Server de base
- PowerShell (lecture de commandes)
- Politique de groupe (GPO) - notions
- Active Directory (si Domain Controller)

### Accès nécessaire
- Compte avec privilèges administrateur local
- Accès RDP ou console
- Droits de lecture des GPO (si domaine)

### Outils recommandés
```powershell
# Installation des outils d'audit (PowerShell en tant qu'administrateur)
Install-Module -Name SecurityPolicyDsc -Force
Install-Module -Name AuditPolicyDsc -Force

# Télécharger les outils Microsoft
# - Microsoft Security Compliance Toolkit (SCT)
# - Microsoft Baseline Security Analyzer (MBSA) - si compatible
# - Sysinternals Suite
```

---

## 🔍 Points de Contrôle d'Audit

### 1. GESTION DES MISES À JOUR

#### 1.1 Vérification des mises à jour Windows

**Objectif :** S'assurer que toutes les mises à jour de sécurité sont installées

**Justification :** Les mises à jour de sécurité corrigent des vulnérabilités critiques (CVE). Un serveur non à jour est exposé à des exploits publics, notamment les ransomwares qui ciblent les serveurs Windows.

**Procédure :**
```powershell
# Vérifier les mises à jour installées récemment
Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 20

# Vérifier les mises à jour disponibles
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
$SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
$SearchResult.Updates | Select-Object Title, IsDownloaded

# Vérifier la configuration de Windows Update
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

# Vérifier le service Windows Update
Get-Service -Name wuauserv
```

**Résultats attendus :**
- ✅ Dernières mises à jour de sécurité installées (< 30 jours)
- ✅ Aucune mise à jour critique en attente
- ✅ Windows Update configuré pour les mises à jour automatiques
- ✅ Service Windows Update en cours d'exécution

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Mises à jour critiques > 30 jours | 🔴 CRITIQUE | Exploitation de CVE connues (EternalBlue, PrintNightmare, etc.) |
| Service désactivé | 🔴 CRITIQUE | Pas de protection contre nouvelles vulnérabilités |
| Mises à jour en attente | 🟠 ÉLEVÉ | Fenêtre d'exposition aux attaques |

**Recommandations :**
```powershell
# Activer les mises à jour automatiques via GPO ou registre
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 4

# Démarrer le service
Start-Service -Name wuauserv
Set-Service -Name wuauserv -StartupType Automatic

# Installer les mises à jour immédiatement
Install-WindowsUpdate -AcceptAll -AutoReboot
```

---

### 2. GESTION DES COMPTES ET AUTHENTIFICATION

#### 2.1 Politique de mots de passe

**Objectif :** Vérifier la robustesse de la politique de mots de passe

**Justification :** Les mots de passe faibles sont la principale cause de compromission. Une politique stricte conforme au CIS Benchmark réduit drastiquement les risques d'attaques par force brute ou dictionnaire.

**Procédure :**
```powershell
# Exporter et afficher la politique de mot de passe
net accounts

# Vérifier via PowerShell
Get-ADDefaultDomainPasswordPolicy  # Pour Domain Controller
# OU pour serveur standalone:
$secedit = "C:\Windows\Temp\secpol.cfg"
secedit /export /cfg $secedit
Get-Content $secedit | Select-String -Pattern "Password|Lockout"

# Vérifier les GPO appliquées
gpresult /H C:\GPReport.html
```

**Résultats attendus (CIS Benchmark Level 1) :**
```
Minimum password age: 1 day
Maximum password age: 365 days (CIS recommande 365 ou moins)
Minimum password length: 14 characters
Password complexity: Enabled
Password history: 24 passwords remembered
Account lockout threshold: 5 invalid attempts (CIS Level 1)
Account lockout duration: 15 minutes minimum
Reset lockout counter after: 15 minutes
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Longueur < 8 caractères | 🔴 CRITIQUE | Force brute rapide, compromission facile |
| Complexité désactivée | 🔴 CRITIQUE | Mots de passe simples (Password123) |
| Pas d'historique | 🟠 ÉLEVÉ | Réutilisation immédiate de mots de passe |
| Pas de verrouillage | 🔴 CRITIQUE | Attaques par force brute illimitées |
| Expiration > 365 jours | 🟡 MOYEN | Fenêtre d'exploitation longue |

**Recommandations :**
```powershell
# Configuration via secedit (serveur standalone)
# Créer un fichier de politique
@"
[System Access]
MinimumPasswordAge = 1
MaximumPasswordAge = 365
MinimumPasswordLength = 14
PasswordComplexity = 1
PasswordHistorySize = 24
LockoutBadCount = 5
LockoutDuration = 15
ResetLockoutCount = 15
"@ | Out-File C:\secpol.inf

# Appliquer
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol.inf /areas SECURITYPOLICY

# Pour un domaine Active Directory
Set-ADDefaultDomainPasswordPolicy -MinPasswordLength 14 -ComplexityEnabled $true -MaxPasswordAge 365 -MinPasswordAge 1 -PasswordHistoryCount 24
```

#### 2.2 Désactivation du compte Administrateur intégré

**Objectif :** Vérifier que le compte Administrator par défaut est renommé ou désactivé

**Justification :** Le compte Administrator est une cible privilégiée des attaquants car son nom est connu. Le renommer et/ou le désactiver force les attaquants à deviner le nom du compte admin.

**Procédure :**
```powershell
# Vérifier le statut du compte Administrator
Get-LocalUser -Name "Administrator" | Select-Object Name, Enabled, Description

# Vérifier si le compte a été renommé
Get-LocalUser | Where-Object {$_.SID -like "*-500"}

# Pour un domaine
Get-ADUser -Filter {SID -like "*-500"} -Properties Enabled, Description
```

**Résultats attendus :**
- ✅ Compte Administrator renommé OU désactivé
- ✅ Si activé, compte renommé avec nom non évident
- ✅ Description modifiée pour ne pas indiquer qu'il s'agit du compte admin

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Compte "Administrator" actif | 🟠 ÉLEVÉ | Cible connue pour attaques par force brute |
| Compte avec nom évident | 🟡 MOYEN | Facilite l'identification du compte privilégié |

**Recommandations :**
```powershell
# Renommer le compte Administrator
Rename-LocalUser -Name "Administrator" -NewName "SysAdmin_DC01"

# OU désactiver complètement
Disable-LocalUser -Name "Administrator"

# Pour un domaine (via GPO)
# Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
# "Accounts: Rename administrator account"
```

#### 2.3 Compte Invité (Guest)

**Objectif :** Vérifier que le compte Guest est désactivé

**Justification :** Le compte Guest, même avec des privilèges limités, peut être utilisé comme point d'entrée pour reconnaissance et élévation de privilèges.

**Procédure :**
```powershell
# Vérifier le statut du compte Guest
Get-LocalUser -Name "Guest" | Select-Object Name, Enabled

# Pour un domaine
Get-ADUser -Filter {Name -eq "Guest"} -Properties Enabled
```

**Résultats attendus :**
- ✅ Compte Guest désactivé (Enabled = False)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Guest activé | 🟠 ÉLEVÉ | Accès non authentifié, reconnaissance |

**Recommandations :**
```powershell
# Désactiver le compte Guest
Disable-LocalUser -Name "Guest"

# Via GPO : Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
# "Accounts: Guest account status" = Disabled
```

#### 2.4 Comptes avec privilèges administrateur

**Objectif :** Inventorier tous les comptes avec privilèges administrateur

**Justification :** Limiter le nombre de comptes administrateurs réduit la surface d'attaque. Chaque compte admin est une cible potentielle.

**Procédure :**
```powershell
# Lister les membres du groupe Administrateurs local
Get-LocalGroupMember -Group "Administrators"

# Pour un domaine
Get-ADGroupMember -Identity "Domain Admins" -Recursive
Get-ADGroupMember -Identity "Enterprise Admins" -Recursive

# Vérifier les dernières connexions de ces comptes
Get-LocalUser | Where-Object {$_.Enabled -eq $true} | ForEach-Object {
    $username = $_.Name
    $lastLogon = (Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -MaxEvents 1000 |
                  Where-Object {$_.Properties[5].Value -eq $username} |
                  Select-Object -First 1).TimeCreated
    [PSCustomObject]@{
        Username = $username
        LastLogon = $lastLogon
    }
}
```

**Résultats attendus :**
- ✅ Nombre minimal de comptes administrateurs (idéalement 2-3 max)
- ✅ Chaque compte justifié et documenté
- ✅ Comptes avec activité récente uniquement
- ✅ Pas de comptes de service dans Admins du domaine

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| > 5 comptes administrateurs | 🟠 ÉLEVÉ | Trop de comptes privilégiés |
| Comptes sans activité | 🟡 MOYEN | Comptes dormants potentiellement compromis |
| Comptes de service admin | 🔴 CRITIQUE | Mots de passe souvent faibles ou jamais changés |

**Recommandations :**
- Documenter chaque compte administrateur et sa justification
- Supprimer les comptes inutilisés
- Utiliser des comptes séparés pour administration (principe du moindre privilège)
- Implémenter des Privileged Access Workstations (PAW)

---

### 3. CONFIGURATION DU BUREAU À DISTANCE (RDP)

#### 3.1 Sécurisation de RDP

**Objectif :** Vérifier que RDP est sécurisé ou désactivé si non utilisé

**Justification :** RDP est une cible majeure des attaques (ransomwares, bruteforce). Une mauvaise configuration expose le serveur à des compromissions.

**Procédure :**
```powershell
# Vérifier si RDP est activé
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"

# Vérifier le niveau de sécurité RDP
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer"
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication"

# Vérifier le port RDP
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber"

# Vérifier le pare-feu
Get-NetFirewallRule -DisplayName "*Remote Desktop*" | Select-Object DisplayName, Enabled, Direction, Action
```

**Résultats attendus :**
- ✅ RDP désactivé si non nécessaire (fDenyTSConnections = 1)
- ✅ Si RDP actif :
  - SecurityLayer = 2 (SSL/TLS)
  - UserAuthentication = 1 (Network Level Authentication activé)
  - Port changé (optionnel mais recommandé)
  - Règle firewall limitée à IPs spécifiques

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| RDP activé inutilement | 🟠 ÉLEVÉ | Surface d'attaque inutile |
| NLA désactivé | 🔴 CRITIQUE | Pas d'authentification avant session, vulnérable aux attaques |
| Port 3389 standard + ouvert à Internet | 🔴 CRITIQUE | Scans automatisés, attaques par force brute |
| Pas de restriction IP | 🟠 ÉLEVÉ | Accessible depuis n'importe où |

**Recommandations :**
```powershell
# Désactiver RDP si non utilisé
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1

# Si RDP nécessaire, sécuriser :
# Activer NLA
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# Forcer SSL/TLS
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value 2

# Changer le port (exemple : 13389)
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" -Value 13389

# Limiter par IP dans le pare-feu
New-NetFirewallRule -DisplayName "RDP - IP Restreinte" -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow -RemoteAddress "192.168.1.100/32"

# Redémarrer le service
Restart-Service -Name TermService -Force
```

#### 3.2 Chiffrement RDP

**Objectif :** Vérifier le niveau de chiffrement RDP

**Justification :** Un chiffrement faible permet l'interception et le déchiffrement du trafic RDP.

**Procédure :**
```powershell
# Vérifier le niveau de chiffrement
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel"
```

**Résultats attendus :**
- ✅ MinEncryptionLevel = 3 (High - 128 bits)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Chiffrement faible (< 3) | 🔴 CRITIQUE | Interception et déchiffrement du trafic |

**Recommandations :**
```powershell
# Forcer le chiffrement maximum
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel" -Value 3
```

---

### 4. PARE-FEU WINDOWS (Windows Defender Firewall)

#### 4.1 Activation du pare-feu

**Objectif :** Vérifier que le pare-feu Windows est actif sur tous les profils

**Justification :** Le pare-feu est la première ligne de défense contre les connexions réseau non autorisées.

**Procédure :**
```powershell
# Vérifier le statut du pare-feu sur tous les profils
Get-NetFirewallProfile | Select-Object Name, Enabled

# Vérifier les règles entrantes
Get-NetFirewallRule -Direction Inbound -Enabled True | Select-Object DisplayName, Action, Profile

# Vérifier la politique par défaut
Get-NetFirewallProfile | Select-Object Name, DefaultInboundAction, DefaultOutboundAction
```

**Résultats attendus :**
- ✅ Pare-feu activé pour tous les profils (Domain, Private, Public)
- ✅ DefaultInboundAction = Block
- ✅ DefaultOutboundAction = Allow (ou Block selon politique)
- ✅ Règles entrantes justifiées uniquement

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pare-feu désactivé | 🔴 CRITIQUE | Tous les ports accessibles, aucune protection |
| DefaultInboundAction Allow | 🔴 CRITIQUE | Trafic entrant non filtré |
| Profil Public désactivé | 🟠 ÉLEVÉ | Pas de protection sur réseaux non fiables |

**Recommandations :**
```powershell
# Activer le pare-feu sur tous les profils
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True

# Définir les politiques par défaut
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block -DefaultOutboundAction Allow

# Empêcher les utilisateurs de désactiver le pare-feu (via GPO)
# Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall
# "Prohibit use of Internet Connection Firewall on your DNS domain network" = Enabled
```

#### 4.2 Règles de pare-feu

**Objectif :** Auditer les règles de pare-feu entrantes

**Justification :** Chaque règle entrante est un point d'entrée potentiel. Seules les règles nécessaires doivent être activées.

**Procédure :**
```powershell
# Lister toutes les règles entrantes actives
Get-NetFirewallRule -Direction Inbound -Enabled True |
    Get-NetFirewallPortFilter |
    Select-Object @{Name='Rule';Expression={(Get-NetFirewallRule -AssociatedNetFirewallPortFilter $_).DisplayName}}, Protocol, LocalPort |
    Sort-Object LocalPort

# Identifier les règles "Any" (dangereuses)
Get-NetFirewallRule -Direction Inbound -Enabled True |
    Get-NetFirewallAddressFilter |
    Where-Object {$_.RemoteAddress -eq 'Any'} |
    ForEach-Object {(Get-NetFirewallRule -AssociatedNetFirewallAddressFilter $_).DisplayName}
```

**Résultats attendus :**
- ✅ Nombre minimal de règles entrantes
- ✅ Chaque règle justifiée et documentée
- ✅ Règles limitées par IP source si possible
- ✅ Pas de règles "Any" inutiles

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| > 20 règles entrantes | 🟡 MOYEN | Surface d'attaque élargie |
| Règles "Any/Any" | 🟠 ÉLEVÉ | Ports accessibles depuis Internet |
| Ports non standard ouverts | 🟡 MOYEN | Services potentiellement non sécurisés |

**Recommandations :**
- Désactiver toutes les règles inutiles
- Limiter les règles par adresse IP source
- Documenter chaque règle active

---

### 5. WINDOWS DEFENDER ET ANTIVIRUS

#### 5.1 État de Windows Defender

**Objectif :** Vérifier que Windows Defender est actif et à jour

**Justification :** Windows Defender est la protection antimalware intégrée. Elle doit être active sauf si un autre antivirus professionnel est déployé.

**Procédure :**
```powershell
# Vérifier le statut de Windows Defender
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled, IoavProtectionEnabled, BehaviorMonitorEnabled, AntivirusSignatureLastUpdated

# Vérifier les préférences
Get-MpPreference | Select-Object DisableRealtimeMonitoring, DisableBehaviorMonitoring, DisableIOAVProtection

# Vérifier les exclusions (peuvent être abusées)
Get-MpPreference | Select-Object ExclusionPath, ExclusionExtension, ExclusionProcess

# Vérifier l'historique des menaces
Get-MpThreatDetection | Select-Object -First 10
```

**Résultats attendus :**
- ✅ AntivirusEnabled = True
- ✅ RealTimeProtectionEnabled = True
- ✅ BehaviorMonitorEnabled = True
- ✅ Signatures < 7 jours
- ✅ Exclusions justifiées uniquement (minimum)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Defender désactivé sans alternative | 🔴 CRITIQUE | Aucune protection antimalware |
| RealTime désactivé | 🔴 CRITIQUE | Malware non détecté en temps réel |
| Signatures > 30 jours | 🟠 ÉLEVÉ | Malwares récents non détectés |
| Exclusions larges (C:\, *.exe) | 🔴 CRITIQUE | Contournement complet de l'antivirus |

**Recommandations :**
```powershell
# Activer toutes les protections
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableIOAVProtection $false

# Mettre à jour les signatures
Update-MpSignature

# Supprimer les exclusions inutiles
Remove-MpPreference -ExclusionPath "C:\Temp"

# Activer Cloud Protection
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendAllSamples
```

#### 5.2 Exploit Protection

**Objectif :** Vérifier que les protections contre les exploits sont activées

**Justification :** Exploit Protection (successeur d'EMET) protège contre les techniques d'exploitation modernes (DEP, ASLR, etc.)

**Procédure :**
```powershell
# Vérifier les configurations Exploit Protection
Get-ProcessMitigation -System

# Vérifier pour des applications spécifiques
Get-ProcessMitigation -Name "explorer.exe"
```

**Résultats attendus :**
- ✅ DEP (Data Execution Prevention) activé
- ✅ ASLR (Address Space Layout Randomization) activé
- ✅ SEHOP activé
- ✅ CFG (Control Flow Guard) activé

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Protections désactivées | 🟠 ÉLEVÉ | Exploitation facilitée des vulnérabilités |

**Recommandations :**
```powershell
# Activer les protections système
Set-ProcessMitigation -System -Enable DEP,ASLR,SEHOP,ControlFlowGuard
```

---

### 6. AUDIT ET JOURNALISATION

#### 6.1 Politique d'audit avancée

**Objectif :** Vérifier que les événements de sécurité critiques sont audités

**Justification :** Sans audit approprié, impossible de détecter les tentatives d'intrusion ou de retracer les actions malveillantes.

**Procédure :**
```powershell
# Vérifier la politique d'audit avancée
auditpol /get /category:*

# Vérifier la taille et rétention des logs de sécurité
Get-EventLog -List | Where-Object {$_.Log -eq "Security"}
wevtutil gl Security

# Vérifier les événements de connexion récents
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624,4625} -MaxEvents 100
```

**Résultats attendus (CIS Benchmark Level 1) :**
```
Account Logon:
  - Credential Validation: Success and Failure

Account Management:
  - Security Group Management: Success
  - User Account Management: Success and Failure

Logon/Logoff:
  - Logon: Success and Failure
  - Logoff: Success
  - Account Lockout: Failure
  - Special Logon: Success

Policy Change:
  - Audit Policy Change: Success
  - Authentication Policy Change: Success

Privilege Use:
  - Sensitive Privilege Use: Success and Failure

System:
  - Security System Extension: Success
  - System Integrity: Success and Failure
  - Security State Change: Success

Log Settings:
  - Maximum log size: Minimum 32768 KB (32 MB), recommandé 1 GB
  - Retention: Overwrite as needed OU Archive automatique
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas d'audit de connexions | 🔴 CRITIQUE | Intrusions non détectées |
| Taille log < 32 MB | 🟠 ÉLEVÉ | Perte rapide d'historique |
| Audit désactivé | 🔴 CRITIQUE | Aucune traçabilité |
| Pas d'audit des échecs | 🟠 ÉLEVÉ | Tentatives d'attaque non tracées |

**Recommandations :**
```powershell
# Activer les audits critiques (exemples)
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable
auditpol /set /subcategory:"Audit Policy Change" /success:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable

# Augmenter la taille du journal de sécurité (1 GB)
wevtutil sl Security /ms:1073741824

# Configurer la rétention
wevtutil sl Security /rt:false   # Ne pas écraser automatiquement
```

#### 6.2 Centralisation des logs

**Objectif :** Vérifier si les logs sont centralisés (SIEM, serveur syslog)

**Justification :** La centralisation des logs protège contre l'effacement par un attaquant et permet une corrélation multi-serveurs.

**Procédure :**
```powershell
# Vérifier si Windows Event Forwarding est configuré
Get-Service -Name Wecsvc
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager"

# Vérifier les abonnements
wecutil es
```

**Résultats attendus :**
- ✅ Logs envoyés à un collecteur central (SIEM, WEF, Syslog)
- ✅ Service Wecsvc actif si Windows Event Forwarding utilisé

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de centralisation | 🟠 ÉLEVÉ | Perte de logs si compromission, pas de corrélation |

**Recommandations :**
- Configurer Windows Event Forwarding (WEF) vers un collecteur
- OU configurer un agent SIEM (Splunk, Elastic, Sentinel)
- Protéger les logs locaux en attendant la transmission

---

### 7. SERVICES WINDOWS

#### 7.1 Inventaire des services actifs

**Objectif :** Identifier tous les services en cours d'exécution

**Justification :** Chaque service est une surface d'attaque. Seuls les services nécessaires doivent être actifs.

**Procédure :**
```powershell
# Lister tous les services en cours d'exécution
Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name, DisplayName, StartType | Sort-Object DisplayName

# Identifier les services tiers
Get-Service | Where-Object {$_.Status -eq "Running"} | ForEach-Object {
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='$($_.Name)'"
    [PSCustomObject]@{
        Name = $service.Name
        DisplayName = $service.DisplayName
        PathName = $service.PathName
    }
} | Where-Object {$_.PathName -notlike "*\Windows\*"}
```

**Résultats attendus :**
- ✅ Liste minimale de services Microsoft nécessaires
- ✅ Services tiers justifiés et documentés
- ✅ Services obsolètes désactivés

**Services à désactiver si non utilisés (selon CIS) :**
- Print Spooler (si pas d'impression)
- Remote Registry
- Windows Media Player Network Sharing Service
- Xbox services
- IIS (si pas de serveur web)
- SNMP (si pas de monitoring SNMP)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Print Spooler actif inutilement | 🔴 CRITIQUE | Vulnérabilité PrintNightmare (CVE-2021-34527) |
| Remote Registry actif | 🟠 ÉLEVÉ | Accès distant à la base de registre |
| Services obsolètes | 🟡 MOYEN | Vulnérabilités non patchées |

**Recommandations :**
```powershell
# Désactiver les services inutiles (exemples)
Stop-Service -Name "Spooler" -Force
Set-Service -Name "Spooler" -StartupType Disabled

Stop-Service -Name "RemoteRegistry" -Force
Set-Service -Name "RemoteRegistry" -StartupType Disabled

# Vérifier les dépendances avant désactivation
Get-Service -Name "ServiceName" -DependentServices
```

#### 7.2 Comptes de service

**Objectif :** Auditer les comptes utilisés pour exécuter les services

**Justification :** Les services ne doivent pas s'exécuter avec des comptes sur-privilégiés (LocalSystem, Domain Admin).

**Procédure :**
```powershell
# Lister les services et leurs comptes
Get-WmiObject Win32_Service | Select-Object Name, DisplayName, StartName, State | Where-Object {$_.State -eq "Running"} | Sort-Object StartName

# Identifier les services avec comptes privilégiés
Get-WmiObject Win32_Service | Where-Object {$_.StartName -like "*admin*" -or $_.StartName -like "*domain*"}
```

**Résultats attendus :**
- ✅ Services utilisant comptes dédiés (Managed Service Accounts si domaine)
- ✅ Pas de services avec comptes Domain Admins
- ✅ Principe du moindre privilège respecté

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Service avec Domain Admin | 🔴 CRITIQUE | Compromission = contrôle du domaine |
| Services avec comptes utilisateurs | 🟠 ÉLEVÉ | Mots de passe stockés, non changés |

**Recommandations :**
- Utiliser Group Managed Service Accounts (gMSA) pour les domaines
- Utiliser des comptes locaux dédiés avec privilèges minimaux
- Ne jamais utiliser de comptes administrateurs pour les services

---

### 8. PARTAGES RÉSEAU (SMB)

#### 8.1 Inventaire des partages

**Objectif :** Identifier tous les partages réseau actifs

**Justification :** Les partages mal configurés sont une source majeure de fuite de données et de propagation de malware (ransomware).

**Procédure :**
```powershell
# Lister tous les partages
Get-SmbShare

# Vérifier les permissions de chaque partage
Get-SmbShare | ForEach-Object {
    $shareName = $_.Name
    Write-Host "=== Share: $shareName ==="
    Get-SmbShareAccess -Name $shareName
}

# Vérifier les sessions actives
Get-SmbSession

# Vérifier la version SMB
Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol, EnableSMB2Protocol
```

**Résultats attendus :**
- ✅ Pas de partages inutiles (seulement ADMIN$, C$, IPC$ et partages métier nécessaires)
- ✅ Permissions restrictives (pas de "Everyone")
- ✅ SMB1 désactivé
- ✅ SMB signing activé

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| SMB1 activé | 🔴 CRITIQUE | Vulnérable à EternalBlue (WannaCry, NotPetya) |
| Partages avec "Everyone" | 🔴 CRITIQUE | Accès non authentifié, fuite de données |
| SMB signing désactivé | 🟠 ÉLEVÉ | Attaques relay, man-in-the-middle |
| Partages administratifs exposés | 🟠 ÉLEVÉ | Mouvement latéral facilité |

**Recommandations :**
```powershell
# Désactiver SMBv1 (CRITIQUE)
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
# Désinstaller complètement
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

# Activer SMB signing
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force

# Supprimer les partages inutiles
Remove-SmbShare -Name "PartageInutile" -Force

# Corriger les permissions (exemple)
Revoke-SmbShareAccess -Name "Partage" -AccountName "Everyone" -Force
Grant-SmbShareAccess -Name "Partage" -AccountName "DOMAIN\GroupeAutorise" -AccessRight Read -Force
```

---

### 9. USER ACCOUNT CONTROL (UAC)

#### 9.1 Configuration UAC

**Objectif :** Vérifier que UAC est activé et correctement configuré

**Justification :** UAC protège contre l'élévation de privilèges non autorisée et limite l'impact des malwares.

**Procédure :**
```powershell
# Vérifier la configuration UAC
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" |
    Select-Object EnableLUA, ConsentPromptBehaviorAdmin, ConsentPromptBehaviorUser, PromptOnSecureDesktop
```

**Résultats attendus (CIS Benchmark Level 1) :**
```
EnableLUA = 1 (UAC activé)
ConsentPromptBehaviorAdmin = 2 (Prompt for consent on the secure desktop)
PromptOnSecureDesktop = 1 (Actif)
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| UAC désactivé (EnableLUA = 0) | 🔴 CRITIQUE | Élévation silencieuse de privilèges |
| Pas de prompt admin | 🟠 ÉLEVÉ | Actions privilégiées sans confirmation |
| Secure Desktop désactivé | 🟡 MOYEN | Prompt UAC peut être simulé |

**Recommandations :**
```powershell
# Activer UAC avec niveau maximum
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1
```

---

### 10. SÉCURITÉ RÉSEAU ET PROTOCOLES

#### 10.1 Durcissement SMB et NTLM

**Objectif :** Vérifier la configuration sécurisée de SMB et limitation de NTLM

**Justification :** NTLM est obsolète et vulnérable aux attaques relay. Kerberos doit être privilégié.

**Procédure :**
```powershell
# Vérifier la configuration SMB
Get-SmbServerConfiguration | Select-Object *

# Vérifier les paramètres NTLM
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" | Select-Object LmCompatibilityLevel, RestrictSendingNTLMTraffic

# Vérifier les authentifications récentes
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 100 |
    Where-Object {$_.Message -like "*NTLM*"} |
    Select-Object TimeCreated, Message -First 10
```

**Résultats attendus :**
- ✅ LmCompatibilityLevel = 5 (NTLMv2 only, refuse LM & NTLM)
- ✅ SMB Encryption activé pour partages sensibles
- ✅ Auditer les authentifications NTLM

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| LM ou NTLMv1 activé | 🔴 CRITIQUE | Vulnérable au cracking (rainbow tables) |
| NTLM non restreint | 🟠 ÉLEVÉ | Attaques relay (SMB relay, NTLM relay) |
| Pas de chiffrement SMB | 🟡 MOYEN | Interception du trafic |

**Recommandations :**
```powershell
# Forcer NTLMv2 uniquement
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5

# Auditer l'utilisation de NTLM
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Name "AuditReceivingNTLMTraffic" -Value 2

# Activer le chiffrement SMB
Set-SmbServerConfiguration -EncryptData $true -Force
```

---

## 📊 Matrice de Criticité Globale

| Niveau | Délai de correction | Exemples |
|--------|---------------------|----------|
| 🔴 CRITIQUE | 24-48h | SMBv1 activé, Defender désactivé, mises à jour critiques manquantes, pas de pare-feu |
| 🟠 ÉLEVÉ | 1 semaine | RDP mal configuré, NTLM non restreint, services inutiles actifs |
| 🟡 MOYEN | 1 mois | UAC optimisations, audits manquants, durcissement avancé |
| 🟢 FAIBLE | Opportunité | Améliorations mineures |

---

## ✅ Checklist Finale d'Audit

### Mises à jour et configuration de base
- [ ] Mises à jour Windows installées (< 30 jours)
- [ ] Politique de mots de passe conforme CIS (14 car, complexité, expiration)
- [ ] Compte Administrator renommé ou désactivé
- [ ] Compte Guest désactivé
- [ ] Verrouillage de compte après échecs configuré

### Accès à distance et réseau
- [ ] RDP sécurisé (NLA, chiffrement, port) ou désactivé
- [ ] Pare-feu Windows actif sur tous les profils
- [ ] SMBv1 désactivé
- [ ] SMB signing activé
- [ ] Partages réseau minimaux et sécurisés

### Protection antimalware
- [ ] Windows Defender actif et à jour OU antivirus tiers
- [ ] Exploit Protection activée
- [ ] Exclusions justifiées uniquement

### Audit et journalisation
- [ ] Politique d'audit avancée configurée
- [ ] Taille des logs suffisante (> 32 MB, recommandé 1 GB)
- [ ] Centralisation des logs (optionnel mais recommandé)

### Services et sécurité système
- [ ] Services minimaux actifs
- [ ] Print Spooler désactivé si non utilisé
- [ ] Remote Registry désactivé
- [ ] UAC activé avec niveau maximum
- [ ] NTLM restreint (niveau 5)

### Comptes et privilèges
- [ ] Nombre minimal de comptes administrateurs
- [ ] Pas de comptes de service avec privilèges Domain Admin
- [ ] Comptes sans activité désactivés

---

## 🔧 Scripts d'Audit Automatisés

### Script PowerShell d'audit rapide

```powershell
# Script d'audit rapide Windows Server 2022
# À exécuter en tant qu'administrateur

Write-Host "=== AUDIT WINDOWS SERVER 2022 ===" -ForegroundColor Cyan

# 1. Mises à jour
Write-Host "`n[1] MISES À JOUR" -ForegroundColor Yellow
Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 5

# 2. Politique de mots de passe
Write-Host "`n[2] POLITIQUE DE MOT DE PASSE" -ForegroundColor Yellow
net accounts

# 3. Comptes administrateurs
Write-Host "`n[3] COMPTES ADMINISTRATEURS" -ForegroundColor Yellow
Get-LocalGroupMember -Group "Administrators"

# 4. RDP
Write-Host "`n[4] CONFIGURATION RDP" -ForegroundColor Yellow
$rdp = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
if ($rdp.fDenyTSConnections -eq 0) {
    Write-Host "RDP ACTIVÉ - Vérifier la sécurisation" -ForegroundColor Red
    Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" |
        Select-Object UserAuthentication, SecurityLayer, MinEncryptionLevel
} else {
    Write-Host "RDP désactivé" -ForegroundColor Green
}

# 5. Pare-feu
Write-Host "`n[5] PARE-FEU" -ForegroundColor Yellow
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction

# 6. Windows Defender
Write-Host "`n[6] WINDOWS DEFENDER" -ForegroundColor Yellow
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled, AntivirusSignatureLastUpdated

# 7. SMBv1
Write-Host "`n[7] SMBv1 (DOIT ÊTRE DÉSACTIVÉ)" -ForegroundColor Yellow
$smb1 = Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol
if ($smb1.EnableSMB1Protocol) {
    Write-Host "CRITIQUE: SMBv1 ACTIVÉ - DÉSACTIVER IMMÉDIATEMENT" -ForegroundColor Red
} else {
    Write-Host "SMBv1 désactivé" -ForegroundColor Green
}

# 8. Services à risque
Write-Host "`n[8] SERVICES À RISQUE" -ForegroundColor Yellow
$riskyServices = @("Spooler", "RemoteRegistry", "SNMP")
foreach ($svc in $riskyServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service -and $service.Status -eq "Running") {
        Write-Host "ATTENTION: $svc est actif" -ForegroundColor Red
    }
}

# 9. UAC
Write-Host "`n[9] UAC" -ForegroundColor Yellow
$uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" |
    Select-Object EnableLUA, ConsentPromptBehaviorAdmin
if ($uac.EnableLUA -eq 0) {
    Write-Host "CRITIQUE: UAC DÉSACTIVÉ" -ForegroundColor Red
} else {
    Write-Host "UAC activé" -ForegroundColor Green
}

# 10. Partages
Write-Host "`n[10] PARTAGES RÉSEAU" -ForegroundColor Yellow
Get-SmbShare | Select-Object Name, Path

Write-Host "`n=== FIN DE L'AUDIT ===" -ForegroundColor Cyan
```

---

## 📚 Références

### Documentation officielle Microsoft
- [Windows Server 2022 Security](https://learn.microsoft.com/en-us/windows-server/security/security-and-assurance)
- [Microsoft Security Baselines](https://learn.microsoft.com/en-us/windows/security/operating-system-security/device-management/windows-security-configuration-framework/windows-security-baselines)
- [Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319)

### Standards de sécurité
- [CIS Benchmark Windows Server 2022 v4.0.0](https://www.cisecurity.org/benchmark/microsoft_windows_server)
- [DISA STIG Windows Server 2022](https://public.cyber.mil/stigs/)
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)

### Outils d'audit
- [Microsoft Security Compliance Toolkit](https://www.microsoft.com/en-us/download/details.aspx?id=55319)
- [CIS-CAT Pro](https://www.cisecurity.org/cybersecurity-tools/cis-cat-pro/)
- [PowerSTIG](https://github.com/Microsoft/PowerStig)

### CVE et vulnérabilités Windows
- [Microsoft Security Response Center](https://msrc.microsoft.com/)
- [Windows Security Updates](https://msrc.microsoft.com/update-guide/)
- [CVE Database](https://cve.mitre.org/)

### Ressources additionnelles
- [ANSSI - Recommandations de sécurité relatives à Active Directory](https://www.ssi.gouv.fr/)
- [Australian Cyber Security Centre - Windows Hardening](https://www.cyber.gov.au/)

---

**Note :** Ce guide doit être adapté à votre environnement spécifique. Testez toutes les modifications dans un environnement de test avant de les appliquer en production.
