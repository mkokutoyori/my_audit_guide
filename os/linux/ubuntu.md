# 🐧 Tutoriel d'Audit Ubuntu - De Zéro à Héros

Salut futur·e expert·e en sécurité ! 🎓

Bienvenue dans LE tutoriel qui va te transformer en pro de l'audit de sécurité Ubuntu. On va y aller étape par étape, commande par commande, et je vais TOUT t'expliquer. À la fin, tu sauras exactement ce que tu fais et pourquoi !

## 🎯 Ce que tu vas apprendre

À la fin de ce tutoriel, tu seras capable de :
- ✅ Auditer un serveur Ubuntu comme un pro
- ✅ Comprendre exactement ce que fait chaque commande
- ✅ Interpréter les résultats que tu vois dans ton terminal
- ✅ Identifier instantanément les problèmes de sécurité
- ✅ Savoir comment corriger chaque problème trouvé
- ✅ Expliquer à ton boss/client pourquoi c'est important

**Promesse :** Si tu suis ce guide jusqu'au bout, tu ne seras plus jamais perdu devant un serveur Ubuntu !

---

## 📋 Avant de Commencer

### Ce qu'il te faut

**Niveau requis :** Débutant qui sait :
- Ouvrir un terminal
- Se connecter en SSH (ou tu vas apprendre maintenant !)
- Copier-coller

**Matériel :**
- Un serveur Ubuntu (ou une VM pour t'entraîner)
- Une connexion SSH
- 1-2 heures devant toi (prends un café ☕)

### Comment se connecter en SSH

Si tu ne l'as jamais fait, voici comment :

```bash
ssh votre_nom_utilisateur@ip_du_serveur
```

**Exemple concret :**
```bash
ssh admin@192.168.1.100
```

**Ce que tu vas voir :**
```
The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
ED25519 key fingerprint is SHA256:abc123def456...
Are you sure you want to continue connecting (yes/no)?
```

**Tape :** `yes` puis ENTRÉE

Ensuite, tape ton mot de passe (tu ne verras rien s'afficher, c'est normal !).

**Résultat si c'est bon :**
```
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-91-generic x86_64)
admin@serveur:~$
```

Bravo, tu es connecté ! Le symbole `$` signifie que tu peux taper des commandes. 🎉

---

## 🔍 PARTIE 1 : Vérifier les Mises à Jour

### 🎓 Concept : Pourquoi les mises à jour ?

Imagine : un chercheur découvre une faille dans Ubuntu. Il prévient Ubuntu. Ubuntu crée un patch (correctif). Si tu ne l'installes pas, c'est comme laisser ta porte d'entrée cassée alors que tout le monde sait qu'elle est cassée !

**Exemples réels :**
- **WannaCry (2017)** : Ransomware qui a paralysé le monde. La faille était patchée depuis 2 mois !
- **Shellshock (2014)** : Faille Bash. Les serveurs non mis à jour ont été hackés en masse.

### ✅ Check #1 : Voir les mises à jour disponibles

#### Commande 1 : Mettre à jour la liste des paquets

```bash
sudo apt update
```

**📖 Explication :**
- `sudo` = exécute en tant que super-utilisateur (admin)
- `apt` = gestionnaire de paquets d'Ubuntu
- `update` = télécharge la liste des mises à jour disponibles (ne les installe PAS encore)

**💻 Ce que tu vas voir dans ton terminal :**

```
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [119 kB]
Get:3 http://archive.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Get:4 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages [500 kB]
Fetched 729 kB in 2s (364 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
23 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

**🔍 Analyse ligne par ligne :**

| Ligne | Signification | C'est bon ? |
|-------|---------------|-------------|
| `Hit:1 http://archive...` | Vérifie le dépôt principal d'Ubuntu | ✅ Normal |
| `Get:2 ... jammy-updates` | Télécharge la liste des mises à jour | ✅ Normal |
| `Get:3 ... jammy-security` | Télécharge les mises à jour de SÉCURITÉ | ✅ Très important ! |
| `Fetched 729 kB` | Taille téléchargée | ✅ Info |
| `23 packages can be upgraded` | 23 paquets ont des mises à jour dispo | ⚠️ À vérifier ! |

**🎯 Ce qu'il faut retenir :**
- ✅ Si tu vois `jammy-security` = les mises à jour de sécurité sont bien configurées
- ⚠️ Le nombre de paquets à mettre à jour (ici 23)
- ❌ Si tu vois des erreurs de connexion = problème de réseau ou de sources

#### Commande 2 : Voir quels paquets sont à mettre à jour

```bash
apt list --upgradable
```

**📖 Explication :**
- `list --upgradable` = montre la liste détaillée de ce qui peut être mis à jour

**💻 Exemple de résultat :**

```
Listing... Done
base-files/jammy-updates 12ubuntu4.5 amd64 [upgradable from: 12ubuntu4.4]
curl/jammy-updates 7.81.0-1ubuntu1.15 amd64 [upgradable from: 7.81.0-1ubuntu1.14]
libcurl4/jammy-updates 7.81.0-1ubuntu1.15 amd64 [upgradable from: 7.81.0-1ubuntu1.14]
linux-generic/jammy-updates 5.15.0-91.101 amd64 [upgradable from: 5.15.0-89.99]
openssl/jammy-security 3.0.2-0ubuntu1.12 amd64 [upgradable from: 3.0.2-0ubuntu1.10]
sudo/jammy-updates 1.9.9-1ubuntu2.4 amd64 [upgradable from: 1.9.9-1ubuntu2.3]
```

**🔍 Analyse détaillée :**

Regardons une ligne en détail :
```
openssl/jammy-security 3.0.2-0ubuntu1.12 amd64 [upgradable from: 3.0.2-0ubuntu1.10]
```

| Partie | Signification | Importance |
|--------|---------------|-----------|
| `openssl` | Nom du paquet (ici la bibliothèque de chiffrement) | 🔴 CRITIQUE si pas à jour |
| `/jammy-security` | C'est une mise à jour de SÉCURITÉ | 🔴 À installer ASAP ! |
| `3.0.2-0ubuntu1.12` | Version NOUVELLE disponible | ⬆️ Nouvelle |
| `from: 3.0.2-0ubuntu1.10` | Version ACTUELLE installée | 📌 Ancienne |
| `amd64` | Architecture (64 bits) | ℹ️ Info technique |

**🎨 Couleurs d'alerte :**

| Type de mise à jour | Niveau | Action |
|---------------------|--------|--------|
| `/jammy-security` | 🔴 URGENT | Installer dans les 24h ! |
| `/jammy-updates` | 🟡 Important | Installer cette semaine |
| Kernel (`linux-generic`) | 🔴 CRITIQUE | Toujours installer (redémarrage requis) |
| `openssl`, `sudo`, `ssh` | 🔴 CRITIQUE | Paquets de sécurité vitaux |

**✅ BONNE PRATIQUE :**
- Mises à jour de sécurité (`/jammy-security`) = installer IMMÉDIATEMENT
- Kernel mis à jour = planifier un redémarrage
- Paquets critiques (ssh, sudo, openssl) = installer dès que possible

**❌ MAUVAIS SIGNE :**
- Plus de 50 paquets en retard = serveur négligé !
- Mises à jour de sécurité datant de >30 jours = DANGER

#### Commande 3 : Vérifier les mises à jour automatiques

```bash
systemctl status unattended-upgrades
```

**📖 Explication :**
- `systemctl` = commande pour gérer les services
- `status` = voir l'état d'un service
- `unattended-upgrades` = service de mises à jour automatiques

**💻 Exemple BIEN configuré :**

```
● unattended-upgrades.service - Unattended Upgrades Shutdown
     Loaded: loaded (/lib/systemd/system/unattended-upgrades.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-01-13 10:23:45 UTC; 2 days ago
       Docs: man:unattended-upgrade(8)
   Main PID: 1234 (unattended-upgr)
      Tasks: 2 (limit: 2345)
     Memory: 15.2M
        CPU: 4.532s
     CGroup: /system.slice/unattended-upgrades.service
             └─1234 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal

Jan 13 10:23:45 serveur systemd[1]: Started Unattended Upgrades Shutdown.
```

**🔍 Analyse ligne par ligne :**

| Ligne | Signification | Bon signe ? |
|-------|---------------|-------------|
| `Loaded: loaded` | Le service existe et est chargé | ✅ |
| `enabled` | Se lance automatiquement au démarrage | ✅ ESSENTIEL |
| `Active: active (running)` | Le service tourne MAINTENANT | ✅ PARFAIT |
| `since Mon 2025-01-13` | Lancé depuis cette date | ✅ |
| `Main PID: 1234` | Identifiant du processus | ℹ️ Info |

**🎨 Interprétation visuelle :**

✅ **CONFIGURATION PARFAITE :**
```
● (point vert)
Loaded: enabled
Active: active (running)
```

⚠️ **PROBLÈME :**
```
● (point vert mais...)
Loaded: disabled   ← PAS BON !
Active: inactive   ← PAS BON !
```

❌ **GROS PROBLÈME :**
```
○ (point gris)
Loaded: masked
Active: inactive (dead)
```

**💡 Que faire selon le résultat ?**

**Si tu vois `disabled` ou `inactive` :**
```bash
# Active le service
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades

# Vérifie que c'est bon
systemctl status unattended-upgrades
```

**Si tu vois `masked` (service bloqué) :**
```bash
# Débloque le service
sudo systemctl unmask unattended-upgrades
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades
```

### 🔧 Action : Installer les mises à jour

#### Commande 4 : Installer les mises à jour

```bash
sudo apt upgrade -y
```

**📖 Explication détaillée :**
- `sudo` = en tant qu'admin
- `apt upgrade` = installer les mises à jour disponibles
- `-y` = répondre automatiquement "yes" aux confirmations (sinon il demande à chaque paquet)

**💻 Ce que tu vas voir :**

```
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following packages will be upgraded:
  base-files curl libcurl4 linux-generic openssl sudo
6 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Need to get 125 MB of archives.
After this operation, 15.3 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu jammy-security/main amd64 openssl amd64 3.0.2-0ubuntu1.12 [1,234 kB]
Get:2 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 curl amd64 7.81.0-1ubuntu1.15 [194 kB]
[... téléchargement des paquets ...]
Fetched 125 MB in 15s (8,333 kB/s)
Preconfiguring packages ...
(Reading database ... 123456 files and directories currently installed.)
Preparing to unpack .../openssl_3.0.2-0ubuntu1.12_amd64.deb ...
Unpacking openssl (3.0.2-0ubuntu1.12) over (3.0.2-0ubuntu1.10) ...
Setting up openssl (3.0.2-0ubuntu1.12) ...
[... installation des autres paquets ...]
Processing triggers for man-db (2.10.2-1) ...
Processing triggers for libc-bin (2.35-0ubuntu3.6) ...
```

**🔍 Décryptage :**

| Phase | Ce qui se passe | Durée typique |
|-------|-----------------|---------------|
| `Reading package lists` | Lecture de la base de données | Quelques secondes |
| `Calculating upgrade` | Calcul des dépendances | Quelques secondes |
| `Need to get 125 MB` | Taille à télécharger | Variable |
| `Get:1 ... Get:2 ...` | Téléchargement | Selon ta connexion |
| `Preparing to unpack` | Préparation de l'installation | Secondes |
| `Unpacking ... over` | Remplacement de l'ancien | Secondes par paquet |
| `Setting up` | Configuration du nouveau | Secondes par paquet |
| `Processing triggers` | Actions post-installation | Fin du processus |

**⚠️ ATTENTION - Messages importants à surveiller :**

**Message 1 - Kernel mis à jour :**
```
*** System restart required ***
```
**Signification :** Le noyau Linux a été mis à jour. Il FAUT redémarrer pour l'activer.

**Action :**
```bash
# Vérifie qu'un redémarrage est nécessaire
ls /var/run/reboot-required
# Si le fichier existe, planifie un redémarrage

# Redémarre maintenant (attention, ça coupe la connexion !)
sudo reboot
```

**Message 2 - Services à redémarrer :**
```
*** Services to be restarted ***
Services to be restarted:
 systemctl restart ssh.service
```
**Signification :** Certains services (ici SSH) doivent redémarrer.

**Action :**
```bash
# Redémarre le service indiqué
sudo systemctl restart ssh.service
```

**Message 3 - Configuration modifiée :**
```
Configuration file '/etc/ssh/sshd_config'
 ==> Modified (by you or by a script) since installation.
 ==> Package distributor has shipped an updated version.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : start a shell to examine the situation
 The default action is to keep your current version.
*** sshd_config (Y/I/N/O/D/Z) [default=N] ?
```

**🎯 Que choisir ?**
- **N** (recommandé) = Garder ta config actuelle (surtout si tu l'as personnalisée)
- **D** = Voir les différences (pour les curieux !)
- **Y** = Utiliser la nouvelle version (si tu n'as rien modifié)

**💡 Conseil :** Choisis **D** d'abord pour voir les différences, puis décide !

### 📊 Récapitulatif de la Partie 1

**✅ Checklist :**
- [ ] `sudo apt update` = liste à jour
- [ ] `apt list --upgradable` = vérifié ce qui est disponible
- [ ] Mises à jour de sécurité (`/jammy-security`) = identifiées
- [ ] `systemctl status unattended-upgrades` = service actif
- [ ] `sudo apt upgrade -y` = mises à jour installées
- [ ] Si besoin, redémarrage effectué

**🎓 Ce que tu as appris :**
- ✅ Mettre à jour la liste des paquets
- ✅ Identifier les mises à jour critiques
- ✅ Comprendre la différence entre sécurité et mises à jour normales
- ✅ Installer les mises à jour
- ✅ Gérer les services et redémarrages

**Niveau actuel : 🌟 Débutant → Intermédiaire !**

---

## 🔐 PARTIE 2 : Comptes Utilisateurs - Qui a les Clés ?

### 🎓 Concept : Pourquoi c'est LA priorité

Les comptes utilisateurs, c'est comme les clés de ta maison. Si tu :
- Laisses une clé sous le paillasson → Compte sans mot de passe
- Donnes la clé à tout le monde → Trop de comptes admin
- Ne changes jamais les serrures → Mots de passe qui n'expirent jamais

**Statistiques choquantes :**
- 81% des piratages utilisent des mots de passe volés ou faibles (Verizon 2023)
- Le mot de passe le plus courant reste "123456" (en 2024 !)

### ✅ Check #1 : Vérifier le compte ROOT

#### Qu'est-ce que ROOT ?

`root` = Le Dieu du serveur. Il peut :
- ✅ Installer/supprimer n'importe quoi
- ✅ Lire TOUS les fichiers (même les secrets)
- ✅ Modifier la config système
- ❌ Mais aussi TOUT casser en une commande !

**Règle d'or :** Ne JAMAIS se connecter directement en root. Utilise ton compte normal + `sudo`.

#### Commande 1 : Vérifier si root peut se connecter en SSH

```bash
sudo grep "PermitRootLogin" /etc/ssh/sshd_config
```

**📖 Explication :**
- `sudo` = en tant qu'admin (nécessaire pour lire ce fichier)
- `grep` = cherche une ligne contenant...
- `"PermitRootLogin"` = ...cette phrase
- `/etc/ssh/sshd_config` = dans ce fichier (config SSH)

**💻 Exemple de résultat - CAS 1 (BIEN) :**

```
PermitRootLogin no
```

**🔍 Analyse :**
- ✅ **PARFAIT !** Root ne peut PAS se connecter en SSH
- C'est la configuration recommandée par tous les experts de sécurité

**💻 Exemple de résultat - CAS 2 (PAS BIEN) :**

```
#PermitRootLogin prohibit-password
```

**🔍 Analyse :**
- ⚠️ Le `#` au début = ligne commentée = DÉSACTIVÉE
- Donc cette ligne ne fait rien !
- Par défaut, SSH pourrait autoriser root

**💻 Exemple de résultat - CAS 3 (DANGEREUX) :**

```
PermitRootLogin yes
```

**🔍 Analyse :**
- ❌ **DANGER !** Root peut se connecter en SSH
- Les robots scannent Internet 24/7 en essayant "root/password"
- C'est comme mettre un panneau "Entrez librement !" sur ta porte

**💻 Exemple de résultat - CAS 4 (ACCEPTABLE) :**

```
PermitRootLogin prohibit-password
```

**🔍 Analyse :**
- 🟡 Root peut se connecter MAIS uniquement avec une clé SSH (pas de mot de passe)
- C'est mieux que "yes" mais pas idéal
- Recommandation : passer à "no"

**📊 Tableau récapitulatif :**

| Valeur | Niveau | Signification | Action |
|--------|--------|---------------|--------|
| `PermitRootLogin no` | ✅ PARFAIT | Root bloqué en SSH | Rien à faire ! |
| `PermitRootLogin prohibit-password` | 🟡 OK | Root avec clé SSH seulement | Passer à "no" |
| `PermitRootLogin yes` | ❌ DANGER | Root avec mot de passe OK | CORRIGER ! |
| `#PermitRootLogin ...` | ⚠️ INCONNU | Ligne commentée | CORRIGER ! |

#### Commande 2 : Vérifier si root a un mot de passe

```bash
sudo passwd -S root
```

**📖 Explication :**
- `passwd` = commande de gestion des mots de passe
- `-S` = **S**tatus = affiche l'état du mot de passe
- `root` = pour l'utilisateur root

**💻 Exemple de résultat - CAS 1 (IDÉAL) :**

```
root L 01/15/2024 0 99999 7 -1
```

**🔍 Décryptage colonne par colonne :**

| Colonne | Valeur | Signification | Bon ? |
|---------|--------|---------------|-------|
| 1 | `root` | Nom de l'utilisateur | ℹ️ |
| 2 | `L` | **L**ocked = verrouillé | ✅ PARFAIT |
| 3 | `01/15/2024` | Date du dernier changement | ℹ️ |
| 4 | `0` | Jours min entre changements | ℹ️ |
| 5 | `99999` | Jours max avant expiration | ℹ️ |
| 6 | `7` | Avertissement X jours avant | ℹ️ |
| 7 | `-1` | Pas de période d'inactivité | ℹ️ |

**Le plus important :** La lettre en colonne 2 !

| Lettre | Signification | Niveau |
|--------|---------------|--------|
| `L` | **L**ocked - Verrouillé | ✅ PARFAIT |
| `P` | **P**assword set - Mot de passe actif | ⚠️ PAS TERRIBLE |
| `NP` | **N**o **P**assword - Pas de mot de passe | ❌ CATASTROPHE |

**💻 Exemple de résultat - CAS 2 (PAS BON) :**

```
root P 01/15/2024 0 99999 7 -1
```

**🔍 Analyse :**
- ❌ Le `P` signifie que root a un mot de passe actif
- Combiné avec `PermitRootLogin yes` = TRÈS DANGEREUX
- Les bots testent des millions de mots de passe

**💻 Exemple de résultat - CAS 3 (CATASTROPHE) :**

```
root NP 01/15/2024 0 99999 7 -1
```

**🔍 Analyse :**
- 🔴 `NP` = **N**o **P**assword = AUCUN mot de passe !
- C'est comme laisser ta porte ouverte avec un panneau "Servez-vous"
- À corriger IMMÉDIATEMENT

### 🔧 CORRECTION : Sécuriser le compte root

#### Étape 1 : Bloquer le login root SSH

```bash
# Édite le fichier de config SSH
sudo nano /etc/ssh/sshd_config
```

**💻 Dans l'éditeur nano :**
- Utilise les flèches pour naviguer
- Trouve la ligne `PermitRootLogin ...`
- Change-la pour : `PermitRootLogin no`
- **Sauvegarde :** `Ctrl + O` puis `Entrée`
- **Quitte :** `Ctrl + X`

**OU en une commande (pour les pros) :**
```bash
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
```

**📖 Explication de cette commande magique :**
- `sed` = éditeur de flux (modification de fichiers)
- `-i` = modifie le fichier directement
- `s/` = **s**ubstitute = remplace
- `^#\?PermitRootLogin.*` = trouve toute ligne commençant par (éventuellement #) PermitRootLogin
- `/PermitRootLogin no/` = remplace par ça
- `/etc/ssh/sshd_config` = dans ce fichier

#### Étape 2 : Vérifier que la modif est OK

```bash
sudo grep "PermitRootLogin" /etc/ssh/sshd_config
```

**💻 Tu dois voir :**
```
PermitRootLogin no
```

#### Étape 3 : Redémarrer SSH pour appliquer

⚠️ **SUPER IMPORTANT :** Ne ferme PAS ta session SSH avant de tester !

**Dans ta session SSH actuelle :**
```bash
# Teste d'abord que la config est valide
sudo sshd -t
```

**💻 Si tout va bien, tu ne vois RIEN (c'est bon signe) :**
```
(pas de sortie = tout est OK)
```

**Si tu vois une erreur :**
```
/etc/ssh/sshd_config line 38: Bad configuration option: PeritRootLogin
/etc/ssh/sshd_config: terminating, 1 bad configuration options
```
**Signification :** Typo dans le fichier ! (ici "Perit" au lieu de "Permit")

**🔧 Si erreur, corrige :**
```bash
sudo nano /etc/ssh/sshd_config
# Corrige la faute de frappe
```

**Une fois que `sudo sshd -t` ne dit rien (=OK) :**

```bash
# Redémarre SSH
sudo systemctl restart sshd
```

**💻 Ce que tu verras :**
```
(rien = c'est bon !)
```

**Vérification :**
```bash
systemctl status sshd
```

**💻 Tu dois voir :**
```
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded
     Active: active (running) since [date récente]
```

#### Étape 4 : Teste dans une NOUVELLE fenêtre

**Ouvre un NOUVEAU terminal** (garde l'ancien ouvert !), teste :

```bash
ssh root@ip_du_serveur
```

**💻 Résultat attendu :**
```
root@ip_du_serveur: Permission denied (publickey).
```

**✅ PARFAIT !** Root ne peut plus se connecter !

#### Étape 5 : Verrouiller le compte root

```bash
sudo passwd -l root
```

**📖 Explication :**
- `passwd` = gestion des mots de passe
- `-l` = **l**ock = verrouiller
- `root` = le compte root

**💻 Tu verras :**
```
passwd: password expiry information changed.
```

**Vérification :**
```bash
sudo passwd -S root
```

**💻 Maintenant tu vois :**
```
root L 01/15/2025 0 99999 7 -1
     ^
     Ça c'est le "L" de Locked !
```

**🎉 Bravo ! Le compte root est maintenant sécurisé !**

---

## 📊 Récapitulatif Partie 2

**✅ Checklist - Sécurisation du compte root :**
- [ ] `grep PermitRootLogin` = vérifié dans sshd_config
- [ ] Changé pour `PermitRootLogin no`
- [ ] `sudo sshd -t` = config testée et valide
- [ ] `systemctl restart sshd` = service redémarré
- [ ] Testé dans nouvelle fenêtre que root ne peut plus se connecter
- [ ] `sudo passwd -l root` = compte root verrouillé
- [ ] `passwd -S root` = vérifié que le `L` apparaît

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Lire et modifier un fichier de config critique (sshd_config)
- ✅ Utiliser `grep` pour chercher dans un fichier
- ✅ Utiliser `sed` pour modifier automatiquement
- ✅ Tester une config SSH sans risque
- ✅ Interpréter les statuts de mots de passe
- ✅ Verrouiller un compte utilisateur

**Niveau actuel : 🌟🌟 Intermédiaire → Intermédiaire+ !**

---

## 🚪 PARTIE 3 : SSH - Blindage de ta Porte d'Entrée

### 🎓 Concept : SSH = Ta Porte Principale

SSH (Secure Shell), c'est LA porte d'entrée de ton serveur. Si elle est mal sécurisée, c'est game over.

**Chiffres qui font peur :**
- Un serveur SSH exposé sur Internet reçoit environ **3000-5000 tentatives de connexion par jour** !
- 90% des serveurs compromis l'ont été via SSH mal configuré

**Analogie :** Imagine une porte d'appartement :
- 🔐 Clés SSH = Serrure à carte magnétique (super sécurisé)
- 🔑 Mot de passe = Clé traditionnelle (peut être copiée)
- 🚪 SSH ouvert à tous = Porte sans serrure

### ✅ Check #1 : Configuration SSH Complète

#### Commande : Voir toute la config active

```bash
sudo sshd -T | head -30
```

**📖 Explication :**
- `sshd` = le daemon (service) SSH
- `-T` = **T**est mode = affiche la config complète après traitement
- `| head -30` = affiche seulement les 30 premières lignes

**💻 Exemple de résultat :**

```
port 22
addressfamily any
listenaddress [::]:22
listenaddress 0.0.0.0:22
permitrootlogin no
pubkeyauthentication yes
passwordauthentication yes
permitemptypasswords no
challengeresponseauthentication no
usepam yes
x11forwarding yes
printmotd no
acceptenv LANG LC_*
subsystem sftp /usr/lib/openssh/sftp-server
maxauthtries 6
logingracetime 120
clientaliveinterval 0
clientalivecountmax 3
```

**🔍 Analyse des paramètres critiques :**

| Paramètre | Valeur ACTUELLE | Valeur SÉCURISÉE | Niveau Risque |
|-----------|-----------------|------------------|---------------|
| `permitrootlogin` | yes | **no** | 🔴 CRITIQUE |
| `passwordauthentication` | yes | **no** | 🔴 CRITIQUE |
| `pubkeyauthentication` | yes | **yes** | ✅ BON |
| `permitemptypasswords` | no | **no** | ✅ BON |
| `x11forwarding` | yes | **no** | 🟡 MOYEN |
| `maxauthtries` | 6 | **3-4** | 🟠 À CORRIGER |
| `logingracetime` | 120 | **60** | 🟡 MOYEN |
| `clientaliveinterval` | 0 | **300** | 🟠 À CORRIGER |

**🎯 Configuration SSH PARFAITE :**

```
permitrootlogin no
passwordauthentication no         ← Clés SSH uniquement !
pubkeyauthentication yes
permitemptypasswords no
x11forwarding no
maxauthtries 3
logingracetime 60
clientaliveinterval 300          ← Déconnexion auto après 5 min
clientalivecountmax 2
```

### 🔧 CORRECTION : Sécuriser SSH comme Fort Knox

#### Étape 1 : Créer des clés SSH (SI PAS DÉJÀ FAIT)

**⚠️ IMPORTANT : Fais ça depuis TON ordinateur, PAS le serveur !**

```bash
ssh-keygen -t ed25519 -C "mon-email@example.com"
```

**📖 Explication :**
- `ssh-keygen` = générateur de clés SSH
- `-t ed25519` = utilise l'algorithme Ed25519 (le plus sécurisé)
- `-C "..."` = **C**omment = ajoute un commentaire (ton email)

**💻 Ce que tu vas voir :**

```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519):
```

**➡️ Action :** Appuie sur ENTRÉE (accepte l'emplacement par défaut)

```
Enter passphrase (empty for no passphrase):
```

**➡️ Action :** Tape une phrase de passe FORTE (ou laisse vide si tu préfères)

**💡 Conseil :** Une phrase de passe, c'est un mot de passe pour ta clé SSH. C'est une double sécurité !

```
Enter same passphrase again:
```

**➡️ Action :** Re-tape la même phrase

**💻 Résultat final :**

```
Your identification has been saved in /home/user/.ssh/id_ed25519
Your public key has been saved in /home/user/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:abc123def456ghi789jkl... mon-email@example.com
The key's randomart image is:
+--[ED25519 256]--+
|    .o.          |
|   .  o          |
|  . .  .         |
|   o  . .        |
|    o. oS.       |
|   . +oo+.       |
|    E.=+o .      |
|   .o*=+o        |
|    o*B+.        |
+----[SHA256]-----+
```

**✅ Félicitations ! Tu as créé ta paire de clés !**
- **Clé PRIVÉE** : `/home/user/.ssh/id_ed25519` → GARDE-LA SECRÈTE !
- **Clé PUBLIQUE** : `/home/user/.ssh/id_ed25519.pub` → Celle-ci va sur le serveur

#### Étape 2 : Copier la clé publique sur le serveur

```bash
ssh-copy-id votre_user@ip_du_serveur
```

**📖 Explication :**
- `ssh-copy-id` = copie ta clé publique sur le serveur
- `votre_user` = ton nom d'utilisateur sur le serveur
- `@ip_du_serveur` = l'adresse IP ou nom de domaine

**💻 Ce que tu vas voir :**

```
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
votre_user@192.168.1.100's password:
```

**➡️ Action :** Tape ton mot de passe (dernière fois que tu en as besoin !)

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'votre_user@192.168.1.100'"
and check to make sure that only the key(s) you wanted were added.
```

**✅ Succès ! Ta clé est maintenant sur le serveur !**

#### Étape 3 : Tester la connexion avec la clé

**Dans un NOUVEAU terminal (garde l'ancien ouvert !) :**

```bash
ssh votre_user@192.168.1.100
```

**💻 Si tout va bien :**

```
Welcome to Ubuntu 22.04.3 LTS
votre_user@serveur:~$
```

**🎉 Aucun mot de passe demandé = Tu utilises la clé SSH !**

**❌ Si on te demande le mot de passe :**
- La clé n'a pas été copiée correctement
- Recommence l'étape 2

**❌ Si tu vois "Permission denied (publickey)" :**
- Ta clé privée n'est pas au bon endroit
- Vérifie avec : `ls -la ~/.ssh/id_ed25519`

#### Étape 4 : Durcir la configuration SSH

**Maintenant qu'on a les clés, on peut tout verrouiller !**

```bash
sudo nano /etc/ssh/sshd_config
```

**💻 Dans l'éditeur, trouve et modifie ces lignes :**

```
# Désactive root en SSH
PermitRootLogin no

# SEULEMENT les clés SSH (pas de mot de passe)
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no

# Limite les tentatives
MaxAuthTries 3
LoginGraceTime 60

# Déconnexion automatique après inactivité
ClientAliveInterval 300        # 5 minutes
ClientAliveCountMax 2          # 2 tentatives max

# Désactive X11 (pas nécessaire)
X11Forwarding no

# Optionnel : Limite aux utilisateurs spécifiques
AllowUsers votre_user
```

**💾 Sauvegarde :** `Ctrl+O`, ENTRÉE, `Ctrl+X`

#### Étape 5 : Vérifier et appliquer

**⚠️ NE FERME PAS ta session SSH actuelle !**

```bash
# Teste que la config est valide
sudo sshd -t
```

**💻 Si OK, tu ne vois rien :**
```
(silence = succès)
```

**💻 Si erreur :**
```
/etc/ssh/sshd_config line 42: Bad configuration option: Passwrd
sshd_config: terminating, 1 bad configuration options
```
**➡️ Corrige la typo** (ici "Passwrd" au lieu de "Password")

**Une fois OK :**

```bash
# Redémarre SSH
sudo systemctl restart sshd

# Vérifie qu'il tourne
systemctl status sshd
```

**💻 Tu dois voir :**
```
● ssh.service - OpenBSD Secure Shell server
     Active: active (running)
```

#### Étape 6 : Tester dans une NOUVELLE fenêtre

**Ouvre un NOUVEAU terminal, teste :**

```bash
# Teste avec ton user (doit marcher)
ssh votre_user@ip_du_serveur
```
**✅ Doit fonctionner sans mot de passe**

```bash
# Teste avec root (doit être refusé)
ssh root@ip_du_serveur
```
**✅ Doit afficher : "Permission denied"**

**Si les deux tests passent : BRAVO ! Ton SSH est blindé ! 🔐**

### 🛡️ BONUS : Fail2Ban - Le Videur Automatique

Fail2Ban, c'est comme un videur qui ban automatiquement les IPs qui essaient trop de fois de se connecter.

#### Installation

```bash
sudo apt install fail2ban -y
```

**💻 Ce que tu vas voir :**
```
Reading package lists... Done
Building dependency tree... Done
[...]
Setting up fail2ban (0.11.2-6) ...
Created symlink /etc/systemd/system/multi-user.target.wants/fail2ban.service
```

#### Configuration

```bash
# Crée une config personnalisée
sudo nano /etc/fail2ban/jail.local
```

**💻 Ajoute ce contenu :**

```ini
[DEFAULT]
# Ban les IPs pour 1 heure (3600 secondes)
bantime = 3600

# Fenêtre de temps pour compter les échecs (10 min)
findtime = 600

# Nombre max d'échecs avant ban
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

**💾 Sauvegarde et quitte**

#### Activation

```bash
# Redémarre Fail2Ban
sudo systemctl restart fail2ban

# Vérifie qu'il tourne
sudo systemctl status fail2ban
```

**💻 Tu dois voir :**
```
● fail2ban.service - Fail2Ban Service
     Active: active (running)
```

#### Vérifier les bans

```bash
# Voir le statut de la jail SSH
sudo fail2ban-client status sshd
```

**💻 Exemple de résultat :**

```
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     45
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 2
   |- Total banned:     8
   `- Banned IP list:   103.251.167.10 185.156.73.54
```

**🔍 Analyse :**

| Info | Signification |
|------|---------------|
| `Currently failed: 0` | Aucune tentative échouée récente |
| `Total failed: 45` | 45 tentatives ratées depuis le début |
| `Currently banned: 2` | 2 IPs bannies actuellement |
| `Banned IP list` | Liste des IPs bannies |

**💡 Astuce - Débannir une IP (si tu t'es auto-banni !) :**

```bash
sudo fail2ban-client set sshd unbanip VOTRE_IP
```

**📊 Récapitulatif Partie 3**

**✅ Checklist - SSH Blindé :**
- [ ] Clés SSH créées (`ssh-keygen`)
- [ ] Clés copiées sur serveur (`ssh-copy-id`)
- [ ] Connexion par clé testée et fonctionnelle
- [ ] `PasswordAuthentication no` dans sshd_config
- [ ] `PermitRootLogin no` dans sshd_config
- [ ] `MaxAuthTries` réduit à 3
- [ ] `ClientAliveInterval` configuré
- [ ] Config testée (`sshd -t`)
- [ ] SSH redémarré et fonctionnel
- [ ] Fail2Ban installé et actif
- [ ] Testé dans nouvelle fenêtre : connexion OK, root refusé

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Créer et utiliser des clés SSH
- ✅ Comprendre la différence clés vs mots de passe
- ✅ Configurer SSH avec sécurité maximale
- ✅ Tester une config SSH sans te bloquer dehors
- ✅ Installer et configurer Fail2Ban
- ✅ Surveiller les tentatives d'intrusion

**Niveau actuel : 🌟🌟🌟 Intermédiaire+ → Avancé !**

---

## 🔥 PARTIE 4 : Pare-feu UFW - Le Videur de Ton Serveur

### 🎓 Concept : Le Pare-feu = Videur de Boîte de Nuit

Un pare-feu, c'est comme le videur d'une boîte de nuit :
- **Liste blanche** : Seules les personnes autorisées entrent
- **Par défaut** : Tout le monde est dehors
- **Règles** : "Entrée VIP port 443", "Entrée normale port 80"

**Sans pare-feu = Portes grandes ouvertes sur Internet !**

### ✅ Check #1 : État du pare-feu

#### Commande : Vérifier si UFW est actif

```bash
sudo ufw status verbose
```

**📖 Explication :**
- `ufw` = **U**ncomplicated **F**ire**w**all = pare-feu simple
- `status` = état actuel
- `verbose` = mode bavard (plus de détails)

**💻 Exemple CAS 1 - BIEN configuré :**

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp (OpenSSH)          LIMIT       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
22/tcp (OpenSSH (v6))     LIMIT       Anywhere (v6)
80/tcp (v6)                ALLOW       Anywhere (v6)
443/tcp (v6)               ALLOW       Anywhere (v6)
```

**🔍 Analyse ligne par ligne :**

| Ligne | Signification | Bon signe ? |
|-------|---------------|-------------|
| `Status: active` | Le pare-feu est ACTIF | ✅ ESSENTIEL |
| `Logging: on (low)` | Les logs sont activés | ✅ BON |
| `Default: deny (incoming)` | PAR DÉFAUT, tout entrant est BLOQUÉ | ✅ PARFAIT |
| `allow (outgoing)` | Tout sortant est autorisé | ✅ Normal |
| `22/tcp LIMIT` | SSH avec limitation (anti brute-force) | ✅ EXCELLENT |
| `80/tcp ALLOW` | HTTP autorisé | ℹ️ Si tu as un site web |
| `443/tcp ALLOW` | HTTPS autorisé | ℹ️ Si tu as un site web sécurisé |

**💻 Exemple CAS 2 - PAS BON :**

```
Status: inactive
```

**🔍 Analyse :**
- 🔴 **DANGER !** Le pare-feu est éteint
- Tous les ports sont ouverts = serveur sans protection
- À corriger IMMÉDIATEMENT

**💻 Exemple CAS 3 - MAUVAISE CONFIG :**

```
Status: active
Default: allow (incoming), allow (outgoing)
```

**🔍 Analyse :**
- ⚠️ Le pare-feu est actif MAIS...
- `allow (incoming)` = tout est autorisé par défaut !
- C'est comme avoir un videur qui laisse entrer tout le monde

### 🔧 CORRECTION : Activer et configurer UFW

#### ⚠️ ATTENTION - Étape CRITIQUE !

**Si tu es connecté en SSH, tu DOIS autoriser SSH AVANT d'activer le pare-feu, sinon tu te bloques toi-même dehors !**

#### Étape 1 : Autoriser SSH d'abord

```bash
# Autorise SSH avec limitation de débit (anti brute-force)
sudo ufw limit 22/tcp
```

**📖 Explication :**
- `ufw limit` = autorise MAIS limite les tentatives de connexion
- `22/tcp` = port 22, protocole TCP (SSH)

**💻 Tu verras :**
```
Rules updated
Rules updated (v6)
```

**✅ Les deux lignes (IPv4 et IPv6) = normal et bon !**

**💡 Différence `allow` vs `limit` :**

| Commande | Signification | Quand l'utiliser |
|----------|---------------|------------------|
| `ufw allow 22/tcp` | Autorise TOUT le trafic | Pour les services sans risque |
| `ufw limit 22/tcp` | Autorise MAIS limite à 6 connexions/30s par IP | Pour SSH (anti brute-force) |

#### Étape 2 : Définir les règles par défaut

```bash
# Bloque tout entrant par défaut
sudo ufw default deny incoming

# Autorise tout sortant
sudo ufw default allow outgoing
```

**💻 Tu verras :**
```
Default incoming policy changed to 'deny'
(be sure to update your rules accordingly)
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)
```

#### Étape 3 : Activer UFW

```bash
sudo ufw enable
```

**💻 Tu verras :**
```
Command may disrupt existing ssh connections. Proceed with operation (y|n)?
```

**➡️ Action :** Tape `y` puis ENTRÉE

**💻 Résultat :**
```
Firewall is active and enabled on system startup
```

**✅ Parfait ! Le pare-feu est actif et se lancera au démarrage !**

#### Étape 4 : Vérifier

```bash
sudo ufw status verbose
```

**💻 Tu dois voir :**
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
22/tcp                     LIMIT       Anywhere
22/tcp (v6)                LIMIT       Anywhere (v6)
```

**✅ C'est parfait ! SSH est autorisé, tout le reste est bloqué !**

### 🎯 Ajouter d'autres règles selon tes besoins

#### Exemple 1 : Serveur Web

```bash
# HTTP (site web non sécurisé)
sudo ufw allow 80/tcp

# HTTPS (site web sécurisé)
sudo ufw allow 443/tcp
```

#### Exemple 2 : Base de données MySQL (depuis une IP spécifique)

```bash
# MySQL seulement depuis 192.168.1.50
sudo ufw allow from 192.168.1.50 to any port 3306
```

**📖 Explication :**
- `from 192.168.1.50` = seulement depuis cette IP
- `to any port 3306` = vers le port 3306 (MySQL)

**💡 Conseil :** Toujours limiter les bases de données par IP source !

#### Exemple 3 : Plage d'adresses

```bash
# Autorise tout le sous-réseau 192.168.1.0/24 pour SSH
sudo ufw allow from 192.168.1.0/24 to any port 22
```

### 📋 Gérer les règles existantes

#### Voir les règles numérotées

```bash
sudo ufw status numbered
```

**💻 Exemple de résultat :**

```
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     LIMIT IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 443/tcp                    ALLOW IN    Anywhere
[ 4] 3306                       ALLOW IN    192.168.1.50
[ 5] 22/tcp (v6)                LIMIT IN    Anywhere (v6)
[ 6] 80/tcp (v6)                ALLOW IN    Anywhere (v6)
[ 7] 443/tcp (v6)               ALLOW IN    Anywhere (v6)
```

#### Supprimer une règle

```bash
# Supprime la règle numéro 4
sudo ufw delete 4
```

**💻 Tu verras :**
```
Deleting:
 allow from 192.168.1.50 to any port 3306
Proceed with operation (y|n)?
```

**➡️ Tape `y` pour confirmer**

### 💡 Bonnes Pratiques Pare-feu

**✅ À FAIRE :**
1. **Principe du moindre privilège** : N'ouvre QUE les ports nécessaires
2. **Spécificité** : Restreins par IP quand possible
3. **SSH en limit** : Toujours utiliser `limit` pour SSH
4. **Documentation** : Note pourquoi chaque port est ouvert
5. **Révision régulière** : Tous les 3-6 mois, vérifie que tu as encore besoin de chaque règle

**❌ À ÉVITER :**
1. Ouvrir des ports "au cas où"
2. Utiliser `allow` au lieu de `limit` pour SSH
3. Autoriser `0.0.0.0/0` (tout Internet) pour des services internes
4. Désactiver le pare-feu "temporairement" (et oublier de le réactiver !)

**📊 Récapitulatif Partie 4**

**✅ Checklist - Pare-feu :**
- [ ] `ufw status` = actif
- [ ] Règles par défaut : deny incoming, allow outgoing
- [ ] SSH autorisé avec `limit`
- [ ] Seuls les ports nécessaires ouverts
- [ ] Bases de données restreintes par IP
- [ ] UFW enabled au démarrage
- [ ] Testé que la connexion SSH fonctionne toujours

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Activer et configurer un pare-feu
- ✅ Comprendre les règles par défaut
- ✅ Différence entre allow et limit
- ✅ Restreindre par IP source
- ✅ Gérer et supprimer des règles
- ✅ Sécuriser ton serveur sans te bloquer dehors

**Niveau actuel : 🌟🌟🌟🌟 Avancé → Expert !**

---

## 📝 PARTIE 5 : Logs et Audit - Tracer Tout ce qui Bouge

### 🎓 Concept : Les Logs = Caméras de Surveillance

Les logs (journaux), c'est comme les caméras de surveillance d'un magasin :
- **Sans logs** = Pas de vidéo. Un vol se produit, tu ne sauras jamais qui c'était
- **Avec logs** = Tu peux remonter dans le temps et voir exactement ce qui s'est passé

**Statistiques impressionnantes :**
- 70% des piratages ne sont détectés qu'après **plusieurs mois** (IBM Security 2023)
- Sans logs, impossible de savoir QUAND et COMMENT tu as été piraté
- Les logs permettent aussi de détecter les comportements anormaux AVANT un incident

### ✅ Check #1 : Configuration des Logs Système

#### Commande : Vérifier le service de logs

```bash
systemctl status rsyslog
```

**📖 Explication :**
- `rsyslog` = Le service qui gère les logs système sous Ubuntu
- C'est lui qui écrit tous les événements dans `/var/log/`

**💻 Exemple BIEN configuré :**

```
● rsyslog.service - System Logging Service
     Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-01-13 10:23:12 UTC; 3 days ago
TriggeredBy: ● syslog.socket
       Docs: man:rsyslogd(8)
             man:rsyslog.conf(5)
   Main PID: 723 (rsyslogd)
      Tasks: 4 (limit: 2345)
     Memory: 4.2M
        CPU: 2.341s
     CGroup: /system.slice/rsyslog.service
             └─723 /usr/sbin/rsyslogd -n -iNONE
```

**🔍 Analyse :**

| Élément | Valeur | Bon ? |
|---------|--------|-------|
| `Loaded` | enabled | ✅ Se lance au démarrage |
| `Active` | active (running) | ✅ Tourne actuellement |
| `Main PID` | 723 | ✅ Processus actif |

**❌ Si tu vois `inactive` :**
```bash
# Active et démarre rsyslog
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
```

### ✅ Check #2 : Vérifier les Fichiers de Logs

#### Commande : Lister les logs principaux

```bash
ls -lh /var/log/ | grep -E "(syslog|auth.log|kern.log)"
```

**📖 Explication :**
- `/var/log/` = Répertoire contenant TOUS les logs
- `syslog` = Log général du système
- `auth.log` = Log des authentifications (connexions SSH, sudo, etc.)
- `kern.log` = Log du noyau Linux

**💻 Exemple de résultat :**

```
-rw-r----- 1 syslog adm  145K Jan 16 10:23 auth.log
-rw-r----- 1 syslog adm  234K Jan 16 10:23 syslog
-rw-r----- 1 syslog adm   89K Jan 16 10:23 kern.log
```

**🔍 Analyse des permissions :**

| Colonne | Valeur | Signification | Bon ? |
|---------|--------|---------------|-------|
| Permissions | `-rw-r-----` | Owner: lecture/écriture, Group: lecture, Others: rien | ✅ SÉCURISÉ |
| Owner | `syslog` | Propriétaire = service syslog | ✅ |
| Group | `adm` | Groupe admin peut lire | ✅ |
| Taille | `145K` | Taille du fichier | ℹ️ |

**❌ PROBLÈME - Permissions trop ouvertes :**

```
-rw-r--r-- 1 syslog adm  145K Jan 16 10:23 auth.log
          ^^
      Tout le monde peut lire !
```

**🔧 Correction :**
```bash
# Corrige les permissions (640 = rw-r-----)
sudo chmod 640 /var/log/auth.log
sudo chmod 640 /var/log/syslog
sudo chmod 640 /var/log/kern.log
```

### ✅ Check #3 : Analyser les Logs d'Authentification

#### Commande : Voir les dernières connexions SSH

```bash
sudo grep "Accepted" /var/log/auth.log | tail -10
```

**📖 Explication :**
- `grep "Accepted"` = cherche les lignes contenant "Accepted" (connexions réussies)
- `/var/log/auth.log` = fichier des logs d'authentification
- `tail -10` = affiche seulement les 10 dernières

**💻 Exemple de résultat :**

```
Jan 16 09:15:32 serveur sshd[12345]: Accepted publickey for admin from 192.168.1.100 port 54321 ssh2: ED25519 SHA256:abc123...
Jan 16 10:22:18 serveur sshd[12456]: Accepted publickey for admin from 192.168.1.100 port 54322 ssh2: ED25519 SHA256:abc123...
```

**🔍 Décryptage ligne par ligne :**

| Partie | Valeur | Signification |
|--------|--------|---------------|
| `Jan 16 09:15:32` | Date et heure | Quand ça s'est passé |
| `serveur` | Nom du serveur | Sur quel serveur |
| `sshd[12345]` | Service SSH, processus 12345 | Quel service |
| `Accepted publickey` | Connexion ACCEPTÉE par clé SSH | ✅ BON (clé, pas mot de passe) |
| `for admin` | Utilisateur = admin | Qui s'est connecté |
| `from 192.168.1.100` | Depuis cette IP | D'où |
| `ED25519` | Type de clé | ✅ Algorithme moderne |

**✅ BONS SIGNES :**
- `Accepted publickey` = Connexion par clé SSH (sécurisé)
- IPs reconnues = Tes IPs habituelles

**🚨 MAUVAIS SIGNES :**
- `Accepted password` = Connexion par mot de passe (moins sécurisé)
- IPs inconnues = Possiblement une intrusion !

#### Commande : Voir les tentatives ÉCHOUÉES

```bash
sudo grep "Failed password" /var/log/auth.log | tail -10
```

**💻 Exemple de résultat :**

```
Jan 16 03:45:12 serveur sshd[23456]: Failed password for invalid user admin from 185.220.101.42 port 43210 ssh2
Jan 16 03:45:15 serveur sshd[23457]: Failed password for invalid user root from 185.220.101.42 port 43211 ssh2
Jan 16 03:45:18 serveur sshd[23458]: Failed password for invalid user test from 185.220.101.42 port 43212 ssh2
```

**🔍 Analyse :**

**C'est quoi ?** Un bot/attaquant essaie de se connecter avec des mots de passe au hasard.

| Indicateur | Ce que ça veut dire | Action |
|------------|---------------------|--------|
| IP étrangère (185.x.x.x) | Attaquant probablement à l'étranger | Normal si Fail2Ban actif |
| Tentatives multiples rapides | Attaque automatisée (bot) | Vérifie que l'IP est bannie |
| `invalid user` | Essaie des users qui n'existent pas | ✅ Échec garanti |

**🔧 Vérification - L'IP est-elle bannie ?**

```bash
sudo fail2ban-client status sshd | grep "185.220.101.42"
```

**✅ Si l'IP apparaît dans "Banned IP list" = Fail2Ban a fait son job !**

### ✅ Check #4 : Auditd - L'Enregistreur Professionnel

Auditd, c'est le niveau supérieur des logs. Il peut enregistrer :
- **Qui** a accédé à **quel fichier**
- **Qui** a exécuté **quelle commande**
- **Qui** a modifié **quelle config**

#### Installation

```bash
sudo apt install auditd audispd-plugins -y
```

**💻 Tu verras :**
```
Reading package lists... Done
[...]
Setting up auditd (1:3.0.7-1build1) ...
Created symlink /etc/systemd/system/multi-user.target.wants/auditd.service
```

#### Vérification

```bash
sudo systemctl status auditd
```

**💻 Résultat attendu :**
```
● auditd.service - Security Auditing Service
     Active: active (running)
```

#### Configuration - Surveiller un fichier critique

**Exemple : Surveiller /etc/passwd (fichier des utilisateurs)**

```bash
# Ajoute une règle d'audit
sudo auditctl -w /etc/passwd -p wa -k passwd_changes
```

**📖 Explication :**
- `auditctl` = commande de gestion des règles d'audit
- `-w /etc/passwd` = **w**atch = surveille ce fichier
- `-p wa` = **p**ermissions = **w**rite (écriture) et **a**ttribute change (changement d'attributs)
- `-k passwd_changes` = **k**ey = étiquette pour retrouver facilement ces événements

**Surveiller d'autres fichiers critiques :**

```bash
# Surveille les modifications de la config SSH
sudo auditctl -w /etc/ssh/sshd_config -p wa -k sshd_config_changes

# Surveille les modifications de sudoers
sudo auditctl -w /etc/sudoers -p wa -k sudoers_changes

# Surveille les connexions/déconnexions
sudo auditctl -w /var/log/auth.log -p wa -k auth_log_changes
```

#### Voir les événements d'audit

```bash
# Recherche les événements liés à passwd
sudo ausearch -k passwd_changes
```

**💻 Exemple si quelqu'un a modifié /etc/passwd :**

```
time->Wed Jan 16 14:32:11 2025
type=PROCTITLE msg=audit(1705416731.123:456): proctitle=2F7573722F7362696E2F7573657261646400746573747573657200
type=SYSCALL msg=audit(1705416731.123:456): arch=c000003e syscall=257 success=yes exit=3 a0=ffffff9c a1=55c8a2345678 a2=80042 a3=1b6 items=2 ppid=12345 pid=12346 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=123 comm="useradd" exe="/usr/sbin/useradd" key="passwd_changes"
```

**🔍 Les infos importantes :**

| Champ | Valeur | Signification |
|-------|--------|---------------|
| `time` | Wed Jan 16 14:32:11 2025 | Quand |
| `comm="useradd"` | Commande = useradd | Quelle commande |
| `exe="/usr/sbin/useradd"` | Programme exécuté | Quel programme |
| `auid=1000` | User ID qui a lancé | Qui (1000 = premier user créé) |
| `key="passwd_changes"` | Notre étiquette | Notre marqueur |

**💡 C'est puissant ! Tu peux maintenant savoir exactement qui a fait quoi et quand !**

### 📊 Récapitulatif Partie 5

**✅ Checklist - Logs et Audit :**
- [ ] `rsyslog` actif et enabled
- [ ] Fichiers de logs présents dans `/var/log/`
- [ ] Permissions des logs = 640 (rw-r-----)
- [ ] Logs d'authentification vérifiés
- [ ] Tentatives échouées surveillées
- [ ] IPs malveillantes bannies par Fail2Ban
- [ ] `auditd` installé et actif
- [ ] Règles d'audit configurées pour fichiers critiques
- [ ] Capacité à chercher dans les logs d'audit

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Comprendre le système de logs Linux
- ✅ Vérifier les connexions SSH (réussies et échouées)
- ✅ Identifier les tentatives d'intrusion
- ✅ Configurer auditd pour surveiller des fichiers
- ✅ Rechercher dans les logs d'audit
- ✅ Tracer qui a fait quoi sur le système

**Niveau actuel : 🌟🌟🌟🌟🌟 Expert !**

---

## ⚙️ PARTIE 6 : Gestion des Services - Désactiver le Superflu

### 🎓 Concept : Moins de Services = Moins de Risques

Chaque service qui tourne, c'est :
- Une **porte d'entrée potentielle** pour un attaquant
- Des **ressources consommées** (RAM, CPU)
- Une **surface d'attaque** plus grande

**Analogie :** Si tu as 10 portes dans ta maison mais que tu n'utilises qu'une seule, pourquoi laisser les 9 autres déverrouillées ?

**Principe de sécurité :** **Désactive tout ce dont tu n'as PAS besoin !**

### ✅ Check #1 : Lister TOUS les Services Actifs

#### Commande : Voir les services qui tournent

```bash
systemctl list-units --type=service --state=running
```

**📖 Explication :**
- `list-units` = liste les unités systemd
- `--type=service` = seulement les services
- `--state=running` = seulement ceux qui tournent MAINTENANT

**💻 Exemple de résultat :**

```
UNIT                         LOAD   ACTIVE SUB     DESCRIPTION
accounts-daemon.service      loaded active running Accounts Service
cron.service                 loaded active running Regular background program processing daemon
dbus.service                 loaded active running D-Bus System Message Bus
fail2ban.service             loaded active running Fail2Ban Service
rsyslog.service              loaded active running System Logging Service
ssh.service                  loaded active running OpenBSD Secure Shell server
systemd-journald.service     loaded active running Journal Service
systemd-logind.service       loaded active running User Login Management
systemd-networkd.service     loaded active running Network Configuration
systemd-resolved.service     loaded active running Network Name Resolution
ufw.service                  loaded active exited  Uncomplicated firewall
unattended-upgrades.service  loaded active running Unattended Upgrades Shutdown

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
12 loaded units listed.
```

**🔍 Analyse des services :**

| Service | Nécessaire ? | Pourquoi |
|---------|--------------|----------|
| `ssh.service` | ✅ OUI | C'est comme ça que tu te connectes ! |
| `cron.service` | ✅ OUI | Exécute les tâches planifiées |
| `rsyslog.service` | ✅ OUI | Logs système |
| `fail2ban.service` | ✅ OUI | Protection SSH |
| `ufw.service` | ✅ OUI | Pare-feu |
| `unattended-upgrades.service` | ✅ OUI | Mises à jour auto |
| `systemd-*` | ✅ OUI | Services système de base |
| `dbus.service` | ✅ OUI | Communication inter-processus |

**Services POTENTIELLEMENT inutiles :**

| Service | Utilité | Serveur ? |
|---------|---------|-----------|
| `bluetooth.service` | Bluetooth | ❌ Serveur n'a pas besoin |
| `cups.service` | Imprimantes | ❌ Sauf si serveur d'impression |
| `avahi-daemon.service` | Découverte réseau local | ❌ Généralement inutile |
| `snapd.service` | Snap packages | ⚠️ Selon ton usage |
| `apache2.service` ou `nginx.service` | Serveur web | ✅ Si tu héberges un site |
| `mysql.service` | Base de données | ✅ Si tu utilises MySQL |

### ✅ Check #2 : Désactiver Services Inutiles

#### Exemple : Désactiver Bluetooth (inutile sur serveur)

```bash
# Arrête le service
sudo systemctl stop bluetooth

# Désactive au démarrage
sudo systemctl disable bluetooth

# Vérifie
systemctl status bluetooth
```

**💻 Résultat attendu :**

```
● bluetooth.service - Bluetooth service
     Loaded: loaded (/lib/systemd/system/bluetooth.service; disabled; vendor preset: enabled)
     Active: inactive (dead)
```

**🔍 Analyse :**
- `disabled` = ✅ Ne se lancera plus au démarrage
- `inactive (dead)` = ✅ N'est pas en cours d'exécution

#### Liste des Services à Désactiver (serveur typique)

**⚠️ ATTENTION : Vérifie d'abord que tu n'en as PAS besoin !**

```bash
# Bluetooth (inutile sur serveur)
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth

# CUPS (imprimantes - inutile sur serveur)
sudo systemctl stop cups
sudo systemctl disable cups

# Avahi (découverte réseau - rarement nécessaire)
sudo systemctl stop avahi-daemon
sudo systemctl disable avahi-daemon

# ModemManager (modems - inutile sur serveur)
sudo systemctl stop ModemManager
sudo systemctl disable ModemManager
```

### ✅ Check #3 : Ports Ouverts et Services Exposés

#### Commande : Voir tous les ports en écoute

```bash
sudo ss -tulpn
```

**📖 Explication :**
- `ss` = **s**ocket **s**tatistics = statistiques des connexions
- `-t` = TCP
- `-u` = UDP
- `-l` = **l**istening = en écoute
- `-p` = **p**rocess = affiche le processus
- `-n` = **n**umeric = affiche les numéros de ports (pas les noms)

**💻 Exemple de résultat :**

```
Netid State   Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
tcp   LISTEN  0      128    0.0.0.0:22          0.0.0.0:*     users:(("sshd",pid=723,fd=3))
tcp   LISTEN  0      80     127.0.0.1:3306      0.0.0.0:*     users:(("mysqld",pid=1234,fd=21))
tcp   LISTEN  0      511    0.0.0.0:80          0.0.0.0:*     users:(("nginx",pid=2345,fd=6))
tcp   LISTEN  0      511    0.0.0.0:443         0.0.0.0:*     users:(("nginx",pid=2345,fd=7))
tcp   LISTEN  0      128    [::]:22             [::]:*        users:(("sshd",pid=723,fd=4))
```

**🔍 Décryptage ligne par ligne :**

**Ligne 1 : SSH**
```
tcp   LISTEN  0      128    0.0.0.0:22          0.0.0.0:*     users:(("sshd",pid=723,fd=3))
```

| Partie | Valeur | Signification | OK ? |
|--------|--------|---------------|------|
| `Local Address:Port` | `0.0.0.0:22` | Écoute sur TOUTES les interfaces, port 22 | ✅ Normal pour SSH |
| `Process` | `sshd` | Service SSH | ✅ Attendu |

**Ligne 2 : MySQL**
```
tcp   LISTEN  0      80     127.0.0.1:3306      0.0.0.0:*     users:(("mysqld",pid=1234,fd=21))
```

| Partie | Valeur | Signification | OK ? |
|--------|--------|---------------|------|
| `Local Address` | `127.0.0.1:3306` | Écoute SEULEMENT sur localhost | ✅ EXCELLENT ! Pas exposé sur Internet |
| `Process` | `mysqld` | MySQL | ✅ Si tu utilises MySQL |

**🎯 Ce qu'il faut retenir :**

| Adresse d'écoute | Signification | Risque |
|------------------|---------------|--------|
| `0.0.0.0:PORT` | Accessible depuis TOUTES les interfaces (Internet inclus) | ⚠️ Seulement pour services publics (SSH, HTTP, HTTPS) |
| `127.0.0.1:PORT` | Accessible SEULEMENT en local | ✅ PARFAIT pour bases de données |
| `192.168.x.x:PORT` | Accessible seulement sur le réseau local | ✅ BON pour services internes |

**❌ PROBLÈME - MySQL exposé sur Internet :**

```
tcp   LISTEN  0      80     0.0.0.0:3306      0.0.0.0:*     users:(("mysqld",pid=1234,fd=21))
                            ^^^^^^^^
                         DANGER ! Exposé publiquement !
```

**🔧 Correction MySQL :**

```bash
# Édite la config MySQL
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Cherche et modifie :
bind-address = 127.0.0.1    # ← Vérifie que c'est bien 127.0.0.1

# Redémarre MySQL
sudo systemctl restart mysql

# Vérifie
sudo ss -tulpn | grep 3306
# Doit afficher : 127.0.0.1:3306 (pas 0.0.0.0:3306)
```

### 📊 Récapitulatif Partie 6

**✅ Checklist - Services :**
- [ ] Liste des services en cours vérifiée
- [ ] Services inutiles désactivés (bluetooth, cups, avahi...)
- [ ] Ports en écoute vérifiés avec `ss -tulpn`
- [ ] Bases de données écoutent sur 127.0.0.1 (pas 0.0.0.0)
- [ ] Seuls les services nécessaires sont actifs
- [ ] Aucun service inconnu ne tourne

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Lister et analyser les services actifs
- ✅ Désactiver les services inutiles
- ✅ Identifier les ports ouverts
- ✅ Distinguer localhost vs exposition publique
- ✅ Sécuriser les services (MySQL, etc.)
- ✅ Réduire la surface d'attaque du serveur

**Niveau actuel : 🌟🌟🌟🌟🌟 Expert Confirmé !**

---

## 🔒 PARTIE 7 : Permissions Fichiers - Qui Peut Faire Quoi

### 🎓 Concept : Permissions = Droits d'Accès

Sous Linux, CHAQUE fichier a des permissions qui définissent :
- **Qui** peut le **lire** (read)
- **Qui** peut le **modifier** (write)
- **Qui** peut l'**exécuter** (execute)

**Analogie :** C'est comme les clés d'un immeuble :
- **Owner** (propriétaire) = Clé de l'appartement
- **Group** (groupe) = Clé de la boîte aux lettres commune
- **Others** (autres) = Hall d'entrée accessible à tous

### ✅ Check #1 : Comprendre les Permissions

#### Commande : Voir les permissions détaillées

```bash
ls -la /etc/passwd /etc/shadow /etc/ssh/sshd_config
```

**💻 Résultat :**

```
-rw-r--r-- 1 root root    2234 Jan 15 10:00 /etc/passwd
-rw-r----- 1 root shadow  1456 Jan 15 10:00 /etc/shadow
-rw------- 1 root root    3423 Jan 15 09:00 /etc/ssh/sshd_config
```

**🔍 Décryptage COMPLET d'une ligne :**

```
-rw-r--r-- 1 root root    2234 Jan 15 10:00 /etc/passwd
│││││││││ │  │    │       │    │            │
│││││││││ │  │    │       │    │            └─ Nom du fichier
│││││││││ │  │    │       │    └─ Date de modification
│││││││││ │  │    │       └─ Taille (octets)
│││││││││ │  │    └─ Groupe propriétaire
│││││││││ │  └─ Utilisateur propriétaire
│││││││││ └─ Nombre de liens
│││││││││
││└─┴─┴── Permissions "Others" (autres utilisateurs) : r-- = lecture seule
│└─┴──── Permissions "Group" (groupe) : r-- = lecture seule
└──────── Permissions "Owner" (propriétaire) : rw- = lecture + écriture
```

**📊 Tableau des Permissions :**

| Symbole | Nom | Valeur numérique | Signification |
|---------|-----|------------------|---------------|
| `r` | **r**ead | 4 | Peut lire le fichier |
| `w` | **w**rite | 2 | Peut modifier le fichier |
| `x` | e**x**ecute | 1 | Peut exécuter le fichier (si c'est un script/programme) |
| `-` | aucun | 0 | Pas de permission |

**Exemples de combinaisons :**

| Permissions | Numérique | Signification |
|-------------|-----------|---------------|
| `rwx` | 7 (4+2+1) | Lecture + Écriture + Exécution |
| `rw-` | 6 (4+2) | Lecture + Écriture |
| `r--` | 4 | Lecture seule |
| `---` | 0 | Aucun accès |

**Permissions complètes (format 3 chiffres) :**

| Format | Owner | Group | Others | Exemple |
|--------|-------|-------|--------|---------|
| `755` | rwx (7) | r-x (5) | r-x (5) | Scripts exécutables |
| `644` | rw- (6) | r-- (4) | r-- (4) | Fichiers de config normaux |
| `600` | rw- (6) | --- (0) | --- (0) | Fichiers secrets (clés SSH) |
| `640` | rw- (6) | r-- (4) | --- (0) | Logs (owner écrit, group lit) |

### ✅ Check #2 : Fichiers Critiques et Leurs Permissions

**🎯 Permissions ATTENDUES pour fichiers système :**

```bash
# Vérifie plusieurs fichiers critiques
ls -l /etc/passwd /etc/shadow /etc/ssh/sshd_config ~/.ssh/authorized_keys
```

**📊 Table de référence :**

| Fichier | Permissions ATTENDUES | Propriétaire | Pourquoi |
|---------|----------------------|--------------|----------|
| `/etc/passwd` | `644 (rw-r--r--)` | root:root | Infos utilisateurs (non sensibles) |
| `/etc/shadow` | `640 (rw-r-----)` ou `600` | root:shadow | Mots de passe hashés (TRÈS sensible) |
| `/etc/ssh/sshd_config` | `600 (rw-------)` | root:root | Config SSH (sensible) |
| `~/.ssh/authorized_keys` | `600 (rw-------)` | user:user | Clés SSH autorisées |
| `~/.ssh/id_ed25519` (clé privée) | `600 (rw-------)` | user:user | Clé privée SSH |
| `/var/log/auth.log` | `640 (rw-r-----)` | syslog:adm | Logs d'authentification |

**💻 Vérification /etc/shadow :**

```bash
ls -l /etc/shadow
```

**✅ BON :**
```
-rw-r----- 1 root shadow 1456 Jan 15 10:00 /etc/shadow
```

**❌ PROBLÈME :**
```
-rw-r--r-- 1 root root 1456 Jan 15 10:00 /etc/shadow
       ^^^
  Tout le monde peut lire !
```

**🔧 Correction :**
```bash
sudo chmod 640 /etc/shadow
sudo chown root:shadow /etc/shadow
```

### ✅ Check #3 : Trouver les Fichiers Dangereux

#### Commande : Trouver les fichiers world-writable

**Fichiers "world-writable" = N'importe qui peut les modifier = DANGER !**

```bash
sudo find / -type f -perm -002 ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null
```

**📖 Explication :**
- `find /` = cherche depuis la racine
- `-type f` = seulement les fichiers (pas les dossiers)
- `-perm -002` = permissions = others have write (le 2 à la fin)
- `! -path "/proc/*"` = exclut /proc (système virtuel)
- `! -path "/sys/*"` = exclut /sys (système virtuel)
- `2>/dev/null` = ignore les erreurs de permission

**💻 Résultat IDÉAL :**
```
(vide - aucun fichier world-writable trouvé)
```

**❌ PROBLÈME - Si tu vois des fichiers :**
```
/home/user/script.sh
/var/www/html/config.php
```

**🔧 Correction :**
```bash
# Enlève le write pour "others"
sudo chmod o-w /home/user/script.sh
sudo chmod o-w /var/www/html/config.php

# Vérifie
ls -l /home/user/script.sh
# Doit afficher : -rwxr-xr-x (pas -rwxrwxrwx)
```

#### Commande : Trouver les fichiers SUID/SGID

**SUID/SGID** = Fichiers qui s'exécutent avec les droits du propriétaire (pas de l'utilisateur qui les lance)

**Exemple :** `sudo` a le bit SUID pour pouvoir donner des droits root temporairement.

**Danger :** Un fichier SUID malveillant peut donner des droits root à un attaquant !

```bash
sudo find / -type f \( -perm -4000 -o -perm -2000 \) ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | head -20
```

**📖 Explication :**
- `-perm -4000` = SUID bit activé
- `-perm -2000` = SGID bit activé

**💻 Exemple de résultat :**

```
/usr/bin/sudo
/usr/bin/passwd
/usr/bin/chsh
/usr/bin/gpasswd
/usr/lib/openssh/ssh-keysign
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
```

**✅ Ces fichiers sont NORMAUX et ATTENDUS :**

| Fichier | Raison | OK ? |
|---------|--------|------|
| `/usr/bin/sudo` | Besoin de donner droits root temporairement | ✅ |
| `/usr/bin/passwd` | Modifier son mot de passe (écrit dans /etc/shadow) | ✅ |
| `/usr/bin/chsh` | Changer son shell | ✅ |
| `/usr/lib/openssh/*` | Opérations SSH | ✅ |

**🚨 ALERTE - Si tu vois :**
- Des scripts shell (`*.sh`) avec SUID
- Des fichiers dans `/tmp/` avec SUID
- Des fichiers inconnus avec SUID

**🔧 Enlever le bit SUID d'un fichier suspect :**

```bash
# Enlève SUID
sudo chmod u-s /chemin/vers/fichier/suspect

# Vérifie
ls -l /chemin/vers/fichier/suspect
```

### ✅ Check #4 : Sécuriser le Répertoire Home

```bash
# Vérifie les permissions de ton répertoire home
ls -ld /home/*
```

**💻 Résultat ATTENDU :**

```
drwxr-x--- 5 user1 user1 4096 Jan 15 10:00 /home/user1
drwxr-x--- 6 user2 user2 4096 Jan 15 09:30 /home/user2
```

**🔍 Analyse :**
- `drwxr-x---` = Owner: full, Group: read+execute, Others: nothing
- `750` en numérique
- ✅ Les autres utilisateurs ne peuvent PAS lire dans ton home

**❌ PROBLÈME :**

```
drwxr-xr-x 5 user1 user1 4096 Jan 15 10:00 /home/user1
       ^^^
Tout le monde peut lire !
```

**🔧 Correction :**

```bash
# Enlève tous les droits pour "others"
chmod 750 /home/user1

# Ou plus restrictif : seulement owner
chmod 700 /home/user1
```

### 📊 Récapitulatif Partie 7

**✅ Checklist - Permissions Fichiers :**
- [ ] Permissions des fichiers critiques vérifiées (passwd, shadow, sshd_config)
- [ ] `/etc/shadow` = 640 ou 600
- [ ] `/etc/ssh/sshd_config` = 600
- [ ] `~/.ssh/authorized_keys` = 600
- [ ] Aucun fichier world-writable trouvé (sauf exceptions système)
- [ ] Fichiers SUID/SGID vérifiés (seulement fichiers système légitimes)
- [ ] Répertoires home = 750 ou 700

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Lire et comprendre les permissions Unix (rwx)
- ✅ Convertir entre permissions symboliques et numériques
- ✅ Identifier les permissions dangereuses
- ✅ Chercher les fichiers world-writable
- ✅ Comprendre SUID/SGID et leurs risques
- ✅ Sécuriser les répertoires personnels
- ✅ Corriger les permissions incorrectes

**Niveau actuel : 🌟🌟🌟🌟🌟 Expert Avancé !**

---

## 🌐 PARTIE 8 : Durcissement Réseau - Blinder la Couche TCP/IP

### 🎓 Concept : Sysctl = Paramètres Noyau Réseau

Le noyau Linux a des centaines de paramètres réseau configurables via `sysctl`.

**Analogie :** C'est comme les réglages avancés d'un routeur :
- Activer/désactiver le forwarding IP
- Protéger contre les attaques SYN flood
- Ignorer les pings ICMP (invisibilité réseau)

**Par défaut, Linux est configuré pour être "gentil" sur le réseau. Pour un serveur exposé sur Internet, on veut être MÉFIANT !**

### ✅ Check #1 : Voir les Paramètres Réseau Actuels

#### Commande : Afficher tous les paramètres réseau

```bash
sudo sysctl -a | grep -E "net.ipv4.conf.all|net.ipv4.tcp_syncookies|net.ipv4.icmp_echo"
```

**💻 Exemple de résultat (AVANT durcissement) :**

```
net.ipv4.conf.all.accept_redirects = 1
net.ipv4.conf.all.accept_source_route = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.icmp_echo_ignore_all = 0
net.ipv4.tcp_syncookies = 1
```

### ✅ Check #2 : Appliquer le Durcissement Réseau

#### Créer le fichier de configuration

```bash
sudo nano /etc/sysctl.d/99-security-hardening.conf
```

**💻 Ajoute ce contenu (copie-colle) :**

```ini
# ====================================================================
# DURCISSEMENT RÉSEAU - UBUNTU SERVER
# ====================================================================

# ---- PROTECTION CONTRE ATTAQUES RÉSEAU ----

# Protection SYN flood (attaque DoS)
net.ipv4.tcp_syncookies = 1

# Ignore les paquets ICMP redirect (attaque Man-in-the-Middle)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Ignore les ICMP secure redirects
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Désactive IP source routing (spoofing)
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Ignore les pings (optionnel - rend le serveur "invisible" aux scans ICMP)
# Décommente si tu veux bloquer les pings
# net.ipv4.icmp_echo_ignore_all = 1

# ---- PROTECTION CONTRE IP SPOOFING ----

# Active la protection anti-spoofing (Reverse Path Filtering)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# ---- LOGGING ----

# Log les paquets martiens (paquets avec adresses IP impossibles)
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# ---- DÉSACTIVATION IPV6 (si tu ne l'utilises pas) ----

# Décommente si tu n'utilises PAS IPv6
# net.ipv6.conf.all.disable_ipv6 = 1
# net.ipv6.conf.default.disable_ipv6 = 1

# ---- AUTRES OPTIMISATIONS SÉCURITÉ ----

# Désactive l'envoi de redirects ICMP (on n'est pas un routeur)
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Ignore les broadcast pings (attaque Smurf)
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore les erreurs ICMP bogués
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Réduit le temps de connexions TCP en TIME_WAIT (libère ressources plus vite)
net.ipv4.tcp_fin_timeout = 15

# Limite les connexions semi-ouvertes (protection SYN flood)
net.ipv4.tcp_max_syn_backlog = 2048
```

**💾 Sauvegarde :** `Ctrl+O`, ENTRÉE, `Ctrl+X`

#### Appliquer la Configuration

```bash
# Applique les nouveaux paramètres
sudo sysctl -p /etc/sysctl.d/99-security-hardening.conf
```

**💻 Tu verras :**

```
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
[...]
```

**✅ Si tu vois toutes les lignes s'afficher = Configuration appliquée avec succès !**

#### Vérification

```bash
# Vérifie quelques paramètres clés
sudo sysctl net.ipv4.tcp_syncookies
sudo sysctl net.ipv4.conf.all.accept_redirects
sudo sysctl net.ipv4.conf.all.rp_filter
```

**💻 Résultat ATTENDU :**

```
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.rp_filter = 1
```

### 🔍 Explications Détaillées de Chaque Paramètre

**🛡️ Protection SYN Flood :**

```ini
net.ipv4.tcp_syncookies = 1
```

**C'est quoi un SYN flood ?** Un attaquant envoie des milliers de demandes de connexion TCP sans jamais les finaliser, saturant le serveur.

**Solution :** Les SYN cookies permettent au serveur de gérer ces attaques sans saturer.

---

**🚫 Désactiver ICMP Redirects :**

```ini
net.ipv4.conf.all.accept_redirects = 0
```

**Attaque :** Un attaquant envoie de faux redirects ICMP pour rediriger ton trafic vers lui (Man-in-the-Middle).

**Solution :** Ignorer tous les redirects.

---

**🎭 Désactiver IP Source Routing :**

```ini
net.ipv4.conf.all.accept_source_route = 0
```

**Attaque :** L'attaquant spécifie le chemin réseau que les paquets doivent prendre (spoofing).

**Solution :** Bloquer complètement.

---

**🔍 Reverse Path Filtering (anti-spoofing) :**

```ini
net.ipv4.conf.all.rp_filter = 1
```

**Attaque :** Un attaquant envoie des paquets avec une fausse adresse IP source.

**Solution :** Le serveur vérifie que la route de retour est valide. Si elle ne l'est pas, le paquet est rejeté.

---

**📝 Logging des Paquets Martiens :**

```ini
net.ipv4.conf.all.log_martians = 1
```

**C'est quoi un paquet "martien" ?** Un paquet avec une adresse IP impossible (ex: 0.0.0.0, 255.255.255.255, adresses privées depuis Internet).

**Utilité :** Aide à détecter des tentatives d'attaques.

**Où voir les logs ?**
```bash
sudo dmesg | grep martian
```

### 📊 Récapitulatif Partie 8

**✅ Checklist - Durcissement Réseau :**
- [ ] Fichier `/etc/sysctl.d/99-security-hardening.conf` créé
- [ ] `tcp_syncookies = 1` (protection SYN flood)
- [ ] `accept_redirects = 0` (protection redirects ICMP)
- [ ] `accept_source_route = 0` (protection spoofing)
- [ ] `rp_filter = 1` (reverse path filtering)
- [ ] `log_martians = 1` (logging attaques)
- [ ] Configuration appliquée avec `sysctl -p`
- [ ] Paramètres vérifiés et actifs

**🎓 Ce que tu maîtrises maintenant :**
- ✅ Comprendre les attaques réseau courantes (SYN flood, spoofing, redirects)
- ✅ Configurer les paramètres noyau via sysctl
- ✅ Durcir la couche réseau du serveur
- ✅ Protéger contre les attaques DoS
- ✅ Activer le logging des tentatives d'attaques
- ✅ Appliquer des configurations permanentes

**Niveau actuel : 🌟🌟🌟🌟🌟🌟 EXPERT ULTIME !**

---

## ✅ CHECKLIST FINALE COMPLÈTE

Voici ta checklist ultime ! Si tu as tout coché, ton serveur Ubuntu est SÉRIEUSEMENT sécurisé ! 🛡️

### 🔄 Mises à Jour
- [ ] `sudo apt update` exécuté
- [ ] Aucune mise à jour de sécurité en attente (< 7 jours)
- [ ] `systemctl status unattended-upgrades` = active (running)
- [ ] Mises à jour automatiques configurées

### 🔐 Comptes Utilisateurs
- [ ] `PermitRootLogin no` dans /etc/ssh/sshd_config
- [ ] `sudo passwd -S root` affiche "L" (Locked)
- [ ] Aucun compte sans mot de passe vérifié
- [ ] Politique de mots de passe : minlen ≥ 14
- [ ] Expiration des mots de passe : ≤ 365 jours
- [ ] Comptes inutilisés supprimés

### 🚪 SSH
- [ ] Clés SSH créées et testées
- [ ] `PasswordAuthentication no`
- [ ] `PubkeyAuthentication yes`
- [ ] `PermitEmptyPasswords no`
- [ ] `MaxAuthTries` ≤ 3
- [ ] `ClientAliveInterval 300` configuré
- [ ] `X11Forwarding no`
- [ ] Config testée avec `sudo sshd -t`
- [ ] Fail2Ban installé et actif
- [ ] `fail2ban-client status sshd` fonctionne

### 🔥 Pare-feu
- [ ] `sudo ufw status` = active
- [ ] Default policy : deny (incoming), allow (outgoing)
- [ ] SSH autorisé avec `limit` (pas juste `allow`)
- [ ] Seuls les ports nécessaires ouverts
- [ ] Règles documentées (tu sais pourquoi chaque port est ouvert)
- [ ] Testé : connexion SSH fonctionne toujours

### 📝 Logs et Audit
- [ ] `rsyslog` actif et enabled
- [ ] Fichiers de logs présents dans `/var/log/`
- [ ] Permissions des logs = 640 (rw-r-----)
- [ ] Logs d'authentification vérifiés (pas d'IPs suspectes)
- [ ] Tentatives échouées surveillées
- [ ] `auditd` installé et actif
- [ ] Règles d'audit configurées pour fichiers critiques (/etc/passwd, /etc/shadow, /etc/ssh/sshd_config)
- [ ] Capacité à rechercher dans les logs d'audit testée

### ⚙️ Services
- [ ] Liste des services actifs vérifiée
- [ ] Services inutiles désactivés (bluetooth, cups, avahi, etc.)
- [ ] Ports en écoute vérifiés avec `ss -tulpn`
- [ ] Bases de données écoutent sur 127.0.0.1 (pas 0.0.0.0)
- [ ] Seuls les services nécessaires sont actifs
- [ ] Aucun service inconnu ne tourne

### 🔒 Permissions Fichiers
- [ ] Permissions des fichiers critiques vérifiées
- [ ] `/etc/shadow` = 640 ou 600
- [ ] `/etc/ssh/sshd_config` = 600
- [ ] `~/.ssh/authorized_keys` = 600 (si clés SSH utilisées)
- [ ] Aucun fichier world-writable trouvé
- [ ] Fichiers SUID/SGID vérifiés (seulement fichiers système légitimes)
- [ ] Répertoires home = 750 ou 700

### 🌐 Durcissement Réseau
- [ ] Fichier `/etc/sysctl.d/99-security-hardening.conf` créé
- [ ] `tcp_syncookies = 1` (protection SYN flood)
- [ ] `accept_redirects = 0` (protection redirects ICMP)
- [ ] `accept_source_route = 0` (protection spoofing)
- [ ] `rp_filter = 1` (reverse path filtering)
- [ ] `log_martians = 1` (logging attaques)
- [ ] Configuration appliquée avec `sysctl -p`
- [ ] Paramètres vérifiés et actifs

---

## 🚀 SCRIPT D'AUDIT RAPIDE

Copie-colle ce script pour un audit express de ton serveur ! (version étendue avec TOUTES les parties)

```bash
#!/bin/bash
# Script d'audit complet Ubuntu Server
# Version : 2.0 - From Zero to Hero Edition COMPLÈTE
# Couvre : Mises à jour, Comptes, SSH, Pare-feu, Logs, Services, Permissions, Réseau

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     🔍 AUDIT COMPLET UBUNTU SERVER v2.0                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher OK ou FAIL
check_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ PROBLÈME${NC}"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 1. MISES À JOUR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
updates=$(apt list --upgradable 2>/dev/null | grep -v "Listing" | wc -l)
echo -n "Mises à jour disponibles : $updates "
if [ $updates -eq 0 ]; then
    echo -e "${GREEN}✅${NC}"
elif [ $updates -lt 10 ]; then
    echo -e "${YELLOW}⚠️${NC}"
else
    echo -e "${RED}❌${NC}"
fi

if [ $updates -gt 0 ]; then
    echo -e "${YELLOW}Mises à jour de SÉCURITÉ :${NC}"
    apt list --upgradable 2>/dev/null | grep -i security | head -5
fi

echo -n "Service unattended-upgrades : "
systemctl is-active unattended-upgrades &>/dev/null
check_status $?
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 2. COMPTES UTILISATEURS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

permitroot=$(sudo grep "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}')
echo -n "PermitRootLogin : $permitroot "
if [ "$permitroot" == "no" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

rootstatus=$(sudo passwd -S root 2>/dev/null | awk '{print $2}')
echo -n "Compte root verrouillé : "
if [ "$rootstatus" == "L" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

nopasswd=$(sudo awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
echo -n "Comptes sans mot de passe : "
if [ -z "$nopasswd" ]; then
    echo -e "${GREEN}✅ Aucun${NC}"
else
    echo -e "${RED}❌ $nopasswd${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚪 3. SSH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

passauth=$(sudo sshd -T 2>/dev/null | grep "^passwordauthentication" | awk '{print $2}')
echo -n "PasswordAuthentication : $passauth "
if [ "$passauth" == "no" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️${NC}"
fi

maxauth=$(sudo sshd -T 2>/dev/null | grep "^maxauthtries" | awk '{print $2}')
echo -n "MaxAuthTries : $maxauth "
if [ "$maxauth" -le 3 ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️${NC}"
fi

echo -n "Fail2Ban : "
systemctl is-active fail2ban &>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Actif${NC}"
    banned=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $4}')
    echo "   IPs bannies : $banned"
else
    echo -e "${RED}❌${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔥 4. PARE-FEU (UFW)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ufwstatus=$(sudo ufw status | grep -w "Status" | awk '{print $2}')
echo -n "Statut UFW : $ufwstatus "
if [ "$ufwstatus" == "active" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

defaultin=$(sudo ufw status verbose 2>/dev/null | grep "Default:" | grep -o "deny (incoming)")
echo -n "Politique par défaut : "
if [ ! -z "$defaultin" ]; then
    echo -e "${GREEN}✅ deny (incoming)${NC}"
else
    echo -e "${RED}❌${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 5. LOGS ET AUDIT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -n "Rsyslog : "
systemctl is-active rsyslog &>/dev/null
check_status $?

echo -n "Auditd : "
systemctl is-active auditd &>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Actif${NC}"
    auditrules=$(sudo auditctl -l 2>/dev/null | grep -v "No rules" | wc -l)
    echo "   Règles d'audit : $auditrules"
else
    echo -e "${YELLOW}⚠️  Non installé${NC}"
fi

authlog="/var/log/auth.log"
if [ -f "$authlog" ]; then
    logperms=$(stat -c %a "$authlog")
    echo -n "Permissions auth.log : $logperms "
    if [ "$logperms" == "640" ] || [ "$logperms" == "600" ]; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${YELLOW}⚠️  (devrait être 640)${NC}"
    fi
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  6. SERVICES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

running_services=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
echo "Services en cours : $running_services"

# Vérifie services inutiles
echo -n "Bluetooth : "
systemctl is-active bluetooth &>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Actif (inutile sur serveur)${NC}"
else
    echo -e "${GREEN}✅ Inactif${NC}"
fi

echo -n "CUPS (imprimantes) : "
systemctl is-active cups &>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Actif (inutile sur serveur)${NC}"
else
    echo -e "${GREEN}✅ Inactif${NC}"
fi

# Ports en écoute
listening_ports=$(sudo ss -tulpn 2>/dev/null | grep LISTEN | grep -v "127.0.0.1" | grep -v "::1" | wc -l)
echo "Ports publics en écoute : $listening_ports"
if [ $listening_ports -gt 5 ]; then
    echo -e "${YELLOW}⚠️  Vérifier si tous sont nécessaires${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔒 7. PERMISSIONS FICHIERS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# /etc/shadow
shadowperms=$(stat -c %a /etc/shadow 2>/dev/null)
echo -n "/etc/shadow permissions : $shadowperms "
if [ "$shadowperms" == "640" ] || [ "$shadowperms" == "600" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

# sshd_config
sshdperms=$(stat -c %a /etc/ssh/sshd_config 2>/dev/null)
echo -n "/etc/ssh/sshd_config : $sshdperms "
if [ "$sshdperms" == "600" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️${NC}"
fi

# World-writable files (quick check)
echo -n "Fichiers world-writable : "
worldwrite=$(sudo find / -type f -perm -002 ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null | head -1)
if [ -z "$worldwrite" ]; then
    echo -e "${GREEN}✅ Aucun trouvé${NC}"
else
    echo -e "${RED}❌ Trouvés !${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 8. DURCISSEMENT RÉSEAU"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

syncookies=$(sudo sysctl -n net.ipv4.tcp_syncookies 2>/dev/null)
echo -n "SYN cookies : $syncookies "
if [ "$syncookies" == "1" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

redirects=$(sudo sysctl -n net.ipv4.conf.all.accept_redirects 2>/dev/null)
echo -n "Accept redirects : $redirects "
if [ "$redirects" == "0" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️${NC}"
fi

rpfilter=$(sudo sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null)
echo -n "Reverse path filter : $rpfilter "
if [ "$rpfilter" == "1" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️${NC}"
fi

# Vérifie si fichier de config existe
if [ -f "/etc/sysctl.d/99-security-hardening.conf" ]; then
    echo -e "Fichier de durcissement : ${GREEN}✅ Présent${NC}"
else
    echo -e "Fichier de durcissement : ${YELLOW}⚠️  Absent${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SCORE GLOBAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Calcul du score (20 points total)
score=0
total=20

# Mises à jour (2 pts)
[ $updates -lt 10 ] && ((score++))
systemctl is-active unattended-upgrades &>/dev/null && ((score++))

# Comptes (3 pts)
[ "$permitroot" == "no" ] && ((score++))
[ "$rootstatus" == "L" ] && ((score++))
[ -z "$nopasswd" ] && ((score++))

# SSH (3 pts)
[ "$passauth" == "no" ] && ((score++))
[ "$maxauth" -le 3 ] && ((score++))
systemctl is-active fail2ban &>/dev/null && ((score++))

# Pare-feu (2 pts)
[ "$ufwstatus" == "active" ] && ((score++))
[ ! -z "$defaultin" ] && ((score++))

# Logs (2 pts)
systemctl is-active rsyslog &>/dev/null && ((score++))
systemctl is-active auditd &>/dev/null && ((score++))

# Services (2 pts)
! systemctl is-active bluetooth &>/dev/null && ((score++))
! systemctl is-active cups &>/dev/null && ((score++))

# Permissions (2 pts)
([ "$shadowperms" == "640" ] || [ "$shadowperms" == "600" ]) && ((score++))
[ "$sshdperms" == "600" ] && ((score++))

# Réseau (4 pts)
[ "$syncookies" == "1" ] && ((score++))
[ "$redirects" == "0" ] && ((score++))
[ "$rpfilter" == "1" ] && ((score++))
[ -f "/etc/sysctl.d/99-security-hardening.conf" ] && ((score++))

percent=$((score * 100 / total))

echo "Score de sécurité : $score/$total ($percent%)"
echo ""

if [ $percent -ge 90 ]; then
    echo -e "${GREEN}🏆 EXCELLENT ! Serveur très bien sécurisé !${NC}"
elif [ $percent -ge 75 ]; then
    echo -e "${GREEN}✅ BON ! Quelques améliorations mineures possibles${NC}"
elif [ $percent -ge 60 ]; then
    echo -e "${YELLOW}⚠️  MOYEN. Plusieurs points à améliorer${NC}"
else
    echo -e "${RED}❌ CRITIQUE ! Sécurité insuffisante${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Audit terminé ! 🎉"
echo ""
echo "Pour corriger les problèmes, consulte :"
echo "my_audit_guide/os/linux/ubuntu.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Comment utiliser ce script

```bash
# Sauvegarde le script
nano audit-ubuntu.sh

# Copie-colle le script ci-dessus
# Ctrl+O pour sauvegarder, Ctrl+X pour quitter

# Rends-le exécutable
chmod +x audit-ubuntu.sh

# Lance-le !
./audit-ubuntu.sh
```

**💻 Exemple de résultat :**

```
╔══════════════════════════════════════════════════════════╗
║     🔍 AUDIT EXPRESS UBUNTU SERVER                      ║
╚══════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 1. MISES À JOUR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mises à jour disponibles : 0
✅ Système à jour !

Service de mises à jour automatiques :
✅ OK

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 2. COMPTES UTILISATEURS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PermitRootLogin : no ✅ OK
Compte root verrouillé : ✅ OK
Comptes sans mot de passe : ✅ Aucun

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚪 3. SSH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PasswordAuthentication : no ✅ OK (clés SSH uniquement)
MaxAuthTries : 3 ✅ OK
Fail2Ban : ✅ Actif
   IPs bannies actuellement : 2

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔥 4. PARE-FEU (UFW)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Statut UFW : active ✅ OK
Politique par défaut : ✅ deny (incoming)

Règles actives :
[ 1] 22/tcp                     LIMIT IN    Anywhere

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 5. RÉSUMÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Score de sécurité : 10/10 (100%)

🏆 EXCELLENT ! Ton serveur est bien sécurisé !

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Audit terminé ! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🏆 CONCLUSION - De Zéro à Héros !

### 🎉 Félicitations Champion·ne !

Si tu es arrivé jusqu'ici et que tu as tout suivi, tu as accompli quelque chose d'énorme !

**Tu es passé de :**
```
❓ "C'est quoi sudo ?"
                ↓
🦸 "Je sais auditer un serveur Ubuntu comme un pro !"
```

### 🎯 Ce que tu maîtrises VRAIMENT maintenant

**Compétences techniques :**
- ✅ Interpréter CHAQUE commande Linux que tu tapes
- ✅ Comprendre CHAQUE ligne de résultat dans ton terminal
- ✅ Identifier instantanément les problèmes de sécurité
- ✅ Corriger les failles sans te bloquer dehors
- ✅ Expliquer à ton boss/client POURQUOI c'est important

**Compétences d'audit :**
- ✅ Vérifier les mises à jour et leur criticité
- ✅ Auditer les comptes utilisateurs et privilèges
- ✅ Sécuriser SSH avec clés et Fail2Ban
- ✅ Configurer un pare-feu sans se tirer une balle dans le pied
- ✅ Utiliser un script d'audit automatique

**Soft skills :**
- ✅ Méthodologie : Tu sais suivre une checklist
- ✅ Prudence : Tu testes avant d'appliquer
- ✅ Documentation : Tu comprends pourquoi chaque règle existe
- ✅ Autonomie : Tu peux maintenant chercher et comprendre seul·e

### 📈 Ton Parcours

```
🌱 Débutant
   "J'ai peur de casser le serveur"
        ↓
🌿 Bases acquises
   "Je comprends les commandes de base"
        ↓
🌳 Intermédiaire
   "Je sais ce que je fais"
        ↓
🌲 Avancé
   "Je peux auditer en autonomie"
        ↓
🦸 HÉROS !
   "Je peux enseigner aux autres !"
```

**Tu es ici → 🦸 HÉROS !**

### 💪 Tes Prochaines Missions

**Mission 1 : Pratique en situation réelle**
1. Crée une VM Ubuntu de test
2. Fais l'audit complet avec ce guide
3. Corrige tous les problèmes trouvés
4. Lance le script d'audit → vise 100% !

**Mission 2 : Documente ton premier audit**
1. Prends des screenshots de tes résultats
2. Note les problèmes trouvés et les corrections apportées
3. Calcule ton score avant/après
4. Crée un rapport simple (ça fera bien dans ton CV !)

**Mission 3 : Partage tes connaissances**
1. Enseigne à un·e collègue ce que tu as appris
2. Explique POURQUOI chaque point est important
3. C'est en enseignant qu'on apprend vraiment !

**Mission 4 : Élargis tes compétences**
1. Audite maintenant un autre OS (Windows Server ?)
2. Audite une base de données (MySQL, PostgreSQL ?)
3. Audite des équipements réseau (Firewall ?)

### 🎓 Ressources pour Aller Plus Loin

**Pour approfondir Ubuntu :**
- [Ubuntu Security Guide](https://ubuntu.com/security) - Doc officielle
- [CIS Ubuntu Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux) - Standard professionnel
- [ANSSI Hardening Guide](https://cyber.gouv.fr/) - Recommandations françaises

**Outils avancés :**
- [Lynis](https://cisofy.com/lynis/) - Audit automatique complet
- [AIDE](https://aide.github.io/) - Détection d'intrusion
- [OpenSCAP](https://www.open-scap.org/) - Conformité automatisée

**Communautés :**
- r/linuxadmin sur Reddit
- serverfault.com pour les questions techniques
- linux.org/forums pour discuter

### 🌟 Le Mot de la Fin

**Tu n'es plus un débutant.**

Tu as maintenant les compétences pour :
- Auditer un serveur Ubuntu professionnel
- Identifier et corriger des failles de sécurité
- Expliquer tes choix avec des arguments solides
- Continuer à apprendre en autonomie

**La cybersécurité, c'est un marathon, pas un sprint.**

Continue à :
- Pratiquer régulièrement
- Rester à jour sur les nouvelles vulnérabilités
- Auditer tes serveurs tous les 3-6 mois
- Partager tes connaissances

### 🎁 Bonus : Ta Certification Mentale

```
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          🏆 CERTIFICAT DE HÉROS UBUNTU 🏆             ║
║                                                        ║
║    Ce certificat atteste que TU es capable de :      ║
║                                                        ║
║    ✅ Auditer un serveur Ubuntu                       ║
║    ✅ Identifier les failles de sécurité              ║
║    ✅ Corriger les problèmes trouvés                  ║
║    ✅ Expliquer POURQUOI c'est important              ║
║                                                        ║
║    Niveau atteint : 🦸 HÉROS                          ║
║    Score : De Zéro à Héros en 1 Guide !              ║
║                                                        ║
║    Continue comme ça ! Tu es sur la bonne voie ! 🚀   ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

**Maintenant, va sécuriser ce serveur ! 💪🛡️**

---

## 💬 Questions ? Feedback ?

Ce guide est vivant et évolue !

**Si tu as :**
- 🐛 Trouvé une erreur
- 💡 Une suggestion d'amélioration
- ❓ Une question pas claire
- 🎉 Un succès à partager

N'hésite pas à contribuer ou ouvrir une issue !

**Merci d'avoir suivi ce guide jusqu'au bout !**

Tu es maintenant officiellement un·e Héros·ïne de la sécurité Ubuntu ! 🎉🏆🦸

---

*Guide créé avec ❤️ pour les futurs experts en cybersécurité*

*Dernière mise à jour : Janvier 2025*
