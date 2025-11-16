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

*[Guide Windows Server 2022 - Parties 4-10 à venir]*

**Parties suivantes :**
- Partie 4 : Pare-feu Windows Defender
- Partie 5 : Windows Defender et Antivirus
- Partie 6 : Audit et Journalisation
- Partie 7 : Services Windows
- Partie 8 : Partages Réseau (SMB)
- Partie 9 : User Account Control (UAC)
- Partie 10 : Sécurité Réseau et Protocoles
- Script d'Audit Automatisé v2.0
- Checklist Finale Complète
- Conclusion : De Zéro à Héros !

---

*Transformation en cours... La suite arrive bientôt !*
