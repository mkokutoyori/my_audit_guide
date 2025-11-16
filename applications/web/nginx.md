# Guide d'Audit Technique - Nginx

## 📋 Vue d'ensemble

Ce guide permet d'effectuer un audit de sécurité d'un serveur web Nginx. Basé sur :
- **Nginx Security Best Practices**
- **OWASP Web Server Security**
- **CIS Web Server Hardening**

### Version du guide
- **Dernière mise à jour** : Janvier 2025
- **Versions couvertes** : Nginx 1.20+
- **Type d'audit** : Sécurité et conformité

---

## 🎯 Objectifs

- Auditer la configuration de sécurité Nginx
- Vérifier le durcissement du serveur
- Contrôler la configuration SSL/TLS
- Valider les headers de sécurité
- Vérifier les logs et monitoring

---

## 📚 Prérequis

### Accès nécessaire
- Accès SSH au serveur
- Privilèges sudo
- Accès aux fichiers de configuration Nginx

---

## 🔍 Points de Contrôle

### 1. VERSION ET INSTALLATION

#### 1.1 Version de Nginx

**Objectif :** Vérifier que Nginx est à jour

**Procédure :**
```bash
# Vérifier la version
nginx -v
nginx -V  # version détaillée avec modules

# Vérifier les mises à jour disponibles
sudo apt update
sudo apt list --upgradable | grep nginx
```

**Résultats attendus :**
- ✅ Nginx 1.20+ (version stable récente)
- ✅ Pas de version avec CVE connues
- ✅ Modules de sécurité installés (headers-more, naxsi optionnel)

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Nginx < 1.18 | 🔴 CRITIQUE | Vulnérabilités connues (CVE) |
| Version avec CVE actives | 🔴 CRITIQUE | Exploitation possible |

**Recommandations :**
```bash
# Mettre à jour Nginx
sudo apt update
sudo apt upgrade nginx
```

---

### 2. CONFIGURATION DE BASE

#### 2.1 Utilisateur Nginx

**Objectif :** Vérifier que Nginx s'exécute avec un utilisateur dédié non privilégié

**Procédure :**
```bash
# Vérifier l'utilisateur dans la config
grep "user" /etc/nginx/nginx.conf

# Vérifier le processus
ps aux | grep nginx
```

**Résultats attendus :**
- ✅ `user www-data;` (ou nginx, pas root)
- ✅ Processus worker en tant que www-data

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| user root | 🔴 CRITIQUE | Élévation de privilèges en cas d'exploit |

**Recommandations :**
```nginx
# Dans /etc/nginx/nginx.conf
user www-data;
```

#### 2.2 Masquage de la version

**Objectif :** Cacher la version Nginx dans les headers

**Justification :** La version expose des informations aux attaquants pour cibler des exploits spécifiques.

**Procédure :**
```bash
# Vérifier la configuration
grep "server_tokens" /etc/nginx/nginx.conf

# Tester avec curl
curl -I http://localhost | grep Server
```

**Résultats attendus :**
- ✅ `server_tokens off;`
- ✅ Header "Server: nginx" (sans version)

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| server_tokens on | 🟡 MOYEN | Exposition de version, fingerprinting |

**Recommandations :**
```nginx
# Dans /etc/nginx/nginx.conf (section http)
http {
    server_tokens off;
    ...
}
```

---

### 3. SSL/TLS

#### 3.1 Configuration SSL/TLS

**Objectif :** Vérifier que SSL/TLS est correctement configuré

**Procédure :**
```bash
# Vérifier la config SSL
grep -r "ssl_protocols" /etc/nginx/
grep -r "ssl_ciphers" /etc/nginx/

# Tester avec SSL Labs
# https://www.ssllabs.com/ssltest/
```

**Résultats attendus :**
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305';
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_stapling on;
ssl_stapling_verify on;
```

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| TLS 1.0/1.1 activé | 🔴 CRITIQUE | Protocoles obsolètes et vulnérables |
| Ciphers faibles (3DES, RC4) | 🔴 CRITIQUE | Chiffrement cassable |
| Pas de HSTS | 🟠 ÉLEVÉ | Downgrade attacks, MITM |
| Certificat expiré | 🔴 CRITIQUE | Avertissements navigateur, MITM |

**Recommandations :**
```nginx
# Configuration SSL moderne (A+ sur SSL Labs)
server {
    listen 443 ssl http2;
    server_name example.com;

    # Certificats
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # Protocoles et ciphers modernes
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';

    # Session cache
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;

    # DH parameters
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
}

# Redirection HTTP vers HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

```bash
# Générer DH parameters
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 4096
```

---

### 4. HEADERS DE SÉCURITÉ

#### 4.1 Headers HTTP de sécurité

**Objectif :** Vérifier que les headers de sécurité sont présents

**Procédure :**
```bash
# Tester les headers
curl -I https://example.com

# Vérifier la configuration
grep "add_header" /etc/nginx/sites-available/*
```

**Résultats attendus :**
```
Strict-Transport-Security: max-age=63072000
X-Frame-Options: DENY ou SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

**Risques :**
| Header manquant | Criticité | Risque |
|-----------------|-----------|---------|
| HSTS | 🟠 ÉLEVÉ | Downgrade attacks |
| X-Frame-Options | 🟠 ÉLEVÉ | Clickjacking |
| CSP | 🟠 ÉLEVÉ | XSS attacks |
| X-Content-Type-Options | 🟡 MOYEN | MIME type sniffing |

**Recommandations :**
```nginx
server {
    # HSTS
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # Clickjacking protection
    add_header X-Frame-Options "SAMEORIGIN" always;

    # MIME type sniffing protection
    add_header X-Content-Type-Options "nosniff" always;

    # XSS Protection
    add_header X-XSS-Protection "1; mode=block" always;

    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;

    # Referrer Policy
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Permissions Policy
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
}
```

---

### 5. PROTECTION CONTRE LES ATTAQUES

#### 5.1 Rate Limiting

**Objectif :** Protéger contre les attaques par force brute et DoS

**Procédure :**
```bash
grep -r "limit_req" /etc/nginx/
```

**Résultats attendus :**
- ✅ Rate limiting configuré
- ✅ Zones définies pour différents endpoints

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de rate limiting | 🟠 ÉLEVÉ | DoS, brute force |

**Recommandations :**
```nginx
# Dans http block
http {
    # Définir une zone de rate limiting
    limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;

    # Limiter la taille des buffers
    client_body_buffer_size 1K;
    client_header_buffer_size 1k;
    client_max_body_size 1m;
    large_client_header_buffers 2 1k;
}

# Dans server block
server {
    # Rate limiting général
    location / {
        limit_req zone=general burst=20 nodelay;
    }

    # Rate limiting strict pour login
    location /login {
        limit_req zone=login burst=3;
    }
}
```

#### 5.2 Restriction d'accès

**Objectif :** Restreindre l'accès aux pages sensibles

**Procédure :**
```bash
grep -r "allow\|deny" /etc/nginx/
```

**Résultats attendus :**
- ✅ Pages admin restreintes par IP
- ✅ Fichiers sensibles (.git, .env) bloqués

**Recommandations :**
```nginx
# Bloquer l'accès aux fichiers sensibles
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}

location ~ \.(git|env|htaccess|htpasswd)$ {
    deny all;
}

# Restreindre admin par IP
location /admin {
    allow 192.168.1.0/24;
    deny all;
}
```

---

### 6. LOGGING ET MONITORING

#### 6.1 Configuration des logs

**Objectif :** Vérifier que les logs sont correctement configurés

**Procédure :**
```bash
# Vérifier les logs
grep "access_log\|error_log" /etc/nginx/nginx.conf

# Consulter les logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

**Résultats attendus :**
- ✅ Access log activé avec format détaillé
- ✅ Error log avec niveau approprié (warn ou error)
- ✅ Logs rotatés régulièrement
- ✅ Logs protégés (permissions 640)

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Logs désactivés | 🔴 CRITIQUE | Pas de traçabilité |
| Logs world-readable | 🟡 MOYEN | Exposition d'informations |
| Pas de rotation | 🟡 MOYEN | Disque plein |

**Recommandations :**
```nginx
# Format de log personnalisé
http {
    log_format custom '$remote_addr - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent" '
                      '$request_time $upstream_response_time';

    access_log /var/log/nginx/access.log custom;
    error_log /var/log/nginx/error.log warn;
}
```

```bash
# Permissions des logs
sudo chmod 640 /var/log/nginx/*.log
sudo chown www-data:adm /var/log/nginx/*.log

# Rotation (logrotate)
# /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
    endscript
}
```

---

### 7. MODULES ET FONCTIONNALITÉS

#### 7.1 Modules inutiles

**Objectif :** Désactiver les modules non utilisés

**Procédure :**
```bash
# Lister les modules compilés
nginx -V 2>&1 | grep -o 'with-[^ ]*'
```

**Résultats attendus :**
- ✅ Modules inutiles désactivés ou non compilés
- ❌ Éviter : autoindex, ssi (si non utilisés)

**Recommandations :**
```nginx
# Désactiver autoindex (directory listing)
autoindex off;

# Désactiver SSI si non utilisé
ssi off;
```

---

## ✅ Checklist Finale

### Version
- [ ] Nginx version récente (1.20+)
- [ ] Pas de CVE connues

### Configuration de base
- [ ] user = www-data (pas root)
- [ ] server_tokens off
- [ ] Modules inutiles désactivés

### SSL/TLS
- [ ] TLS 1.2 et 1.3 uniquement
- [ ] Ciphers modernes
- [ ] HSTS activé
- [ ] Certificats valides
- [ ] OCSP Stapling
- [ ] Redirection HTTP → HTTPS

### Headers de sécurité
- [ ] HSTS
- [ ] X-Frame-Options
- [ ] X-Content-Type-Options
- [ ] CSP
- [ ] X-XSS-Protection

### Protection
- [ ] Rate limiting configuré
- [ ] Fichiers sensibles bloqués
- [ ] Admin restreint par IP

### Logging
- [ ] Access log activé
- [ ] Error log configuré
- [ ] Rotation des logs
- [ ] Permissions correctes (640)

---

## 📚 Références

- [Nginx Security Guide](https://nginx.org/en/docs/http/ngx_http_core_module.html)
- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

---

**Note :** Testez toute modification dans un environnement de test avant production.
