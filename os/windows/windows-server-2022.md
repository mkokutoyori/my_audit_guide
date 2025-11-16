# 🪟 Tutoriel d'Audit Windows Server 2022 - De Zéro à Héros

Salut futur·e expert·e en sécurité Windows ! 🎓

Bienvenue dans LE tutoriel qui va te transformer en pro de l'audit de sécurité Windows Server 2022. On va y aller étape par étape, commande PowerShell par commande PowerShell, et je vais TOUT t'expliquer. À la fin, tu sauras exactement ce que tu fais et pourquoi !

## 🎯 Ce que tu vas apprendre

À la fin de ce tutoriel, tu seras capable de :
- ✅ Auditer un serveur Windows Server 2022 comme un pro
- ✅ Comprendre exactement ce que fait chaque commande PowerShell
- ✅ Interpréter les résultats que tu vois dans ton terminal
- ✅ Identifier instantanément les problèmes de sécurité critiques
- ✅ Savoir comment corriger chaque problème trouvé
- ✅ Expliquer à ton boss/client POURQUOI c'est important

**Promesse :** Si tu suis ce guide jusqu'au bout, tu ne seras plus jamais perdu devant un serveur Windows !

---

## 📋 Avant de Commencer

### Ce qu'il te faut

**Niveau requis :** Débutant qui sait :
- Ouvrir PowerShell en tant qu'administrateur
- Se connecter à un serveur via RDP
- Copier-coller (oui, c'est important !)

**Matériel :**
- Un serveur Windows Server 2022 (ou une VM pour t'entraîner)
- Accès administrateur
- PowerShell 5.1 ou supérieur (déjà installé sur Windows Server 2022)
- 2-3 heures devant toi (prends un café ☕)

### Comment ouvrir PowerShell en mode Administrateur

Si tu ne l'as jamais fait, voici comment :

**Méthode 1 : Depuis le menu Démarrer**
1. Clique sur le menu Démarrer (logo Windows)
2. Tape "PowerShell"
3. Fais un **clic droit** sur "Windows PowerShell"
4. Choisis "Exécuter en tant qu'administrateur"

**Méthode 2 : Raccourci clavier (plus rapide)**
1. Appuie sur `Windows + X`
2. Choisis "Windows PowerShell (Admin)" ou "Terminal (Admin)"

**💻 Tu sauras que c'est bon si tu vois :**
```
Administrator: Windows PowerShell
PS C:\Windows\system32>
```

Le mot "Administrator" dans le titre de la fenêtre = tu es admin ! 🎉

---

## 🔍 Standards et Références

Ce guide est basé sur les meilleurs standards de l'industrie :

| Standard | Description | Niveau |
|----------|-------------|--------|
| **CIS Benchmark v4.0.0** | Standard de sécurité le plus reconnu | ⭐⭐⭐ |
| **Microsoft Security Baseline** | Recommandations officielles Microsoft | ⭐⭐⭐ |
| **DISA STIG** | Standard militaire américain (très strict) | ⭐⭐ |
| **ANSSI** | Agence nationale française de cybersécurité | ⭐⭐ |

**Tu n'as pas besoin de connaître tous ces standards** - ce guide te dit exactement quoi faire ! 😊

---

## 🔄 PARTIE 1 : Mises à Jour Windows - La Base de Tout

### 🎓 Concept : Pourquoi les mises à jour ?

**Analogie :** Imagine que ta voiture a un rappel constructeur pour un problème de freins. Si tu ne vas pas au garage, tu roules avec des freins défectueux alors que tout le monde sait qu'ils sont dangereux !

C'est pareil pour Windows : chaque mois, Microsoft publie des correctifs pour des failles de sécurité. Si tu ne les installes pas, ton serveur a des "freins défectueux" et tous les hackers le savent.

**Exemples réels qui ont fait les gros titres :**
- **WannaCry (2017)** : Ransomware qui a paralysé des hôpitaux, des entreprises. Le patch existait depuis 2 mois !
- **BlueKeep (2019)** : Faille RDP critique. Serveurs non patchés = pwned en 30 secondes
- **PrintNightmare (2021)** : Faille Print Spooler. Exploitée massivement pendant des semaines

**Le chiffre qui fait peur :** 60% des piratages exploitent des vulnérabilités pour lesquelles un patch existe depuis plus de 1 an (Ponemon Institute).

### ✅ Check #1 : Voir les mises à jour installées récemment

#### Commande : Lister les dernières mises à jour

```powershell
Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 20
```

**📖 Explication :**
- `Get-HotFix` = récupère la liste des mises à jour (hotfixes) installées
- `Sort-Object -Property InstalledOn -Descending` = trie par date d'installation, du plus récent au plus ancien
- `Select-Object -First 20` = affiche seulement les 20 premières (les plus récentes)

**💻 Ce que tu vas voir dans PowerShell :**

```
Source        Description      HotFixID      InstalledBy          InstalledOn
------        -----------      --------      -----------          -----------
SERVER2022    Update           KB5034129     NT AUTHORITY\SYSTEM  1/15/2025 12:00:00 AM
SERVER2022    Security Update  KB5034127     NT AUTHORITY\SYSTEM  1/15/2025 12:00:00 AM
SERVER2022    Update           KB5033918     NT AUTHORITY\SYSTEM  12/18/2024 12:00:00 AM
SERVER2022    Security Update  KB5032392     NT AUTHORITY\SYSTEM  11/20/2024 12:00:00 AM
SERVER2022    Update           KB5031990     NT AUTHORITY\SYSTEM  10/15/2024 12:00:00 AM
```

**🔍 Analyse colonne par colonne :**

| Colonne | Exemple | Signification |
|---------|---------|---------------|
| `Source` | SERVER2022 | Nom de ton serveur |
| `Description` | Security Update | Type de mise à jour |
| `HotFixID` | KB5034129 | Numéro de la mise à jour (KB = Knowledge Base) |
| `InstalledBy` | NT AUTHORITY\SYSTEM | Qui a installé (SYSTEM = installation automatique) |
| `InstalledOn` | 1/15/2025 | **LA DATE LA PLUS IMPORTANTE** |

**🎯 Ce qu'il faut regarder :**

✅ **BON SIGNE :**
- La dernière mise à jour date de moins de 30 jours
- Tu vois des "Security Update" récents
- Les dates sont régulières (tous les mois environ)

⚠️ **PROBLÈME :**
- La dernière mise à jour date de plus de 30 jours
- Pas de "Security Update" depuis plusieurs mois
- Grandes périodes sans aucune mise à jour

❌ **DANGER :**
- Dernière mise à jour > 6 mois
- Aucune mise à jour de sécurité depuis plus d'un an
- Liste vide ou presque vide

**💡 Conseil :** Microsoft publie des mises à jour le 2ème mardi de chaque mois (appelé "Patch Tuesday"). Si tu ne vois rien depuis plusieurs "Patch Tuesday", c'est louche !

### ✅ Check #2 : Vérifier les mises à jour disponibles

#### Commande : Chercher les mises à jour non installées

```powershell
# Cette commande utilise Windows Update pour chercher les mises à jour disponibles
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
$SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
$SearchResult.Updates | Select-Object Title, IsDownloaded, MsrcSeverity
```

**📖 Explication ligne par ligne :**
- Ligne 1 : Crée une session Windows Update (comme ouvrir l'application)
- Ligne 2 : Crée un "chercheur" de mises à jour
- Ligne 3 : Lance la recherche. `IsInstalled=0` = pas installé, `Type='Software'` = logiciels (pas pilotes)
- Ligne 4 : Affiche les résultats avec colonnes : Titre, Téléchargé?, Gravité

**💻 Exemple de résultat - CAS 1 (PARFAIT) :**

```
Title                                                                          IsDownloaded MsrcSeverity
-----                                                                          ------------ ------------

```

**(Vide = Aucune mise à jour en attente)**

✅ **EXCELLENT !** Ton serveur est 100% à jour ! Tu es un champion ! 🏆

**💻 Exemple de résultat - CAS 2 (ATTENTION) :**

```
Title                                                                          IsDownloaded MsrcSeverity
-----                                                                          ------------ ------------
2025-01 Cumulative Update for Windows Server 2022 (KB5034129)                       False     Important
Security Update for Microsoft Defender (KB5007651)                                   False      Critical
```

**🔍 Analyse :**

| Champ | Valeur | Signification | Urgence |
|-------|--------|---------------|---------|
| `Title` | 2025-01 Cumulative Update... | Mise à jour cumulative de janvier 2025 | ℹ️ |
| `IsDownloaded` | False | Pas encore téléchargée | ⚠️ |
| `MsrcSeverity` | **Critical** | 🔴 **CRITIQUE** | À installer MAINTENANT |
| `MsrcSeverity` | Important | 🟠 **IMPORTANT** | À installer cette semaine |

**🎨 Niveaux de gravité (MsrcSeverity) :**

| Niveau | Emoji | Délai d'installation | Exemple |
|--------|-------|---------------------|---------|
| **Critical** | 🔴 | 24-48h MAX | Failles d'exécution de code à distance (RCE) |
| **Important** | 🟠 | 7 jours | Élévation de privilèges, contournement sécurité |
| **Moderate** | 🟡 | 30 jours | Failles mineures |
| **Low** | 🟢 | Opportunité | Améliorations non critiques |

**❌ MAUVAIS EXEMPLE :**

```
Title                                                                          IsDownloaded MsrcSeverity
-----                                                                          ------------ ------------
2024-03 Security Update for Windows Server (KB5035857)                              False      Critical
2024-03 Cumulative Update for .NET Framework (KB5035856)                            False     Important
2024-04 Security Update for Remote Desktop (KB5036893)                              False      Critical
2024-05 Cumulative Update for Windows Server 2022 (KB5037765)                       False      Critical
2024-06 Security Update for SMB Protocol (KB5039211)                                False      Critical
```

**🚨 ALERTE ROUGE :**
- Mises à jour critiques datant de mars, avril, mai, juin
- Plusieurs "Critical" en attente
- Serveur probablement vulnérable à des exploits publics

**Risque :** Compromission quasi-certaine si le serveur est exposé sur Internet !

### ✅ Check #3 : Configuration de Windows Update

#### Commande : Voir comment Windows Update est configuré

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
```

**📖 Explication :**
- `Get-ItemProperty` = lire une valeur dans le registre Windows
- `HKLM:\SOFTWARE\...` = chemin dans le registre (HKLM = HKEY_LOCAL_MACHINE)
- `\AU` = Automatic Updates = mises à jour automatiques

**💻 Exemple de résultat - CAS 1 (BIEN configuré) :**

```
NoAutoUpdate               : 0
AUOptions                  : 4
ScheduledInstallDay        : 0
ScheduledInstallTime       : 3
```

**🔍 Décryptage :**

| Paramètre | Valeur | Signification | Bon ? |
|-----------|--------|---------------|-------|
| `NoAutoUpdate` | 0 | 0 = Mises à jour automatiques ACTIVÉES | ✅ PARFAIT |
| `AUOptions` | 4 | 4 = Télécharger ET installer automatiquement | ✅ PARFAIT |
| `ScheduledInstallDay` | 0 | 0 = Tous les jours | ✅ |
| `ScheduledInstallTime` | 3 | 3 = 03h00 du matin | ✅ Hors heures de bureau |

**📊 Valeurs possibles pour AUOptions :**

| Valeur | Signification | Recommandé ? |
|--------|---------------|--------------|
| 1 | Désactivé | ❌ DANGEREUX |
| 2 | Notifier avant téléchargement | ❌ Pas pour serveur |
| 3 | Télécharger mais demander avant installation | 🟡 OK mais pas idéal |
| **4** | **Télécharger ET installer automatiquement** | ✅ **RECOMMANDÉ** |
| 5 | Laisser l'admin local décider | 🟡 OK en environnement géré |

**💻 Exemple de résultat - CAS 2 (PAS BON) :**

```
NoAutoUpdate               : 1
```

**❌ PROBLÈME :**
- `NoAutoUpdate = 1` signifie que les mises à jour automatiques sont **DÉSACTIVÉES**
- Le serveur ne recevra JAMAIS de mises à jour automatiquement
- Il faut les installer manuellement (et spoiler : personne ne le fait !)

**🔧 Correction :**

```powershell
# Active les mises à jour automatiques
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0

# Configure l'installation automatique
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 4

# Planifie l'installation tous les jours à 3h du matin
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallDay" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallTime" -Value 3
```

### ✅ Check #4 : Service Windows Update

#### Commande : Vérifier que le service tourne

```powershell
Get-Service -Name wuauserv
```

**📖 Explication :**
- `Get-Service` = affiche les informations sur un service Windows
- `-Name wuauserv` = le service Windows Update (wuauserv = Windows Update Auto Update Service)

**💻 Exemple de résultat - BIEN :**

```
Status   Name               DisplayName
------   ----               -----------
Running  wuauserv           Windows Update
```

**✅ Analyse :**
- `Status: Running` = Le service tourne actuellement
- C'est parfait !

**💻 Exemple de résultat - PAS BON :**

```
Status   Name               DisplayName
------   ----               -----------
Stopped  wuauserv           Windows Update
```

**❌ PROBLÈME :**
- `Status: Stopped` = Le service est arrêté
- Conséquence : Aucune mise à jour ne sera installée, même en automatique !

**🔧 Correction :**

```powershell
# Démarre le service
Start-Service -Name wuauserv

# Configure le service pour démarrer automatiquement
Set-Service -Name wuauserv -StartupType Automatic

# Vérifie que c'est bon
Get-Service -Name wuauserv
```

**💻 Résultat après correction :**
```
Status   Name               DisplayName
------   ----               -----------
Running  wuauserv           Windows Update
```

✅ **C'est réparé !**

### 🔧 ACTION : Installer les mises à jour maintenant

⚠️ **IMPORTANT :** Installer des mises à jour peut nécessiter un redémarrage. Assure-toi d'avoir :
1. Sauvegardé ton travail
2. Prévenu les utilisateurs
3. Planifié une fenêtre de maintenance si serveur en production

#### Méthode 1 : Via Windows Update (GUI)

**Si tu préfères l'interface graphique :**
1. Ouvre "Paramètres Windows" (Windows + I)
2. Va dans "Windows Update"
3. Clique sur "Rechercher les mises à jour"
4. Clique sur "Télécharger et installer"

#### Méthode 2 : Via PowerShell (pour les pros !)

**Installe d'abord le module PSWindowsUpdate :**

```powershell
# Installe le module (une seule fois)
Install-Module -Name PSWindowsUpdate -Force

# Importe le module
Import-Module PSWindowsUpdate
```

**Cherche et installe les mises à jour :**

```powershell
# Liste les mises à jour disponibles
Get-WindowsUpdate

# Installe TOUTES les mises à jour (ATTENTION : peut redémarrer)
Install-WindowsUpdate -AcceptAll -AutoReboot
```

**💻 Ce que tu vas voir :**

```
ComputerName Status     KB          Size Title
------------ ------     --          ---- -----
SERVER2022   Accepted   KB5034129   250M 2025-01 Cumulative Update for Windows Server 2022
SERVER2022   Accepted   KB5007651    15M Security Update for Microsoft Defender

Reboot is required. Do you want to reboot now? [Y/N]:
```

**Si tu vois "Reboot is required" :**
- `Y` = Redémarre maintenant
- `N` = Redémarre plus tard (mais n'oublie pas !)

**⏳ Temps d'installation :**
- Petites mises à jour : 5-10 minutes
- Cumulative Updates : 15-30 minutes
- Avec redémarrage : Ajoute 5-10 minutes

**💡 Conseil pro :** Utilise l'option `-IgnoreReboot` si tu veux installer sans redémarrer automatiquement :

```powershell
Install-WindowsUpdate -AcceptAll -IgnoreReboot
```

Puis redémarre manuellement quand tu es prêt :
```powershell
Restart-Computer -Force
```

### 📊 Récapitulatif Partie 1

**✅ Checklist - Mises à Jour :**
- [ ] Dernières mises à jour < 30 jours (`Get-HotFix`)
- [ ] Aucune mise à jour critique en attente
- [ ] Windows Update configuré en automatique (`AUOptions = 4`)
- [ ] Service wuauserv actif (`Running`)
- [ ] Mises à jour installées (si nécessaire)
- [ ] Redémarrage effectué (si requis)

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Vérifier l'historique des mises à jour
- ✅ Chercher les mises à jour disponibles
- ✅ Interpréter les niveaux de gravité (Critical, Important, etc.)
- ✅ Configurer Windows Update
- ✅ Installer les mises à jour en PowerShell
- ✅ Comprendre pourquoi c'est VITAL pour la sécurité

**Niveau actuel : 🌟 Débutant → Intermédiaire !**

---

## 🔐 PARTIE 2 : Comptes Utilisateurs - Qui a les Clés du Royaume ?

### 🎓 Concept : Les comptes = Les clés de ton château

**Analogie :** Imagine ton serveur comme un château :
- Le compte **Administrator** = La clé du coffre-fort royal
- Les comptes **utilisateurs normaux** = Clés des chambres
- Les comptes **sans mot de passe** = Portes grandes ouvertes !

**Statistiques qui font peur :**
- 81% des piratages utilisent des identifiants compromis (Verizon DBIR 2024)
- 60% des comptes d'admin utilisent des mots de passe faibles ou réutilisés
- Les comptes "dormants" (inactifs) représentent 30% des comptes et sont rarement surveillés

**Exemples réels :**
- **SolarWinds (2020)** : Compromission via un mot de passe faible ("solarwinds123")
- **Colonial Pipeline (2021)** : Ransomware via un compte VPN sans MFA
- **Target (2013)** : Accès initial via credentials d'un sous-traitant

### ✅ Check #1 : Politique de Mots de Passe

#### Commande : Voir la politique actuelle

```powershell
net accounts
```

**📖 Explication :**
- `net accounts` = affiche la politique de mots de passe locale du serveur
- C'est une commande DOS legacy mais toujours très utile !

**💻 Ce que tu vas voir - CAS 1 (BIEN configuré selon CIS Benchmark) :**

```
Force user logoff how long after time expires?:       Never
Minimum password age (days):                          1
Maximum password age (days):                          365
Minimum password length:                              14
Length of password history maintained:                24
Lockout threshold:                                    5
Lockout duration (minutes):                           15
Lockout observation window (minutes):                 15
Computer role:                                        SERVER
The command completed successfully.
```

**🔍 Analyse ligne par ligne :**

| Paramètre | Valeur IDÉALE | Valeur dans l'exemple | Bon ? |
|-----------|---------------|----------------------|-------|
| `Minimum password age` | 1 jour | 1 | ✅ Empêche de changer trop souvent |
| `Maximum password age` | ≤ 365 jours | 365 | ✅ CIS Level 1 conforme |
| `Minimum password length` | ≥ 14 caractères | 14 | ✅ PARFAIT |
| `Password history` | ≥ 24 | 24 | ✅ Empêche réutilisation |
| `Lockout threshold` | 5 tentatives | 5 | ✅ Protection brute-force |
| `Lockout duration` | ≥ 15 minutes | 15 | ✅ Bloque l'attaquant |
| `Lockout observation window` | 15 minutes | 15 | ✅ Fenêtre de comptage |

**🎨 Explication des paramètres clés :**

**Minimum password length (14 caractères) :**
- 8 caractères = **6 heures** pour cracker (force brute moderne)
- 10 caractères = **5 ans** pour cracker
- **14 caractères** = **200+ millions d'années** pour cracker
- Conclusion : 14 = sécurité réelle !

**Lockout threshold (5 tentatives) :**
- Si quelqu'un essaie 5 mauvais mots de passe → compte verrouillé pendant 15 min
- Bloque les attaques automatisées qui essaient des milliers de mots de passe

**Password history (24) :**
- Le serveur se souvient des 24 derniers mots de passe
- Tu ne peux pas réutiliser "Password123" que tu avais il y a 6 mois

**💻 Exemple CAS 2 (DANGER - Valeurs par défaut Windows) :**

```
Minimum password age (days):                          0
Maximum password age (days):                          42
Minimum password length:                              0
Length of password history maintained:                0
Lockout threshold:                                    Never
```

**🚨 ALERTE ROUGE :**

| Problème | Risque | Gravité |
|----------|--------|---------|
| `Minimum length: 0` | Mots de passe vides autorisés ! | 🔴 CRITIQUE |
| `History: 0` | Réutilisation immédiate de "Password1" | 🔴 CRITIQUE |
| `Lockout: Never` | Attaques brute-force illimitées | 🔴 CRITIQUE |
| `Max age: 42 jours` | Mots de passe changent trop souvent (users écrivent sur post-it) | 🟡 MOYEN |

**🔧 Correction : Appliquer la politique CIS Benchmark Level 1**

```powershell
# ATTENTION : Cette commande change la politique de TOUT le serveur
# Teste d'abord sur un serveur de test !

# Configure la politique de mot de passe via net accounts
net accounts /minpwlen:14 /maxpwage:365 /minpwage:1 /uniquepw:24

# Configure le verrouillage de compte
net accounts /lockoutthreshold:5 /lockoutduration:15 /lockoutwindow:15
```

**💻 Vérification après correction :**
```powershell
net accounts
```

Tu dois maintenant voir les valeurs sécurisées !

**💡 Note importante :** Sur un **Domain Controller**, utilise plutôt :
```powershell
Get-ADDefaultDomainPasswordPolicy
Set-ADDefaultDomainPasswordPolicy -MinPasswordLength 14 -MaxPasswordAge 365.00:00:00 -MinPasswordAge 1.00:00:00 -PasswordHistoryCount 24 -LockoutThreshold 5
```

#### Check supplémentaire : Complexité du mot de passe

```powershell
# Vérifie si la complexité est activée
secedit /export /cfg C:\secpol.cfg
Get-Content C:\secpol.cfg | Select-String -Pattern "PasswordComplexity"
```

**💻 Résultat attendu :**
```
PasswordComplexity = 1
```

**✅ `1` = Activé** (le mot de passe doit contenir au moins 3 des 4 catégories : majuscules, minuscules, chiffres, symboles)

**❌ `0` = Désactivé** (mot de passe peut être "aaaaaaaaaaaa" même avec 14 caractères !)

**🔧 Si désactivé, active-le :**
```powershell
# Via commande secedit
@"
[System Access]
PasswordComplexity = 1
"@ | Out-File C:\secpol_fix.inf

secedit /configure /db C:\Windows\security\local.sdb /cfg C:\secpol_fix.inf /areas SECURITYPOLICY
```

### ✅ Check #2 : Compte Administrator Intégré

#### Commande : Vérifier le statut du compte Administrator

```powershell
Get-LocalUser -Name "Administrator" | Select-Object Name, Enabled, Description, PasswordLastSet, PasswordExpires
```

**📖 Explication :**
- `Get-LocalUser` = récupère les infos d'un compte local
- `-Name "Administrator"` = le compte Administrator intégré de Windows
- `Select-Object ...` = affiche les colonnes qui nous intéressent

**💻 Exemple de résultat - CAS 1 (ACCEPTABLE) :**

```
Name          Enabled Description                      PasswordLastSet      PasswordExpires
----          ------- -----------                      ---------------      ---------------
Administrator   False Built-in account for admin...   1/15/2025 10:00:00 AM
```

**✅ Analyse :**
- `Enabled: False` = Le compte est **désactivé** = ✅ BON
- Un compte désactivé ne peut pas se connecter = sécurité !

**💻 Exemple de résultat - CAS 2 (PAS TERRIBLE mais courant) :**

```
Name          Enabled Description                      PasswordLastSet      PasswordExpires
----          ------- -----------                      ---------------      ---------------
Administrator    True Built-in account for admin...   1/15/2025 10:00:00 AM  4/15/2025
```

**⚠️ Analyse :**
- `Enabled: True` = Le compte est **actif**
- Problème : Le nom "Administrator" est connu de tous les hackers
- Ils vont essayer de deviner le mot de passe (force brute)

**🎯 Meilleures pratiques CIS Benchmark :**

**Option A (Recommandée) :** Renommer + Désactiver
```powershell
# 1. Renomme le compte Administrator
Rename-LocalUser -Name "Administrator" -NewName "SysAdmin_Hidden_2025"

# 2. Désactive-le
Disable-LocalUser -Name "SysAdmin_Hidden_2025"

# 3. Vérifie
Get-LocalUser -Name "SysAdmin_Hidden_2025"
```

**Option B (Si tu DOIS le garder actif) :** Renommer seulement
```powershell
# Renomme avec un nom non-évident
Rename-LocalUser -Name "Administrator" -NewName "SrvAdmin_DC01"

# Change la description pour ne pas indiquer que c'est l'admin
Set-LocalUser -Name "SrvAdmin_DC01" -Description "Service Account"
```

**💡 Astuce pro :** Crée un compte "leurre" nommé "Administrator" sans privilèges :
```powershell
# Crée un faux compte Administrator (honeypot)
New-LocalUser -Name "Administrator_Decoy" -Description "Honeypot" -NoPassword
# Si quelqu'un essaie ce compte, tu sauras que c'est une tentative d'intrusion !
```

### ✅ Check #3 : Compte Guest

#### Commande : Vérifier le compte Guest

```powershell
Get-LocalUser -Name "Guest" | Select-Object Name, Enabled
```

**💻 Résultat ATTENDU :**
```
Name  Enabled
----  -------
Guest   False
```

**✅ `Enabled: False`** = PARFAIT ! Le compte Guest est désactivé.

**❌ Si `Enabled: True`** :
```powershell
# Désactive le compte Guest
Disable-LocalUser -Name "Guest"
```

**🎓 Pourquoi désactiver Guest ?**
- Même avec privilèges limités, il peut servir de point d'entrée
- Un attaquant peut l'utiliser pour la reconnaissance (énumérer les fichiers, les services, etc.)
- Principe de sécurité : **Moins de comptes = Moins de risques**

### ✅ Check #4 : Comptes Administrateurs

#### Commande : Lister TOUS les administrateurs

```powershell
Get-LocalGroupMember -Group "Administrators"
```

**📖 Explication :**
- `Get-LocalGroupMember` = liste les membres d'un groupe local
- `-Group "Administrators"` = le groupe des administrateurs locaux

**💻 Exemple de résultat - BIEN :**

```
ObjectClass Name                       PrincipalSource
----------- ----                       ---------------
User        SERVER2022\SysAdmin_Hidden Local
User        SERVER2022\JohnDoe_Admin   Local
Group       DOMAIN\Domain Admins       ActiveDirectory
```

**✅ Analyse :**
- **2-3 comptes** administrateurs locaux = Nombre raisonnable
- Nom renommé (SysAdmin_Hidden) = Bon
- Domain Admins présent = Normal sur un serveur membre du domaine

**💻 Exemple de résultat - PROBLÈME :**

```
ObjectClass Name                       PrincipalSource
----------- ----                       ---------------
User        SERVER2022\Administrator   Local
User        SERVER2022\admin           Local
User        SERVER2022\root            Local
User        SERVER2022\test            Local
User        SERVER2022\backup          Local
User        SERVER2022\JohnDoe         Local
User        SERVER2022\SQLService      Local
Group       DOMAIN\Domain Admins       ActiveDirectory
```

**🚨 Problèmes identifiés :**

| Compte | Problème | Risque |
|--------|----------|--------|
| `Administrator` | Nom par défaut pas renommé | 🔴 Cible facile |
| `admin`, `root` | Noms évidents | 🔴 Première tentative des hackers |
| `test` | Compte de test oublié ? | 🟠 Probablement inutilisé |
| `backup` | Compte de service ? | 🔴 Mot de passe jamais changé ? |
| `JohnDoe` | Compte utilisateur normal avec droits admin | 🟠 Violation principe moindre privilège |
| `SQLService` | Compte de service SQL | 🔴 CRITIQUE si admin du domaine |

**🔧 Actions à prendre :**

```powershell
# 1. Inventorier et documenter chaque compte admin
Get-LocalGroupMember -Group "Administrators" | ForEach-Object {
    $user = $_.Name.Split('\')[1]
    try {
        $lastLogon = (Get-LocalUser -Name $user -ErrorAction Stop).LastLogon
        [PSCustomObject]@{
            Name = $_.Name
            LastLogon = $lastLogon
            DaysSinceLogon = if($lastLogon){(New-TimeSpan -Start $lastLogon -End (Get-Date)).Days}else{"Never"}
        }
    } catch {
        [PSCustomObject]@{
            Name = $_.Name
            LastLogon = "N/A (Domain/Group)"
            DaysSinceLogon = "N/A"
        }
    }
}
```

**💻 Résultat :**
```
Name                       LastLogon              DaysSinceLogon
----                       ---------              --------------
SERVER2022\Administrator   1/10/2025 10:00:00 AM  5
SERVER2022\test            12/1/2024 3:00:00 PM   45
SERVER2022\backup                                 Never
```

**✅ Compte utilisé récemment** (< 30 jours) = OK à garder
**⚠️ Compte non utilisé depuis 30-90 jours** = À investiguer
**❌ Compte jamais utilisé ou > 90 jours** = **À SUPPRIMER**

```powershell
# 2. Supprimer les comptes inutilisés
Remove-LocalUser -Name "test"
Remove-LocalGroupMember -Group "Administrators" -Member "backup"

# 3. Créer des comptes admin dédiés (principe: 1 personne = 1 compte admin dédié)
# Exemple: John Doe a son compte "jdoe" normal + "jdoe-admin" pour admin
New-LocalUser -Name "jdoe-admin" -Description "Admin account for John Doe" -PasswordNeverExpires:$false
Add-LocalGroupMember -Group "Administrators" -Member "jdoe-admin"
```

### 📊 Récapitulatif Partie 2

**✅ Checklist - Comptes Utilisateurs :**
- [ ] Politique de mot de passe : ≥ 14 caractères, complexité activée
- [ ] Expiration : ≤ 365 jours
- [ ] Historique : ≥ 24 mots de passe
- [ ] Verrouillage : 5 tentatives, 15 minutes
- [ ] Compte Administrator renommé ou désactivé
- [ ] Compte Guest désactivé
- [ ] Nombre d'administrateurs ≤ 5
- [ ] Tous les comptes admin documentés et justifiés
- [ ] Comptes inactifs > 90 jours supprimés
- [ ] Pas de comptes de service dans Administrators

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Auditer la politique de mots de passe
- ✅ Calculer la sécurité d'un mot de passe (longueur vs temps de crack)
- ✅ Sécuriser le compte Administrator
- ✅ Identifier les comptes à risque
- ✅ Appliquer le principe du moindre privilège
- ✅ Nettoyer les comptes dormants

**Niveau actuel : 🌟🌟 Intermédiaire → Intermédiaire+ !**

---

## 🖥️ PARTIE 3 : Bureau à Distance (RDP) - Sécuriser la Porte d'Entrée

### 🎓 Concept : RDP = La porte principale de ton serveur

**Analogie :** RDP (Remote Desktop Protocol), c'est comme la porte d'entrée principale de ton immeuble :
- **Bien sécurisée** = Digicode, interphone, caméra, gardien
- **Mal sécurisée** = Porte ouverte avec un panneau "Entrez librement !"

**Statistiques alarmantes :**
- **RDP est la cible #1 des ransomwares** (90% des attaques l'utilisent)
- Un serveur Windows avec RDP exposé sur Internet reçoit **~10 000 tentatives d'attaque par jour**
- En moyenne, un serveur RDP mal configuré est compromis en **moins de 24 heures**

**Exemples réels :**
- **Colonial Pipeline (2021)** : Ransomware via RDP non protégé par MFA
- **Kaseya (2021)** : RDP compromis → REvil ransomware → 1 500 entreprises impactées
- **Banques russes (2023)** : 25 millions $ volés via brute-force RDP

### ✅ Check #1 : RDP est-il activé ?

#### Commande : Vérifier le statut RDP

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
```

**📖 Explication :**
- `Get-ItemProperty` = lit une clé du registre Windows
- `fDenyTSConnections` = **f**lag **Deny** **T**erminal **S**ervices **Connections**
  - `0` = RDP est **AUTORISÉ** (activé)
  - `1` = RDP est **REFUSÉ** (désactivé)

**💻 Exemple de résultat - CAS 1 (RDP DÉSACTIVÉ - IDÉAL si non utilisé) :**

```
fDenyTSConnections : 1
```

**✅ Analyse :**
- `1` = RDP est **désactivé**
- Si tu n'utilises pas RDP = **C'est PARFAIT !**
- Principe de sécurité : Ce qui n'est pas actif ne peut pas être attaqué

**💻 Exemple de résultat - CAS 2 (RDP ACTIVÉ - À sécuriser) :**

```
fDenyTSConnections : 0
```

**⚠️ Analyse :**
- `0` = RDP est **actif**
- Ce n'est pas mauvais EN SOI, mais il FAUT le sécuriser correctement !
- Continue les checks suivants pour sécuriser RDP

**🔧 Si RDP n'est PAS nécessaire, désactive-le :**

```powershell
# Désactive RDP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1

# Désactive aussi la règle du pare-feu
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Vérifie
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
```

**💡 Question importante :** "Mais si je désactive RDP, comment je me connecte à mon serveur ?"

**Réponses :**
1. **En local** (console directe, KVM)
2. **Via PowerShell Remoting** (WinRM) - plus sécurisé que RDP
3. **Via un bastion/jump server** avec RDP activé uniquement là
4. **Via VPN** puis RDP (ajoute une couche de sécurité)

### ✅ Check #2 : Network Level Authentication (NLA)

**C'est quoi NLA ?** = Authentification AVANT d'établir la session RDP

**Sans NLA :**
1. Attaquant se connecte à RDP
2. Voit l'écran de login Windows
3. Essaie 10 000 mots de passe
4. Peut exploiter des vulnérabilités de la stack RDP

**Avec NLA :**
1. Attaquant doit s'authentifier AVANT même de voir l'écran
2. Impossible d'exploiter les vulnérabilités de l'écran de login
3. Protection contre BlueKeep (CVE-2019-0708) et autres CVE RDP

#### Commande : Vérifier si NLA est actif

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication"
```

**💻 Résultat ATTENDU :**
```
UserAuthentication : 1
```

**✅ `1` = NLA est **ACTIVÉ** = PARFAIT**

**❌ `0` = NLA est **DÉSACTIVÉ** = DANGER**

**🔧 Active NLA si désactivé :**

```powershell
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# Redémarre le service RDP pour appliquer
Restart-Service -Name TermService -Force
```

### ✅ Check #3 : Niveau de Chiffrement RDP

#### Commande : Vérifier le niveau de chiffrement

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel"
```

**💻 Résultat ATTENDU :**
```
MinEncryptionLevel : 3
```

**🔍 Valeurs possibles :**

| Valeur | Niveau | Chiffrement | Sécurité |
|--------|--------|-------------|----------|
| 1 | Low | 56-bit | ❌ OBSOLÈTE (crackable) |
| 2 | Client Compatible | Négocié | 🟡 Selon client |
| **3** | **High** | **128-bit (AES)** | ✅ **RECOMMANDÉ** |
| 4 | FIPS Compliant | FIPS 140-2 | ✅ Requis pour gouvernement US |

**🔧 Force le chiffrement maximum :**

```powershell
# Niveau 3 = High (128-bit)
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel" -Value 3

# Niveau 4 = FIPS (si requis par compliance)
# Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "MinEncryptionLevel" -Value 4
```

### ✅ Check #4 : Couche de Sécurité (TLS vs RDP)

#### Commande : Vérifier la couche de sécurité

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer"
```

**💻 Résultat ATTENDU :**
```
SecurityLayer : 2
```

**🔍 Valeurs possibles :**

| Valeur | Protocole | Sécurité |
|--------|-----------|----------|
| 0 | RDP natif | ❌ OBSOLÈTE (vulnérabilités connues) |
| 1 | Negotiate | 🟡 Dépend du client |
| **2** | **SSL/TLS** | ✅ **RECOMMANDÉ** (HTTPS-like) |

**🔧 Force SSL/TLS :**

```powershell
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value 2
```

### ✅ Check #5 : Port RDP

#### Commande : Voir le port RDP

```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber"
```

**💻 Résultat par défaut :**
```
PortNumber : 3389
```

**🎯 Port 3389 = Port RDP par défaut**

**Problème :** TOUS les hackers scannent le port 3389 sur Internet
- Scans automatisés 24/7
- Attaques ciblées sur 3389

**💡 Option (débattue) : Changer le port**

**Pour :**
- Réduit le bruit (scans automatisés)
- "Security through obscurity" partielle

**Contre :**
- Ne protège PAS contre un attaquant déterminé
- Peut compliquer la maintenance

**🔧 Si tu décides de changer le port :**

```powershell
# Change le port RDP (exemple: 13389)
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "PortNumber" -Value 13389

# Ajoute une règle de pare-feu pour le nouveau port
New-NetFirewallRule -DisplayName "RDP Custom Port" -Direction Inbound -LocalPort 13389 -Protocol TCP -Action Allow

# Désactive l'ancienne règle sur le port 3389
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Redémarre le service
Restart-Service -Name TermService -Force
```

**⚠️ IMPORTANT après changement de port :**
Pour te connecter, utilise :
```
mstsc /v:server_ip:13389
```

### ✅ Check #6 : Règles Pare-feu RDP

#### Commande : Voir les règles RDP du pare-feu

```powershell
Get-NetFirewallRule -DisplayName "*Remote Desktop*" | Select-Object DisplayName, Enabled, Direction, Action
```

**💻 Exemple de résultat :**

```
DisplayName                                      Enabled Direction Action
-----------                                      ------- --------- ------
Remote Desktop - User Mode (TCP-In)                True Inbound   Allow
Remote Desktop - User Mode (UDP-In)                True Inbound   Allow
Remote Desktop - Shadow (TCP-In)                  False Inbound   Allow
```

**✅ Ce qui est BON :**
- Règles RDP activées SEULEMENT si tu utilises RDP
- Direction `Inbound` (entrant)
- Action `Allow`

**⚠️ MAIS il manque une chose CRITIQUE : La restriction par IP !**

#### Commande : Vérifier si les règles sont restreintes par IP

```powershell
Get-NetFirewallRule -DisplayName "*Remote Desktop*" | Get-NetFirewallAddressFilter
```

**💻 Exemple DANGEREUX :**

```
LocalAddress  : Any
RemoteAddress : Any
```

**🚨 PROBLÈME :**
- `RemoteAddress: Any` = N'importe qui sur Internet peut essayer de se connecter !
- Exposition maximale aux attaques

**🔧 SOLUTION : Restreindre RDP aux IPs autorisées**

```powershell
# Supprime les règles RDP par défaut
Remove-NetFirewallRule -DisplayGroup "Remote Desktop"

# Crée une nouvelle règle RESTREINTE à ton IP
New-NetFirewallRule -DisplayName "RDP - IP Restreinte Admin" `
    -Direction Inbound `
    -LocalPort 3389 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress "192.168.1.100/32"  # TON IP !

# Ou pour un réseau entier (VPN par exemple)
New-NetFirewallRule -DisplayName "RDP - Réseau VPN" `
    -Direction Inbound `
    -LocalPort 3389 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress "10.0.1.0/24"  # Ton réseau VPN
```

**💡 Si tu as plusieurs IPs autorisées :**

```powershell
New-NetFirewallRule -DisplayName "RDP - IPs Autorisées" `
    -Direction Inbound `
    -LocalPort 3389 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress @("192.168.1.100","192.168.1.101","10.5.1.50")
```

### 🔧 Configuration RDP COMPLÈTE ET SÉCURISÉE

Voici un script complet pour sécuriser RDP comme un pro :

```powershell
# ============================================
# SCRIPT DE SÉCURISATION RDP COMPLET
# ============================================

Write-Host "=== SÉCURISATION RDP ===" -ForegroundColor Cyan

# 1. Active NLA (Network Level Authentication)
Write-Host "[1/6] Activation NLA..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
    -Name "UserAuthentication" -Value 1

# 2. Force SSL/TLS
Write-Host "[2/6] Force SSL/TLS..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
    -Name "SecurityLayer" -Value 2

# 3. Force chiffrement maximum (128-bit)
Write-Host "[3/6] Force chiffrement High..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
    -Name "MinEncryptionLevel" -Value 3

# 4. Configure le timeout d'inactivité (15 minutes)
Write-Host "[4/6] Configure timeout inactivité..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
    -Name "MaxIdleTime" -Value 900000  # 15 minutes en millisecondes

# 5. Désactive les anciennes règles de pare-feu
Write-Host "[5/6] Nettoyage pare-feu..." -ForegroundColor Yellow
Remove-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

# 6. Crée une règle restreinte par IP
Write-Host "[6/6] Création règle pare-feu restreinte..." -ForegroundColor Yellow
$AdminIP = Read-Host "Entre l'IP autorisée pour RDP (ex: 192.168.1.100)"
New-NetFirewallRule -DisplayName "RDP - IP Admin Autorisée" `
    -Direction Inbound `
    -LocalPort 3389 `
    -Protocol TCP `
    -Action Allow `
    -RemoteAddress $AdminIP `
    -Profile Any

# Redémarre le service RDP
Write-Host "Redémarrage service RDP..." -ForegroundColor Yellow
Restart-Service -Name TermService -Force

Write-Host "`n=== RDP SÉCURISÉ ! ===" -ForegroundColor Green
Write-Host "NLA: Activé" -ForegroundColor Green
Write-Host "SSL/TLS: Forcé" -ForegroundColor Green
Write-Host "Chiffrement: 128-bit" -ForegroundColor Green
Write-Host "Pare-feu: Restreint à $AdminIP" -ForegroundColor Green
```

### 📊 Récapitulatif Partie 3

**✅ Checklist - RDP Sécurisé :**
- [ ] RDP désactivé si non utilisé (`fDenyTSConnections = 1`)
- [ ] Si RDP actif :
  - [ ] NLA activé (`UserAuthentication = 1`)
  - [ ] SSL/TLS forcé (`SecurityLayer = 2`)
  - [ ] Chiffrement High (`MinEncryptionLevel = 3`)
  - [ ] Port changé (optionnel mais recommandé)
  - [ ] Pare-feu restreint par IP source (CRITIQUE)
  - [ ] Timeout d'inactivité configuré
- [ ] Testé la connexion RDP depuis IP autorisée
- [ ] Vérifié que connexion est refusée depuis autres IPs

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Comprendre les risques RDP (pourquoi c'est LA cible #1)
- ✅ Activer Network Level Authentication (NLA)
- ✅ Configurer le chiffrement RDP
- ✅ Forcer SSL/TLS pour RDP
- ✅ Restreindre RDP par adresse IP (CRUCIAL)
- ✅ Changer le port RDP (optionnel)
- ✅ Appliquer une configuration RDP sécurisée complète

**Niveau actuel : 🌟🌟🌟 Intermédiaire+ → Avancé !**

---

## 🛡️ PARTIE 4 : Pare-feu Windows Defender - La Première Ligne de Défense

### 🎓 Concept : Le Pare-feu = Le Mur d'enceinte de ton Château

**Analogie :** Le pare-feu Windows Defender, c'est le mur d'enceinte de ton château :
- **Activé** = Mur haut et solide, avec gardes aux portes
- **Désactivé** = Pas de mur, tout le monde entre et sort librement

**Principe fondamental :** **Deny by default, allow by exception**
- Par défaut, tout est **BLOQUÉ**
- Tu autorises SEULEMENT ce qui est nécessaire

**Statistiques :**
- 43% des PME n'ont PAS de pare-feu actif sur leurs serveurs (Cybint 2023)
- Un serveur sans pare-feu sur Internet est scanné en moyenne **5 minutes** après sa mise en ligne

### ✅ Check #1 : Pare-feu Actif sur Tous les Profils

Windows a **3 profils** de pare-feu :
1. **Domain** = Quand le serveur est connecté à un domaine Active Directory
2. **Private** = Réseau privé/local
3. **Public** = Réseaux publics (WiFi café, etc.)

**IMPORTANT :** Le pare-feu doit être actif sur LES 3 profils !

#### Commande : Vérifier le statut du pare-feu

```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled
```

**💻 Résultat ATTENDU :**

```
Name    Enabled
----    -------
Domain     True
Private    True
Public     True
```

**✅ Analyse :**
- Les 3 profils affichent `Enabled: True`
- **PARFAIT !** Ton serveur est protégé dans tous les contextes réseau

**❌ PROBLÈME - Si un profil est désactivé :**

```
Name    Enabled
----    -------
Domain     True
Private   False    ← PROBLÈME !
Public     True
```

**Risque :** Si ton serveur est sur un réseau considéré comme "Private" sans pare-feu = **porte grande ouverte !**

**🔧 Correction :**

```powershell
# Active le pare-feu sur TOUS les profils
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True

# Vérifie
Get-NetFirewallProfile | Select-Object Name, Enabled
```

### ✅ Check #2 : Politique Par Défaut

#### Commande : Vérifier les actions par défaut

```powershell
Get-NetFirewallProfile | Select-Object Name, DefaultInboundAction, DefaultOutboundAction
```

**💻 Résultat ATTENDU (configuration sécurisée) :**

```
Name    DefaultInboundAction DefaultOutboundAction
----    -------------------- ---------------------
Domain  Block                Allow
Private Block                Allow
Public  Block                Allow
```

**🔍 Analyse :**

| Paramètre | Valeur IDÉALE | Signification |
|-----------|---------------|---------------|
| `DefaultInboundAction` | **Block** | Tout le trafic ENTRANT est bloqué par défaut |
| `DefaultOutboundAction` | **Allow** | Le trafic SORTANT est autorisé par défaut |

**💡 Pourquoi cette configuration ?**

**Inbound (entrant) = Block :**
- Empêche les connexions non sollicitées depuis Internet
- Tu dois explicitement autoriser chaque service (RDP, HTTP, etc.)
- Sécurité maximale

**Outbound (sortant) = Allow :**
- Le serveur peut accéder aux mises à jour Windows
- Peut contacter les serveurs DNS, NTP, etc.
- Plus pratique pour l'administration

**⚠️ Configuration TRÈS restrictive (pour environnements ultra-sécurisés) :**

```powershell
# Bloque AUSSI le trafic sortant par défaut
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultOutboundAction Block
```

**Note :** Si tu fais ça, tu devras autoriser CHAQUE connexion sortante (Windows Update, DNS, etc.). Réservé aux environnements avec besoin de traçabilité maximale.

**❌ PROBLÈME - DefaultInboundAction = Allow :**

```
Name    DefaultInboundAction DefaultOutboundAction
----    -------------------- ---------------------
Domain  Allow                Allow    ← DANGER !
```

**Risque :** N'importe qui peut se connecter à n'importe quel port !

**🔧 Correction URGENTE :**

```powershell
Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block -DefaultOutboundAction Allow
```

### ✅ Check #3 : Règles Entrantes Actives

#### Commande : Lister toutes les règles entrantes actives

```powershell
Get-NetFirewallRule -Direction Inbound -Enabled True | Select-Object DisplayName, Action, Profile | Sort-Object DisplayName
```

**💻 Exemple de résultat :**

```
DisplayName                                    Action Profile
-----------                                    ------ -------
Core Networking - Destination Unreachable...  Allow  Any
Core Networking - Dynamic Port (ICMPv6-In)    Allow  Any
File and Printer Sharing (Echo Request -...   Allow  Domain
Remote Desktop - User Mode (TCP-In)           Allow  Domain
Windows Remote Management (HTTP-In)           Allow  Domain
```

**🔍 Ce qu'il faut vérifier :**

1. **Nombre de règles** : Idéalement < 20 règles
   - Plus tu as de règles = Plus la surface d'attaque est grande

2. **Chaque règle doit être justifiée** :
   - ✅ "Remote Desktop" si tu utilises RDP
   - ✅ "WinRM" si tu utilises PowerShell Remoting
   - ❌ "File and Printer Sharing" si tu ne partages rien

3. **Profil** : Sur quel(s) profil(s) la règle est active
   - `Domain` = OK pour services internes
   - `Public` = ⚠️ Attention ! Exposé sur réseaux publics

**⚠️ Règles DANGEREUSES à vérifier :**

| Règle | Risque | Action |
|-------|--------|--------|
| File and Printer Sharing | Partages accessibles | Désactiver si non utilisé |
| Remote Desktop (sur profil Public) | RDP exposé sur réseaux publics | Restreindre au profil Domain/Private |
| Network Discovery | Énumération réseau | Désactiver sur Public |
| Remote Event Log Management | Accès aux logs à distance | Désactiver si non nécessaire |

**🔧 Désactiver une règle inutile :**

```powershell
# Désactive File and Printer Sharing
Disable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

# Désactive Network Discovery
Disable-NetFirewallRule -DisplayGroup "Network Discovery"

# Vérifie qu'elles sont désactivées
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Select-Object DisplayName, Enabled
```

### ✅ Check #4 : Règles avec Adresses Sources "Any"

**C'est LE check le plus important !**

Les règles qui autorisent **n'importe quelle IP source** (RemoteAddress = Any) sont les plus dangereuses.

#### Commande : Trouver les règles "Any/Any"

```powershell
Get-NetFirewallRule -Direction Inbound -Enabled True | Get-NetFirewallAddressFilter | Where-Object {$_.RemoteAddress -eq 'Any'} | ForEach-Object {
    $rule = Get-NetFirewallRule -AssociatedNetFirewallAddressFilter $_
    [PSCustomObject]@{
        DisplayName = $rule.DisplayName
        RemoteAddress = $_.RemoteAddress
        Profile = $rule.Profile
    }
} | Select-Object -First 20
```

**💻 Exemple de résultat :**

```
DisplayName                              RemoteAddress Profile
-----------                              ------------- -------
Remote Desktop - User Mode (TCP-In)      Any           Domain, Private, Public
Windows Remote Management (HTTP-In)      Any           Domain
Core Networking - Destination Unreac...  Any           Any
```

**🎯 Analyse règle par règle :**

**Règle : Remote Desktop - RemoteAddress: Any**

**Problème :** N'importe qui sur Internet peut essayer de se connecter en RDP !

**Solution :** Restreindre aux IPs admin (déjà vu dans Partie 3)

```powershell
# Supprime la règle RDP par défaut
Remove-NetFirewallRule -DisplayGroup "Remote Desktop"

# Recrée avec restriction IP
New-NetFirewallRule -DisplayName "RDP - Admin IP Only" -Direction Inbound -LocalPort 3389 -Protocol TCP -Action Allow -RemoteAddress "192.168.1.100"
```

**Règle : Core Networking**

**Analyse :** Les règles "Core Networking" sont souvent nécessaires pour le fonctionnement réseau de base (ICMP, etc.)

**Action :** Garder, mais vérifier si vraiment nécessaire

### ✅ Check #5 : Empêcher les Utilisateurs de Désactiver le Pare-feu

**Scénario :** Un admin junior ou un utilisateur avec droits locaux désactive le pare-feu "pour tester un truc" et oublie de le réactiver...

#### Commande : Vérifier si le pare-feu peut être désactivé localement

Via GPO (Group Policy), tu peux **verrouiller** le pare-feu.

**🔧 Configuration recommandée (via GPO ou registre) :**

```powershell
# Empêche la désactivation du pare-feu pour le profil Domain
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DisableNotifications" -Value 1

# Empêche les utilisateurs de désactiver le pare-feu
# (Nécessite GPO pour être vraiment efficace)
```

**💡 Meilleure pratique :** Utilise Group Policy pour forcer l'activation du pare-feu sur tous les serveurs du domaine.

### 📊 Récapitulatif Partie 4

**✅ Checklist - Pare-feu Windows Defender :**
- [ ] Pare-feu activé sur les 3 profils (Domain, Private, Public)
- [ ] DefaultInboundAction = Block (sur tous les profils)
- [ ] DefaultOutboundAction = Allow (ou Block si très restrictif)
- [ ] Nombre de règles entrantes < 20
- [ ] Toutes les règles actives justifiées et documentées
- [ ] Règles dangereuses désactivées (File Sharing, Network Discovery sur Public)
- [ ] RDP restreint par IP (si actif)
- [ ] Aucune règle "Any/Any" inutile
- [ ] Pare-feu verrouillé via GPO (impossible à désactiver)

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Comprendre les 3 profils de pare-feu Windows
- ✅ Vérifier et activer le pare-feu sur tous les profils
- ✅ Configurer les politiques par défaut (Block/Allow)
- ✅ Auditer les règles entrantes actives
- ✅ Identifier les règles dangereuses (RemoteAddress: Any)
- ✅ Désactiver les règles inutiles
- ✅ Restreindre les règles par adresse IP source

**Niveau actuel : 🌟🌟🌟🌟 Avancé !**

---

## 🦠 PARTIE 5 : Windows Defender - Ton Antivirus Intégré

### 🎓 Concept : Windows Defender = Le Système Immunitaire de ton Serveur

**Analogie :** Windows Defender, c'est comme le système immunitaire de ton corps :
- **Actif** = Détecte et élimine les virus en temps réel
- **Désactivé** = Tu attrapes toutes les maladies qui passent

**Windows Defender est GRATUIT, intégré à Windows, et très efficace !**

**Statistiques :**
- Windows Defender détecte **99,7%** des malwares connus (AV-Comparatives 2024)
- Protection en temps réel bloque **5+ milliards** de menaces par mois
- Mais 30% des serveurs l'ont désactivé "pour des raisons de performance" 🤦

### ✅ Check #1 : Windows Defender Est-il Actif ?

#### Commande : Vérifier le statut complet

```powershell
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled, BehaviorMonitorEnabled, IoavProtectionEnabled, AntivirusSignatureLastUpdated
```

**💻 Résultat ATTENDU :**

```
AntivirusEnabled              : True
RealTimeProtectionEnabled     : True
BehaviorMonitorEnabled        : True
IoavProtectionEnabled         : True
AntivirusSignatureLastUpdated : 1/16/2025 2:00:00 AM
```

**🔍 Analyse complète :**

| Paramètre | Valeur IDÉALE | Signification |
|-----------|---------------|---------------|
| `AntivirusEnabled` | **True** | Windows Defender est activé |
| `RealTimeProtectionEnabled` | **True** | Scan en temps réel des fichiers |
| `BehaviorMonitorEnabled` | **True** | Détection par comportement (heuristique) |
| `IoavProtectionEnabled` | **True** | Protection Office (macros malveillantes) |
| `AntivirusSignatureLastUpdated` | **< 7 jours** | Signatures à jour |

**📚 Explication des protections :**

**RealTimeProtection (Temps Réel) :**
- Scanne CHAQUE fichier que tu ouvres/télécharges
- Bloque les malwares AVANT qu'ils ne s'exécutent
- **C'est LA protection la plus importante !**

**BehaviorMonitor (Surveillance Comportementale) :**
- Détecte les malwares **sans signature** connue
- Exemple : Un fichier essaie d'accéder à 1000 fichiers en 2 secondes = Comportement de ransomware → BLOQUÉ !

**IoavProtection (Office et navigateur) :**
- Protège contre les documents Office malveillants (macros)
- Scanne les téléchargements depuis les navigateurs

**❌ PROBLÈME - Defender désactivé :**

```
AntivirusEnabled              : False   ← DANGER !
RealTimeProtectionEnabled     : False   ← DANGER !
```

**🔧 Correction URGENTE :**

```powershell
# Active toutes les protections
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableIOAVProtection $false

# Vérifie
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled
```

### ✅ Check #2 : Signatures Antivirus À Jour

#### Commande : Voir la date des dernières signatures

```powershell
Get-MpComputerStatus | Select-Object AntivirusSignatureLastUpdated, AntivirusSignatureVersion, NISSignatureLastUpdated
```

**💻 Résultat ATTENDU :**

```
AntivirusSignatureLastUpdated : 1/16/2025 2:00:00 AM
AntivirusSignatureVersion     : 1.405.217.0
NISSignatureLastUpdated       : 1/16/2025 2:00:00 AM
```

**🎯 Dates à vérifier :**

| Ancienneté | Statut | Action |
|------------|--------|--------|
| < 24 heures | ✅ EXCELLENT | RAS |
| 1-7 jours | 🟡 ACCEPTABLE | Mettre à jour |
| 7-30 jours | 🟠 PROBLÈME | Mettre à jour MAINTENANT |
| > 30 jours | 🔴 CRITIQUE | Serveur probablement infecté |

**💡 Pourquoi c'est important ?**

Chaque jour, **350 000 nouveaux malwares** sont créés. Des signatures vieilles de 30 jours = Tu ne détectes PAS 10+ millions de malwares récents !

**🔧 Mettre à jour les signatures :**

```powershell
# Met à jour les signatures immédiatement
Update-MpSignature

# Vérifie la nouvelle date
Get-MpComputerStatus | Select-Object AntivirusSignatureLastUpdated
```

**⏱️ Temps de mise à jour :** 30 secondes à 2 minutes selon ta connexion

### ✅ Check #3 : Exclusions (Le Point Faible)

**Les exclusions** = Fichiers/dossiers que Windows Defender **NE scanne PAS**

**Pourquoi c'est dangereux ?**
- Les malwares adorent se cacher dans les dossiers exclus
- Un attaquant qui compromet ton serveur va essayer d'ajouter des exclusions

#### Commande : Lister toutes les exclusions

```powershell
Get-MpPreference | Select-Object ExclusionPath, ExclusionExtension, ExclusionProcess
```

**💻 Résultat IDÉAL :**

```
ExclusionPath      :
ExclusionExtension :
ExclusionProcess   :
```

**(Vide = Aucune exclusion = ✅ PARFAIT !)**

**💻 Résultat ACCEPTABLE (avec justifications) :**

```
ExclusionPath      : {C:\DatabaseFiles, C:\TempBuild}
ExclusionExtension : {}
ExclusionProcess   : {sqlservr.exe}
```

**✅ Analyse :**
- `C:\DatabaseFiles` = Fichiers de base de données (performance)
- `sqlservr.exe` = SQL Server (exclusion courante recommandée par Microsoft)

**Ces exclusions DOIVENT être :**
1. **Documentées** (tu sais pourquoi elles existent)
2. **Justifiées** (vraie raison de performance ou compatibilité)
3. **Minimales** (le moins possible)

**❌ EXCLUSIONS DANGEREUSES :**

```
ExclusionPath      : {C:\, C:\Windows\System32, C:\Users}
ExclusionExtension : {.exe, .dll, .ps1}
ExclusionProcess   : {}
```

**🚨 ALERTE ROUGE :**

| Exclusion | Problème |
|-----------|----------|
| `C:\` | Windows Defender ne scanne PLUS RIEN sur le disque C: ! |
| `C:\Windows\System32` | Dossier système pas scanné = Malware peut s'y cacher |
| `*.exe` | AUCUN exécutable scanné = Defender complètement contourné |
| `*.ps1` | Scripts PowerShell malveillants pas détectés |

**Ces exclusions = Désactiver complètement Windows Defender !**

**🔧 Supprimer les exclusions dangereuses :**

```powershell
# Supprime TOUTES les exclusions de chemins
Remove-MpPreference -ExclusionPath (Get-MpPreference).ExclusionPath

# Supprime les exclusions d'extensions
Remove-MpPreference -ExclusionExtension (Get-MpPreference).ExclusionExtension

# Vérifie
Get-MpPreference | Select-Object ExclusionPath, ExclusionExtension
```

**⚠️ Attention :** Si des exclusions sont légitimes (SQL Server, etc.), ne les supprime pas toutes ! Supprime seulement les dangereuses :

```powershell
# Supprime UNE exclusion spécifique
Remove-MpPreference -ExclusionPath "C:\"
Remove-MpPreference -ExclusionExtension ".exe"
```

### ✅ Check #4 : Cloud Protection et Soumission d'Échantillons

Windows Defender peut envoyer des fichiers suspects à Microsoft pour analyse en temps réel.

#### Commande : Vérifier Cloud Protection

```powershell
Get-MpPreference | Select-Object MAPSReporting, SubmitSamplesConsent
```

**💻 Résultat RECOMMANDÉ :**

```
MAPSReporting        : Advanced
SubmitSamplesConsent : SendAllSamples
```

**🔍 Valeurs possibles :**

**MAPSReporting** (Microsoft Active Protection Service) :

| Valeur | Niveau | Recommandé ? |
|--------|--------|--------------|
| Disabled | Pas de cloud | ❌ Perd 30% d'efficacité |
| Basic | Protection basique | 🟡 OK |
| **Advanced** | **Protection maximale** | ✅ **RECOMMANDÉ** |

**SubmitSamplesConsent** :

| Valeur | Signification | Recommandé ? |
|--------|---------------|--------------|
| NeverSend | Ne jamais envoyer | ❌ |
| PromptBeforeSending | Demander | 🟡 Serveur = pas d'utilisateur pour répondre |
| **SendAllSamples** | **Envoyer automatiquement** | ✅ **RECOMMANDÉ** |

**🔧 Activer Cloud Protection :**

```powershell
# Active Cloud Protection au niveau Advanced
Set-MpPreference -MAPSReporting Advanced

# Autorise l'envoi automatique d'échantillons
Set-MpPreference -SubmitSamplesConsent SendAllSamples
```

**💡 Confidentialité :** Si tu as des fichiers ultra-confidentiels, tu peux mettre `MAPSReporting: Basic` au lieu d'Advanced.

### ✅ Check #5 : Historique des Menaces Détectées

#### Commande : Voir les dernières menaces

```powershell
Get-MpThreatDetection | Select-Object -First 10
```

**💻 Si aucune menace détectée (PARFAIT) :**

```
(Vide)
```

**💻 Si menaces détectées :**

```
ActionSuccess     : True
DomainUser        : NT AUTHORITY\SYSTEM
InitialDetectionTime : 1/15/2025 10:23:45 AM
ProcessName       : C:\Users\Admin\Downloads\setup.exe
Resources         : {file:_C:\Users\Admin\Downloads\setup.exe}
ThreatID          : 2147735503
ThreatName        : Trojan:Win32/Meterpreter.A
```

**🔍 Analyse :**

| Champ | Valeur | Signification |
|-------|--------|---------------|
| `ActionSuccess` | True | Menace bloquée avec succès ✅ |
| `ThreatName` | Trojan:Win32/Meterpreter.A | Type de malware détecté |
| `ProcessName` | setup.exe | Fichier infecté |
| `InitialDetectionTime` | Date | Quand la menace a été détectée |

**✅ Si `ActionSuccess: True`** = Windows Defender a bloqué la menace, tout va bien !

**❌ Si `ActionSuccess: False`** = La menace N'A PAS été bloquée → Investigation nécessaire !

**🔧 Si menace non bloquée :**

```powershell
# Lance un scan complet immédiatement
Start-MpScan -ScanType FullScan

# Nettoie les menaces détectées
Remove-MpThreat

# Vérifie qu'il n'y a plus de menaces actives
Get-MpThreat
```

### 📊 Récapitulatif Partie 5

**✅ Checklist - Windows Defender :**
- [ ] AntivirusEnabled = True
- [ ] RealTimeProtectionEnabled = True
- [ ] BehaviorMonitorEnabled = True
- [ ] Signatures < 7 jours
- [ ] Exclusions justifiées uniquement (idéalement aucune)
- [ ] Pas d'exclusions larges (C:\, *.exe, etc.)
- [ ] Cloud Protection activé (MAPSReporting = Advanced)
- [ ] Soumission automatique d'échantillons activée
- [ ] Historique des menaces vérifié
- [ ] Aucune menace active non bloquée

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Vérifier le statut complet de Windows Defender
- ✅ Comprendre les différentes protections (temps réel, comportementale, IOAV)
- ✅ Mettre à jour les signatures antivirus
- ✅ Auditer et nettoyer les exclusions dangereuses
- ✅ Activer Cloud Protection pour efficacité maximale
- ✅ Analyser l'historique des menaces détectées
- ✅ Lancer des scans manuels en cas de suspicion

**Niveau actuel : 🌟🌟🌟🌟🌟 Avancé+ !**

---

## 📝 PARTIE 6 : Audit et Journalisation - Ne Rien Rater

### 🎓 Concept : Les Logs = La Boîte Noire de ton Serveur

**Analogie :** Les logs Windows, c'est comme la boîte noire d'un avion :
- **Avec logs** = Tu peux remonter le fil de toute action (qui s'est connecté, quand, depuis où)
- **Sans logs** = Un piratage se produit, tu ne sauras jamais comment

**Statistiques terrifiantes :**
- **277 jours** = Temps moyen pour détecter une intrusion (IBM Security 2024)
- 60% des entreprises n'ont PAS de logs d'audit configurés
- Sans logs, impossible de prouver une compromission ou respecter les normes (RGPD, PCI-DSS, etc.)

### ✅ Check #1 : Politique d'Audit Avancée

Windows peut auditer des dizaines d'événements. On va se concentrer sur les **critiques**.

#### Commande : Voir la politique d'audit actuelle

```powershell
auditpol /get /category:*
```

**💻 Résultat (extrait) :**

```
System Audit Policy
Category/Subcategory                      Setting
Logon/Logoff
  Logon                                   Success and Failure
  Logoff                                  Success
  Account Lockout                         Failure
  Special Logon                           Success

Account Management
  User Account Management                 Success and Failure
  Security Group Management               Success

Policy Change
  Audit Policy Change                     Success
  Authentication Policy Change            Success
```

**🔍 Configuration RECOMMANDÉE (CIS Benchmark Level 1) :**

| Catégorie | Sous-catégorie | Audit | Pourquoi |
|-----------|----------------|-------|----------|
| **Logon/Logoff** | Logon | Success + Failure | Voir qui se connecte (et qui échoue) |
| | Logoff | Success | Voir quand quelqu'un se déconnecte |
| | Account Lockout | Failure | Détecte les attaques brute-force |
| | Special Logon | Success | Connexions avec privilèges élevés |
| **Account Management** | User Account Management | Success + Failure | Détecte création/suppression de comptes |
| | Security Group Management | Success | Modification des groupes admin |
| **Policy Change** | Audit Policy Change | Success | Détecte si quelqu'un change les audits |
| | Authentication Policy Change | Success | Modification politique de mot de passe |
| **Privilege Use** | Sensitive Privilege Use | Success + Failure | Utilisation de droits sensibles |
| **System** | Security State Change | Success | Démarrage/arrêt du serveur |
| | System Integrity | Success + Failure | Violation d'intégrité système |

**✅ Pourquoi "Success AND Failure" ?**

- **Success** = Actions réussies (qui s'est connecté)
- **Failure** = Actions échouées (tentatives d'intrusion !)

**Exemple :**
- `Logon: Success` → Tu vois : "Admin s'est connecté à 10h"
- `Logon: Failure` → Tu vois : "Quelqu'un a essayé le mot de passe 'Password123' 50 fois depuis une IP chinoise"

**🔧 Activer les audits recommandés :**

```powershell
# Logon/Logoff
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Logoff" /success:enable
auditpol /set /subcategory:"Account Lockout" /failure:enable
auditpol /set /subcategory:"Special Logon" /success:enable

# Account Management
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable

# Policy Change
auditpol /set /subcategory:"Audit Policy Change" /success:enable
auditpol /set /subcategory:"Authentication Policy Change" /success:enable

# Privilege Use
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable

# System
auditpol /set /subcategory:"Security State Change" /success:enable
auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable

# Vérifie que c'est appliqué
auditpol /get /category:*
```

### ✅ Check #2 : Taille du Journal de Sécurité

Les logs sont stockés dans le **journal de sécurité** (Security log).

**Problème :** Par défaut, le journal fait seulement **20 MB** → Il se remplit en quelques jours et écrase les vieux logs !

#### Commande : Voir la taille actuelle

```powershell
Get-EventLog -List | Where-Object {$_.Log -eq "Security"}
```

**💻 Résultat :**

```
Max(K) Retain OverflowAction        Entries Log
------ ------ --------------        ------- ---
20,480      0 OverwriteAsNeeded      15,234 Security
```

**🔍 Analyse :**

| Champ | Valeur | Signification | Bon ? |
|-------|--------|---------------|-------|
| `Max(K)` | 20,480 | Taille max = 20 MB | ❌ TROP PETIT |
| `OverflowAction` | OverwriteAsNeeded | Écrase les vieux logs quand plein | ⚠️ Perte d'historique |
| `Entries` | 15,234 | Nombre d'événements actuels | ℹ️ |

**🎯 Taille RECOMMANDÉE :**

| Environnement | Taille recommandée |
|---------------|--------------------|
| Serveur peu sollicité | **100 MB** minimum |
| Serveur normal | **512 MB** à **1 GB** |
| Serveur critique/AD/DC | **2 GB** à **4 GB** |

**🔧 Augmenter la taille à 1 GB :**

```powershell
# Augmente la taille à 1 GB (1073741824 octets)
wevtutil sl Security /ms:1073741824

# Vérifie
Get-EventLog -List | Where-Object {$_.Log -eq "Security"}
```

**💻 Résultat après modification :**

```
Max(K)    Retain OverflowAction        Entries Log
------    ------ --------------        ------- ---
1,048,576      0 OverwriteAsNeeded      15,234 Security
```

**✅ `Max(K): 1,048,576` = 1 GB !**

### ✅ Check #3 : Événements de Connexion Récents

#### Commande : Voir les 20 dernières connexions réussies

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 20 | Select-Object TimeCreated, Message | Format-List
```

**🎓 Event ID Windows importants :**

| Event ID | Signification | Bon/Mauvais |
|----------|---------------|-------------|
| **4624** | Connexion réussie | Voir qui se connecte |
| **4625** | Connexion échouée | ⚠️ Tentatives d'intrusion |
| **4720** | Compte créé | Surveiller créations suspectes |
| **4726** | Compte supprimé | Surveiller suppressions |
| **4728** | Membre ajouté à groupe sécurité | Qui devient admin ? |
| **4732** | Membre ajouté au groupe Administrators local | Escalade de privilèges |
| **4776** | Tentative authentification NTLM | Surveiller attaques pass-the-hash |

**💻 Exemple Event ID 4624 (connexion réussie) :**

```
TimeCreated : 1/16/2025 10:23:45 AM
Message     : An account was successfully logged on.

Subject:
    Security ID:        S-1-0-0
    Account Name:       -
    Account Domain:     -
    Logon ID:           0x0

Logon Information:
    Logon Type:         10
    Restricted Admin Mode: -
    Virtual Account:    No
    Elevated Token:     Yes

New Logon:
    Security ID:        S-1-5-21-xxx-xxx-xxx-1000
    Account Name:       Administrator
    Account Domain:     SERVER2022
    Logon ID:           0x123456

Network Information:
    Workstation Name:   LAPTOP-ADMIN
    Source Network Address: 192.168.1.100
    Source Port:        54321
```

**🔍 Infos importantes :**

| Champ | Valeur | Signification |
|-------|--------|---------------|
| `Logon Type` | 10 | RemoteInteractive (RDP) |
| `Account Name` | Administrator | Qui s'est connecté |
| `Source Network Address` | 192.168.1.100 | Depuis quelle IP |

**📊 Logon Types courants :**

| Logon Type | Méthode | Exemple |
|------------|---------|---------|
| 2 | Interactive | Console locale |
| 3 | Network | Accès partage réseau |
| 4 | Batch | Tâche planifiée |
| 5 | Service | Démarrage service |
| **10** | **RemoteInteractive** | **RDP** |
| 11 | CachedInteractive | Connexion hors-ligne |

**🔧 Voir les connexions ÉCHOUÉES (Event ID 4625) :**

```powershell
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 20 | ForEach-Object {
    $xml = [xml]$_.ToXml()
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        Account = $xml.Event.EventData.Data[5].'#text'
        SourceIP = $xml.Event.EventData.Data[19].'#text'
        FailureReason = $xml.Event.EventData.Data[8].'#text'
    }
}
```

**💻 Exemple (attaque brute-force détectée) :**

```
TimeCreated   Account      SourceIP        FailureReason
-----------   -------      --------        -------------
1/16 03:45:12 admin        185.220.101.42  0xc000006d (Bad username or password)
1/16 03:45:15 administrator 185.220.101.42 0xc000006d (Bad username or password)
1/16 03:45:18 root         185.220.101.42  0xc000006d (Bad username or password)
1/16 03:45:21 test         185.220.101.42  0xc000006d (Bad username or password)
```

**🚨 ATTAQUE DÉTECTÉE !**
- Même IP essaie plusieurs comptes
- Intervalle de 3 secondes = Script automatique
- IP étrangère (185.x.x.x)

**✅ Solution :** Vérifie que Fail2Ban (ou équivalent Windows) a banni cette IP !

### 📊 Récapitulatif Partie 6

**✅ Checklist - Audit et Journalisation :**
- [ ] Politique d'audit avancée configurée (auditpol)
- [ ] Connexions (Logon/Logoff) : Success + Failure
- [ ] Gestion des comptes : Success + Failure
- [ ] Changements de politique : Success
- [ ] Taille journal Security ≥ 512 MB (idéalement 1 GB)
- [ ] Rétention configurée (ne pas écraser trop vite)
- [ ] Logs vérifiés régulièrement
- [ ] Event IDs critiques surveillés (4624, 4625, 4720, etc.)
- [ ] Centralisation des logs (SIEM/Syslog) - optionnel mais recommandé

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Configurer la politique d'audit avancée Windows
- ✅ Comprendre les Event IDs importants
- ✅ Augmenter la taille du journal de sécurité
- ✅ Analyser les connexions (réussies et échouées)
- ✅ Détecter les tentatives d'intrusion dans les logs
- ✅ Identifier les Logon Types (RDP, réseau, service, etc.)
- ✅ Créer des filtres PowerShell pour extraire les événements critiques

**Niveau actuel : 🌟🌟🌟🌟🌟🌟 Expert !**

---

## 🛠️ Partie 7 : Services Windows - La Chasse aux Portes Dérobées

### 🎯 Concept : Les services, c'est quoi ?

Imagine ton serveur comme un immeuble. Les **services** sont les boutiques ouvertes 24/7 au rez-de-chaussée : imprimerie, accueil, surveillance, maintenance, etc.

**Le problème** : Plus tu as de boutiques ouvertes, plus tu offres de points d'entrée aux cambrioleurs ! 🚪🚪🚪

**En sécurité** :
- **Moins de services = Moins de surface d'attaque**
- Chaque service qui tourne est une cible potentielle
- Certains services ont des failles connues (PrintNightmare = 💥)

### 📊 Quelques statistiques qui font réfléchir

- **Print Spooler** (service d'impression) : Responsable de **PrintNightmare** (CVE-2021-34527), une faille critique qui a permis à des hackers de prendre le contrôle total de millions de serveurs Windows en 2021
- **Remote Registry** : Utilisé dans **90% des attaques par ransomware** pour modifier la configuration à distance
- **SNMP** : Protocole ancien qui envoie les mots de passe en **clair** sur le réseau
- Selon le **CIS Benchmark** : Un serveur Windows avec configuration par défaut a environ **180 services installés**, mais seulement **60-80 sont réellement nécessaires** pour un serveur web ou applicatif

**Exemples d'attaques réelles** :
- **PrintNightmare (2021)** : Exploitation du service Print Spooler → Exécution de code à distance → Prise de contrôle totale
- **EternalBlue (2017)** : Exploitation du service SMBv1 → WannaCry → 200 000+ ordinateurs infectés → 4 milliards de dollars de dégâts

### 🔍 Vérification 1 : Inventaire des services en cours d'exécution

**Commande** :

```powershell
Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object Name, DisplayName, StartType | Sort-Object DisplayName | Format-Table -AutoSize
```

**Décortiquons la commande** :

| Partie de la commande | Signification |
|----------------------|---------------|
| `Get-Service` | Liste **tous** les services Windows (démarrés ou arrêtés) |
| `Where-Object {$_.Status -eq 'Running'}` | Filtre pour ne garder que ceux qui tournent **actuellement** |
| `Select-Object Name, DisplayName, StartType` | Affiche le nom technique, le nom affiché, et le type de démarrage |
| `Sort-Object DisplayName` | Trie par ordre alphabétique du nom affiché |
| `Format-Table -AutoSize` | Affichage en tableau avec colonnes ajustées automatiquement |

**Exemple de résultat** :

```
Name                          DisplayName                                    StartType
----                          -----------                                    ---------
AdobeARMservice               Adobe Acrobat Update Service                   Automatic
Appinfo                       Application Information                        Manual
AudioEndpointBuilder          Windows Audio Endpoint Builder                 Automatic
Audiosrv                      Windows Audio                                  Automatic
BFE                           Base Filtering Engine                          Automatic
BITS                          Background Intelligent Transfer Service        Manual
Browser                       Computer Browser                               Manual
CertPropSvc                   Certificate Propagation                        Manual
CryptSvc                      Cryptographic Services                         Automatic
DcomLaunch                    DCOM Server Process Launcher                   Automatic
Dhcp                          DHCP Client                                    Automatic
Dnscache                      DNS Client                                     Automatic
eventlog                      Windows Event Log                              Automatic
EventSystem                   COM+ Event System                              Automatic
FontCache                     Windows Font Cache Service                     Automatic
gpsvc                         Group Policy Client                            Automatic
IKEEXT                        IKE and AuthIP IPsec Keying Modules           Automatic
iphlpsvc                      IP Helper                                      Automatic
LanmanServer                  Server                                         Automatic
LanmanWorkstation             Workstation                                    Automatic
lmhosts                       TCP/IP NetBIOS Helper                         Manual
mpssvc                        Windows Defender Firewall                      Automatic
MpsSvc                        Windows Firewall                               Automatic
MSDTC                         Distributed Transaction Coordinator            Automatic
msiserver                     Windows Installer                              Manual
NetTcpPortSharing             Net.Tcp Port Sharing Service                   Disabled
Netlogon                      Netlogon                                       Automatic
Netman                        Network Connections                            Manual
nsi                           Network Store Interface Service                Automatic
PlugPlay                      Plug and Play                                  Automatic
PolicyAgent                   IPsec Policy Agent                            Manual
Power                         Power                                          Automatic
ProfSvc                       User Profile Service                           Automatic
RpcEptMapper                  RPC Endpoint Mapper                           Automatic
RpcSs                         Remote Procedure Call (RPC)                    Automatic
SamSs                         Security Accounts Manager                      Automatic
Schedule                      Task Scheduler                                 Automatic
seclogon                      Secondary Logon                                Manual
SENS                          System Event Notification Service              Automatic
SessionEnv                    Remote Desktop Configuration                   Manual
SharedAccess                  Internet Connection Sharing (ICS)              Disabled
ShellHWDetection              Shell Hardware Detection                       Automatic
Spooler                       Print Spooler                                  Automatic
SSDPSRV                       SSDP Discovery                                Manual
SstpSvc                       Secure Socket Tunneling Protocol Service       Manual
SysMain                       Superfetch                                     Automatic
TabletInputService            Tablet PC Input Service                        Disabled
TapiSrv                       Telephony                                      Manual
TermService                   Remote Desktop Services                        Manual
Themes                        Themes                                         Automatic
TrkWks                        Distributed Link Tracking Client              Automatic
TrustedInstaller              Windows Modules Installer                      Manual
UI0Detect                     Interactive Services Detection                 Manual
UmRdpService                  Remote Desktop Services UserMode Port Redirector Manual
UxSms                         Desktop Window Manager Session Manager         Automatic
VaultSvc                      Credential Manager                            Manual
vds                           Virtual Disk                                   Manual
VSS                           Volume Shadow Copy                             Manual
W32Time                       Windows Time                                   Automatic
Wcmsvc                        Windows Connection Manager                     Automatic
WdiServiceHost                Diagnostic Service Host                        Manual
WdiSystemHost                 Diagnostic System Host                         Manual
WinDefend                     Windows Defender Antivirus Service            Automatic
Wecsvc                        Windows Event Collector                        Manual
WinHttpAutoProxySvc           WinHTTP Web Proxy Auto-Discovery Service      Manual
Winmgmt                       Windows Management Instrumentation            Automatic
WinRM                         Windows Remote Management (WS-Management)      Automatic
Wlansvc                       WLAN AutoConfig                               Manual
wmiApSrv                      WMI Performance Adapter                       Manual
WPDBusEnum                    Portable Device Enumerator Service            Manual
wscsvc                        Security Center                                Automatic
wuauserv                      Windows Update                                 Manual
wudfsvc                       Windows Driver Foundation - User-mode Driver Framework Manual
```

**Analyse de ce résultat** :

Sur ce serveur, on voit **70+ services en cours d'exécution**. C'est beaucoup ! Regardons les suspects :

| Service | Nom Technique | Problème Potentiel | Risque |
|---------|--------------|-------------------|--------|
| Print Spooler | `Spooler` | PrintNightmare (CVE-2021-34527) - RCE | 🔴 **CRITIQUE** |
| Computer Browser | `Browser` | Obsolète depuis Windows 10, failles connues | 🟠 **ÉLEVÉ** |
| Remote Registry | `RemoteRegistry` | Permet modification registre à distance | 🔴 **CRITIQUE** |
| SSDP Discovery | `SSDPSRV` | Utilisé pour UPnP, souvent exploité | 🟠 **ÉLEVÉ** |
| Bluetooth Support Service | `bthserv` | Sur un serveur ?? Aucune utilité | 🟡 **MOYEN** |
| Interactive Services Detection | `UI0Detect` | Ancien mécanisme, rarement nécessaire | 🟡 **MOYEN** |

### 🎯 Vérification 2 : Services dangereux à désactiver

Voici une liste des services souvent **inutiles** sur un serveur et qui représentent des **risques de sécurité** :

**Commande pour vérifier un service spécifique** :

```powershell
Get-Service -Name "Spooler" | Select-Object Name, DisplayName, Status, StartType
```

#### 🔴 Services CRITIQUES à désactiver

**1. Print Spooler (Spooler)** - PrintNightmare

```powershell
# Vérifier
Get-Service -Name "Spooler"

# Si Status = Running et que tu n'as PAS besoin d'imprimantes :
Stop-Service -Name "Spooler" -Force
Set-Service -Name "Spooler" -StartupType Disabled
```

**Pourquoi ?**
- **PrintNightmare** : Faille critique permettant l'exécution de code à distance
- Microsoft a publié des correctifs, MAIS de nouvelles variantes continuent d'apparaître
- Si ton serveur n'imprime pas = **AUCUNE raison de laisser ce service actif**

**Scénario ✅ BON** :
```
Name     : Spooler
Status   : Stopped
StartType: Disabled
```
👉 Print Spooler désactivé, serveur protégé contre PrintNightmare !

**Scénario ❌ DANGER** :
```
Name     : Spooler
Status   : Running
StartType: Automatic
```
👉 Print Spooler actif sur un serveur web qui n'imprime jamais = Surface d'attaque inutile !

---

**2. Remote Registry (RemoteRegistry)**

```powershell
# Vérifier
Get-Service -Name "RemoteRegistry"

# Désactiver (sauf cas très spécifique)
Stop-Service -Name "RemoteRegistry" -Force
Set-Service -Name "RemoteRegistry" -StartupType Disabled
```

**Pourquoi ?**
- Permet de modifier le **registre Windows** (configuration système) **à distance**
- Utilisé par les ransomwares pour désactiver l'antivirus, créer des comptes, etc.
- **99% des serveurs n'en ont PAS besoin**

**Scénario ✅ BON** :
```
Name     : RemoteRegistry
Status   : Stopped
StartType: Disabled
```

**Scénario ❌ DANGER** :
```
Name     : RemoteRegistry
Status   : Running
StartType: Automatic
```

---

**3. SNMP Service (SNMP)** - Si présent

```powershell
# Vérifier (peut ne pas être installé)
Get-Service -Name "SNMP" -ErrorAction SilentlyContinue

# Si présent et inutile :
Stop-Service -Name "SNMP" -Force
Set-Service -Name "SNMP" -StartupType Disabled
```

**Pourquoi ?**
- Protocole de monitoring **très ancien** (années 1990)
- Version SNMPv1 et v2 : Mots de passe ("community strings") envoyés en **clair**
- Si tu as besoin de monitoring : Utilise des outils modernes (Prometheus, Zabbix, etc.)

---

#### 🟠 Services à examiner (selon ton usage)

**4. Computer Browser (Browser)**

```powershell
Get-Service -Name "Browser" -ErrorAction SilentlyContinue
Stop-Service -Name "Browser" -Force
Set-Service -Name "Browser" -StartupType Disabled
```

**Pourquoi ?**
- Obsolète depuis Windows 10
- Sert à "parcourir le voisinage réseau" (fonctionnalité des années 2000)
- Failles de sécurité connues

---

**5. SSDP Discovery (SSDPSRV)** - UPnP

```powershell
Get-Service -Name "SSDPSRV"
Stop-Service -Name "SSDPSRV" -Force
Set-Service -Name "SSDPSRV" -StartupType Disabled
```

**Pourquoi ?**
- Utilisé pour la découverte automatique de périphériques (imprimantes, TV, etc.)
- Protocole **UPnP** : Historiquement très vulnérable
- Sur un serveur : Aucune utilité

---

**6. Bluetooth Support Service (bthserv)** - Si présent

```powershell
Get-Service -Name "bthserv" -ErrorAction SilentlyContinue
Stop-Service -Name "bthserv" -Force
Set-Service -Name "bthserv" -StartupType Disabled
```

**Pourquoi ?**
- Bluetooth sur un serveur ? 🤔
- Vecteur d'attaque supplémentaire (BlueBorne, etc.)

---

### 🔍 Vérification 3 : Services avec comptes à privilèges

**Le risque** : Un service qui tourne avec un compte **Domain Admin** ou **Administrateur local**, c'est une **catastrophe** en attente !

**Pourquoi ?**
- Si le service est compromis, l'attaquant hérite des privilèges du compte
- **Principe du moindre privilège** : Chaque service doit avoir **uniquement** les droits nécessaires

**Commande pour auditer** :

```powershell
Get-WmiObject Win32_Service | Where-Object {$_.StartMode -eq "Auto" -or $_.State -eq "Running"} | Select-Object Name, DisplayName, StartName, State | Format-Table -AutoSize
```

**Décortiquons** :

| Partie | Explication |
|--------|-------------|
| `Get-WmiObject Win32_Service` | Récupère TOUS les services via WMI (Windows Management Instrumentation) |
| `Where-Object {$_.StartMode -eq "Auto" -or $_.State -eq "Running"}` | Filtre : Démarrage automatique OU actuellement en cours d'exécution |
| `Select-Object Name, DisplayName, StartName, State` | Affiche : Nom technique, nom affiché, **compte utilisé**, état |
| `StartName` | 👈 **C'est LE champ critique** : Quel compte exécute ce service ? |

**Exemple de résultat** :

```
Name               DisplayName                                StartName                      State
----               -----------                                ---------                      -----
AdobeARMservice    Adobe Acrobat Update Service               LocalSystem                    Running
Appinfo            Application Information                    LocalSystem                    Stopped
BITS               Background Intelligent Transfer Service    LocalSystem                    Running
CryptSvc           Cryptographic Services                     NT AUTHORITY\NetworkService    Running
Dhcp               DHCP Client                                NT AUTHORITY\LocalService      Running
Dnscache           DNS Client                                 NT AUTHORITY\NetworkService    Running
eventlog           Windows Event Log                          NT AUTHORITY\LocalService      Running
LanmanServer       Server                                     LocalSystem                    Running
MSSQLSERVER        SQL Server (MSSQLSERVER)                   DOMAIN\sqlservice_account      Running
MyAppService       Application Métier Critique                DOMAIN\Administrator           Running  ❌
Spooler            Print Spooler                              LocalSystem                    Running
W32Time            Windows Time                               NT AUTHORITY\LocalService      Running
WinDefend          Windows Defender Antivirus Service         LocalSystem                    Running
```

**Analyse** :

| Compte Utilisé | Niveau de Privilège | Utilisation Recommandée | Risque |
|----------------|---------------------|------------------------|--------|
| `LocalSystem` | **MAXIMUM** - Contrôle total du système | Services système Windows uniquement | 🔴 Si service tiers |
| `NT AUTHORITY\NetworkService` | Moyen - Peut accéder au réseau | Services réseau Microsoft | 🟢 Acceptable |
| `NT AUTHORITY\LocalService` | Faible - Accès local limité | Services locaux simples | ✅ Idéal |
| `DOMAIN\Administrator` | **CATASTROPHIQUE** | **JAMAIS !** | 🔴🔴🔴 |
| `DOMAIN\sqlservice_account` | Dépend des permissions du compte | Si compte dédié avec droits minimaux | 🟡 À vérifier |

**🚨 PROBLÈME DÉTECTÉ** :
```
MyAppService    Application Métier Critique    DOMAIN\Administrator    Running
```

👉 Un service applicatif qui tourne avec le compte **Administrateur du domaine** !

**Conséquences si ce service est compromis** :
1. L'attaquant hérite des droits **Administrateur du domaine**
2. Il peut créer des comptes, modifier les GPO, accéder à TOUS les serveurs du domaine
3. C'est le **jackpot** pour un hacker 💰

**Correction URGENTE** :

```powershell
# 1. Créer un compte de service dédié avec droits minimaux
# (À faire dans Active Directory Users and Computers)
# Exemple: DOMAIN\svc_myapp

# 2. Modifier le service pour utiliser ce compte
$service = Get-WmiObject Win32_Service -Filter "Name='MyAppService'"
$service.Change($null,$null,$null,$null,$null,$null,"DOMAIN\svc_myapp","MotDePasseComplexe123!")

# 3. Redémarrer le service
Restart-Service -Name "MyAppService"

# 4. Vérifier
Get-WmiObject Win32_Service -Filter "Name='MyAppService'" | Select-Object Name, StartName
```

**Résultat attendu** :
```
Name          StartName
----          ---------
MyAppService  DOMAIN\svc_myapp
```

✅ Service désormais avec un compte dédié à droits limités !

---

### 📋 Récapitulatif : Services Windows

**Checklist de sécurité** :

- [ ] Inventaire des services en cours d'exécution réalisé
- [ ] Print Spooler (Spooler) : **Désactivé** si pas d'imprimantes
- [ ] Remote Registry : **Désactivé**
- [ ] SNMP : **Désactivé** ou **supprimé**
- [ ] Computer Browser : **Désactivé**
- [ ] SSDP Discovery : **Désactivé**
- [ ] Bluetooth : **Désactivé** sur serveur
- [ ] Aucun service avec compte `Administrator` ou `Domain Admin`
- [ ] Services tiers avec comptes de service dédiés à droits minimaux
- [ ] Documentation des services nécessaires et justification
- [ ] Révision trimestrielle de la liste des services actifs

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Lister les services Windows en cours d'exécution
- ✅ Identifier les services dangereux (Print Spooler, Remote Registry, SNMP)
- ✅ Comprendre PrintNightmare et son impact
- ✅ Désactiver proprement un service Windows
- ✅ Auditer les comptes utilisés par les services
- ✅ Appliquer le principe du moindre privilège aux services
- ✅ Utiliser WMI pour récupérer des informations détaillées

**Niveau actuel : 🌟🌟🌟🌟🌟🌟🌟 Expert Avancé !**

---

## 🌐 Partie 8 : Partages Réseau (SMB) - Verrouiller les Coffres-Forts

### 🎯 Concept : SMB, c'est quoi ?

**SMB** (Server Message Block) = Le protocole qui permet de **partager des fichiers et des imprimantes** entre ordinateurs Windows.

**L'analogie** : Imagine SMB comme un système de **coffres-forts partagés** dans une banque.
- Chaque coffre = Un partage réseau (`\\serveur\partage`)
- Certains ont des **serrures solides** (SMB3 avec chiffrement)
- D'autres ont des **serrures cassées** (SMBv1 = portes ouvertes !)

### 📊 Statistiques qui font froid dans le dos

- **SMBv1** : Protocole des années **1990**, plein de failles de sécurité
- **EternalBlue** (2017) : Exploit SMBv1 utilisé par **WannaCry** → 200 000+ victimes → 4 milliards $ de dégâts
- **NotPetya** (2017) : Ransomware via SMBv1 → 10 milliards $ de dégâts (Maersk, FedEx, Merck...)
- Selon Microsoft : **SMBv1 devrait être supprimé depuis 2017**, mais encore présent sur 30% des serveurs Windows

**Exemples d'attaques réelles** :
- **WannaCry (2017)** : Exploit EternalBlue (SMBv1) → Hôpitaux paralysés, usines arrêtées
- **NotPetya (2017)** : Propagation via SMBv1 → Pertes estimées à 10 milliards de dollars
- **Emotet (2018-2021)** : Trojan se propageant via partages SMB mal sécurisés

### 🔍 Vérification 1 : Inventaire des partages réseau

**Commande** :

```powershell
Get-SmbShare | Select-Object Name, Path, Description, CurrentUsers | Format-Table -AutoSize
```

**Décortiquons** :

| Partie | Explication |
|--------|-------------|
| `Get-SmbShare` | Liste **tous** les partages SMB sur le serveur |
| `Select-Object Name, Path, Description, CurrentUsers` | Affiche : Nom du partage, chemin local, description, utilisateurs connectés |
| `CurrentUsers` | Nombre d'utilisateurs **actuellement** connectés au partage |

**Exemple de résultat** :

```
Name       Path                    Description                           CurrentUsers
----       ----                    -----------                           ------------
ADMIN$     C:\Windows              Administration à distance                        0
C$         C:\                     Partage par défaut                              0
IPC$                               IPC distant                                      2
Backup     D:\Backups              Sauvegardes serveurs                            5
Public     D:\Public               Fichiers publics entreprise                    23
Projets    E:\Projets              Projets en cours                               12
OldFiles   F:\Archives\Old         Anciens fichiers 2015                           0
```

**Analyse** :

| Partage | Type | Risque | Explication |
|---------|------|--------|-------------|
| `ADMIN$` | Système | 🟡 | Partage administratif par défaut (C:\Windows) - Nécessaire pour administration à distance |
| `C$` | Système | 🟠 | Partage de TOUT le disque C: - Très dangereux si mal protégé |
| `IPC$` | Système | 🟢 | Inter-Process Communication - Nécessaire au fonctionnement |
| `Backup` | Utilisateur | 🔴 | **CRITIQUE** : Sauvegardes = cible n°1 des ransomwares ! |
| `Public` | Utilisateur | 🟡 | Fichiers publics - Vérifier les permissions |
| `Projets` | Utilisateur | 🟡 | Vérifier qui a accès |
| `OldFiles` | Utilisateur | 🟠 | **PROBLÈME** : 0 utilisateurs connectés = Probablement inutile, surface d'attaque inutile |

**🚨 Problèmes détectés** :
1. Partage `C$` accessible (tout le disque !)
2. Partage `OldFiles` : 0 utilisateurs → À supprimer
3. Partage `Backup` : **5 utilisateurs connectés** → Qui sont-ils ? Ont-ils vraiment besoin d'accéder aux sauvegardes ?

---

### 🔍 Vérification 2 : Permissions sur les partages

**Commande pour vérifier les permissions d'un partage** :

```powershell
Get-SmbShareAccess -Name "Backup" | Format-Table -AutoSize
```

**Exemple de résultat** :

```
Name   ScopeName AccountName          AccessControlType AccessRight
----   --------- -----------          ----------------- -----------
Backup *         Everyone             Allow             Full
```

**❌ CATASTROPHE !**

**Analyse** :
- `Everyone` = **Tout le monde** (tous les utilisateurs du réseau)
- `Full` = **Contrôle total** (lecture, écriture, suppression, modification permissions)

👉 **N'importe qui sur le réseau peut lire, modifier, ou SUPPRIMER les sauvegardes !**

**Scénario d'attaque ransomware** :
1. Hacker compromet un poste utilisateur (phishing, etc.)
2. Scanne le réseau, trouve le partage `\\serveur\Backup`
3. Accède avec le compte utilisateur compromis (Everyone = accès garanti)
4. **CHIFFRE ou SUPPRIME toutes les sauvegardes**
5. Chiffre ensuite le serveur principal
6. Demande une rançon → Vous n'avez **PLUS DE SAUVEGARDES** pour restaurer

👉 **C'est exactement ce qui s'est passé avec Colonial Pipeline, Kaseya, et des milliers d'entreprises**

---

**Vérification ✅ BON** (exemple sur un autre partage) :

```powershell
Get-SmbShareAccess -Name "Projets"
```

```
Name    ScopeName AccountName               AccessControlType AccessRight
----    --------- -----------               ----------------- -----------
Projets *         DOMAIN\Groupe_Projets     Allow             Change
Projets *         DOMAIN\Admins_IT          Allow             Full
Projets *         DOMAIN\Users              Deny              Full
```

**Analyse** :
- `DOMAIN\Groupe_Projets` : Lecture + Écriture (Change)
- `DOMAIN\Admins_IT` : Contrôle total (Full)
- `DOMAIN\Users` : **Refus explicite** (Deny)

✅ Permissions restrictives, accès limité aux groupes autorisés !

---

### 🛠️ Correction : Sécuriser les permissions du partage Backup

```powershell
# 1. Retirer l'accès "Everyone"
Revoke-SmbShareAccess -Name "Backup" -AccountName "Everyone" -Force

# 2. Ajouter uniquement les comptes de service backup
Grant-SmbShareAccess -Name "Backup" -AccountName "DOMAIN\svc_backup" -AccessRight Full -Force

# 3. Ajouter les admins IT (lecture seule pour vérification)
Grant-SmbShareAccess -Name "Backup" -AccountName "DOMAIN\Admins_IT" -AccessRight Read -Force

# 4. Vérifier
Get-SmbShareAccess -Name "Backup"
```

**Résultat attendu** :
```
Name   ScopeName AccountName          AccessControlType AccessRight
----   --------- -----------          ----------------- -----------
Backup *         DOMAIN\svc_backup    Allow             Full
Backup *         DOMAIN\Admins_IT     Allow             Read
```

✅ Seul le compte de service backup et les admins IT peuvent accéder !

---

### 🔍 Vérification 3 : SMBv1 activé ? (DANGER)

**La vérification LA PLUS CRITIQUE** de cette partie !

**Commande** :

```powershell
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
```

**Scénario ❌ DANGER** :

```
FeatureName      : SMB1Protocol
DisplayName      : SMB 1.0/CIFS File Sharing Support
Description      : Support for the SMB 1.0/CIFS file sharing protocol...
RestartRequired  : Possible
State            : Enabled  ❌❌❌
```

👉 **SMBv1 est ACTIVÉ** → Ton serveur est vulnérable à **EternalBlue** et toutes les failles SMBv1 !

**Scénario ✅ BON** :

```
FeatureName      : SMB1Protocol
State            : Disabled  ✅
```

ou même mieux :

```
Get-WindowsOptionalFeature : Impossible de trouver la fonctionnalité 'SMB1Protocol'
```

👉 SMBv1 complètement supprimé du système !

---

**Correction URGENTE : Désactiver SMBv1**

```powershell
# Méthode 1 : Désactiver la fonctionnalité
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

# Méthode 2 : Désactiver via la clé de registre (pour être sûr)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Type DWord -Force

# Méthode 3 : Désactiver le pilote SMBv1
sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi
sc.exe config mrxsmb10 start= disabled

# Vérifier
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
```

**Résultat attendu** :
```
State : Disabled
```

**⚠️ IMPORTANT** : Un **redémarrage** est généralement nécessaire pour que la désactivation soit complète.

```powershell
# Planifier un redémarrage (par exemple dans 10 minutes)
shutdown /r /t 600 /c "Redémarrage pour désactivation SMBv1"

# Annuler le redémarrage si besoin
shutdown /a
```

---

### 🔍 Vérification 4 : SMB Signing (Signature SMB)

**Concept** : La signature SMB garantit que les paquets réseau ne sont **pas modifiés** en transit.

**Analogie** : C'est comme un **sceau de cire** sur une lettre royale. Si quelqu'un ouvre la lettre pour la modifier, le sceau est cassé, et tu le vois immédiatement.

**Sans signature** : Un attaquant en position "Man-in-the-Middle" peut **modifier** les paquets SMB (changer les données, injecter du code, etc.)

**Commande** :

```powershell
Get-SmbServerConfiguration | Select-Object EnableSecuritySignature, RequireSecuritySignature
```

**Décortiquons** :

| Paramètre | Signification | Valeur Recommandée |
|-----------|---------------|-------------------|
| `EnableSecuritySignature` | Le serveur **peut** signer les paquets si le client le demande | `True` |
| `RequireSecuritySignature` | Le serveur **EXIGE** la signature (refuse les connexions non signées) | `True` |

**Scénario ❌ DANGER** :

```
EnableSecuritySignature  : False
RequireSecuritySignature : False
```

👉 Aucune signature SMB → Vulnérable aux attaques Man-in-the-Middle !

**Scénario ⚠️ PROBLÈME** :

```
EnableSecuritySignature  : True
RequireSecuritySignature : False
```

👉 Signature disponible mais pas obligatoire → Un client ancien (Windows XP, vieux NAS) peut se connecter SANS signature

**Scénario ✅ BON** :

```
EnableSecuritySignature  : True
RequireSecuritySignature : True
```

👉 Signature SMB **obligatoire** pour toutes les connexions !

---

**Correction : Activer et forcer la signature SMB**

```powershell
Set-SmbServerConfiguration -EnableSecuritySignature $true -RequireSecuritySignature $true -Force
```

**Vérifier** :

```powershell
Get-SmbServerConfiguration | Select-Object EnableSecuritySignature, RequireSecuritySignature
```

**Résultat attendu** :
```
EnableSecuritySignature  : True
RequireSecuritySignature : True
```

✅ Signature SMB activée et obligatoire !

**⚠️ Attention** : Si tu as de très vieux clients (Windows XP, Windows 2000), ils ne pourront **plus se connecter**. Mais franchement, en 2025, si tu as encore Windows XP sur ton réseau... tu as des problèmes bien plus graves ! 😅

---

### 🔍 Vérification 5 : Chiffrement SMB3

**Concept** : SMB3 (depuis Windows 8/Server 2012) peut **chiffrer** les données en transit.

**Analogie** : C'est comme envoyer tes documents dans un **coffre-fort blindé** plutôt qu'une enveloppe transparente.

**Commande** :

```powershell
Get-SmbServerConfiguration | Select-Object EncryptData, RejectUnencryptedAccess
```

**Scénario ✅ BON** :

```
EncryptData             : True
RejectUnencryptedAccess : True
```

👉 Chiffrement activé, connexions non chiffrées refusées !

**Scénario ❌ DANGER** :

```
EncryptData             : False
RejectUnencryptedAccess : False
```

👉 Aucun chiffrement → Données lisibles en clair sur le réseau (sniffing possible)

**Correction** :

```powershell
Set-SmbServerConfiguration -EncryptData $true -RejectUnencryptedAccess $true -Force
```

**⚠️ Compatibilité** : Le chiffrement SMB3 nécessite :
- Windows 8 / Server 2012 ou plus récent
- Si tu as des clients plus anciens, ils ne pourront pas se connecter

**Alternative** : Chiffrer uniquement certains partages critiques

```powershell
# Chiffrer uniquement le partage "Backup"
Set-SmbShare -Name "Backup" -EncryptData $true
```

---

### 🗑️ Vérification 6 : Supprimer les partages inutiles

**Rappel** : Dans notre inventaire, on avait détecté `OldFiles` avec 0 utilisateurs connectés.

**Commande pour supprimer un partage** :

```powershell
# Vérifier une dernière fois
Get-SmbShare -Name "OldFiles"

# Supprimer le partage (ne supprime PAS les fichiers, juste le partage réseau)
Remove-SmbShare -Name "OldFiles" -Force
```

**⚠️ IMPORTANT** : `Remove-SmbShare` supprime **uniquement** le partage réseau, pas les fichiers physiques sur le disque.

**Si tu veux aussi supprimer les fichiers** :

```powershell
# Sauvegarder d'abord (au cas où)
Copy-Item -Path "F:\Archives\Old" -Destination "F:\Archives\OLD_BACKUP_$(Get-Date -Format 'yyyyMMdd')" -Recurse

# Puis supprimer
Remove-Item -Path "F:\Archives\Old" -Recurse -Force
```

---

### 📋 Récapitulatif : Partages Réseau (SMB)

**Checklist de sécurité** :

- [ ] Inventaire des partages réseau réalisé
- [ ] Partages inutiles supprimés (0 utilisateurs, anciens projets, etc.)
- [ ] Permissions vérifiées : **AUCUN partage avec "Everyone : Full"**
- [ ] Partages de sauvegardes : Accès limité aux comptes de service uniquement
- [ ] SMBv1 : **DÉSACTIVÉ** (State: Disabled)
- [ ] SMB Signing : **ACTIVÉ ET OBLIGATOIRE**
  - `EnableSecuritySignature: True`
  - `RequireSecuritySignature: True`
- [ ] Chiffrement SMB3 : **ACTIVÉ** (au moins sur partages sensibles)
- [ ] Partages administratifs (C$, ADMIN$) : Accès restreint aux admins uniquement
- [ ] Documentation des partages légitimes et de leurs permissions
- [ ] Révision trimestrielle des partages et permissions

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Lister et auditer les partages SMB
- ✅ Comprendre les risques de SMBv1 (EternalBlue, WannaCry)
- ✅ Désactiver complètement SMBv1
- ✅ Configurer les permissions SMB de manière restrictive
- ✅ Activer et forcer la signature SMB
- ✅ Activer le chiffrement SMB3
- ✅ Sécuriser les partages de sauvegardes (cible n°1 des ransomwares)
- ✅ Supprimer les partages inutiles

**Niveau actuel : 🌟🌟🌟🌟🌟🌟🌟🌟 Maître de la Sécurité !**

---

## 🛡️ Partie 9 : User Account Control (UAC) - Le Gardien du Château

### 🎯 Concept : UAC, c'est quoi ?

**UAC** (User Account Control) = Le mécanisme qui te demande **"Êtes-vous sûr ?"** quand tu veux faire une action d'administration.

**L'analogie** : Imagine UAC comme le **garde royal** à l'entrée du château.
- Sans UAC : N'importe qui peut entrer dans la salle du trône (= exécuter du code avec privilèges admin)
- Avec UAC : Le garde demande **"Êtes-vous vraiment le roi ?"** avant de laisser passer

**Pourquoi c'est important ?**
- **Bloque les malwares** qui tentent d'obtenir des privilèges admin silencieusement
- Force l'utilisateur (ou l'attaquant) à **confirmer** les actions sensibles
- Empêche les modifications du système par des processus non autorisés

### 📊 Statistiques et attaques réelles

- Selon Microsoft : **UAC bloque environ 80% des tentatives d'infection par malwares** qui nécessitent des privilèges admin
- **Bypass UAC** : Technique utilisée par les hackers pour contourner UAC (environ 50+ méthodes connues)
- De nombreux ransomwares tentent de désactiver UAC via le registre pour faciliter leur propagation
- **CIS Benchmark** : Recommande UAC au niveau **maximum** (Always notify) pour les serveurs critiques

**Exemples d'attaques** :
- **Emotet** : Tente de désactiver UAC pour installer des composants supplémentaires
- **Ryuk Ransomware** : Abuse des comptes admin avec UAC désactivé pour se propager
- **Privilege Escalation** : De nombreux exploits Windows nécessitent UAC désactivé ou mal configuré

### 🔍 Vérification 1 : Niveau UAC configuré

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object ConsentPromptBehaviorAdmin, PromptOnSecureDesktop, EnableLUA
```

**Décortiquons les paramètres** :

| Paramètre | Signification | Valeurs |
|-----------|---------------|---------|
| `EnableLUA` | UAC activé ou désactivé | `1` = Activé ✅ / `0` = Désactivé ❌ |
| `ConsentPromptBehaviorAdmin` | Comportement pour les admins | `0` = Pas de prompt ❌ / `2` = Prompt ✅ / `5` = Prompt avec mot de passe 🔐 |
| `PromptOnSecureDesktop` | Afficher le prompt sur bureau sécurisé (fond sombre) | `1` = Oui ✅ / `0` = Non ❌ |

**Exemple de résultat** :

**Scénario ❌ CATASTROPHE** :

```
EnableLUA                    : 0
ConsentPromptBehaviorAdmin   : 0
PromptOnSecureDesktop        : 0
```

👉 **UAC complètement désactivé** → N'importe quel programme peut obtenir des privilèges admin sans demander !

**Scénario ⚠️ PROBLÈME** :

```
EnableLUA                    : 1
ConsentPromptBehaviorAdmin   : 0
PromptOnSecureDesktop        : 0
```

👉 UAC activé mais ne demande **jamais** de confirmation → Inutile !

**Scénario ✅ BON** :

```
EnableLUA                    : 1
ConsentPromptBehaviorAdmin   : 2
PromptOnSecureDesktop        : 1
```

👉 UAC activé avec demande de confirmation sur bureau sécurisé !

**Scénario 🔐 EXCELLENT** (recommandé pour serveurs critiques) :

```
EnableLUA                    : 1
ConsentPromptBehaviorAdmin   : 5
PromptOnSecureDesktop        : 1
```

👉 UAC au niveau **maximum** : Demande le mot de passe administrateur à chaque fois !

---

### 🛠️ Correction : Configurer UAC au niveau recommandé

**Pour serveurs de production (recommandé CIS Benchmark)** :

```powershell
# Activer UAC
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1

# Forcer le prompt de consentement pour les admins
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2

# Utiliser le bureau sécurisé (fond sombre, impossible de cliquer ailleurs)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1

# Vérifier
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object EnableLUA, ConsentPromptBehaviorAdmin, PromptOnSecureDesktop
```

**Pour serveurs ULTRA-critiques (niveau maximum)** :

```powershell
# UAC au niveau le plus strict : Demander le mot de passe admin à chaque fois
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
```

**⚠️ Impact** :
- Avec `ConsentPromptBehaviorAdmin = 2` : Une boîte de dialogue **Oui/Non** apparaît
- Avec `ConsentPromptBehaviorAdmin = 5` : Il faut entrer le **mot de passe administrateur** à chaque fois

Pour un serveur, `2` est généralement suffisant. Pour un contrôleur de domaine ou serveur ultra-sensible, considère `5`.

---

### 🔍 Vérification 2 : UAC pour les utilisateurs standard

**Concept** : Les utilisateurs **non-administrateurs** devraient **TOUJOURS** avoir besoin d'un mot de passe admin pour élever leurs privilèges.

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object ConsentPromptBehaviorUser
```

**Valeurs possibles** :

| Valeur | Signification | Sécurité |
|--------|---------------|----------|
| `0` | Refuser automatiquement les demandes d'élévation | 🟡 Sécurisé mais peut bloquer des tâches légitimes |
| `1` | Demander les credentials sur bureau sécurisé | ✅ **RECOMMANDÉ** |
| `3` | Demander les credentials (bureau normal) | ⚠️ Moins sécurisé (peut être "overlayé" par un malware) |

**Scénario ✅ BON** :

```
ConsentPromptBehaviorUser : 1
```

👉 Les utilisateurs standard doivent fournir un mot de passe admin sur bureau sécurisé !

**Scénario ❌ PROBLÈME** :

```
ConsentPromptBehaviorUser : 3
```

👉 Demande credentials mais pas sur bureau sécurisé → Un malware peut afficher une fausse fenêtre de login !

---

**Correction** :

```powershell
# Forcer le prompt sur bureau sécurisé pour les utilisateurs standard
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value 1
```

---

### 🔍 Vérification 3 : Applications signées vs non-signées

**Concept** : UAC peut faire la distinction entre les applications **signées numériquement** (Microsoft, éditeurs reconnus) et les **applications non signées** (potentiellement dangereuses).

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object ValidateAdminCodeSignatures
```

**Valeurs** :

| Valeur | Signification |
|--------|---------------|
| `0` | Ne pas valider les signatures (par défaut) |
| `1` | Exiger que les applications soient signées pour obtenir élévation |

**Scénario ✅ TRÈS SÉCURISÉ** (environnements hautement sensibles) :

```
ValidateAdminCodeSignatures : 1
```

👉 Seules les applications **signées numériquement** peuvent obtenir des privilèges admin !

**⚠️ Attention** : Cela peut **bloquer** certains scripts PowerShell maison ou outils d'administration non signés. À activer uniquement si tu contrôles strictement ce qui s'exécute sur le serveur.

**Activation (optionnel, pour environnements ultra-sécurisés)** :

```powershell
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ValidateAdminCodeSignatures" -Value 1
```

---

### 🔍 Vérification 4 : Détection des modifications UAC

**Le risque** : Un malware ou un attaquant peut tenter de **désactiver UAC** en modifiant le registre.

**Commande pour vérifier l'historique des modifications** :

```powershell
# Vérifier l'Event ID 4719 : Modification de politique d'audit système
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4719} -MaxEvents 20 | ForEach-Object {
    $xml = [xml]$_.ToXml()
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        User = $xml.Event.EventData.Data[1].'#text'
        Changes = $_.Message
    }
} | Format-Table -Wrap
```

**Recherche de modifications dans le registre UAC** :

```powershell
# Vérifier l'Event ID 4657 : Modification de clé de registre
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4657} -MaxEvents 100 | Where-Object {
    $_.Message -like "*Policies\System*"
} | Select-Object TimeCreated, Message | Format-List
```

**Ce qu'il faut surveiller** :
- Modifications des clés `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`
- Changements de `EnableLUA` de 1 à 0
- Modifications par des comptes **non autorisés**

---

### 📋 Récapitulatif : User Account Control (UAC)

**Checklist de sécurité** :

- [ ] UAC activé (`EnableLUA = 1`)
- [ ] Prompt de consentement pour admins activé (`ConsentPromptBehaviorAdmin = 2` ou `5`)
- [ ] Bureau sécurisé activé (`PromptOnSecureDesktop = 1`)
- [ ] Prompt pour utilisateurs standard configuré (`ConsentPromptBehaviorUser = 1`)
- [ ] Validation des signatures (optionnel) : Considérée pour environnements critiques
- [ ] Surveillance des modifications UAC dans les logs (Event ID 4719, 4657)
- [ ] Aucune exception UAC configurée via GPO pour des applications non fiables
- [ ] Documentation des raisons si UAC est abaissé sur certains serveurs
- [ ] Test régulier du fonctionnement UAC

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Comprendre le rôle d'UAC dans la défense en profondeur
- ✅ Vérifier la configuration UAC via le registre
- ✅ Configurer UAC aux niveaux recommandés (CIS Benchmark)
- ✅ Différencier les niveaux UAC (0, 2, 5)
- ✅ Configurer UAC pour utilisateurs standard vs administrateurs
- ✅ Activer le bureau sécurisé (protection contre les fake prompts)
- ✅ Surveiller les tentatives de désactivation d'UAC
- ✅ Comprendre l'impact de la validation des signatures

**Niveau actuel : 🌟🌟🌟🌟🌟🌟🌟🌟🌟 Grand Maître !**

---

## 🌍 Partie 10 : Sécurité Réseau et Protocoles - Blinder les Communications

### 🎯 Concept : Protocoles d'authentification Windows

Windows utilise plusieurs protocoles pour **authentifier** les utilisateurs sur le réseau :

1. **NTLM** (NT LAN Manager) : Ancien protocole des années 1990
   - **NTLMv1** : Extrêmement faible, cassable en quelques heures
   - **NTLMv2** : Plus robuste, mais toujours vulnérable aux attaques "Pass-the-Hash"

2. **Kerberos** : Protocole moderne et sécurisé (depuis Windows 2000)
   - Utilise des **tickets** avec durée de vie limitée
   - Chiffrement fort (AES)
   - **Recommandé** pour tous les environnements Active Directory

**L'analogie** :
- **NTLMv1** = Envoyer ton mot de passe en lettre recommandée (facilement interceptable)
- **NTLMv2** = Envoyer un code d'accès temporaire (mieux, mais peut être réutilisé)
- **Kerberos** = Système de badges à durée limitée avec vérification d'identité (moderne et sûr)

### 📊 Statistiques et attaques

- **80% des compromissions Active Directory** impliquent des attaques NTLM (Pass-the-Hash, NTLM Relay)
- **Mimikatz** : Outil hacker capable d'extraire les hash NTLM de la mémoire en quelques secondes
- **NTLM Relay** : Technique permettant de "relayer" une authentification NTLM pour accéder à un autre serveur
- Selon le **CIS Benchmark** : NTLM devrait être **désactivé** ou limité au strict minimum, Kerberos préféré

**Exemples d'attaques réelles** :
- **Pass-the-Hash** : L'attaquant vole le hash NTLM (sans connaître le mot de passe) et l'utilise pour s'authentifier
- **NTLM Relay** : Utilisé dans les attaques PetitPotam, PrinterBug pour compromettre des contrôleurs de domaine
- **Downgrade Attack** : Forcer un client Kerberos à utiliser NTLM (plus faible) pour faciliter l'attaque

### 🔍 Vérification 1 : Niveau de compatibilité LM (LmCompatibilityLevel)

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel"
```

**Valeurs possibles** :

| Valeur | Protocoles Acceptés | Sécurité | Recommandation |
|--------|---------------------|----------|----------------|
| `0` | LM, NTLM, NTLMv2 | ❌ **CATASTROPHIQUE** | Jamais ! |
| `1` | LM, NTLM, NTLMv2 (préfère NTLMv2) | ❌ **TRÈS FAIBLE** | Jamais ! |
| `2` | NTLM, NTLMv2 | 🟠 **FAIBLE** | Non recommandé |
| `3` | NTLMv2 uniquement | 🟡 **MOYEN** | Acceptable temporaire |
| `4` | NTLMv2, refuse LM/NTLM | 🟢 **BON** | Minimum recommandé |
| `5` | NTLMv2 uniquement, refus total LM/NTLM | ✅ **EXCELLENT** | **CIS Benchmark recommandé** |

**Scénario ❌ CATASTROPHE** :

```
LmCompatibilityLevel : 0
```

ou

```
Get-ItemProperty : La propriété 'LmCompatibilityLevel' est introuvable
```

👉 Niveau par défaut (0 ou non défini) → Accepte **LM et NTLM** (protocoles des années 1990, cassables en minutes) !

**Scénario ✅ BON** :

```
LmCompatibilityLevel : 5
```

👉 Refuse complètement LM et NTLM, n'accepte que NTLMv2 (et préfère Kerberos) !

---

### 🛠️ Correction : Forcer NTLMv2 et refuser LM/NTLM

```powershell
# Définir le niveau de compatibilité LM au niveau 5 (le plus sécurisé)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5 -Type DWord

# Vérifier
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel"
```

**Résultat attendu** :

```
LmCompatibilityLevel : 5
```

**⚠️ Compatibilité** :
- Niveau 5 peut **bloquer** de très vieux clients (Windows 95/98, Windows NT 4.0)
- En 2025, si tu as encore de tels systèmes... il est temps de les remplacer ! 😅
- Tous les systèmes **Windows 2000 et ultérieurs** supportent NTLMv2

---

### 🔍 Vérification 2 : Audit NTLM et restrictions

**Objectif** : Identifier quels systèmes utilisent **encore** NTLM pour pouvoir les migrer vers Kerberos.

**Commande pour activer l'audit NTLM** :

```powershell
# Activer l'audit NTLM (niveau : Auditer tout)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Name "AuditReceivingNTLMTraffic" -Value 2 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Name "RestrictSendingNTLMTraffic" -Value 1 -Type DWord

# Redémarrer le service Netlogon pour appliquer
Restart-Service -Name "Netlogon" -Force
```

**Explications** :

| Paramètre | Valeur | Signification |
|-----------|--------|---------------|
| `AuditReceivingNTLMTraffic` | `2` | Auditer **toutes** les authentifications NTLM entrantes |
| `RestrictSendingNTLMTraffic` | `1` | Auditer les tentatives NTLM sortantes (mais **ne pas bloquer**) |

**Consulter les logs NTLM** :

```powershell
# Event ID 8004 : Audit NTLM
Get-WinEvent -FilterHashtable @{LogName='System'; ID=8004} -MaxEvents 20 | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        Message = $_.Message
    }
} | Format-List
```

**Ce que tu verras** :
- Quels **serveurs/clients** utilisent encore NTLM
- Quelles **applications** dépendent de NTLM
- Cela te permet de **planifier la migration** vers Kerberos

**Phase 2 : Bloquer NTLM (après avoir identifié et corrigé les dépendances)** :

```powershell
# BLOQUER complètement NTLM (phase finale, après tests approfondis)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Name "RestrictSendingNTLMTraffic" -Value 2 -Type DWord
```

⚠️ **NE PAS FAIRE IMMÉDIATEMENT** : Cela peut **casser** des applications qui dépendent encore de NTLM. Procéder par étapes :
1. Activer l'audit (`Value = 1`)
2. Identifier les dépendances
3. Migrer vers Kerberos
4. Bloquer NTLM (`Value = 2`)

---

### 🔍 Vérification 3 : Désactiver le stockage des hash LM

**Le risque** : Par défaut, Windows peut stocker les **hash LM** (ultra-faibles) en plus des hash NTLM.

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash" -ErrorAction SilentlyContinue
```

**Scénario ❌ DANGER** :

```
Get-ItemProperty : La propriété 'NoLMHash' est introuvable
```

ou

```
NoLMHash : 0
```

👉 Le système **stocke les hash LM** → Cassables en quelques minutes avec des outils comme **Hashcat** !

**Scénario ✅ BON** :

```
NoLMHash : 1
```

👉 Hash LM **désactivés** → Seuls les hash NTLM (plus robustes) sont stockés !

---

**Correction : Désactiver complètement les hash LM** :

```powershell
# Désactiver le stockage des hash LM
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash" -Value 1 -Type DWord

# Vérifier
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "NoLMHash"
```

**Résultat attendu** :

```
NoLMHash : 1
```

✅ Hash LM désactivés !

**⚠️ Important** : Les hash LM **existants** ne sont pas supprimés automatiquement. Pour forcer leur suppression, les utilisateurs doivent **changer leur mot de passe** après cette modification.

**Commande pour forcer le changement de mot de passe** (à faire pour les comptes locaux critiques) :

```powershell
# Exemple : Forcer le changement de mot de passe pour un compte local
net user "NomUtilisateur" /logonpasswordchg:yes
```

---

### 🔍 Vérification 4 : Protection LDAP Signing et LDAP Channel Binding

**Concept** : LDAP (Lightweight Directory Access Protocol) est utilisé pour communiquer avec Active Directory.

**Les risques** :
- **LDAP sans signature** : Un attaquant peut intercepter et **modifier** les requêtes LDAP
- **LDAP Relay** : Technique pour "relayer" une authentification LDAP vers un autre serveur

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -Name "LDAPServerIntegrity" -ErrorAction SilentlyContinue
```

**Valeurs** :

| Valeur | Signification | Sécurité |
|--------|---------------|----------|
| `0` | Pas de signature requise | ❌ **FAIBLE** |
| `1` | Signature requise | ✅ **RECOMMANDÉ** |
| `2` | Signature et chiffrement requis | 🔐 **EXCELLENT** |

**Scénario ❌ PROBLÈME** :

```
Get-ItemProperty : La propriété 'LDAPServerIntegrity' est introuvable
```

ou

```
LDAPServerIntegrity : 0
```

👉 LDAP **sans signature** → Vulnérable aux attaques Man-in-the-Middle et LDAP Relay !

**Scénario ✅ BON** :

```
LDAPServerIntegrity : 1
```

👉 Signature LDAP **obligatoire** !

---

**Correction : Activer la signature LDAP** :

```powershell
# Activer la signature LDAP (nécessite que le serveur soit un contrôleur de domaine)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -Name "LDAPServerIntegrity" -Value 1 -Type DWord

# Pour les clients LDAP (forcer la signature côté client aussi)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LDAP" -Name "LDAPClientIntegrity" -Value 1 -Type DWord

# Vérifier
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -Name "LDAPServerIntegrity" -ErrorAction SilentlyContinue
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LDAP" -Name "LDAPClientIntegrity" -ErrorAction SilentlyContinue
```

**Note** : `HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters` n'existe que sur les **contrôleurs de domaine**. Si tu es sur un serveur membre, seul le paramètre client (`LDAP`) est applicable.

---

### 🔍 Vérification 5 : Chiffrement Kerberos (AES vs RC4)

**Concept** : Kerberos peut utiliser différents algorithmes de chiffrement.

**Algorithmes disponibles** :

| Algorithme | Force | Statut | Recommandation |
|------------|-------|--------|----------------|
| DES | Très faible (56-bit) | Obsolète depuis 2008 | ❌ **DÉSACTIVER** |
| RC4-HMAC | Faible (128-bit mais vulnérabilités) | Déprécié | 🟠 **DÉSACTIVER si possible** |
| AES128-SHA1 | Fort (128-bit) | Moderne | ✅ **ACTIVER** |
| AES256-SHA1 | Très fort (256-bit) | Moderne | ✅ **ACTIVER** |

**Commande** :

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" -Name "SupportedEncryptionTypes" -ErrorAction SilentlyContinue
```

**Valeurs** (flags binaires additionnés) :

| Flag | Valeur | Algorithme |
|------|--------|------------|
| DES_CBC_CRC | 0x1 | DES (obsolète) |
| DES_CBC_MD5 | 0x2 | DES (obsolète) |
| RC4_HMAC_MD5 | 0x4 | RC4 (faible) |
| AES128_HMAC_SHA1 | 0x8 | AES-128 ✅ |
| AES256_HMAC_SHA1 | 0x10 | AES-256 ✅ |
| FUTURE | 0x20 | Algorithmes futurs |

**Configuration RECOMMANDÉE** : `0x18` (décimal : `24`)
- `0x8` (AES-128) + `0x10` (AES-256) = `0x18`
- Active **uniquement** AES-128 et AES-256, refuse DES et RC4

**Scénario ❌ PROBLÈME** :

```
Get-ItemProperty : La propriété 'SupportedEncryptionTypes' est introuvable
```

👉 Configuration par défaut → Accepte **tous** les algorithmes (y compris DES et RC4) !

**Scénario ✅ BON** :

```
SupportedEncryptionTypes : 24
```

ou en hexadécimal :

```
SupportedEncryptionTypes : 0x18
```

👉 Uniquement AES-128 et AES-256 activés !

---

**Correction : Forcer AES uniquement pour Kerberos** :

```powershell
# Créer le chemin si nécessaire
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos" -Name "Parameters" -Force -ErrorAction SilentlyContinue

# Activer UNIQUEMENT AES-128 et AES-256 (valeur 24 décimal = 0x18 hex)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" -Name "SupportedEncryptionTypes" -Value 24 -Type DWord

# Vérifier
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" -Name "SupportedEncryptionTypes"
```

**Résultat attendu** :

```
SupportedEncryptionTypes : 24
```

✅ Kerberos configuré pour utiliser **uniquement AES** !

**⚠️ Compatibilité** :
- AES est supporté depuis **Windows Server 2008** et **Windows Vista**
- Si tu as des systèmes plus anciens (Windows XP, Server 2003)... il est **vraiment** temps de les remplacer !

---

### 📋 Récapitulatif : Sécurité Réseau et Protocoles

**Checklist de sécurité** :

- [ ] Niveau de compatibilité LM : **5** (Refuse LM et NTLM, n'accepte que NTLMv2)
- [ ] Hash LM désactivés (`NoLMHash = 1`)
- [ ] Audit NTLM activé pour identifier les dépendances
- [ ] Plan de migration de NTLM vers Kerberos en cours
- [ ] Signature LDAP activée (serveur et client)
- [ ] Kerberos : Uniquement AES-128 et AES-256 activés (`SupportedEncryptionTypes = 24`)
- [ ] DES et RC4 désactivés pour Kerberos
- [ ] Surveillance des authentifications NTLM (Event ID 8004)
- [ ] Documentation des systèmes nécessitant encore NTLM (et plan de migration)
- [ ] Tests de compatibilité avant blocage complet de NTLM

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Comprendre les différences entre LM, NTLM, NTLMv2, et Kerberos
- ✅ Configurer le niveau de compatibilité LM (LmCompatibilityLevel)
- ✅ Désactiver les hash LM (NoLMHash)
- ✅ Auditer les utilisations de NTLM
- ✅ Activer la signature LDAP (protection contre LDAP Relay)
- ✅ Configurer Kerberos pour utiliser uniquement AES
- ✅ Comprendre les attaques Pass-the-Hash et NTLM Relay
- ✅ Planifier une migration progressive vers Kerberos
- ✅ Bloquer les protocoles obsolètes (DES, RC4, LM)

**Niveau actuel : 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟 LÉGENDE ! Respect total ! 🏆**

---

## 🤖 Script d'Audit Automatisé v2.0

### 🎯 L'Arme Ultime : Automatiser ton Audit !

Après avoir tout lu, tout compris, et tout appliqué... il est temps de passer au **niveau supérieur** ! 🚀

**Le problème** : Faire un audit manuel complet prend du temps (2-3 heures). Et il faut le refaire régulièrement (chaque mois, après chaque changement majeur, etc.)

**La solution** : Un **script PowerShell automatisé** qui vérifie TOUT en quelques minutes ! ⚡

### 📥 Téléchargement du script

Le script est disponible dans le même dossier que ce guide :

```
📁 os/windows/
├── windows-server-2022.md          ← Le guide (que tu viens de lire)
└── audit-windows-server-2022.ps1   ← Le script d'audit automatisé
```

### 🚀 Utilisation du script

**Étape 1 : Ouvrir PowerShell en Administrateur**

C'est **crucial** ! Le script ne fonctionnera pas sans droits admin.

1. Clique sur le menu Démarrer
2. Tape "PowerShell"
3. **Clic droit** sur "Windows PowerShell"
4. Choisis **"Exécuter en tant qu'administrateur"**

**Étape 2 : Naviguer vers le dossier du script**

```powershell
cd C:\chemin\vers\le\dossier\
```

Exemple :
```powershell
cd C:\Users\Admin\Downloads\audit\
```

**Étape 3 : Exécuter le script**

```powershell
.\audit-windows-server-2022.ps1
```

**Si tu obtiens une erreur "Execution Policy"** :

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\audit-windows-server-2022.ps1
```

**Explication** :
- `Set-ExecutionPolicy Bypass` : Autorise l'exécution du script
- `-Scope Process` : Uniquement pour cette session PowerShell
- Une fois la fenêtre fermée, la restriction revient (sécurité !)

---

### 📊 Ce que fait le script

Le script vérifie **AUTOMATIQUEMENT** tous les points critiques du guide :

**✅ Partie 1 : Mises à jour**
- Mises à jour récentes (< 30 jours)
- Service Windows Update actif

**✅ Partie 2 : Comptes Utilisateurs**
- Longueur minimale mot de passe >= 14
- Historique >= 24
- Compte Guest désactivé
- Seuil de verrouillage <= 5

**✅ Partie 3 : RDP**
- NLA activé
- Chiffrement 128-bit
- SSL/TLS forcé

**✅ Partie 4 : Pare-feu**
- Activé sur tous les profils
- Politique par défaut (Block Inbound)

**✅ Partie 5 : Windows Defender**
- Antivirus activé
- Protection en temps réel
- Signatures à jour (< 7 jours)
- Cloud Protection

**✅ Partie 6 : Audit et Logs**
- Taille journal Security >= 512 MB
- Audit des connexions (Success + Failure)

**✅ Partie 7 : Services**
- Print Spooler désactivé
- Remote Registry désactivé
- SNMP désactivé

**✅ Partie 8 : SMB**
- SMBv1 DÉSACTIVÉ (critique !)
- SMB Signing requis
- Chiffrement SMB3
- Aucun partage "Everyone : Full"

**✅ Partie 9 : UAC**
- UAC activé
- Prompt de consentement
- Bureau sécurisé

**✅ Partie 10 : Protocoles Réseau**
- LmCompatibilityLevel = 5
- Hash LM désactivés
- Kerberos AES uniquement

---

### 📈 Exemple de résultat

```
═══════════════════════════════════════════════════════════════════
  🪟 AUDIT DE SÉCURITÉ - WINDOWS SERVER 2022
  Version 2.0 - Style 'From Zero to Hero'
═══════════════════════════════════════════════════════════════════

🔍 Démarrage de l'audit de sécurité...
📝 Rapport généré dans: .\audit-windows-server-20250116-143022.txt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 PARTIE 1 : MISES À JOUR WINDOWS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ PASS - Mises à jour récentes (< 30 jours)
✅ PASS - Service Windows Update (wuauserv) actif

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 PARTIE 2 : COMPTES UTILISATEURS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ PASS - Longueur minimale mot de passe >= 14
✅ PASS - Historique mots de passe >= 24
✅ PASS - Compte Guest désactivé
⚠️  WARN - Compte Administrator sécurisé
✅ PASS - Seuil de verrouillage de compte <= 5

[...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 PARTIE 8 : PARTAGES RÉSEAU (SMB)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ PASS - SMBv1 DÉSACTIVÉ (CRITIQUE)
✅ PASS - SMB Signing requis
⚠️  WARN - Chiffrement SMB3 activé
❌ FAIL - Aucun partage avec 'Everyone : Full'

[...]

═══════════════════════════════════════════════════════════════════
📊 RÉSUMÉ DE L'AUDIT
═══════════════════════════════════════════════════════════════════

Total de vérifications    : 42
✅ Réussies (PASS)        : 35
⚠️  Avertissements (WARN) : 4
❌ Échecs (FAIL)          : 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SCORE DE SÉCURITÉ : 83.3%
📈 NIVEAU            : ✅ BON - Quelques améliorations possibles

═══════════════════════════════════════════════════════════════════
📝 Rapport complet sauvegardé dans :
   .\audit-windows-server-20250116-143022.txt
═══════════════════════════════════════════════════════════════════

💡 RECOMMANDATIONS :

1. Consulte le guide détaillé 'windows-server-2022.md'
2. Priorise la correction des checks ❌ FAIL (surtout SEVERITY: HIGH)
3. Reteste avec ce script après corrections
4. Examine les checks ⚠️  WARN pour optimisation

📚 Pour chaque check échoué, le guide 'windows-server-2022.md' contient :
   - L'explication du risque
   - Les commandes PowerShell de correction
   - Des exemples concrets

🎓 Bravo d'avoir audité ton serveur !
   La sécurité, c'est un processus continu, pas une destination ! 🚀
```

---

### 🎨 Interprétation des résultats

**🏆 Score >= 90% - EXCELLENT**
- Ton serveur est très sécurisé !
- Continue la maintenance régulière
- Refais un audit après chaque changement majeur

**✅ Score 75-89% - BON**
- Quelques points à améliorer
- Consulte les checks ❌ FAIL et ⚠️ WARN
- Corrige au minimum les HIGH severity

**⚠️ Score 60-74% - MOYEN**
- Plusieurs problèmes de sécurité
- **Action requise** : Corrige tous les FAIL
- Priorise les HIGH, puis MEDIUM

**🟠 Score 40-59% - FAIBLE**
- Nombreux problèmes critiques
- **URGENT** : Serveur vulnérable
- Planifie une journée de durcissement

**🔴 Score < 40% - CRITIQUE**
- Serveur **TRÈS vulnérable**
- **ALERTE MAXIMALE**
- Envisage une réinstallation propre avec application du guide dès le départ

---

### 📅 Quand relancer le script ?

**Fréquence recommandée** :

| Environnement | Fréquence | Raison |
|---------------|-----------|--------|
| Serveur de production critique | **Hebdomadaire** | Détection rapide de dérives de configuration |
| Serveur de production standard | **Mensuel** | Audit régulier, conformité |
| Serveur de test/dev | **Trimestriel** | Avant mise en production |
| Après chaque changement majeur | **Immédiat** | Vérifier qu'aucune régression de sécurité |
| Après installation de nouvelles applications | **Immédiat** | S'assurer que l'app n'a pas affaibli la sécu |

**Automatisation avancée (optionnel)** :

Tu peux planifier l'exécution automatique du script avec le **Planificateur de tâches Windows** :

```powershell
# Créer une tâche planifiée (exemple : tous les lundis à 9h)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\audit-windows-server-2022.ps1"
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "Audit Sécurité Hebdomadaire" -Action $action -Trigger $trigger -Principal $principal -Description "Audit automatique de sécurité Windows Server 2022"
```

---

### 💾 Sauvegarder les rapports

**Conseil professionnel** : Archive tous tes rapports d'audit !

**Pourquoi ?**
- Traçabilité : Prouver que tu fais des audits réguliers (conformité, assurance, audit externe)
- Comparaison : Voir l'évolution du score dans le temps
- Incident : En cas d'intrusion, comparer l'état avant/après

**Exemple d'organisation** :

```
C:\Audits\
├── 2025-01\
│   ├── audit-windows-server-20250106-090000.txt
│   ├── audit-windows-server-20250113-090000.txt
│   └── audit-windows-server-20250120-090000.txt
├── 2025-02\
│   ├── audit-windows-server-20250203-090000.txt
│   └── audit-windows-server-20250210-090000.txt
└── historique-scores.csv
```

**Script pour générer un historique CSV** :

```powershell
# Ajouter cette ligne à la fin de chaque audit
$csvLine = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$scorePercentage,$script:PassedChecks,$script:FailedChecks,$script:WarningChecks"
Add-Content -Path "C:\Audits\historique-scores.csv" -Value $csvLine
```

Ensuite, tu peux ouvrir `historique-scores.csv` dans Excel et créer un **graphique d'évolution** de ton score ! 📈

---

### 🔧 Personnaliser le script

Le script est conçu pour être **facilement personnalisable**.

**Exemples de personnalisations** :

**1. Ajouter tes propres checks**

```powershell
# Ajouter après la Partie 10
Invoke-Check -Name "Mon application critique est installée" -Severity "HIGH" -Expected "Service MyApp = Running" -Check {
    $myApp = Get-Service -Name "MyApp" -ErrorAction SilentlyContinue
    if ($myApp -and $myApp.Status -eq 'Running') { return $true } else { return $false }
}
```

**2. Modifier les seuils**

Par exemple, tu veux exiger des signatures antivirus à jour depuis moins de **3 jours** au lieu de 7 :

```powershell
# Ligne originale (dans le script) :
if ($daysSinceUpdate.Days -le 7) { return $true } else { return $false }

# Modifier en :
if ($daysSinceUpdate.Days -le 3) { return $true } else { return $false }
```

**3. Envoyer le rapport par email**

```powershell
# À ajouter à la fin du script (nécessite configuration SMTP)
$emailParams = @{
    From = "audit@monentreprise.com"
    To = "admin@monentreprise.com"
    Subject = "Audit Sécurité Windows Server - Score: $scorePercentage%"
    Body = Get-Content -Path $OutputFile -Raw
    SmtpServer = "smtp.monentreprise.com"
    Port = 587
    UseSsl = $true
    Credential = (Get-Credential)
}
Send-MailMessage @emailParams
```

---

## ✅ Checklist Finale Complète

Voici la **checklist ultime** pour un Windows Server 2022 sécurisé selon le **CIS Benchmark v4.0.0** et les recommandations **ANSSI** :

### 📦 Partie 1 : Mises à Jour

- [ ] Windows Update configuré en mode automatique ou manuel contrôlé
- [ ] Mises à jour installées dans les **30 derniers jours**
- [ ] Mises à jour **critiques** installées dans les **7 jours** après publication
- [ ] Service wuauserv démarré
- [ ] Redémarrages planifiés après mises à jour (hors heures de production)
- [ ] Sauvegarde complète AVANT installation de mises à jour majeures

### 👤 Partie 2 : Comptes Utilisateurs

- [ ] Longueur minimale mot de passe : **14 caractères minimum** (idéalement 16+)
- [ ] Complexité des mots de passe : **Activée**
- [ ] Historique des mots de passe : **24 mots de passe mémorisés**
- [ ] Âge maximum du mot de passe : **60 jours** (ou selon politique entreprise)
- [ ] Seuil de verrouillage de compte : **5 tentatives maximum**
- [ ] Durée de verrouillage : **15 minutes minimum**
- [ ] Compte **Guest** : **DÉSACTIVÉ**
- [ ] Compte **Administrator** : **Renommé ET désactivé** (ou au minimum renommé)
- [ ] Honeypot Administrator créé (optionnel mais recommandé)
- [ ] Inventaire des comptes locaux réalisé et documenté
- [ ] Aucun compte avec mot de passe vide
- [ ] Aucun compte inactif depuis plus de 90 jours

### 🖥️ Partie 3 : RDP (Remote Desktop)

- [ ] RDP **désactivé** si non nécessaire (idéal)
- [ ] Si RDP activé : **NLA (Network Level Authentication) = Activé**
- [ ] Niveau de chiffrement : **Élevé (128-bit minimum)**
- [ ] SSL/TLS : **Forcé** (SecurityLayer = 2)
- [ ] Restriction par IP : **Configurée** (limiter aux IP d'administration)
- [ ] Port RDP **modifié** (optionnel, débat sécurité vs obscurité)
- [ ] Timeout de session inactive : **15 minutes maximum**
- [ ] Déconnexion automatique après timeout
- [ ] Journalisation des connexions RDP activée
- [ ] Surveillance des tentatives de connexion échouées (brute-force)

### 🔥 Partie 4 : Pare-feu Windows Defender

- [ ] Pare-feu activé sur profil **Domain** : **✅**
- [ ] Pare-feu activé sur profil **Private** : **✅**
- [ ] Pare-feu activé sur profil **Public** : **✅**
- [ ] Politique par défaut **Inbound** : **Block**
- [ ] Politique par défaut **Outbound** : **Allow** (ou Block si environnement très contrôlé)
- [ ] Inventaire des règles Inbound actives réalisé
- [ ] Aucune règle "Any/Any" dangereuse
- [ ] Règles de partage de fichiers désactivées si non nécessaires
- [ ] Règles de découverte réseau désactivées sur profil Public
- [ ] Journalisation du pare-feu activée (connexions refusées + autorisées)
- [ ] Révision trimestrielle des règles

### 🛡️ Partie 5 : Windows Defender Antivirus

- [ ] Windows Defender **activé** (ou autre antivirus tiers réputé)
- [ ] Protection en temps réel : **Activée**
- [ ] Behavior Monitoring : **Activé**
- [ ] IOAV Protection : **Activé**
- [ ] Signatures antivirus **à jour** (< 7 jours)
- [ ] Cloud Protection (MAPS) : **Advanced** (niveau 2)
- [ ] Soumission automatique d'échantillons : **Activée**
- [ ] Exclusions auditées : **AUCUNE exclusion dangereuse** (C:\, *.exe, etc.)
- [ ] Scan complet programmé : **Hebdomadaire**
- [ ] Historique des détections consulté régulièrement
- [ ] Réponse automatique aux menaces : **Configurée** (quarantaine/suppression)

### 📊 Partie 6 : Audit et Journalisation

- [ ] Politique d'audit avancée configurée (auditpol)
- [ ] Audit Logon/Logoff : **Success + Failure**
- [ ] Audit Account Lockout : **Failure**
- [ ] Audit User Account Management : **Success + Failure**
- [ ] Audit Security Group Management : **Success**
- [ ] Audit Policy Change : **Success**
- [ ] Taille du journal Security : **≥ 512 MB** (idéalement 1 GB)
- [ ] Rétention des logs : **Au moins 90 jours**
- [ ] Surveillance des Event IDs critiques :
  - [ ] 4624 (Connexion réussie)
  - [ ] 4625 (Connexion échouée)
  - [ ] 4720 (Création de compte)
  - [ ] 4726 (Suppression de compte)
  - [ ] 4732 (Ajout à un groupe de sécurité)
  - [ ] 4776 (Validation de credentials)
- [ ] Centralisation des logs (SIEM, Syslog) : **Recommandée**
- [ ] Alertes configurées pour tentatives d'intrusion

### 🛠️ Partie 7 : Services Windows

- [ ] Inventaire des services en cours d'exécution réalisé
- [ ] **Print Spooler** : **DÉSACTIVÉ** (si pas d'imprimantes)
- [ ] **Remote Registry** : **DÉSACTIVÉ**
- [ ] **SNMP** : **DÉSACTIVÉ** ou **supprimé**
- [ ] **Computer Browser** : **DÉSACTIVÉ**
- [ ] **SSDP Discovery** : **DÉSACTIVÉ**
- [ ] **Bluetooth Support** : **DÉSACTIVÉ**
- [ ] Aucun service avec compte **Administrator** ou **Domain Admin**
- [ ] Services tiers : Comptes de service dédiés à droits minimaux
- [ ] Documentation des services nécessaires et justification
- [ ] Révision trimestrielle de la liste des services actifs

### 🌐 Partie 8 : Partages Réseau (SMB)

- [ ] Inventaire des partages réseau réalisé
- [ ] Partages inutiles supprimés
- [ ] **AUCUN partage avec "Everyone : Full"**
- [ ] Partages de sauvegardes : **Accès limité aux comptes de service uniquement**
- [ ] **SMBv1** : **COMPLÈTEMENT DÉSACTIVÉ** 🔴 (CRITIQUE)
- [ ] SMB Signing : **Activé ET Obligatoire**
  - [ ] EnableSecuritySignature = True
  - [ ] RequireSecuritySignature = True
- [ ] Chiffrement SMB3 : **Activé** (au moins sur partages sensibles)
- [ ] Partages administratifs (C$, ADMIN$) : **Accès restreint aux admins uniquement**
- [ ] Documentation des partages légitimes et permissions
- [ ] Révision trimestrielle des partages et permissions

### 🛡️ Partie 9 : User Account Control (UAC)

- [ ] UAC **activé** (EnableLUA = 1)
- [ ] Prompt de consentement pour admins : **Activé** (ConsentPromptBehaviorAdmin ≥ 2)
- [ ] Bureau sécurisé : **Activé** (PromptOnSecureDesktop = 1)
- [ ] Prompt pour utilisateurs standard : **Configuré** (ConsentPromptBehaviorUser = 1)
- [ ] Validation des signatures : **Considérée** pour environnements critiques
- [ ] Surveillance des modifications UAC (Event IDs 4719, 4657)
- [ ] Aucune exception UAC pour applications non fiables
- [ ] Documentation si UAC abaissé (avec justification)

### 🌍 Partie 10 : Sécurité Réseau et Protocoles

- [ ] **LmCompatibilityLevel = 5** (NTLMv2 uniquement, refuse LM/NTLM)
- [ ] Hash LM **désactivés** (NoLMHash = 1)
- [ ] Audit NTLM **activé** pour identifier les dépendances
- [ ] Plan de migration de NTLM vers Kerberos en cours
- [ ] Signature LDAP **activée** (serveur + client)
- [ ] Kerberos : **Uniquement AES-128 + AES-256** (SupportedEncryptionTypes = 24)
- [ ] DES et RC4 **désactivés** pour Kerberos
- [ ] Surveillance des authentifications NTLM (Event ID 8004)
- [ ] Documentation des systèmes nécessitant encore NTLM
- [ ] Tests de compatibilité avant blocage complet NTLM

### 🔒 Sécurité Additionnelle (Bonus)

- [ ] **BitLocker** activé sur tous les volumes (chiffrement disque complet)
- [ ] **AppLocker** ou **Windows Defender Application Control** configuré
- [ ] Sauvegarde **3-2-1** en place :
  - [ ] 3 copies des données
  - [ ] 2 types de supports différents
  - [ ] 1 copie hors site (offsite/cloud)
- [ ] Sauvegarde testée régulièrement (exercice de restauration)
- [ ] Plan de reprise d'activité (PRA) documenté
- [ ] Segmentation réseau (VLAN) : Serveurs isolés des postes de travail
- [ ] Antivirus sur les sauvegardes (scanner les backups)
- [ ] Monitoring et alertes (CPU, RAM, disque, réseau)
- [ ] Inventaire matériel et logiciel à jour
- [ ] Documentation complète (architecture, procédures, contacts)

---

## 🎓 Conclusion : De Zéro à Héros ! 🏆

### 🚀 Le Chemin Parcouru

**Félicitations** ! 🎉

Si tu es arrivé·e jusqu'ici, tu as parcouru un **voyage extraordinaire** :

1. **Tu es parti·e de zéro** : Peut-être que tu ne savais même pas ce qu'était PowerShell, SMB, ou UAC
2. **Tu as appris les concepts** : Avec des analogies simples (coffres-forts, gardes royaux, sceau de cire...)
3. **Tu as compris les risques** : WannaCry, PrintNightmare, EternalBlue ne sont plus de simples noms, mais des menaces réelles que tu sais prévenir
4. **Tu as appliqué les corrections** : Commande par commande, vérification par vérification
5. **Tu es devenu·e un·e HÉROS de la sécurité Windows** ! 🦸‍♂️🦸‍♀️

### 📊 Rappel des Statistiques Impressionnantes

Grâce à ce guide, tu sais maintenant **prévenir** :

- **WannaCry** (2017) : 200 000+ victimes, 4 milliards $ de dégâts → **Tu sais désactiver SMBv1** ✅
- **NotPetya** (2017) : 10 milliards $ de dégâts → **Tu sais sécuriser SMB** ✅
- **PrintNightmare** (2021) : Millions de serveurs compromis → **Tu sais désactiver Print Spooler** ✅
- **Colonial Pipeline** (2021) : Pipeline d'essence paralysé → **Tu sais sécuriser les sauvegardes et RDP** ✅
- **90% des ransomwares** via RDP mal sécurisé → **Tu sais activer NLA, SSL/TLS, et restreindre par IP** ✅

**En d'autres termes** : Grâce à ce guide, tu as acquis les compétences pour **protéger ton organisation contre des milliards de dollars de dégâts potentiels** ! 💰🛡️

### 🌟 Ce que tu maîtrises maintenant

#### 🎯 Compétences Techniques

- ✅ **PowerShell** : Tu sais utiliser Get-Service, Get-ItemProperty, Set-ItemProperty, auditpol, etc.
- ✅ **Registre Windows** : Tu comprends HKLM, les clés de sécurité, et comment les modifier
- ✅ **Gestion des services** : Start, Stop, Disable, analyse des comptes de service
- ✅ **Pare-feu Windows** : Profils, règles, Get-NetFirewallRule, New-NetFirewallRule
- ✅ **SMB/CIFS** : Versions (SMBv1 vs SMB3), signature, chiffrement, permissions
- ✅ **Audit et logs** : Event Viewer, Event IDs, Get-WinEvent, filtres XML
- ✅ **Authentification** : LM, NTLM, NTLMv2, Kerberos, AES, Pass-the-Hash
- ✅ **UAC** : Niveaux, bureau sécurisé, validation de signatures
- ✅ **RDP** : NLA, chiffrement, SecurityLayer, restrictions IP

#### 🧠 Compétences Conceptuelles

- ✅ **Principe du moindre privilège** : Chaque compte/service a uniquement les droits nécessaires
- ✅ **Défense en profondeur** : Plusieurs couches de sécurité (pare-feu + antivirus + UAC + audit...)
- ✅ **Deny by default, allow by exception** : Bloquer tout par défaut, autoriser uniquement ce qui est nécessaire
- ✅ **Surface d'attaque** : Moins de services = moins de portes d'entrée pour les hackers
- ✅ **Gestion des risques** : Identifier, évaluer, mitiger
- ✅ **Conformité** : CIS Benchmark, ANSSI, Microsoft Security Baseline

#### 🔧 Compétences Pratiques

- ✅ **Auditer** un serveur Windows complet (manuellement ET avec script automatisé)
- ✅ **Interpréter** les résultats d'audit et prioriser les corrections
- ✅ **Durcir** (harden) un serveur selon les standards de l'industrie
- ✅ **Automatiser** des tâches de sécurité avec PowerShell
- ✅ **Documenter** les configurations et justifier les choix
- ✅ **Communiquer** les risques de sécurité à des non-techniques (grâce aux analogies !)

### 💼 Valeur Professionnelle

**Sur le marché du travail**, ces compétences sont **TRÈS recherchées** :

- **Administrateur Système Windows** : Salaire moyen 45K-65K€/an
- **Ingénieur Sécurité** : Salaire moyen 50K-80K€/an
- **Auditeur Sécurité** : Salaire moyen 45K-70K€/an
- **Consultant Cybersécurité** : Salaire moyen 55K-90K€/an

**Certifications complémentaires** que tu peux maintenant viser :

- **CompTIA Security+** : Certification sécurité reconnue mondialement
- **Microsoft Certified: Security, Compliance, and Identity Fundamentals** (SC-900)
- **Microsoft Certified: Windows Server Hybrid Administrator Associate** (AZ-800 + AZ-801)
- **CIS Hardening Specialist**
- **CISSP** (Certified Information Systems Security Professional) - niveau avancé

### 🎯 Et Maintenant ?

**La sécurité n'est PAS une destination, c'est un VOYAGE** ! 🛤️

**1. Applique ce que tu as appris**

- Prends un serveur de test
- Applique chaque vérification du guide
- Lance le script d'audit
- Vise un score de 90%+

**2. Pratique régulièrement**

- Refais un audit mensuel
- Teste de nouvelles configurations
- Reste curieux·se !

**3. Reste à jour**

- Suis les blogs Microsoft Security
- Consulte régulièrement le CIS Benchmark (mis à jour annuellement)
- Lis les advisories de sécurité (CVE)
- Rejoins des communautés (r/sysadmin, r/cybersecurity)

**4. Partage tes connaissances**

- Forme tes collègues
- Écris de la documentation pour ton entreprise
- Contribue à des projets open-source
- Deviens mentor·e pour d'autres débutant·e·s

**5. Continue d'apprendre**

- Explore **Active Directory** (GPO, domaines, forêts)
- Apprends **PowerShell scripting avancé** (modules, DSC)
- Découvre **Azure** et le cloud security
- Penche-toi sur **incident response** et **forensics**

### 🌈 Message Final

**Tu n'es plus un·e débutant·e** ! 🎓

Grâce à ce guide, tu es passé·e de "Je ne sais pas ce qu'est PowerShell" à "Je peux auditer et sécuriser un serveur Windows Server 2022 selon les standards de l'industrie".

**C'est ÉNORME** ! 🚀

Chaque serveur que tu sécurises, c'est :
- Des **données personnelles protégées** 🔐
- Des **entreprises sauvées** d'une paralysie ransomware 🏥
- Des **vies numériques préservées** 👨‍👩‍👧‍👦
- De la **confiance restaurée** dans les systèmes informatiques 🤝

**Tu as le pouvoir de faire une vraie différence** ! 💪

### 🙏 Remerciements

Merci d'avoir lu ce guide jusqu'au bout.

Merci de prendre la sécurité au sérieux.

Merci de vouloir faire mieux.

**Le monde numérique a besoin de héros comme toi** ! 🦸‍♂️🦸‍♀️

### 🚀 Maintenant, vas-y et SÉCURISE CE SERVEUR ! 🛡️

---

**🎯 Score final : 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟 + 🏆 LÉGENDE ABSOLUE ! 🏆**

---

**Fait avec ❤️ pour les futurs expert·e·s en sécurité Windows**

*Version 2.0 - Style "From Zero to Hero" - 2025*

---
