# Guide d'Audit Technique - Ubuntu Server

## 📋 Vue d'ensemble

Ce guide vous permet d'effectuer un audit de sécurité complet d'un serveur Ubuntu. Il est basé sur les standards suivants :
- **CIS Benchmark for Ubuntu Linux** (dernière version)
- **ANSSI-BP-028** - Configuration recommendations for GNU/Linux systems
- **NIST National Checklist Program**

### Version du guide
- **Dernière mise à jour** : Janvier 2025
- **Systèmes couverts** : Ubuntu 20.04 LTS, 22.04 LTS, 24.04 LTS
- **Type d'audit** : Sécurité et conformité

---

## 🎯 Objectifs de l'audit

- Évaluer la posture de sécurité du serveur Ubuntu
- Identifier les configurations non conformes aux bonnes pratiques
- Détecter les vulnérabilités potentielles
- Vérifier la conformité aux standards de sécurité
- Produire un rapport d'audit actionnable

---

## 📚 Prérequis

### Connaissances requises
- Commandes Linux de base (ls, cat, grep, etc.)
- Compréhension des permissions Unix
- Notions de base en sécurité informatique

### Accès nécessaire
- Accès SSH au serveur
- Privilèges sudo/root
- Possibilité de lecture des fichiers de configuration

### Outils recommandés
```bash
# Installation des outils d'audit
sudo apt update
sudo apt install -y lynis aide rkhunter chkrootkit ufw auditd fail2ban
```

---

## 🔍 Points de Contrôle d'Audit

### 1. GESTION DES MISES À JOUR

#### 1.1 Vérification des mises à jour de sécurité

**Objectif :** S'assurer que toutes les mises à jour de sécurité sont installées

**Justification :** Les mises à jour de sécurité corrigent des vulnérabilités connues et documentées (CVE). Un système non mis à jour est exposé à des exploits publics.

**Procédure :**
```bash
# Vérifier les mises à jour disponibles
sudo apt update
sudo apt list --upgradable

# Vérifier spécifiquement les mises à jour de sécurité
sudo unattended-upgrades --dry-run -d

# Vérifier la configuration des mises à jour automatiques
cat /etc/apt/apt.conf.d/50unattended-upgrades
systemctl status unattended-upgrades
```

**Résultats attendus :**
- ✅ Aucune mise à jour de sécurité en attente
- ✅ Service `unattended-upgrades` actif et configuré
- ✅ Mises à jour automatiques activées pour les paquets de sécurité

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Mises à jour manquantes > 30 jours | 🔴 CRITIQUE | Exploitation de vulnérabilités connues (CVE) |
| Mises à jour manquantes < 30 jours | 🟠 ÉLEVÉ | Fenêtre d'exposition aux attaques |
| Pas de mise à jour automatique | 🟡 MOYEN | Oubli de patches critiques |

**Recommandations :**
```bash
# Activer les mises à jour automatiques de sécurité
sudo dpkg-reconfigure -plow unattended-upgrades

# Configuration recommandée dans /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
```

---

### 2. CONFIGURATION DU COMPTE ROOT ET UTILISATEURS

#### 2.1 Désactivation du login root direct

**Objectif :** Vérifier que la connexion directe en tant que root est désactivée

**Justification :** La connexion directe root augmente les risques d'attaques par force brute et rend l'audit des actions difficile. L'utilisation de sudo permet une traçabilité des actions.

**Procédure :**
```bash
# Vérifier la configuration SSH pour root
grep "^PermitRootLogin" /etc/ssh/sshd_config

# Vérifier si le compte root a un mot de passe
sudo passwd -S root

# Vérifier les dernières connexions root
sudo lastb | grep root
sudo last | grep root
```

**Résultats attendus :**
- ✅ `PermitRootLogin no` ou `PermitRootLogin prohibit-password`
- ✅ Compte root verrouillé (status L) ou sans mot de passe
- ✅ Aucune connexion root directe dans les logs

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| PermitRootLogin yes | 🔴 CRITIQUE | Attaques par force brute sur root, pas de traçabilité |
| Root avec mot de passe simple | 🔴 CRITIQUE | Compromission facile du compte privilégié |
| Connexions root récentes | 🟠 ÉLEVÉ | Pratiques administratives dangereuses |

**Recommandations :**
```bash
# Désactiver le login root SSH
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Verrouiller le compte root
sudo passwd -l root
```

#### 2.2 Politique de mots de passe

**Objectif :** Vérifier la robustesse de la politique de mots de passe

**Justification :** Des mots de passe faibles sont la première cause de compromission de comptes. Une politique stricte réduit drastiquement ce risque.

**Procédure :**
```bash
# Vérifier la configuration PAM pour les mots de passe
cat /etc/pam.d/common-password

# Vérifier la configuration de la complexité
cat /etc/security/pwquality.conf

# Vérifier les paramètres d'expiration
cat /etc/login.defs | grep -E "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_MIN_LEN|PASS_WARN_AGE"

# Auditer les comptes utilisateurs
sudo awk -F: '($3 >= 1000) {print $1}' /etc/passwd | while read user; do
    sudo chage -l "$user"
done
```

**Résultats attendus :**
- ✅ Longueur minimale : 14 caractères (ANSSI niveau intermédiaire) ou 12 (CIS)
- ✅ Complexité activée (minlen, dcredit, ucredit, lcredit, ocredit)
- ✅ Expiration max : 90 jours (CIS) ou 365 jours (ANSSI niveau minimal)
- ✅ Délai minimum entre changements : 1 jour
- ✅ Avertissement : 7 jours avant expiration

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de politique de complexité | 🔴 CRITIQUE | Mots de passe faibles, attaques par dictionnaire |
| Longueur < 8 caractères | 🔴 CRITIQUE | Force brute rapide |
| Pas d'expiration | 🟠 ÉLEVÉ | Mots de passe compromis restent valides indéfiniment |
| Expiration > 365 jours | 🟡 MOYEN | Fenêtre d'exploitation longue |

**Recommandations :**
```bash
# Configuration recommandée dans /etc/security/pwquality.conf
minlen = 14
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
minclass = 3
maxrepeat = 3
maxclassrepeat = 4
gecoscheck = 1
dictcheck = 1
usercheck = 1
enforcing = 1

# Configuration recommandée dans /etc/login.defs
PASS_MAX_DAYS   90
PASS_MIN_DAYS   1
PASS_WARN_AGE   7
```

#### 2.3 Verrouillage de compte après échecs

**Objectif :** Vérifier que les comptes sont verrouillés après plusieurs tentatives échouées

**Justification :** Protège contre les attaques par force brute en limitant le nombre de tentatives.

**Procédure :**
```bash
# Vérifier la configuration de pam_faillock
grep pam_faillock /etc/pam.d/common-auth
cat /etc/security/faillock.conf

# Vérifier les comptes actuellement verrouillés
sudo faillock --user <username>
```

**Résultats attendus :**
- ✅ `pam_faillock.so` configuré dans PAM
- ✅ Verrouillage après 5 échecs maximum (CIS)
- ✅ Durée de verrouillage : 900 secondes (15 minutes)
- ✅ Root également soumis au verrouillage

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de limitation | 🔴 CRITIQUE | Force brute illimitée |
| Seuil > 10 tentatives | 🟠 ÉLEVÉ | Fenêtre d'attaque trop large |
| Root exclu | 🟠 ÉLEVÉ | Attaques ciblées sur root |

**Recommandations :**
```bash
# Configuration dans /etc/security/faillock.conf
deny = 5
unlock_time = 900
fail_interval = 900
even_deny_root
```

---

### 3. CONFIGURATION SSH

#### 3.1 Durcissement du service SSH

**Objectif :** S'assurer que SSH est configuré de manière sécurisée

**Justification :** SSH est souvent la principale porte d'entrée vers les serveurs. Une configuration faible expose à des risques de compromission.

**Procédure :**
```bash
# Audit complet de la configuration SSH
sudo sshd -T

# Vérifier les paramètres critiques
grep -E "^(Protocol|PermitRootLogin|PubkeyAuthentication|PasswordAuthentication|PermitEmptyPasswords|X11Forwarding|MaxAuthTries|ClientAliveInterval|ClientAliveCountMax|LoginGraceTime|MaxSessions|AllowUsers|AllowGroups)" /etc/ssh/sshd_config
```

**Résultats attendus :**
```
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 4
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
MaxSessions 10
AllowUsers <liste_specifique> OU AllowGroups <groupes_specifiques>
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| PasswordAuthentication yes | 🔴 CRITIQUE | Attaques par force brute |
| PermitRootLogin yes | 🔴 CRITIQUE | Compromission compte root |
| PermitEmptyPasswords yes | 🔴 CRITIQUE | Accès sans authentification |
| X11Forwarding yes | 🟡 MOYEN | Faille de sécurité X11 |
| Pas de restriction utilisateurs | 🟡 MOYEN | Surface d'attaque élargie |

**Recommandations :**
```bash
# Configuration sécurisée dans /etc/ssh/sshd_config
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 4
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
MaxSessions 10
AllowGroups ssh-users

# Créer le groupe et ajouter les utilisateurs autorisés
sudo groupadd ssh-users
sudo usermod -a -G ssh-users <username>

# Redémarrer SSH
sudo systemctl restart sshd
```

#### 3.2 Clés SSH et algorithmes cryptographiques

**Objectif :** Vérifier que seuls des algorithmes cryptographiques robustes sont utilisés

**Justification :** Les algorithmes faibles (MD5, SHA1, DSA) sont vulnérables aux attaques cryptographiques modernes.

**Procédure :**
```bash
# Vérifier les algorithmes activés
sudo sshd -T | grep -E "ciphers|macs|kexalgorithms|hostkeyalgorithms"

# Vérifier les clés hôtes présentes
ls -la /etc/ssh/ssh_host_*_key*
```

**Résultats attendus :**
- ✅ Ciphers : chacha20-poly1305, aes256-gcm, aes256-ctr
- ✅ MACs : hmac-sha2-512, hmac-sha2-256
- ✅ KexAlgorithms : curve25519-sha256, diffie-hellman-group-exchange-sha256
- ✅ HostKeyAlgorithms : ssh-ed25519, rsa-sha2-512, rsa-sha2-256
- ❌ Pas de : 3des, arcfour, md5, sha1, dsa

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Algorithmes faibles activés | 🔴 CRITIQUE | Décryptage des communications |
| Clés DSA présentes | 🟠 ÉLEVÉ | Algorithme obsolète et faible |
| Clés RSA < 2048 bits | 🟠 ÉLEVÉ | Factorisation possible |

**Recommandations :**
```bash
# Configuration dans /etc/ssh/sshd_config
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# Supprimer les anciennes clés faibles
sudo rm /etc/ssh/ssh_host_dsa_key*
sudo rm /etc/ssh/ssh_host_ecdsa_key*

# Regénérer des clés fortes si nécessaire
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
sudo ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
```

---

### 4. PARE-FEU ET RÉSEAU

#### 4.1 Configuration du pare-feu UFW

**Objectif :** Vérifier qu'un pare-feu est actif et correctement configuré

**Justification :** Un pare-feu correctement configuré réduit la surface d'attaque en bloquant les services non nécessaires.

**Procédure :**
```bash
# Vérifier le statut UFW
sudo ufw status verbose

# Vérifier les règles détaillées
sudo ufw status numbered

# Vérifier si iptables est utilisé directement
sudo iptables -L -n -v
sudo ip6tables -L -n -v
```

**Résultats attendus :**
- ✅ UFW actif : `Status: active`
- ✅ Politique par défaut : `Default: deny (incoming), allow (outgoing)`
- ✅ Seuls les ports nécessaires sont ouverts
- ✅ Règles IPv6 également configurées

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pare-feu inactif | 🔴 CRITIQUE | Tous les services exposés |
| Default policy allow | 🔴 CRITIQUE | Aucune protection |
| Ports inutiles ouverts | 🟠 ÉLEVÉ | Surface d'attaque élargie |
| IPv6 non protégé | 🟠 ÉLEVÉ | Contournement via IPv6 |

**Recommandations :**
```bash
# Activer et configurer UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed

# Autoriser uniquement les services nécessaires
sudo ufw allow 22/tcp comment 'SSH'
# Ajouter d'autres règles selon les besoins

# Activer UFW
sudo ufw enable

# Activer le logging
sudo ufw logging on
```

#### 4.2 Désactivation des protocoles réseau non utilisés

**Objectif :** Désactiver les protocoles réseau inutiles (IPv6 si non utilisé, etc.)

**Justification :** Les protocoles non utilisés augmentent la surface d'attaque sans bénéfice.

**Procédure :**
```bash
# Vérifier si IPv6 est utilisé
ip -6 addr show

# Vérifier la configuration de désactivation
cat /etc/sysctl.conf | grep ipv6

# Vérifier les protocoles obsolètes
cat /etc/modprobe.d/blacklist.conf | grep -E "dccp|sctp|rds|tipc"
```

**Résultats attendus :**
- Si IPv6 non utilisé : désactivé dans sysctl
- Protocoles obsolètes blacklistés : dccp, sctp, rds, tipc

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| IPv6 actif mais non surveillé | 🟠 ÉLEVÉ | Contournement des règles de sécurité IPv4 |
| Protocoles obsolètes actifs | 🟡 MOYEN | Vulnérabilités non patchées |

**Recommandations :**
```bash
# Si IPv6 n'est pas utilisé, dans /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Blacklister les protocoles obsolètes dans /etc/modprobe.d/blacklist.conf
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true

# Appliquer
sudo sysctl -p
```

#### 4.3 Durcissement réseau (sysctl)

**Objectif :** Vérifier les paramètres de durcissement réseau du noyau

**Justification :** Ces paramètres protègent contre diverses attaques réseau (spoofing, routing attacks, SYN floods, etc.)

**Procédure :**
```bash
# Vérifier les paramètres actuels
sudo sysctl -a | grep -E "net.ipv4.conf.all.accept_source_route|net.ipv4.conf.all.send_redirects|net.ipv4.conf.all.accept_redirects|net.ipv4.icmp_echo_ignore_broadcasts|net.ipv4.tcp_syncookies|net.ipv4.conf.all.rp_filter|net.ipv4.conf.all.log_martians"
```

**Résultats attendus :**
```
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Source routing activé | 🔴 CRITIQUE | IP spoofing, man-in-the-middle |
| Pas de SYN cookies | 🟠 ÉLEVÉ | SYN flood DoS |
| Redirects activés | 🟠 ÉLEVÉ | Redirection de trafic malveillante |
| RP filter désactivé | 🟡 MOYEN | Spoofing d'adresses IP |

**Recommandations :**
```bash
# Configuration dans /etc/sysctl.conf ou /etc/sysctl.d/99-security.conf
# Protection contre le source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Désactiver les ICMP redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Protection contre les attaques
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Appliquer
sudo sysctl -p
```

---

### 5. AUDIT ET LOGGING

#### 5.1 Configuration d'auditd

**Objectif :** Vérifier que le système d'audit est actif et correctement configuré

**Justification :** Auditd permet de tracer les événements de sécurité critiques pour la détection d'intrusion et l'investigation.

**Procédure :**
```bash
# Vérifier le statut d'auditd
sudo systemctl status auditd

# Vérifier les règles d'audit
sudo auditctl -l

# Vérifier la configuration
cat /etc/audit/auditd.conf
cat /etc/audit/rules.d/*.rules
```

**Résultats attendus :**
- ✅ Service auditd actif et enabled
- ✅ Règles d'audit pour les fichiers critiques (/etc/passwd, /etc/shadow, etc.)
- ✅ Audit des appels système privilégiés
- ✅ Audit des modifications de configuration réseau
- ✅ Retention des logs : min 30 jours

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Auditd non actif | 🔴 CRITIQUE | Aucune traçabilité des événements de sécurité |
| Pas de règles définies | 🟠 ÉLEVÉ | Événements critiques non tracés |
| Retention < 7 jours | 🟡 MOYEN | Investigation limitée |

**Recommandations :**
```bash
# Installer auditd si nécessaire
sudo apt install auditd audispd-plugins

# Exemple de règles dans /etc/audit/rules.d/hardening.rules
## Audit des fichiers critiques
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

## Audit des modifications système
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

## Audit SSH
-w /etc/ssh/sshd_config -p wa -k sshd

## Audit des appels système privilégiés
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale

## Audit des modifications réseau
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications
-w /etc/hosts -p wa -k network_modifications
-w /etc/network/ -p wa -k network_modifications

# Recharger les règles
sudo augenrules --load

# Activer et démarrer
sudo systemctl enable auditd
sudo systemctl start auditd
```

#### 5.2 Configuration de rsyslog

**Objectif :** Vérifier que les logs système sont correctement collectés et conservés

**Justification :** Les logs sont essentiels pour la détection d'incidents, le troubleshooting et la conformité réglementaire.

**Procédure :**
```bash
# Vérifier le statut de rsyslog
sudo systemctl status rsyslog

# Vérifier la configuration
cat /etc/rsyslog.conf
ls -la /etc/rsyslog.d/

# Vérifier les permissions des fichiers de logs
ls -la /var/log/
```

**Résultats attendus :**
- ✅ rsyslog actif et enabled
- ✅ Logs des services critiques configurés
- ✅ Permissions restrictives sur /var/log/* (640 ou 600)
- ✅ Centralisation des logs (optionnel mais recommandé)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| rsyslog non actif | 🔴 CRITIQUE | Perte de traçabilité complète |
| Permissions 644 ou 777 | 🟠 ÉLEVÉ | Lecture des logs par utilisateurs non autorisés |
| Pas de centralisation | 🟡 MOYEN | Perte de logs si compromission |

**Recommandations :**
```bash
# Vérifier les permissions
sudo chmod 640 /var/log/syslog
sudo chmod 640 /var/log/auth.log

# Configurer la rotation des logs dans /etc/logrotate.d/rsyslog
/var/log/syslog
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

---

### 6. SERVICES ET DÉMONS

#### 6.1 Inventaire des services actifs

**Objectif :** Identifier tous les services en cours d'exécution

**Justification :** Chaque service actif est une surface d'attaque potentielle. Seuls les services nécessaires doivent être actifs.

**Procédure :**
```bash
# Lister tous les services actifs
sudo systemctl list-units --type=service --state=running

# Lister les services enabled au démarrage
sudo systemctl list-unit-files --type=service --state=enabled

# Vérifier les ports en écoute
sudo ss -tulpn

# Vérifier les processus
sudo ps aux
```

**Résultats attendus :**
- ✅ Liste minimale de services nécessaires
- ✅ Pas de services inutiles (telnet, ftp, rsh, etc.)
- ✅ Chaque service justifié et documenté

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Services obsolètes actifs (telnet, rsh) | 🔴 CRITIQUE | Protocoles non chiffrés, vulnérabilités connues |
| Services non nécessaires | 🟠 ÉLEVÉ | Surface d'attaque élargie |
| Ports non documentés | 🟡 MOYEN | Services fantômes ou malveillants |

**Recommandations :**
```bash
# Désactiver les services inutiles (exemples)
sudo systemctl stop <service>
sudo systemctl disable <service>

# Services typiquement à désactiver si non utilisés :
# - avahi-daemon (mDNS)
# - cups (impression)
# - bluetooth
# - rpcbind (si pas de NFS)
```

#### 6.2 Vérification de l'absence de rootkits

**Objectif :** Détecter la présence éventuelle de rootkits

**Justification :** Les rootkits permettent à un attaquant de maintenir un accès persistant et caché au système.

**Procédure :**
```bash
# Scanner avec rkhunter
sudo rkhunter --update
sudo rkhunter --check --sk

# Scanner avec chkrootkit
sudo chkrootkit

# Vérifier l'intégrité avec AIDE
sudo aide --check
```

**Résultats attendus :**
- ✅ Aucun rootkit détecté
- ✅ Aucune modification suspecte de binaires système
- ✅ Base AIDE à jour et cohérente

**Risques identifiés :**
| Détection | Criticité | Risque |
|-----------|-----------|---------|
| Rootkit détecté | 🔴 CRITIQUE | Système compromis |
| Binaires modifiés | 🔴 CRITIQUE | Backdoor ou trojan |
| AIDE non configuré | 🟡 MOYEN | Impossible de détecter les modifications |

**Recommandations :**
```bash
# Initialiser AIDE
sudo aideinit
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Planifier des vérifications régulières (cron)
echo "0 5 * * * root /usr/bin/aide --check | mail -s 'AIDE Check' admin@example.com" | sudo tee -a /etc/crontab
```

---

### 7. SÉCURITÉ DU SYSTÈME DE FICHIERS

#### 7.1 Permissions sur fichiers sensibles

**Objectif :** Vérifier que les fichiers sensibles ont des permissions restrictives

**Justification :** Des permissions trop laxistes permettent à des utilisateurs non autorisés de lire ou modifier des fichiers critiques.

**Procédure :**
```bash
# Vérifier les permissions des fichiers critiques
ls -l /etc/passwd /etc/shadow /etc/group /etc/gshadow
ls -l /boot/grub/grub.cfg
ls -l /etc/ssh/sshd_config

# Rechercher les fichiers world-writable
sudo find / -xdev -type f -perm -0002 -ls 2>/dev/null

# Rechercher les fichiers sans propriétaire
sudo find / -xdev \( -nouser -o -nogroup \) -ls 2>/dev/null
```

**Résultats attendus :**
```
-rw-r--r-- /etc/passwd (644)
-rw-r----- /etc/shadow (640 ou 600)
-rw-r--r-- /etc/group (644)
-rw-r----- /etc/gshadow (640 ou 600)
-rw------- /boot/grub/grub.cfg (600)
-rw------- /etc/ssh/sshd_config (600)
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| /etc/shadow lisible par tous | 🔴 CRITIQUE | Extraction et cracking des hash de mots de passe |
| Fichiers world-writable | 🔴 CRITIQUE | Modification malveillante |
| Fichiers sans propriétaire | 🟠 ÉLEVÉ | Fichiers orphelins ou malveillants |

**Recommandations :**
```bash
# Corriger les permissions
sudo chmod 644 /etc/passwd
sudo chmod 640 /etc/shadow
sudo chmod 644 /etc/group
sudo chmod 640 /etc/gshadow
sudo chmod 600 /boot/grub/grub.cfg
sudo chmod 600 /etc/ssh/sshd_config

# Supprimer les fichiers world-writable ou corriger
sudo find / -xdev -type f -perm -0002 -exec chmod o-w {} \;
```

#### 7.2 Montages de partitions sécurisés

**Objectif :** Vérifier que les partitions sont montées avec des options de sécurité

**Justification :** Les options de montage (noexec, nodev, nosuid) empêchent l'exécution de code malveillant depuis certaines partitions.

**Procédure :**
```bash
# Vérifier les options de montage
mount | grep -E "/tmp|/var|/home"
cat /etc/fstab
```

**Résultats attendus :**
- ✅ `/tmp` : noexec,nodev,nosuid
- ✅ `/var/tmp` : noexec,nodev,nosuid
- ✅ `/home` : nodev (minimum)
- ✅ `/dev/shm` : noexec,nodev,nosuid

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| /tmp sans noexec | 🟠 ÉLEVÉ | Exécution de malware depuis /tmp |
| /dev/shm sans noexec | 🟠 ÉLEVÉ | Exécution en mémoire |
| Partitions sans nodev | 🟡 MOYEN | Création de device nodes malveillants |

**Recommandations :**
```bash
# Exemple de configuration dans /etc/fstab
tmpfs /tmp tmpfs defaults,noexec,nodev,nosuid 0 0
tmpfs /var/tmp tmpfs defaults,noexec,nodev,nosuid 0 0
tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid 0 0

# Remonter immédiatement
sudo mount -o remount /tmp
sudo mount -o remount /var/tmp
sudo mount -o remount /dev/shm
```

---

### 8. SÉCURITÉ DU NOYAU

#### 8.1 Paramètres de sécurité du noyau

**Objectif :** Vérifier les paramètres de durcissement du noyau Linux

**Justification :** Ces paramètres activent des protections contre l'exploitation de vulnérabilités noyau.

**Procédure :**
```bash
# Vérifier les paramètres de sécurité
sudo sysctl -a | grep -E "kernel.dmesg_restrict|kernel.kptr_restrict|kernel.yama.ptrace_scope|kernel.kexec_load_disabled|kernel.unprivileged_bpf_disabled"
```

**Résultats attendus :**
```
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.kexec_load_disabled = 1
kernel.unprivileged_bpf_disabled = 1
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| dmesg_restrict = 0 | 🟡 MOYEN | Fuite d'informations kernel |
| kptr_restrict = 0 | 🟠 ÉLEVÉ | Facilite les exploits kernel |
| ptrace non restreint | 🟠 ÉLEVÉ | Débugage de processus privilégiés |

**Recommandations :**
```bash
# Configuration dans /etc/sysctl.d/99-kernel-hardening.conf
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.kexec_load_disabled = 1
kernel.unprivileged_bpf_disabled = 1

# Appliquer
sudo sysctl -p /etc/sysctl.d/99-kernel-hardening.conf
```

---

### 9. CONFORMITÉ ET OUTILS AUTOMATISÉS

#### 9.1 Audit avec Lynis

**Objectif :** Exécuter un audit automatisé complet avec Lynis

**Justification :** Lynis est un outil d'audit reconnu qui vérifie des centaines de points de contrôle.

**Procédure :**
```bash
# Mettre à jour Lynis
sudo lynis update info

# Exécuter l'audit complet
sudo lynis audit system

# Consulter le rapport
cat /var/log/lynis.log
cat /var/log/lynis-report.dat
```

**Résultats attendus :**
- ✅ Score de durcissement > 80
- ✅ Pas d'avertissements critiques
- ✅ Suggestions documentées et analysées

**Risques identifiés :**
| Score Lynis | Criticité | Action |
|-------------|-----------|---------|
| < 50 | 🔴 CRITIQUE | Durcissement urgent nécessaire |
| 50-70 | 🟠 ÉLEVÉ | Améliorations importantes requises |
| 70-80 | 🟡 MOYEN | Optimisations recommandées |

**Recommandations :**
Analyser chaque suggestion de Lynis et implémenter les corrections appropriées selon le contexte.

---

## 📊 Matrice de Criticité Globale

| Niveau | Délai de correction | Exemples |
|--------|---------------------|----------|
| 🔴 CRITIQUE | 24-48h | Root login activé, mises à jour critiques manquantes, pas de pare-feu |
| 🟠 ÉLEVÉ | 1 semaine | Algorithmes faibles, services inutiles, logs non protégés |
| 🟡 MOYEN | 1 mois | Optimisations mineures, durcissement avancé |
| 🟢 FAIBLE | Opportunité | Améliorations cosmétiques |

---

## ✅ Checklist Finale d'Audit

- [ ] Mises à jour de sécurité installées
- [ ] Politique de mots de passe robuste
- [ ] Compte root protégé
- [ ] SSH durci (clés uniquement, root désactivé)
- [ ] Pare-feu actif et configuré
- [ ] Services minimaux actifs
- [ ] Auditd configuré et actif
- [ ] Logs collectés et protégés
- [ ] Permissions fichiers sensibles correctes
- [ ] Partitions montées avec options sécurisées
- [ ] Paramètres kernel durcis
- [ ] Paramètres réseau durcis
- [ ] Pas de rootkits détectés
- [ ] Score Lynis > 80
- [ ] Rapport d'audit documenté

---

## 📚 Références

### Documentation officielle
- [Ubuntu Security Documentation](https://ubuntu.com/security)
- [CIS Benchmark for Ubuntu Linux](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [ANSSI-BP-028 (FR)](https://cyber.gouv.fr/publications/configuration-recommendations-gnulinux-system)
- [NIST National Checklist Program](https://ncp.nist.gov/)

### Standards de sécurité
- CIS Benchmark Ubuntu 20.04/22.04/24.04
- ANSSI-BP-028 v2.0
- NIST SP 800-70
- STIG (Security Technical Implementation Guide)

### Outils
- [Lynis](https://cisofy.com/lynis/)
- [AIDE](https://aide.github.io/)
- [Rkhunter](http://rkhunter.sourceforge.net/)
- [Ubuntu Security Guide (USG)](https://ubuntu.com/security/certifications/docs/usg)

### CVE et vulnérabilités
- [Ubuntu Security Notices](https://ubuntu.com/security/notices)
- [CVE Database](https://cve.mitre.org/)
- [NVD - National Vulnerability Database](https://nvd.nist.gov/)

---

**Note :** Ce guide doit être adapté au contexte spécifique de votre environnement. Certaines recommandations peuvent ne pas être applicables selon vos besoins métier.
