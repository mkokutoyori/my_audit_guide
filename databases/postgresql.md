# Guide d'Audit Technique - PostgreSQL

## 📋 Vue d'ensemble

Ce guide permet d'effectuer un audit de sécurité complet d'un serveur PostgreSQL. Il est basé sur les standards :
- **PostgreSQL Security Best Practices**
- **OWASP Database Security Guidelines**
- **NIST Database Security**
- **Recommandations de la communauté PostgreSQL**

### Version du guide
- **Dernière mise à jour** : Janvier 2025
- **Versions couvertes** : PostgreSQL 13, 14, 15, 16
- **Type d'audit** : Sécurité et conformité

---

## 🎯 Objectifs de l'audit

- Évaluer la sécurité de l'instance PostgreSQL
- Vérifier les méthodes d'authentification (pg_hba.conf)
- Auditer les rôles et privilèges
- Contrôler le chiffrement des connexions
- Assurer la traçabilité via les logs

---

## 📚 Prérequis

### Connaissances requises
- SQL et PostgreSQL de base
- Administration système Linux
- Compréhension de pg_hba.conf

### Accès nécessaire
- Compte superuser PostgreSQL (postgres)
- Accès SSH au serveur
- Accès aux fichiers de configuration

### Outils recommandés
```bash
# Client PostgreSQL
sudo apt install postgresql-client

# Outils d'audit
sudo apt install pgaudit
```

---

## 🔍 Points de Contrôle d'Audit

### 1. VERSION ET INSTALLATION

#### 1.1 Version de PostgreSQL

**Objectif :** Vérifier que la version est supportée

**Justification :** Les versions anciennes contiennent des vulnérabilités non corrigées.

**Procédure :**
```sql
-- Se connecter
sudo -u postgres psql

-- Vérifier la version
SELECT version();
SHOW server_version;
```

```bash
# Depuis le système
psql --version
postgres --version
```

**Résultats attendus :**
- ✅ PostgreSQL 13+ (versions avec support actif)
- ✅ Dernière version mineure installée (ex: 16.1, pas 16.0)

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| PostgreSQL < 11 | 🔴 CRITIQUE | Fin de support, vulnérabilités non corrigées |
| Version mineure obsolète | 🟡 MOYEN | Patches de sécurité manquants |

**Recommandations :**
- Planifier migration vers PostgreSQL 15 ou 16
- Appliquer les mises à jour mineures régulièrement

---

### 2. AUTHENTIFICATION (pg_hba.conf)

#### 2.1 Méthodes d'authentification

**Objectif :** Vérifier que des méthodes d'authentification robustes sont utilisées

**Justification :** La méthode 'trust' n'exige AUCUNE authentification. 'password' envoie le mot de passe en clair. Seules scram-sha-256 ou md5 (moins bon) doivent être utilisées.

**Procédure :**
```bash
# Localiser pg_hba.conf
sudo -u postgres psql -c "SHOW hba_file;"

# Examiner le fichier
sudo cat /etc/postgresql/*/main/pg_hba.conf

# Vérifier les lignes actives (sans #)
sudo grep -v "^#" /etc/postgresql/*/main/pg_hba.conf | grep -v "^$"
```

**Résultats attendus :**
- ✅ Méthode **scram-sha-256** (PostgreSQL 10+)
- ✅ **md5** acceptable si scram non supporté
- ❌ **JAMAIS** : trust, password (clair)
- ✅ Connexions locales : peer ou scram-sha-256
- ✅ Connexions réseau : scram-sha-256 avec restriction IP

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| trust utilisé | 🔴 CRITIQUE | Aucune authentification requise |
| password (clair) | 🔴 CRITIQUE | Credentials interceptables |
| md5 sans restriction IP | 🟠 ÉLEVÉ | Attaques par force brute |
| host all all 0.0.0.0/0 | 🔴 CRITIQUE | Accessible depuis partout |

**Recommandations :**
```bash
# Exemple de pg_hba.conf sécurisé
# /etc/postgresql/*/main/pg_hba.conf

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# Connexions locales (via socket Unix)
local   all             postgres                                peer
local   all             all                                     scram-sha-256

# Connexions IPv4 locales
host    all             all             127.0.0.1/32            scram-sha-256

# Connexions depuis le réseau interne uniquement
host    all             app_user        192.168.1.0/24          scram-sha-256
host    all             backup_user     10.0.0.5/32             scram-sha-256

# IPv6 local uniquement
host    all             all             ::1/128                 scram-sha-256

# REFUSER tout le reste (optionnel, implicite)
host    all             all             0.0.0.0/0               reject
host    all             all             ::/0                    reject

# Recharger la configuration
sudo systemctl reload postgresql
```

```sql
-- Migrer les utilisateurs vers scram-sha-256
SET password_encryption = 'scram-sha-256';
ALTER USER username PASSWORD 'NewStrongPassword123!';

-- Vérifier
SELECT usename, valuntil
FROM pg_user
WHERE usename NOT IN ('postgres');
```

---

### 3. GESTION DES RÔLES ET PRIVILÈGES

#### 3.1 Inventaire des rôles

**Objectif :** Lister tous les rôles et identifier les superusers

**Justification :** Les superusers contournent toutes les vérifications de sécurité. Leur nombre doit être minimal.

**Procédure :**
```sql
-- Lister tous les rôles
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolcanlogin
FROM pg_roles
ORDER BY rolsuper DESC, rolname;

-- Identifier les superusers
SELECT rolname
FROM pg_roles
WHERE rolsuper = true;

-- Vérifier les rôles avec privilèges dangereux
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolreplication
FROM pg_roles
WHERE rolcreaterole = true OR rolcreatedb = true OR rolreplication = true;

-- Rôles pouvant se connecter
SELECT rolname, rolcanlogin, rolconnlimit
FROM pg_roles
WHERE rolcanlogin = true;
```

**Résultats attendus :**
- ✅ 1-2 superusers maximum (postgres + backup)
- ✅ Rôles applicatifs sans privilèges super/createrole
- ✅ Pas de rôles inutilisés

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Rôles applicatifs superuser | 🔴 CRITIQUE | Contournement de toute sécurité |
| Rôles avec createrole | 🟠 ÉLEVÉ | Élévation de privilèges possible |
| Rôles sans limite de connexions | 🟡 MOYEN | DoS par épuisement de connexions |

**Recommandations :**
```sql
-- Créer des rôles avec privilèges minimaux
CREATE ROLE app_reader WITH LOGIN PASSWORD 'StrongPassword123!';
GRANT CONNECT ON DATABASE appdb TO app_reader;
GRANT USAGE ON SCHEMA public TO app_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO app_reader;

-- Rôle avec lecture/écriture
CREATE ROLE app_writer WITH LOGIN PASSWORD 'StrongPassword123!' CONNECTION LIMIT 10;
GRANT CONNECT ON DATABASE appdb TO app_writer;
GRANT USAGE ON SCHEMA public TO app_writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_writer;

-- Révoquer les privilèges superuser inutiles
ALTER ROLE some_user NOSUPERUSER;
ALTER ROLE some_user NOCREATEROLE;
```

#### 3.2 Principe du moindre privilège

**Objectif :** Vérifier que les privilèges sont accordés de manière granulaire

**Justification :** Des privilèges excessifs augmentent l'impact d'une compromission.

**Procédure :**
```sql
-- Vérifier les privilèges sur les bases
SELECT datname, datacl
FROM pg_database
WHERE datname NOT IN ('template0', 'template1');

-- Vérifier les privilèges sur les schémas
SELECT nspname, nspacl
FROM pg_namespace
WHERE nspname NOT LIKE 'pg_%' AND nspname != 'information_schema';

-- Vérifier les privilèges sur les tables
SELECT schemaname, tablename, tableowner,
       has_table_privilege('public', schemaname||'.'||tablename, 'SELECT') as public_select
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');

-- Vérifier les membres des rôles
SELECT r.rolname as role, m.rolname as member
FROM pg_roles r
JOIN pg_auth_members am ON r.oid = am.roleid
JOIN pg_roles m ON am.member = m.oid
ORDER BY r.rolname;
```

**Résultats attendus :**
- ✅ Privilèges PUBLIC révoqués sur schémas sensibles
- ✅ Privilèges accordés à des rôles, pas directement aux utilisateurs
- ✅ Pas de GRANT ALL inutiles

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| PUBLIC peut se connecter partout | 🟠 ÉLEVÉ | Accès non restreint |
| GRANT ALL sur base production | 🔴 CRITIQUE | Destruction de données possible |

**Recommandations :**
```sql
-- Révoquer les privilèges PUBLIC par défaut
REVOKE ALL ON DATABASE appdb FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- Accorder uniquement ce qui est nécessaire
GRANT CONNECT ON DATABASE appdb TO app_role;
GRANT USAGE ON SCHEMA public TO app_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON specific_table TO app_role;

-- Utiliser des rôles groupes
CREATE ROLE readers;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readers;
GRANT readers TO user1, user2;
```

---

### 4. CONFIGURATION RÉSEAU

#### 4.1 Listen addresses

**Objectif :** Vérifier que PostgreSQL écoute sur les interfaces appropriées

**Justification :** Écouter sur * ou 0.0.0.0 expose PostgreSQL sur toutes les interfaces.

**Procédure :**
```sql
-- Vérifier listen_addresses
SHOW listen_addresses;

-- Vérifier le port
SHOW port;
```

```bash
# Vérifier depuis le système
sudo netstat -tulpn | grep postgres
sudo ss -tulpn | grep postgres

# Vérifier postgresql.conf
sudo grep "listen_addresses" /etc/postgresql/*/main/postgresql.conf
```

**Résultats attendus :**
- ✅ `listen_addresses = 'localhost'` (accès local uniquement)
- ✅ `listen_addresses = '10.0.0.5'` (IP interne spécifique)
- ❌ Éviter : `listen_addresses = '*'` sans firewall

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| listen_addresses = '*' | 🟠 ÉLEVÉ | Exposition sur toutes interfaces |
| Port 5432 ouvert sur Internet | 🔴 CRITIQUE | Attaques par force brute |

**Recommandations :**
```bash
# Dans postgresql.conf
listen_addresses = 'localhost,10.0.0.5'  # Interfaces spécifiques
port = 5432

# Ou pour accès local uniquement
listen_addresses = 'localhost'

# Redémarrer
sudo systemctl restart postgresql
```

#### 4.2 SSL/TLS

**Objectif :** Vérifier que les connexions sont chiffrées

**Justification :** Sans SSL, credentials et données transitent en clair.

**Procédure :**
```sql
-- Vérifier si SSL est activé
SHOW ssl;

-- Vérifier les certificats
SHOW ssl_cert_file;
SHOW ssl_key_file;
SHOW ssl_ca_file;

-- Vérifier les connexions actuelles
SELECT datname, usename, client_addr, ssl, version
FROM pg_stat_ssl
JOIN pg_stat_activity USING (pid);
```

```bash
# Vérifier les certificats sur le système
ls -l /etc/postgresql/*/main/server.crt
ls -l /etc/postgresql/*/main/server.key

# Tester la connexion SSL
psql "host=localhost dbname=postgres sslmode=require user=postgres"
```

**Résultats attendus :**
- ✅ `ssl = on`
- ✅ Certificats présents et valides
- ✅ Connexions utilisent SSL (colonne ssl = t)
- ✅ pg_hba.conf exige SSL : `hostssl` au lieu de `host`

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| SSL désactivé | 🔴 CRITIQUE | Credentials en clair |
| SSL optionnel (host au lieu de hostssl) | 🟠 ÉLEVÉ | Connexions peuvent être non chiffrées |
| Certificats auto-signés expirés | 🟡 MOYEN | MITM possible |

**Recommandations :**
```bash
# Générer des certificats SSL
sudo openssl req -new -x509 -days 365 -nodes -text -out /etc/postgresql/*/main/server.crt -keyout /etc/postgresql/*/main/server.key -subj "/CN=dbserver.example.com"
sudo chmod 600 /etc/postgresql/*/main/server.key
sudo chown postgres:postgres /etc/postgresql/*/main/server.*

# Dans postgresql.conf
ssl = on
ssl_cert_file = '/etc/postgresql/*/main/server.crt'
ssl_key_file = '/etc/postgresql/*/main/server.key'

# Dans pg_hba.conf : remplacer 'host' par 'hostssl'
hostssl    all    all    192.168.1.0/24    scram-sha-256

# Redémarrer
sudo systemctl restart postgresql
```

```sql
-- Forcer SSL pour un utilisateur
ALTER USER username SET ssl = on;
```

---

### 5. AUDIT ET LOGGING

#### 5.1 Configuration des logs

**Objectif :** Vérifier que les événements critiques sont tracés

**Justification :** Les logs permettent la détection d'intrusion et l'investigation.

**Procédure :**
```sql
-- Vérifier la configuration des logs
SHOW logging_collector;
SHOW log_directory;
SHOW log_filename;
SHOW log_connections;
SHOW log_disconnections;
SHOW log_duration;
SHOW log_statement;
SHOW log_line_prefix;
```

```bash
# Consulter les logs
sudo tail -f /var/log/postgresql/postgresql-*.log
```

**Résultats attendus :**
```
logging_collector = on
log_connections = on
log_disconnections = on
log_duration = off (sauf pour debug)
log_statement = 'ddl' ou 'mod' (DDL et DML)
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| log_connections = off | 🟠 ÉLEVÉ | Connexions non tracées |
| log_statement = 'none' | 🔴 CRITIQUE | Aucune requête tracée |
| Logs non protégés | 🟡 MOYEN | Modification de logs |

**Recommandations :**
```bash
# Dans postgresql.conf
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_connections = on
log_disconnections = on
log_duration = off
log_statement = 'ddl'    # ou 'mod' pour DDL+DML, ou 'all' si conformité stricte
log_line_prefix = '%m [%p] %q%u@%d '
log_rotation_age = 1d
log_rotation_size = 100MB

# Redémarrer
sudo systemctl restart postgresql

# Protéger les logs
sudo chmod 640 /var/log/postgresql/*.log
sudo chown postgres:postgres /var/log/postgresql/
```

#### 5.2 Extension pgAudit

**Objectif :** Activer un audit détaillé avec pgAudit

**Justification :** pgAudit fournit un audit granulaire pour la conformité (RGPD, PCI-DSS).

**Procédure :**
```sql
-- Vérifier si pgAudit est installé
SELECT * FROM pg_available_extensions WHERE name = 'pgaudit';

-- Vérifier si activé
SELECT * FROM pg_extension WHERE extname = 'pgaudit';

-- Vérifier la configuration
SHOW pgaudit.log;
SHOW shared_preload_libraries;
```

**Résultats attendus :**
- ✅ pgAudit installé et activé
- ✅ pgaudit.log = 'ddl, write, role'
- ✅ shared_preload_libraries contient 'pgaudit'

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| pgAudit non installé | 🟠 ÉLEVÉ | Audit limité, non-conformité |
| Audit insuffisant | 🟡 MOYEN | Événements critiques non tracés |

**Recommandations :**
```bash
# Installer pgAudit
sudo apt install postgresql-*-pgaudit

# Dans postgresql.conf
shared_preload_libraries = 'pgaudit'
pgaudit.log = 'ddl, write, role'   # DDL, DML, changements de rôles
pgaudit.log_catalog = off          # Ne pas auditer les tables système
pgaudit.log_parameter = on         # Inclure les paramètres des requêtes

# Redémarrer (nécessaire pour shared_preload_libraries)
sudo systemctl restart postgresql
```

```sql
-- Activer l'extension dans la base
CREATE EXTENSION pgaudit;

-- Vérifier
SHOW pgaudit.log;
```

---

### 6. SÉCURITÉ DES FICHIERS ET DONNÉES

#### 6.1 Permissions des fichiers

**Objectif :** Vérifier que les fichiers PostgreSQL sont protégés

**Justification :** Des permissions laxistes permettent la lecture directe des données.

**Procédure :**
```bash
# Trouver le data directory
sudo -u postgres psql -c "SHOW data_directory;"

# Vérifier les permissions
ls -la /var/lib/postgresql/*/main/

# Vérifier postgresql.conf
ls -la /etc/postgresql/*/main/postgresql.conf
ls -la /etc/postgresql/*/main/pg_hba.conf
```

**Résultats attendus :**
- ✅ data_directory : propriétaire postgres:postgres, permissions 700
- ✅ Fichiers de config : permissions 640
- ✅ Pas de fichiers world-readable

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Data directory accessible | 🔴 CRITIQUE | Extraction directe des données |
| pg_hba.conf world-readable | 🟠 ÉLEVÉ | Exposition de la configuration |

**Recommandations :**
```bash
# Corriger les permissions
sudo chmod 700 /var/lib/postgresql/*/main/
sudo chown -R postgres:postgres /var/lib/postgresql/
sudo chmod 640 /etc/postgresql/*/main/postgresql.conf
sudo chmod 640 /etc/postgresql/*/main/pg_hba.conf
```

#### 6.2 Chiffrement des données au repos

**Objectif :** Vérifier si le chiffrement des données au repos est activé

**Justification :** Protège contre le vol physique des disques.

**Procédure :**
```bash
# PostgreSQL ne chiffre pas nativement au repos
# Vérifier si le système de fichiers est chiffré (LUKS, dm-crypt)
lsblk
sudo dmsetup status

# Ou vérifier les extensions de chiffrement
# pg_crypto pour chiffrement au niveau colonne
```

```sql
-- Vérifier pg_crypto
SELECT * FROM pg_available_extensions WHERE name = 'pgcrypto';
```

**Résultats attendus :**
- ✅ Système de fichiers chiffré (LUKS/dm-crypt) OU
- ✅ Extension pgcrypto pour chiffrement au niveau colonne

**Risques identifiés :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de chiffrement au repos | 🟡 MOYEN | Vol de disques = données en clair |

**Recommandations :**
- Utiliser LUKS/dm-crypt pour chiffrer le système de fichiers
- Utiliser pgcrypto pour chiffrer des colonnes sensibles

```sql
-- Exemple pgcrypto
CREATE EXTENSION pgcrypto;

-- Chiffrer une colonne
UPDATE users SET password = crypt('password', gen_salt('bf', 8));

-- Vérifier le mot de passe
SELECT (password = crypt('user_input', password)) AS password_match FROM users WHERE username = 'user';
```

---

### 7. CONFIGURATION AVANCÉE

#### 7.1 Limitations de ressources

**Objectif :** Vérifier les limites de connexions et mémoire

**Justification :** Protège contre le DoS par épuisement de ressources.

**Procédure :**
```sql
SHOW max_connections;
SHOW shared_buffers;
SHOW work_mem;
SHOW maintenance_work_mem;
```

**Résultats attendus :**
- ✅ max_connections : valeur raisonnable (100-300 selon charge)
- ✅ Limites par rôle définies

**Recommandations :**
```sql
-- Définir des limites par rôle
ALTER ROLE app_user CONNECTION LIMIT 20;
ALTER ROLE readonly_user CONNECTION LIMIT 5;
```

#### 7.2 Extensions installées

**Objectif :** Inventorier les extensions et désactiver celles non utilisées

**Justification :** Chaque extension augmente la surface d'attaque.

**Procédure :**
```sql
-- Lister les extensions installées
SELECT * FROM pg_extension;

-- Lister les extensions disponibles
SELECT name FROM pg_available_extensions ORDER BY name;
```

**Résultats attendus :**
- ✅ Seules les extensions nécessaires sont installées
- ✅ plpgsql, pgcrypto, pgaudit justifiées

**Recommandations :**
```sql
-- Supprimer les extensions inutiles
DROP EXTENSION IF EXISTS extension_name;
```

---

## ✅ Checklist Finale

### Version
- [ ] PostgreSQL version supportée (13+)
- [ ] Dernière version mineure installée

### Authentification
- [ ] pg_hba.conf : scram-sha-256 utilisé
- [ ] Pas de méthode 'trust' ou 'password'
- [ ] Restrictions IP configurées

### Rôles et privilèges
- [ ] 1-2 superusers maximum
- [ ] Rôles applicatifs sans SUPERUSER
- [ ] Privilèges PUBLIC révoqués
- [ ] Principe du moindre privilège appliqué

### Réseau
- [ ] listen_addresses configuré (pas '*')
- [ ] SSL activé (ssl = on)
- [ ] pg_hba.conf utilise hostssl
- [ ] Port 5432 non exposé sur Internet

### Audit et logging
- [ ] log_connections = on
- [ ] log_statement = ddl ou mod
- [ ] pgAudit installé et configuré
- [ ] Logs protégés (640)

### Fichiers
- [ ] data_directory : permissions 700
- [ ] Fichiers config : permissions 640
- [ ] Chiffrement au repos (LUKS ou pgcrypto)

---

## 📚 Références

- [PostgreSQL Security Documentation](https://www.postgresql.org/docs/current/security.html)
- [PostgreSQL pg_hba.conf](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html)
- [pgAudit Extension](https://github.com/pgaudit/pgaudit)
- [OWASP Database Security](https://owasp.org/www-community/vulnerabilities/)
- [Ubuntu PostgreSQL Security](https://ubuntu.com/engage/postgresql-security-best-practices)

---

**Note :** Testez toutes les modifications dans un environnement de développement avant production.
