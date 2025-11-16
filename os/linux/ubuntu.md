# 🐧 Tutoriel d'Audit - Ubuntu Server

Salut ! Alors comme ça, tu veux auditer un serveur Ubuntu ? Super choix ! Ubuntu, c'est un peu le couteau suisse des serveurs Linux - populaire, bien documenté, et parfait pour apprendre.

Dans ce tutoriel, on va jouer au détective et vérifier ensemble que ton serveur est bien sécurisé. Promis, je vais tout t'expliquer comme si on prenait un café ensemble !

## 🎯 Ce qu'on va faire ensemble

On va vérifier que ton serveur Ubuntu est bien protégé, un peu comme si tu faisais le tour de ta maison pour vérifier que toutes les portes et fenêtres sont bien fermées.

**Concrètement, on va checker :**
- 🔒 Les mots de passe et comptes utilisateurs (qui a les clés ?)
- 🚪 Les accès SSH (la porte d'entrée principale)
- 🔥 Le pare-feu (le videur à l'entrée)
- 📝 Les logs (la vidéosurveillance)
- 🛠️ Les services qui tournent (les appareils allumés dans ta maison)
- 🔐 Les fichiers sensibles (le coffre-fort)

## 📋 Avant de Commencer

### Ce dont tu as besoin

**Niveau requis :**
Si tu sais :
- Te connecter en SSH à un serveur
- Taper des commandes dans un terminal
- Copier-coller (compétence pro !)

Alors tu es prêt·e ! 🎉

**Accès nécessaire :**
- Une connexion SSH au serveur Ubuntu
- Un compte avec les droits `sudo` (l'équivalent admin)
- 30-45 minutes devant toi

**Versions couvertes :**
- Ubuntu 20.04 LTS (le robuste)
- Ubuntu 22.04 LTS (le moderne)
- Ubuntu 24.04 LTS (le tout nouveau)

### Installer les outils d'audit

On va installer quelques outils sympas pour nous aider. Connecte-toi en SSH et tape :

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Installation des outils d'audit
sudo apt install -y lynis aide rkhunter chkrootkit ufw auditd fail2ban

# Vérifie que tout s'est bien passé
echo "C'est bon, on est prêts !"
```

> **💡 Astuce :** Copie-colle ces commandes une par une. Si tu vois des erreurs en rouge, pas de panique ! Lis le message, souvent il te dit exactement quoi faire.

---

## 🔍 Partie 1 : Les Mises à Jour (Super Important !)

### 💬 Qu'est-ce qu'on cherche ?

On veut vérifier que ton serveur n'est pas en retard sur ses mises à jour de sécurité. C'est comme vérifier que ton antivirus est à jour !

### 🤔 Pourquoi c'est crucial ?

Imagine : un hacker découvre une faille sur Ubuntu. Ubuntu sort un patch (un correctif). Si tu ne l'installes pas, c'est comme si tu laissais une fenêtre cassée non réparée alors que tout le quartier sait qu'elle est cassée !

Les attaques les plus connues (WannaCry, NotPetya...) ont exploité des failles qui avaient des patchs disponibles depuis des mois. Les victimes ? Ceux qui n'avaient pas fait leurs mises à jour. 😬

### ⚙️ Comment vérifier

```bash
# Voir quelles mises à jour sont disponibles
sudo apt update
sudo apt list --upgradable

# Vérifier les mises à jour de sécurité spécifiquement
sudo unattended-upgrades --dry-run -d

# Voir si les mises à jour auto sont activées
systemctl status unattended-upgrades
```

### ✅ Ce que tu VEUX voir

**Scénario idéal :**
```
0 upgraded, 0 newly installed, 0 to remove
```
Ou au pire, des mises à jour non-critiques.

**Service des mises à jour automatiques :**
```
● unattended-upgrades.service - Unattended Upgrades Shutdown
   Active: active (running)
```

### ❌ Signaux d'alarme

**🔴 ALERTE ROUGE** si tu vois :
```
Les mises à jour suivantes de sécurité sont disponibles :
linux-generic (security update)
openssl (security update)
```

Surtout si elles datent de plus de 30 jours ! C'est comme laisser ta porte d'entrée cassée pendant un mois.

**🟠 ATTENTION** si :
- Le service `unattended-upgrades` est inactif
- Des mises à jour normales traînent depuis >90 jours

### 🔧 Comment réparer

**Installer les mises à jour NOW :**
```bash
# Installe tout ce qui est en retard
sudo apt update && sudo apt upgrade -y

# Redémarre si nécessaire (surtout si kernel mis à jour)
sudo reboot
```

**Activer les mises à jour automatiques :**
```bash
# Active le service
sudo dpkg-reconfigure -plow unattended-upgrades

# Vérifie que c'est bien activé
cat /etc/apt/apt.conf.d/20auto-upgrades
```

Tu devrais voir :
```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

> **💡 Le conseil du chef :** Active TOUJOURS les mises à jour auto de sécurité. Pour les autres mises à jour, tu peux choisir de le faire manuellement si tu veux garder le contrôle.

---

## 🔐 Partie 2 : Les Comptes Utilisateurs

### 💬 Qu'est-ce qu'on cherche ?

On va faire l'inventaire de qui a accès à ton serveur et avec quels pouvoirs. C'est comme vérifier qui a les clés de ta maison !

### 🤔 Pourquoi c'est important ?

**Analogie du quotidien :**
Tu ne laisserais pas la clé de ta maison sous le paillasson, ni ne donnerais un double à quelqu'un que tu ne connais plus, non ? Pareil pour ton serveur !

Les comptes mal gérés, c'est la porte d'entrée #1 des hackers :
- Comptes avec mot de passe faible → Force brute
- Comptes anonymes → Accès gratuit
- Comptes sans mot de passe → Open bar !

### 🔍 Check #1 : Le compte root

**C'est quoi root ?**
`root` c'est le super-admin absolu du serveur. Il peut TOUT faire, même détruire le serveur en une commande. C'est pour ça qu'on ne veut PAS se connecter directement avec ce compte !

**Vérifie ça :**
```bash
# Regarde si root peut se connecter en SSH
sudo grep "PermitRootLogin" /etc/ssh/sshd_config

# Regarde si root a un mot de passe
sudo passwd -S root
```

**✅ Bon résultat :**
```
PermitRootLogin no
# OU
PermitRootLogin prohibit-password

root L ...  # Le 'L' = compte verrouillé, c'est bon !
```

**❌ Mauvais résultat :**
```
PermitRootLogin yes  # ← NOPE ! Danger !

root P ...  # Le 'P' = mot de passe actif, pas top
```

**🔧 Comment corriger :**
```bash
# Désactiver le login root en SSH
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Redémarrer SSH pour appliquer
sudo systemctl restart sshd

# Verrouiller le compte root pour plus de sécurité
sudo passwd -l root
```

> **⚠️ ATTENTION :** Assure-toi d'avoir un autre compte avec `sudo` avant de bloquer root ! Sinon tu te retrouves enfermé dehors !

### 🔍 Check #2 : Les comptes sans mot de passe (oui, ça existe !)

**Vérifie :**
```bash
# Cherche les comptes sans mot de passe
sudo awk -F: '($2 == "" ) {print "ALERTE: " $1 " n'\''a PAS de mot de passe !"}' /etc/shadow
```

**✅ Bon résultat :**
Rien qui s'affiche ! Silence radio = tout va bien.

**❌ Mauvais résultat :**
```
ALERTE: testuser n'a PAS de mot de passe !
```

**🔧 Comment corriger :**
```bash
# Ajoute un mot de passe au compte
sudo passwd nom_du_compte

# OU supprime le compte si tu ne l'utilises pas
sudo userdel -r nom_du_compte
```

### 🔍 Check #3 : Politique de mots de passe

**C'est quoi une bonne politique ?**
Un mot de passe, c'est comme un mot de passe de carte bleue, mais en mieux :
- Minimum 14 caractères (oui, 14 !)
- Mélange de majuscules, minuscules, chiffres, symboles
- Expire régulièrement (genre tous les 90-365 jours)

**Vérifie :**
```bash
# Regarde les règles actuelles
sudo grep pam_pwquality /etc/pam.d/common-password

# Vérifie la config détaillée
cat /etc/security/pwquality.conf | grep -v "^#" | grep -v "^$"
```

**✅ Configuration sécurisée :**
```
minlen = 14
dcredit = -1   # Au moins 1 chiffre
ucredit = -1   # Au moins 1 majuscule
lcredit = -1   # Au moins 1 minuscule
ocredit = -1   # Au moins 1 caractère spécial
```

**🔧 Configurer une bonne politique :**
```bash
# Édite le fichier de config
sudo nano /etc/security/pwquality.conf

# Ajoute/modifie ces lignes :
minlen = 14
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
minclass = 3
maxrepeat = 2
```

**Configurer l'expiration :**
```bash
# Dans /etc/login.defs
sudo nano /etc/login.defs

# Trouve et modifie :
PASS_MAX_DAYS   90    # Les mots de passe expirent après 90 jours
PASS_MIN_DAYS   1     # On ne peut pas changer son mot de passe avant 1 jour
PASS_WARN_AGE   7     # Avertissement 7 jours avant expiration
```

> **💡 Astuce :** Ces paramètres s'appliquent aux NOUVEAUX comptes. Pour les comptes existants, utilise `sudo chage -M 90 username` pour changer l'expiration.

---

## 🚪 Partie 3 : SSH - Ta Porte d'Entrée

### 💬 Qu'est-ce qu'on cherche ?

SSH (Secure Shell), c'est ta porte d'entrée principale sur le serveur. On veut qu'elle soit blindée comme la porte d'une banque !

### 🤔 Pourquoi c'est critique ?

SSH, c'est ce que tout le monde utilise pour se connecter à un serveur Linux. Si c'est mal configuré :
- Les robots scannent Internet 24/7 pour trouver des SSH mal protégés
- Ils tentent des milliers de mots de passe par seconde
- Une fois entrés, c'est game over

**Fun fact :** Si tu regardes tes logs, tu verras des MILLIERS de tentatives de connexion SSH par jour. C'est normal, c'est Internet ! 🤖

### 🔍 Check complet de SSH

```bash
# Vérifi la config complète
sudo sshd -T | grep -E "permitroot|password|pubkey|maxauth|clientalive"

# Ou regarde le fichier directement
sudo cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"
```

### ✅ Configuration EN OR

Voici la config idéale (checklist) :

```
PermitRootLogin no                    # Root ne peut PAS se connecter
PasswordAuthentication no             # Seulement les clés SSH (pas de mot de passe)
PubkeyAuthentication yes              # Clés SSH activées
PermitEmptyPasswords no               # Mots de passe vides = NON
MaxAuthTries 3                        # 3 essais max
ClientAliveInterval 300               # Déconnexion auto après 5 min d'inactivité
ClientAliveCountMax 2                 # 2 messages max avant déconnexion
X11Forwarding no                      # Pas de X11 (on n'en a pas besoin)
```

### ❌ Configurations DANGEREUSES

| Configuration | Niveau Danger | Pourquoi c'est grave |
|---------------|---------------|----------------------|
| `PasswordAuthentication yes` | 🔴 URGENT | Les robots testent des millions de mots de passe |
| `PermitRootLogin yes` | 🔴 URGENT | Connexion directe en root = jackpot pour le hacker |
| `PermitEmptyPasswords yes` | 🔴 URGENT | Connexion sans mot de passe, sérieusement ?! |
| `X11Forwarding yes` | 🟡 À corriger | Failles de sécurité potentielles |
| Pas de limite de tentatives | 🟠 Important | Attaques par force brute infinies |

### 🔧 Sécuriser SSH comme un pro

**Étape 1 : Créer des clés SSH (si pas déjà fait)**

Sur TON ordinateur (pas le serveur) :
```bash
# Génère une paire de clés
ssh-keygen -t ed25519 -C "mon-email@example.com"

# Copie ta clé sur le serveur
ssh-copy-id votre_user@ip_du_serveur
```

> **💡 C'est quoi ed25519 ?** Un algorithme de chiffrement moderne et super sécurisé. Plus court et plus sûr que RSA !

**Étape 2 : Durcir la config SSH**

```bash
# Sauvegarde d'abord (on est prudents !)
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Édite la config
sudo nano /etc/ssh/sshd_config
```

Modifie/ajoute ces lignes :
```
# Désactiver root
PermitRootLogin no

# Authentification par clés uniquement
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no

# Limiter les tentatives
MaxAuthTries 3
LoginGraceTime 60

# Déconnexion auto
ClientAliveInterval 300
ClientAliveCountMax 2

# Désactiver X11
X11Forwarding no

# Limiter aux utilisateurs spécifiques (optionnel)
AllowUsers votre_user
```

**Étape 3 : Teste AVANT de redémarrer !**

⚠️ **SUPER IMPORTANT** : Ne ferme PAS ta session SSH actuelle !

Dans une NOUVELLE fenêtre de terminal :
```bash
# Teste que la config est valide
sudo sshd -t

# Si pas d'erreur, redémarre SSH
sudo systemctl restart sshd

# Teste la connexion dans la nouvelle fenêtre
ssh votre_user@ip_du_serveur
```

Si ça marche, bravo ! Si ça ne marche pas, tu as toujours ta première session ouverte pour réparer.

> **🆘 En cas de problème :** Retourne dans ta session SSH d'origine et restaure la sauvegarde : `sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config && sudo systemctl restart sshd`

### 🛡️ Bonus : Fail2Ban - Le videur automatique

Fail2Ban, c'est comme un videur de boîte qui ban automatiquement les gens qui essaient trop de fois de rentrer avec le mauvais mot de passe.

```bash
# Installer Fail2Ban
sudo apt install fail2ban -y

# Créer une config personnalisée
sudo nano /etc/fail2ban/jail.local
```

Ajoute :
```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3          # 3 essais ratés
bantime = 3600        # Banni pour 1 heure
findtime = 600        # Dans une fenêtre de 10 minutes
```

```bash
# Redémarre Fail2Ban
sudo systemctl restart fail2ban

# Vérifie que ça tourne
sudo fail2ban-client status sshd
```

**Voir qui est banni :**
```bash
sudo fail2ban-client status sshd
```

**Débannir quelqu'un (si tu t'es auto-banni, oups !) :**
```bash
sudo fail2ban-client set sshd unbanip ADRESSE_IP
```

---

## 🔥 Partie 4 : Le Pare-feu (UFW)

### 💬 Qu'est-ce qu'on cherche ?

On veut vérifier que ton serveur a un pare-feu actif qui bloque tout ce qui n'est pas explicitement autorisé.

### 🤔 L'analogie simple

Un pare-feu, c'est comme un videur à l'entrée d'un club :
- Par défaut, personne ne rentre
- Seules les personnes sur la liste (les ports autorisés) peuvent entrer
- Tout le reste est gentiment redirigé vers la sortie

Sans pare-feu = portes grandes ouvertes sur Internet. Pas top !

### 🔍 Vérifier l'état du pare-feu

```bash
# Voir si UFW est actif
sudo ufw status verbose

# Voir les règles numérotées
sudo ufw status numbered
```

### ✅ Ce que tu veux voir

```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
```

**Traduction :**
- ✅ Status active = Le pare-feu fonctionne
- ✅ Default deny incoming = Par défaut, tout est bloqué (bien !)
- ✅ SSH (port 22) autorisé = Tu peux te connecter

### ❌ Signaux d'alarme

```
Status: inactive  # ← 🔴 PAS BON DU TOUT !
```

**Ou pire :**
```
Default: allow (incoming)  # ← 🔴 Tout est ouvert !
```

### 🔧 Activer et configurer UFW

**Étape 1 : Active UFW**

⚠️ **ATTENTION** : Si tu es connecté en SSH, autorise d'abord le port SSH AVANT d'activer le pare-feu, sinon tu te coupes toi-même !

```bash
# AVANT TOUT : Autorise SSH
sudo ufw allow 22/tcp

# OU si tu veux limiter aux tentatives de connexion (recommandé)
sudo ufw limit 22/tcp  # Limite les tentatives (anti brute-force)

# Active le pare-feu
sudo ufw enable

# Vérifie
sudo ufw status
```

**Étape 2 : Règles par défaut**

```bash
# Bloque tout entrant par défaut
sudo ufw default deny incoming

# Autorise tout sortant
sudo ufw default allow outgoing
```

**Étape 3 : Autorise seulement ce dont tu as besoin**

```bash
# Exemples courants :

# SSH (déjà fait)
sudo ufw limit 22/tcp

# HTTP (site web)
sudo ufw allow 80/tcp

# HTTPS (site web sécurisé)
sudo ufw allow 443/tcp

# MySQL depuis un serveur spécifique
sudo ufw allow from 192.168.1.100 to any port 3306
```

**Voir et supprimer des règles :**
```bash
# Voir les règles numérotées
sudo ufw status numbered

# Supprimer la règle numéro 3
sudo ufw delete 3
```

### 💡 Règles d'or du pare-feu

1. **Whitelisting > Blacklisting** : Bloque tout, puis autorise uniquement ce qui est nécessaire
2. **Spécificité** : Plus ta règle est précise, mieux c'est (IP source, port précis)
3. **Documentation** : Note pourquoi tu ouvres un port (commentaires)
4. **Révision** : Tous les 3-6 mois, vérifie que tu as toujours besoin de chaque règle

---

## 📝 Partie 5 : Les Logs - Ta Vidéosurveillance

### 💬 Qu'est-ce qu'on cherche ?

Les logs (journaux), c'est comme les caméras de surveillance : ça enregistre tout ce qui se passe. On veut s'assurer qu'ils fonctionnent !

### 🤔 Pourquoi c'est crucial ?

Sans logs :
- Tu ne sais pas si quelqu'un essaie de pirater ton serveur
- En cas d'incident, tu es aveugle pour comprendre ce qui s'est passé
- Tu ne peux pas détecter les comportements suspects

Avec de bons logs, tu peux :
- Détecter les attaques en cours
- Faire de l'investigation après un incident
- Prouver ce qui s'est passé (légalement important !)

### 🔍 Check #1 : Les logs système

```bash
# Voir les dernières connexions SSH
sudo last | head -20

# Voir les tentatives de connexion échouées
sudo lastb | head -20

# Voir les logs système récents
sudo journalctl -n 50 --no-pager

# Logs d'authentification
sudo tail -50 /var/log/auth.log
```

**✅ Ce que tu devrais voir :**
- Tes propres connexions
- Quelques tentatives échouées (normal, les bots scannent tout Internet)

**❌ Alerte si :**
- Des MILLIERS de tentatives échouées depuis la même IP récemment
- Des connexions réussies depuis des IPs que tu ne reconnais pas
- Pas de logs du tout (si les fichiers sont vides)

### 🔍 Check #2 : Auditd - Le détective privé

Auditd enregistre des événements de sécurité spécifiques.

```bash
# Vérifie qu'il tourne
sudo systemctl status auditd

# Voir les règles d'audit
sudo auditctl -l
```

**Configurer des règles d'audit importantes :**

```bash
# Crée un fichier de règles
sudo nano /etc/audit/rules.d/security.rules
```

Ajoute :
```bash
# Surveiller les fichiers de mots de passe
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity

# Surveiller les modifications SSH
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Surveiller sudo
-w /etc/sudoers -p wa -k sudoers

# Surveiller les connexions réseau
-a always,exit -F arch=b64 -S connect -k network_connections
```

```bash
# Recharge les règles
sudo augenrules --load

# Vérifie
sudo auditctl -l
```

**Chercher dans les logs d'audit :**
```bash
# Rechercher les événements SSH
sudo ausearch -k sshd_config

# Rechercher les modifications de mots de passe
sudo ausearch -k identity
```

---

## 🎯 Checklist Rapide Finale

Voici ta checklist à cocher. Si tu as tout en ✅, ton serveur est plutôt bien sécurisé !

### Mises à jour
- [ ] Mises à jour de sécurité installées (< 7 jours)
- [ ] Mises à jour automatiques activées
- [ ] Aucune mise à jour critique en attente

### Comptes et authentification
- [ ] Compte root : login SSH désactivé
- [ ] Aucun compte sans mot de passe
- [ ] Politique de mots de passe : 14 caractères minimum
- [ ] Expiration des mots de passe : < 365 jours
- [ ] Comptes inutilisés supprimés

### SSH
- [ ] PasswordAuthentication = no (clés SSH seulement)
- [ ] PermitRootLogin = no
- [ ] Fail2Ban actif
- [ ] Limite de tentatives configurée (MaxAuthTries)
- [ ] Timeout configuré (ClientAliveInterval)

### Pare-feu
- [ ] UFW actif
- [ ] Politique par défaut : deny incoming
- [ ] Seuls les ports nécessaires ouverts
- [ ] SSH en mode limit (anti brute-force)

### Logs et audit
- [ ] Auditd actif
- [ ] Règles d'audit configurées
- [ ] Logs protégés (permissions 640)
- [ ] Rotation des logs configurée

### Services
- [ ] Liste des services actifs vérifiée
- [ ] Services inutiles désactivés
- [ ] Pas de services suspects

### Système de fichiers
- [ ] Permissions fichiers sensibles OK (shadow = 640)
- [ ] Pas de fichiers world-writable
- [ ] Partitions /tmp et /var avec noexec

---

## 🚀 Aller Plus Loin

### Audit automatique avec Lynis

Lynis est un outil qui fait un audit automatique. C'est comme avoir un expert qui vérifie tout pour toi !

```bash
# Installer Lynis
sudo apt install lynis -y

# Lancer un audit complet
sudo lynis audit system

# Voir le rapport
cat /var/log/lynis-report.dat
```

Lynis va te donner un score et des recommandations. Vise au minimum 75/100 !

### Commande magique pour un rapport rapide

Copie-colle ce script pour un rapport express :

```bash
#!/bin/bash
echo "=== 🔍 AUDIT EXPRESS ==="
echo ""
echo "📊 Mises à jour en attente:"
apt list --upgradable 2>/dev/null | grep -v "Listing"
echo ""
echo "🔑 Comptes sans mot de passe:"
sudo awk -F: '($2 == "") {print $1}' /etc/shadow
echo ""
echo "🚪 Config SSH critique:"
sudo sshd -T | grep -E "permitroot|passwordauth"
echo ""
echo "🔥 État pare-feu:"
sudo ufw status
echo ""
echo "📝 Dernières connexions SSH:"
sudo last | head -5
echo ""
echo "🎯 Score Fail2Ban:"
sudo fail2ban-client status sshd 2>/dev/null || echo "Fail2Ban non installé"
echo ""
echo "=== Fin du rapport ==="
```

Sauvegarde-le dans `audit-rapide.sh`, rends-le exécutable et lance-le :

```bash
chmod +x audit-rapide.sh
./audit-rapide.sh
```

---

## 📚 Pour Aller Plus Loin

**Ressources officielles :**
- [Ubuntu Security Guide](https://ubuntu.com/security) - La doc officielle
- [CIS Ubuntu Benchmark](https://www.cisecurity.org/benchmark/ubuntu_linux) - Le guide de référence
- [ANSSI Guide Linux](https://www.ssi.gouv.fr/) - Recommandations françaises

**Outils supplémentaires :**
- [Lynis](https://cisofy.com/lynis/) - Audit automatique
- [AIDE](https://aide.github.io/) - Détection d'intrusion
- [Tiger](http://www.nongnu.org/tiger/) - Scanner de sécurité

---

## 🎓 Conclusion

Bravo ! Si tu as suivi ce guide jusqu'ici, ton serveur Ubuntu est maintenant beaucoup plus sécurisé qu'avant. 🎉

**Les points clés à retenir :**
1. Les mises à jour sont NON-NÉGOCIABLES
2. SSH = clés SSH uniquement, pas de mots de passe
3. Le pare-feu doit TOUJOURS être actif
4. Les logs sont tes meilleurs amis pour détecter les problèmes

**Et surtout :**
La sécurité, c'est un marathon, pas un sprint. Refais un audit tous les 3-6 mois, garde ton système à jour, et reste vigilant !

Des questions ? Des points pas clairs ? N'hésite pas à creuser la doc ou demander de l'aide sur les forums !

Bonne sécurisation ! 🛡️

---

*Ce guide est maintenu par la communauté. Si tu trouves une erreur ou veux améliorer une explication, n'hésite pas à contribuer !*
