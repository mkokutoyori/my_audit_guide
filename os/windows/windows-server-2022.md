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

*[Guide Windows Server 2022 - Suite en cours de rédaction...]*

**Les parties suivantes à venir :**
- Partie 2 : Comptes Utilisateurs et Authentification
- Partie 3 : Bureau à Distance (RDP)
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

*Ce guide est en cours de transformation pour le rendre ultra-accessible et pédagogique. La suite arrive bientôt !*
