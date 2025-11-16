# Guide d'Audit Technique - MySQL / MariaDB

## 📋 Vue d'ensemble

Ce guide vous permet d'effectuer un audit de sécurité complet d'un serveur MySQL ou MariaDB. Il est basé sur les standards suivants :
- **CIS Benchmark for Oracle MySQL** (Community et Enterprise)
- **CIS Benchmark for MariaDB**
- **OWASP Database Security Guidelines**
- **NIST Database Security Guidelines**

### Version du guide
- **Dernière mise à jour** : Janvier 2025
- **Versions couvertes** : MySQL 8.0+, MariaDB 10.5+
- **Type d'audit** : Sécurité et conformité

---

## 🎯 Objectifs de l'audit

- Évaluer la posture de sécurité du serveur de base de données
- Identifier les configurations non conformes aux bonnes pratiques
- Détecter les comptes avec privilèges excessifs
- Vérifier le chiffrement des données au repos et en transit
- Assurer la traçabilité des opérations (audit logging)

---

## 📚 Prérequis

### Connaissances requises
- Commandes SQL de base
- Administration MySQL/MariaDB
- Compréhension des permissions et rôles

### Accès nécessaire
- Compte avec privilèges SUPER ou root MySQL
- Accès au système d'exploitation (pour fichiers de configuration)
- Accès SSH au serveur

### Outils recommandés
```bash
# Client MySQL/MariaDB
mysql --version

# Outils système
sudo apt install mysql-client   # Debian/Ubuntu
sudo yum install mysql          # RHEL/CentOS
```

---

## 🔍 Points de Contrôle d'Audit

### 1. INSTALLATION ET VERSION

#### 1.1 Version de MySQL/MariaDB

**Objectif :** Vérifier que la version installée est supportée et à jour

**Justification :** Les versions anciennes contiennent des vulnérabilités connues (CVE) et ne reçoivent plus de mises à jour de sécurité.

**Procédure :**
```sql
-- Se connecter à MySQL
mysql -u root -p

-- Vérifier la version
SELECT VERSION();
SELECT @@version;

-- Vérifier les variables système
SHOW VARIABLES LIKE '%version%';
```

```bash
# Depuis le système d'exploitation
mysql --version
mysqld --version
```

**Résultats attendus :**
- ✅ MySQL 8.0.x (dernière version stable) ou MySQL 8.4 LTS
- ✅ MariaDB 10.5+ ou 10.11 LTS, 11.x
- ✅ Version avec support actif (vérifier sur site officiel)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| MySQL < 5.7 ou MariaDB < 10.3 | 🔴 CRITIQUE | Vulnérabilités critiques non corrigées, fin de support |
| Version EOL (End Of Life) | 🔴 CRITIQUE | Aucune mise à jour de sécurité disponible |
| Version < 6 mois de retard | 🟡 MOYEN | Patches de sécurité manquants |

**Recommandations :**
- Planifier une mise à jour vers MySQL 8.0 LTS ou MariaDB 10.11 LTS
- Suivre les release notes et security advisories
- Tester les mises à jour dans un environnement de développement d'abord

---

### 2. GESTION DES COMPTES ET AUTHENTIFICATION

#### 2.1 Inventaire des comptes utilisateurs

**Objectif :** Lister tous les comptes et identifier les comptes inutilisés ou suspects

**Justification :** Chaque compte est un point d'entrée potentiel. Les comptes par défaut, anonymes ou non utilisés doivent être supprimés.

**Procédure :**
```sql
-- Lister tous les comptes
SELECT User, Host, plugin, authentication_string
FROM mysql.user
ORDER BY User, Host;

-- Identifier les comptes sans mot de passe
SELECT User, Host
FROM mysql.user
WHERE (plugin = 'mysql_native_password' AND authentication_string = '')
   OR (plugin = '' AND Password = '');

-- Identifier les comptes anonymes
SELECT User, Host
FROM mysql.user
WHERE User = '' OR User IS NULL;

-- Vérifier les comptes avec privilèges SUPER
SELECT User, Host
FROM mysql.user
WHERE Super_priv = 'Y';

-- Vérifier les comptes avec tous les privilèges
SELECT User, Host
FROM mysql.user
WHERE Select_priv = 'Y'
  AND Insert_priv = 'Y'
  AND Update_priv = 'Y'
  AND Delete_priv = 'Y'
  AND Create_priv = 'Y'
  AND Drop_priv = 'Y';
```

**Résultats attendus :**
- ✅ Pas de comptes anonymes (User = '')
- ✅ Pas de comptes sans mot de passe
- ✅ Nombre minimal de comptes avec privilèges SUPER
- ✅ Pas de compte 'test' ou similaire
- ✅ Tous les comptes justifiés et documentés

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Compte anonyme actif | 🔴 CRITIQUE | Accès non authentifié à la base |
| Compte sans mot de passe | 🔴 CRITIQUE | Accès sans authentification |
| Compte 'root' accessible depuis '%' | 🔴 CRITIQUE | Accès admin depuis n'importe quelle IP |
| Comptes inutilisés avec privilèges | 🟠 ÉLEVÉ | Comptes dormants compromissibles |

**Recommandations :**
```sql
-- Supprimer les comptes anonymes
DROP USER ''@'localhost';
DROP USER ''@'%';

-- Supprimer les comptes de test
DROP USER IF EXISTS 'test'@'localhost';

-- Restreindre root à localhost uniquement
DELETE FROM mysql.user WHERE User = 'root' AND Host != 'localhost';

-- Créer des comptes avec privilèges minimaux
CREATE USER 'app_user'@'192.168.1.%' IDENTIFIED BY 'StrongPassword123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON appdb.* TO 'app_user'@'192.168.1.%';

-- Appliquer les changements
FLUSH PRIVILEGES;
```

#### 2.2 Politique de mot de passe

**Objectif :** Vérifier qu'une politique de mot de passe robuste est en place

**Justification :** Les mots de passe faibles sont facilement crackables, notamment avec des dumps de hash (mysql.user).

**Procédure :**
```sql
-- Vérifier les plugins de validation de mot de passe
SHOW PLUGINS;
SELECT PLUGIN_NAME, PLUGIN_STATUS
FROM INFORMATION_SCHEMA.PLUGINS
WHERE PLUGIN_NAME LIKE '%password%';

-- Vérifier la politique de mot de passe (MySQL 8.0+)
SHOW VARIABLES LIKE 'validate_password%';

-- MariaDB : simple_password_check plugin
SHOW VARIABLES LIKE 'simple_password_check%';

-- Vérifier l'expiration par défaut
SHOW VARIABLES LIKE 'default_password_lifetime';

-- Vérifier les comptes avec expiration
SELECT User, Host, password_expired, password_lifetime
FROM mysql.user;
```

**Résultats attendus (CIS Benchmark Level 1) :**
```
validate_password.policy = MEDIUM ou STRONG
validate_password.length = 14 minimum
validate_password.mixed_case_count = 1
validate_password.number_count = 1
validate_password.special_char_count = 1
default_password_lifetime = 90 ou 365
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Plugin de validation non installé | 🔴 CRITIQUE | Mots de passe faibles acceptés |
| Longueur < 8 caractères | 🔴 CRITIQUE | Force brute rapide |
| Pas d'expiration | 🟠 ÉLEVÉ | Mots de passe compromis restent valides |
| Policy = LOW | 🟡 MOYEN | Mots de passe prévisibles |

**Recommandations :**
```sql
-- Installer le plugin de validation (MySQL 8.0+)
INSTALL COMPONENT 'file://component_validate_password';

-- Configurer la politique (dans my.cnf ou my.ini)
-- [mysqld]
-- validate_password.policy=STRONG
-- validate_password.length=14
-- validate_password.mixed_case_count=1
-- validate_password.number_count=1
-- validate_password.special_char_count=1
-- default_password_lifetime=90

-- Ou via SQL (dynamique)
SET GLOBAL validate_password.policy = 'STRONG';
SET GLOBAL validate_password.length = 14;
SET GLOBAL default_password_lifetime = 90;

-- Forcer le changement pour tous les utilisateurs
ALTER USER 'username'@'host' PASSWORD EXPIRE;
```

#### 2.3 Méthode d'authentification

**Objectif :** Vérifier que des méthodes d'authentification modernes sont utilisées

**Justification :** mysql_native_password utilise SHA1 (faible). caching_sha2_password (MySQL 8.0+) utilise SHA256 et est beaucoup plus robuste.

**Procédure :**
```sql
-- Vérifier le plugin par défaut
SELECT @@default_authentication_plugin;

-- Vérifier les méthodes utilisées par compte
SELECT User, Host, plugin
FROM mysql.user
ORDER BY plugin, User;

-- Identifier les comptes avec mysql_native_password
SELECT User, Host, plugin
FROM mysql.user
WHERE plugin = 'mysql_native_password';
```

**Résultats attendus :**
- ✅ MySQL 8.0+ : `caching_sha2_password` par défaut
- ✅ MariaDB : `mysql_native_password` acceptable, ou `ed25519` (plus fort)
- ❌ Éviter : `mysql_old_password` (obsolète et très faible)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| mysql_old_password utilisé | 🔴 CRITIQUE | Hash MD5 crackable en minutes |
| mysql_native_password sur MySQL 8.0+ | 🟡 MOYEN | SHA1 moins robuste que SHA256 |

**Recommandations :**
```sql
-- Définir le plugin par défaut (dans my.cnf)
-- [mysqld]
-- default_authentication_plugin=caching_sha2_password

-- Migrer les comptes existants
ALTER USER 'username'@'host' IDENTIFIED WITH caching_sha2_password BY 'NewStrongPassword123!';

-- Pour MariaDB, utiliser ed25519 (plus fort)
ALTER USER 'username'@'host' IDENTIFIED VIA ed25519 USING PASSWORD('StrongPassword123!');
```

---

### 3. GESTION DES PRIVILÈGES

#### 3.1 Principe du moindre privilège

**Objectif :** Vérifier que les utilisateurs ont uniquement les privilèges nécessaires

**Justification :** Des privilèges excessifs permettent à un attaquant de compromettre l'ensemble de la base après compromission d'un seul compte.

**Procédure :**
```sql
-- Lister tous les privilèges globaux
SELECT User, Host,
       Select_priv, Insert_priv, Update_priv, Delete_priv,
       Create_priv, Drop_priv, Reload_priv, Shutdown_priv,
       Process_priv, File_priv, Grant_priv, References_priv,
       Index_priv, Alter_priv, Show_db_priv, Super_priv,
       Create_tmp_table_priv, Lock_tables_priv, Execute_priv,
       Repl_slave_priv, Repl_client_priv, Create_view_priv,
       Show_view_priv, Create_routine_priv, Alter_routine_priv,
       Create_user_priv, Event_priv, Trigger_priv
FROM mysql.user
WHERE User NOT IN ('mysql.sys', 'mysql.session', 'mysql.infoschema');

-- Vérifier les privilèges au niveau base de données
SELECT * FROM mysql.db;

-- Vérifier les privilèges au niveau table
SELECT * FROM mysql.tables_priv;

-- Afficher les grants d'un utilisateur spécifique
SHOW GRANTS FOR 'username'@'host';

-- Identifier les utilisateurs avec FILE privilege (dangereux)
SELECT User, Host FROM mysql.user WHERE File_priv = 'Y';

-- Identifier les utilisateurs avec SUPER privilege
SELECT User, Host FROM mysql.user WHERE Super_priv = 'Y';
```

**Résultats attendus :**
- ✅ Comptes applicatifs avec privilèges limités (SELECT, INSERT, UPDATE, DELETE)
- ✅ FILE privilege : aucun ou comptes admin uniquement
- ✅ SUPER privilege : comptes admin uniquement (1-2 max)
- ✅ Grant_priv : comptes admin uniquement
- ✅ Privilèges accordés au niveau base/table, pas globalement

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| FILE privilege sur compte applicatif | 🔴 CRITIQUE | Lecture/écriture de fichiers système (escalade) |
| SUPER sur compte applicatif | 🔴 CRITIQUE | Contrôle total du serveur MySQL |
| ALL PRIVILEGES sur compte non-admin | 🔴 CRITIQUE | Élévation de privilèges, destruction de données |
| Grant option sur compte applicatif | 🟠 ÉLEVÉ | Propagation de privilèges |

**Recommandations :**
```sql
-- Principe : accorder uniquement les privilèges nécessaires
-- Exemple : compte applicatif lecture seule
CREATE USER 'app_ro'@'192.168.1.%' IDENTIFIED BY 'StrongPassword123!';
GRANT SELECT ON appdb.* TO 'app_ro'@'192.168.1.%';

-- Exemple : compte applicatif lecture/écriture
CREATE USER 'app_rw'@'192.168.1.%' IDENTIFIED BY 'StrongPassword123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON appdb.* TO 'app_rw'@'192.168.1.%';

-- Révoquer les privilèges dangereux
REVOKE FILE ON *.* FROM 'username'@'host';
REVOKE SUPER ON *.* FROM 'username'@'host';

-- Appliquer
FLUSH PRIVILEGES;
```

#### 3.2 Restriction par hôte

**Objectif :** Vérifier que les comptes sont restreints par adresse IP source

**Justification :** Un compte accessible depuis '%' (partout) peut être attaqué depuis n'importe quelle source, y compris Internet si le port est exposé.

**Procédure :**
```sql
-- Identifier les comptes accessibles depuis n'importe où
SELECT User, Host
FROM mysql.user
WHERE Host IN ('%', '0.0.0.0');

-- Vérifier les restrictions réseau
SELECT User, Host
FROM mysql.user
ORDER BY Host;
```

**Résultats attendus :**
- ✅ Comptes restreints à des IPs/sous-réseaux spécifiques (192.168.1.%, 10.0.0.100)
- ✅ Root accessible uniquement depuis localhost
- ❌ Éviter : comptes avec Host = '%'

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Root accessible depuis '%' | 🔴 CRITIQUE | Attaque admin depuis n'importe où |
| Comptes admin avec '%' | 🔴 CRITIQUE | Surface d'attaque maximale |
| Comptes applicatifs avec '%' | 🟡 MOYEN | Accès depuis sources non autorisées |

**Recommandations :**
```sql
-- Supprimer les entrées avec '%'
DROP USER 'username'@'%';

-- Recréer avec restriction IP
CREATE USER 'username'@'192.168.1.%' IDENTIFIED BY 'StrongPassword123!';
GRANT ... ON ... TO 'username'@'192.168.1.%';

-- S'assurer que root est localhost uniquement
DELETE FROM mysql.user WHERE User = 'root' AND Host != 'localhost';
FLUSH PRIVILEGES;
```

---

### 4. CONFIGURATION RÉSEAU ET CHIFFREMENT

#### 4.1 Binding address (bind-address)

**Objectif :** Vérifier que MySQL écoute uniquement sur les interfaces nécessaires

**Justification :** Si MySQL écoute sur 0.0.0.0, il est accessible depuis toutes les interfaces réseau, y compris Internet si le firewall n'est pas configuré.

**Procédure :**
```bash
# Vérifier la configuration
grep "bind-address" /etc/mysql/my.cnf
grep "bind-address" /etc/my.cnf
grep "bind-address" /etc/mysql/mysql.conf.d/mysqld.cnf

# Vérifier les ports en écoute
sudo netstat -tulpn | grep mysql
sudo ss -tulpn | grep mysql
```

```sql
-- Depuis MySQL
SHOW VARIABLES LIKE 'bind_address';
```

**Résultats attendus :**
- ✅ `bind-address = 127.0.0.1` (si accès local uniquement)
- ✅ `bind-address = <IP privée>` (si accès réseau interne)
- ❌ Éviter : `bind-address = 0.0.0.0` ou absence de bind-address

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| bind-address = 0.0.0.0 | 🟠 ÉLEVÉ | Exposition sur toutes les interfaces |
| Port 3306 ouvert sur Internet | 🔴 CRITIQUE | Attaques par force brute, exploitation |

**Recommandations :**
```bash
# Dans /etc/mysql/my.cnf ou /etc/my.cnf
# [mysqld]
# bind-address = 127.0.0.1        # Si accès local uniquement
# bind-address = 10.0.0.10         # Ou IP interne spécifique

# Redémarrer MySQL
sudo systemctl restart mysql
```

#### 4.2 SSL/TLS pour les connexions

**Objectif :** Vérifier que les connexions client-serveur sont chiffrées

**Justification :** Sans SSL/TLS, les données transitent en clair sur le réseau (credentials, requêtes, résultats), exposées au sniffing.

**Procédure :**
```sql
-- Vérifier si SSL est disponible
SHOW VARIABLES LIKE '%ssl%';

-- Vérifier les connexions actuelles
SHOW STATUS LIKE 'Ssl_cipher';

-- Vérifier les utilisateurs avec exigence SSL
SELECT User, Host, ssl_type, ssl_cipher, x509_issuer, x509_subject
FROM mysql.user;

-- Tester la connexion SSL
-- Depuis client MySQL :
\s
-- Chercher "SSL: Cipher in use is ..."
```

```bash
# Vérifier la présence des certificats
ls -l /etc/mysql/ssl/
ls -l /var/lib/mysql/*.pem

# Tester la connexion SSL
mysql -u root -p --ssl-mode=REQUIRED
```

**Résultats attendus :**
- ✅ `have_ssl = YES`
- ✅ Certificats SSL présents et valides
- ✅ Utilisateurs configurés avec `REQUIRE SSL` ou `REQUIRE X509`
- ✅ Connexions actives utilisent SSL (Ssl_cipher non vide)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| SSL désactivé | 🔴 CRITIQUE | Credentials et données en clair sur le réseau |
| SSL optionnel (non requis) | 🟠 ÉLEVÉ | Connexions peuvent être en clair |
| Certificats auto-signés expirés | 🟡 MOYEN | Vulnérable au man-in-the-middle |

**Recommandations :**
```bash
# Générer des certificats SSL (si absents)
sudo mysql_ssl_rsa_setup --uid=mysql

# Dans /etc/mysql/my.cnf
# [mysqld]
# require_secure_transport=ON    # Force SSL pour TOUTES les connexions
# ssl-ca=/var/lib/mysql/ca.pem
# ssl-cert=/var/lib/mysql/server-cert.pem
# ssl-key=/var/lib/mysql/server-key.pem

# Redémarrer MySQL
sudo systemctl restart mysql
```

```sql
-- Forcer SSL pour un utilisateur spécifique
ALTER USER 'username'@'host' REQUIRE SSL;

-- Ou avec certificat client
ALTER USER 'username'@'host' REQUIRE X509;

-- Appliquer
FLUSH PRIVILEGES;
```

---

### 5. AUDIT ET LOGGING

#### 5.1 Activation des logs généraux et d'erreur

**Objectif :** Vérifier que les événements importants sont tracés

**Justification :** Les logs permettent de détecter les tentatives d'intrusion, les erreurs, et de faire des investigations post-incident.

**Procédure :**
```sql
-- Vérifier les logs activés
SHOW VARIABLES LIKE 'log_error';
SHOW VARIABLES LIKE 'general_log%';
SHOW VARIABLES LIKE 'slow_query_log%';

-- Vérifier les paramètres d'audit (MySQL Enterprise ou MariaDB Audit Plugin)
SHOW PLUGINS;
SELECT PLUGIN_NAME, PLUGIN_STATUS
FROM INFORMATION_SCHEMA.PLUGINS
WHERE PLUGIN_NAME LIKE '%audit%';

SHOW VARIABLES LIKE 'audit%';
```

**Résultats attendus :**
- ✅ `log_error` activé et configuré
- ✅ `general_log` = OFF en production (très verbeux, impact performance)
- ✅ `slow_query_log` = ON (pour performance tuning)
- ✅ Plugin d'audit installé et activé (pour conformité)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de log d'erreur | 🟠 ÉLEVÉ | Pas de traçabilité des erreurs |
| Pas d'audit logging | 🔴 CRITIQUE | Pas de traçabilité des accès/modifications (conformité) |
| General log activé en prod | 🟡 MOYEN | Impact performance, logs énormes |

**Recommandations :**
```bash
# Dans /etc/mysql/my.cnf
# [mysqld]
# log_error = /var/log/mysql/error.log
# slow_query_log = 1
# slow_query_log_file = /var/log/mysql/slow.log
# long_query_time = 2

# Pour MariaDB : installer le plugin d'audit
# server_audit_logging=ON
# server_audit_events=CONNECT,QUERY_DDL,QUERY_DML
# server_audit_file_path=/var/log/mysql/audit.log
```

```sql
-- MySQL Enterprise : Activer l'audit
INSTALL PLUGIN audit_log SONAME 'audit_log.so';
SET GLOBAL audit_log_policy = 'ALL';
SET GLOBAL audit_log_format = 'JSON';
```

#### 5.2 Audit des connexions et requêtes sensibles

**Objectif :** Tracer les connexions, les échecs d'authentification, et les requêtes DDL/DML

**Justification :** Pour la détection d'intrusion et la conformité (RGPD, PCI-DSS, etc.).

**Procédure :**
```sql
-- MariaDB Audit Plugin
SHOW VARIABLES LIKE 'server_audit%';

-- Vérifier si les événements sont tracés
-- Consulter le fichier de log
```

```bash
# Vérifier les logs d'audit
sudo tail -f /var/log/mysql/audit.log

# Analyser les échecs de connexion
sudo grep "Access denied" /var/log/mysql/error.log
```

**Résultats attendus :**
- ✅ Événements CONNECT tracés
- ✅ Événements QUERY_DDL tracés (CREATE, DROP, ALTER)
- ✅ Événements QUERY_DML optionnels (INSERT, UPDATE, DELETE) selon besoins
- ✅ Échecs d'authentification tracés

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas d'audit des connexions | 🔴 CRITIQUE | Intrusions non détectées |
| Pas d'audit DDL | 🟠 ÉLEVÉ | Modifications schéma non tracées |
| Logs non centralisés | 🟡 MOYEN | Perte de logs si compromission |

**Recommandations :**
```bash
# MariaDB : activer l'audit dans my.cnf
# [mysqld]
# server_audit_logging=ON
# server_audit_events=CONNECT,QUERY_DDL,QUERY_DML_INSERT,QUERY_DML_UPDATE,QUERY_DML_DELETE
# server_audit_incl_users=app_user,admin_user
# server_audit_file_path=/var/log/mysql/audit.log
# server_audit_file_rotate_size=100000000   # 100MB

# Centraliser les logs vers un SIEM
# Configurer rsyslog ou filebeat pour envoyer les logs
```

---

### 6. SÉCURITÉ DES FICHIERS ET RÉPERTOIRES

#### 6.1 Permissions des fichiers de données

**Objectif :** Vérifier que les fichiers de données MySQL ne sont accessibles que par l'utilisateur mysql

**Justification :** Des permissions laxistes permettent à un utilisateur système de lire les fichiers de base de données directement (contournement des privilèges MySQL).

**Procédure :**
```bash
# Trouver le datadir
mysql -u root -p -e "SHOW VARIABLES LIKE 'datadir';"

# Vérifier les permissions
ls -la /var/lib/mysql/

# Vérifier le propriétaire
stat /var/lib/mysql/

# Vérifier les permissions des fichiers .ibd et .frm
find /var/lib/mysql/ -type f -ls

# Vérifier my.cnf
ls -la /etc/mysql/my.cnf
ls -la /etc/my.cnf
```

**Résultats attendus :**
- ✅ Datadir : propriétaire `mysql:mysql`, permissions `700` ou `750`
- ✅ Fichiers de données : permissions `600` ou `660`
- ✅ my.cnf : permissions `644` (lecture seule pour autres)
- ✅ Pas de fichiers world-readable

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Datadir accessible en lecture | 🔴 CRITIQUE | Extraction directe des données, dump des hash |
| Datadir accessible en écriture | 🔴 CRITIQUE | Corruption ou modification de données |
| my.cnf avec password en clair | 🟠 ÉLEVÉ | Credentials exposés |

**Recommandations :**
```bash
# Corriger les permissions du datadir
sudo chown -R mysql:mysql /var/lib/mysql/
sudo chmod 700 /var/lib/mysql/

# Corriger les permissions des fichiers
sudo find /var/lib/mysql/ -type f -exec chmod 600 {} \;

# my.cnf
sudo chmod 644 /etc/mysql/my.cnf
sudo chown root:root /etc/mysql/my.cnf

# Ne JAMAIS stocker de password en clair dans my.cnf
# Utiliser mysql_config_editor pour stocker les credentials de manière sécurisée
mysql_config_editor set --login-path=client --host=localhost --user=root --password
```

#### 6.2 Désactivation de LOAD DATA LOCAL INFILE

**Objectif :** Vérifier que LOAD DATA LOCAL INFILE est désactivé

**Justification :** Cette fonctionnalité permet de lire des fichiers depuis le client, ce qui peut être exploité pour exfiltrer des données du serveur (CVE-2019-3824 et autres).

**Procédure :**
```sql
-- Vérifier le paramètre
SHOW VARIABLES LIKE 'local_infile';
```

**Résultats attendus :**
- ✅ `local_infile = OFF`

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| local_infile = ON | 🔴 CRITIQUE | Lecture de fichiers arbitraires (SSRF local) |

**Recommandations :**
```bash
# Dans my.cnf
# [mysqld]
# local-infile=0

# Redémarrer
sudo systemctl restart mysql
```

```sql
-- Ou dynamiquement (non persistant)
SET GLOBAL local_infile = 0;
```

---

### 7. BASES DE DONNÉES ET SCHÉMAS DE TEST

#### 7.1 Suppression de la base 'test'

**Objectif :** Vérifier que la base de données 'test' par défaut est supprimée

**Justification :** La base 'test' est accessible à tous les utilisateurs par défaut, même anonymes dans anciennes versions.

**Procédure :**
```sql
-- Lister toutes les bases
SHOW DATABASES;

-- Vérifier la présence de 'test'
SELECT SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
WHERE SCHEMA_NAME = 'test';
```

**Résultats attendus :**
- ✅ Base 'test' absente
- ✅ Bases système uniquement : mysql, information_schema, performance_schema, sys

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Base 'test' présente | 🟡 MOYEN | Espace de test accessible, risque de fuite |

**Recommandations :**
```sql
-- Supprimer la base test
DROP DATABASE IF EXISTS test;

-- Supprimer les privilèges associés
DELETE FROM mysql.db WHERE Db LIKE 'test%';
FLUSH PRIVILEGES;
```

---

### 8. CONFIGURATION AVANCÉE

#### 8.1 Désactivation de symbolic links

**Objectif :** Vérifier que les liens symboliques sont désactivés

**Justification :** Les symlinks peuvent être utilisés pour rediriger MySQL vers des fichiers système arbitraires.

**Procédure :**
```sql
SHOW VARIABLES LIKE 'have_symlink';
```

**Résultats attendus :**
- ✅ `have_symlink = DISABLED` ou `NO`

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Symlinks activés | 🟠 ÉLEVÉ | Accès à des fichiers système via symlinks |

**Recommandations :**
```bash
# Dans my.cnf
# [mysqld]
# skip-symbolic-links=1

# Redémarrer
sudo systemctl restart mysql
```

#### 8.2 Historique des commandes

**Objectif :** Vérifier que l'historique MySQL n'expose pas de credentials

**Justification :** Le fichier ~/.mysql_history peut contenir des mots de passe tapés en clair dans des requêtes.

**Procédure :**
```bash
# Vérifier le fichier historique
cat ~/.mysql_history | grep -i password
cat /root/.mysql_history | grep -i password

# Vérifier les permissions
ls -la ~/.mysql_history
```

**Résultats attendus :**
- ✅ Pas de passwords en clair dans l'historique
- ✅ Fichier historique désactivé ou sécurisé

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Passwords dans historique | 🟠 ÉLEVÉ | Credentials exposés en clair |
| Historique world-readable | 🟠 ÉLEVÉ | Exposition de commandes sensibles |

**Recommandations :**
```bash
# Désactiver l'historique
ln -s /dev/null ~/.mysql_history
ln -s /dev/null /root/.mysql_history

# Ou sécuriser
chmod 600 ~/.mysql_history

# Nettoyer l'historique existant
cat /dev/null > ~/.mysql_history
```

---

## 📊 Matrice de Criticité Globale

| Niveau | Délai de correction | Exemples |
|--------|---------------------|----------|
| 🔴 CRITIQUE | 24-48h | Comptes sans mot de passe, FILE privilege, SSL désactivé, Version EOL |
| 🟠 ÉLEVÉ | 1 semaine | Privilèges excessifs, bind-address 0.0.0.0, pas d'audit |
| 🟡 MOYEN | 1 mois | Base test présente, optimisations, durcissement avancé |
| 🟢 FAIBLE | Opportunité | Améliorations mineures |

---

## ✅ Checklist Finale d'Audit

### Version et installation
- [ ] Version MySQL/MariaDB supportée et à jour
- [ ] Pas de version End-of-Life

### Comptes et authentification
- [ ] Pas de comptes anonymes
- [ ] Pas de comptes sans mot de passe
- [ ] Politique de mot de passe robuste (14+ caractères)
- [ ] Plugin de validation de mot de passe installé
- [ ] Méthode d'authentification moderne (caching_sha2_password)

### Privilèges
- [ ] Principe du moindre privilège appliqué
- [ ] FILE privilege : admin uniquement
- [ ] SUPER privilege : admin uniquement
- [ ] Pas de comptes avec '%' comme host
- [ ] Root accessible depuis localhost uniquement

### Réseau et chiffrement
- [ ] bind-address configuré (pas 0.0.0.0)
- [ ] SSL/TLS activé et requis
- [ ] Port 3306 non exposé sur Internet

### Audit et logging
- [ ] Log d'erreur activé
- [ ] Plugin d'audit installé et configuré
- [ ] Événements CONNECT et DDL tracés
- [ ] Logs protégés et centralisés

### Sécurité des fichiers
- [ ] Permissions datadir : 700
- [ ] Permissions fichiers : 600
- [ ] local_infile désactivé
- [ ] Symbolic links désactivés

### Bases de données
- [ ] Base 'test' supprimée
- [ ] Historique MySQL sécurisé

---

## 📚 Références

### Documentation officielle
- [MySQL 8.0 Security Guide](https://dev.mysql.com/doc/refman/8.0/en/security.html)
- [MariaDB Security](https://mariadb.com/kb/en/securing-mariadb/)
- [MySQL Security Best Practices](https://dev.mysql.com/doc/mysql-security-excerpt/8.0/en/)

### Standards de sécurité
- [CIS Benchmark for Oracle MySQL](https://www.cisecurity.org/benchmark/oracle_mysql)
- [CIS Benchmark for MariaDB](https://www.cisecurity.org/benchmark/mariadb)
- [OWASP Database Security](https://owasp.org/www-community/vulnerabilities/)

### Outils d'audit
- [MySQL Enterprise Audit](https://dev.mysql.com/doc/refman/8.0/en/audit-log.html)
- [MariaDB Audit Plugin](https://mariadb.com/kb/en/mariadb-audit-plugin/)
- [Percona Toolkit](https://www.percona.com/software/database-tools/percona-toolkit)

### CVE et vulnérabilités
- [MySQL Security Advisories](https://www.mysql.com/support/security/)
- [MariaDB Security Announcements](https://mariadb.org/category/security-announcements/)
- [CVE Database](https://cve.mitre.org/)

---

**Note :** Ce guide doit être adapté à votre environnement spécifique. Testez toutes les modifications dans un environnement de développement avant de les appliquer en production.
