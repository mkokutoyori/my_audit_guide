# Guide d'Audit Technique - Palo Alto Networks Firewall

## 📋 Vue d'ensemble

Ce guide permet d'effectuer un audit de sécurité d'un firewall Palo Alto Networks. Basé sur :
- **Palo Alto Networks Best Practices**
- **CIS Benchmark for Palo Alto Firewall**
- **NIST Firewall Security Guidelines**

### Version du guide
- **Dernière mise à jour** : Janvier 2025
- **PAN-OS couvert** : 10.x, 11.x
- **Type d'audit** : Sécurité et conformité

---

## 🎯 Objectifs

- Auditer la configuration de sécurité du firewall
- Vérifier les politiques de sécurité
- Contrôler la gestion des accès administratifs
- Valider la configuration du déchiffrement SSL
- Vérifier les logs et l'audit

---

## 📚 Prérequis

### Accès nécessaire
- Compte administrateur Palo Alto
- Accès web GUI ou CLI (SSH)
- Accès aux logs et rapports

---

## 🔍 Points de Contrôle

### 1. VERSION ET LICENCES

#### 1.1 Version PAN-OS

**Objectif :** Vérifier que la version PAN-OS est supportée et à jour

**Procédure :**
```
Web GUI : Device > Software
CLI : show system info
```

**Résultats attendus :**
- ✅ PAN-OS 10.2+ ou 11.x (versions maintenues)
- ✅ Dernière version de maintenance installée
- ✅ Licences actives : Threat Prevention, WildFire, URL Filtering

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| PAN-OS < 10.0 | 🔴 CRITIQUE | Vulnérabilités non corrigées, fin de support |
| Threat Prevention expiré | 🔴 CRITIQUE | Signatures de menaces obsolètes |
| WildFire inactif | 🟠 ÉLEVÉ | Malware inconnus non détectés |

---

### 2. ACCÈS ADMINISTRATIF

#### 2.1 Comptes administrateurs

**Objectif :** Auditer les comptes administrateurs et leurs privilèges

**Procédure :**
```
Web GUI : Device > Administrators
CLI : show admins
```

**Résultats attendus :**
- ✅ Nombre minimal de comptes admin (2-3)
- ✅ Pas de compte "admin" par défaut actif
- ✅ Authentification forte (TACACS+/RADIUS + MFA)
- ✅ Profils admin restrictifs (pas tous superuser)

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Compte "admin" avec mot de passe par défaut | 🔴 CRITIQUE | Compromission facile |
| Pas de MFA | 🔴 CRITIQUE | Accès non protégé |
| Tous les admins = superuser | 🟠 ÉLEVÉ | Pas de séparation des privilèges |

**Recommandations :**
```
Device > Administrators > Add
- Nom : admin_user1
- Authentication Profile : <TACACS+/RADIUS>
- Administrator Type : Role Based
- Profile : <custom_profile> (pas superuser)

Device > Setup > Management > Authentication Settings
- Activer Multi-Factor Authentication
```

#### 2.2 Accès management

**Objectif :** Sécuriser l'accès au management du firewall

**Procédure :**
```
Web GUI : Device > Setup > Management
CLI : show management-profile
```

**Résultats attendus :**
- ✅ Management accessible uniquement depuis réseau dédié
- ✅ HTTPS uniquement (pas HTTP)
- ✅ SSH avec clés (pas passwords)
- ✅ Telnet désactivé
- ✅ Timeout de session : 10-30 minutes

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| HTTP activé | 🔴 CRITIQUE | Credentials en clair |
| Telnet activé | 🔴 CRITIQUE | Trafic non chiffré |
| Management sur Internet | 🔴 CRITIQUE | Exposition publique |
| Pas de timeout | 🟡 MOYEN | Sessions ouvertes indéfiniment |

**Recommandations :**
```
Device > Setup > Management
- HTTP : Disabled
- HTTPS : Enabled
- Telnet : Disabled
- SSH : Enabled (avec clés publiques)
- Idle Timeout : 10 minutes

Network > Network Profiles > Interface Mgmt
- Créer un profil restreint : HTTPS + SSH uniquement
- Appliquer aux interfaces management
```

---

### 3. ZONES ET POLITIQUES DE SÉCURITÉ

#### 3.1 Segmentation réseau (Zones)

**Objectif :** Vérifier la segmentation réseau via les zones

**Procédure :**
```
Web GUI : Network > Zones
Policies > Security
```

**Résultats attendus :**
- ✅ Zones définies : Trust, Untrust, DMZ
- ✅ Chaque interface assignée à une zone
- ✅ Pas de zone "any" dans les politiques critiques

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Zones mal définies | 🟠 ÉLEVÉ | Segmentation inefficace |
| Règles "any any any" | 🔴 CRITIQUE | Pas de contrôle d'accès |

**Recommandations :**
- Définir des zones claires (Internal, External, DMZ, Management)
- Appliquer Zone Protection Profiles sur chaque zone

#### 3.2 Politiques de sécurité

**Objectif :** Auditer les règles de sécurité

**Procédure :**
```
Web GUI : Policies > Security
CLI : show running security-policy
```

**Résultats attendus :**
- ✅ Règle implicite deny-all en fin de liste
- ✅ Pas de règles "any any any allow"
- ✅ Règles avec applications spécifiques (pas "any")
- ✅ Profils de sécurité appliqués sur chaque règle
- ✅ Logs activés sur toutes les règles

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Règles permissives (any any any) | 🔴 CRITIQUE | Pas de contrôle |
| Pas de profils de sécurité | 🔴 CRITIQUE | Menaces non bloquées |
| Logs désactivés | 🟠 ÉLEVÉ | Pas de traçabilité |
| Règles obsolètes/inutilisées | 🟡 MOYEN | Complexité inutile |

**Recommandations :**
```
Bonnes pratiques :
1. Nommer clairement les règles (pas "Rule1", "Rule2")
2. Spécifier applications précises (pas "any")
3. Attacher Security Profiles :
   - Antivirus
   - Anti-Spyware
   - Vulnerability Protection
   - URL Filtering
   - File Blocking
   - WildFire Analysis

4. Activer logs : Log at Session Start + Session End
5. Désactiver ou supprimer règles non utilisées (Hit Count = 0)
```

---

### 4. DÉCHIFFREMENT SSL/TLS

#### 4.1 Politique de déchiffrement

**Objectif :** Vérifier que le trafic SSL est déchiffré pour inspection

**Justification :** 80%+ du trafic malveillant utilise HTTPS. Sans déchiffrement, les menaces passent non détectées.

**Procédure :**
```
Web GUI : Policies > Decryption
Objects > Decryption Profile
```

**Résultats attendus :**
- ✅ Politique de déchiffrement SSL Forward Proxy configurée
- ✅ Exceptions pour trafic sensible (santé, finance) documentées
- ✅ Certificats CA déployés sur les postes clients
- ✅ TLS 1.2+ minimum (pas 1.0, 1.1)

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de déchiffrement SSL | 🔴 CRITIQUE | 80% du malware non détecté |
| TLS 1.0/1.1 autorisé | 🟠 ÉLEVÉ | Protocoles obsolètes et faibles |
| Exceptions non documentées | 🟡 MOYEN | Zones aveugles non justifiées |

**Recommandations :**
```
Policies > Decryption > Add
- Name : Decrypt-Outbound
- From : Trust
- To : Untrust
- Action : Decrypt
- Type : SSL Forward Proxy

Objects > Decryption Profile
- Block sessions with expired certificates : Yes
- Block sessions with untrusted issuers : Yes
- Block sessions if SNI is not present : Yes
- Min TLS Version : TLS1.2

Exceptions (ne PAS déchiffrer) :
- Trafic santé (HIPAA)
- Trafic bancaire
- Sites avec certificate pinning (documenté)
```

---

### 5. THREAT PREVENTION

#### 5.1 Profils de sécurité

**Objectif :** Vérifier l'activation et la configuration des profils de sécurité

**Procédure :**
```
Web GUI : Objects > Security Profiles
- Antivirus
- Anti-Spyware
- Vulnerability Protection
- URL Filtering
- File Blocking
- WildFire Analysis
```

**Résultats attendus :**
- ✅ Antivirus : action "block" pour tous les types
- ✅ Anti-Spyware : criticité "critical, high, medium" en block
- ✅ Vulnerability Protection : toutes les signatures critiques actives
- ✅ URL Filtering : catégories dangereuses bloquées
- ✅ WildFire : tous les fichiers suspects analysés

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Profils en mode "alert" uniquement | 🔴 CRITIQUE | Menaces non bloquées |
| Signatures obsolètes | 🔴 CRITIQUE | Nouvelles menaces non détectées |
| WildFire désactivé | 🟠 ÉLEVÉ | Malware 0-day non détecté |

**Recommandations :**
```
Objects > Security Profiles > Antivirus
- Action : block pour tous les types de virus
- WildFire Inline ML : activé

Objects > Security Profiles > Anti-Spyware
- DNS Sinkhole : activé (avec adresse sinkhole)
- Passive DNS Monitoring : activé

Objects > Security Profiles > Vulnerability Protection
- Action : block-ip pour critical et high
- Packet Capture : single-packet (pour investigation)

Objects > Security Profiles > URL Filtering
- Bloquer : malware, phishing, command-and-control
- Alert : gambling, social-networking (selon politique)

Objects > Security Profiles > File Blocking
- Bloquer : .exe, .dll, .bat depuis Internet
- Soumettre à WildFire : tous les autres types

Objects > Security Profiles > WildFire Analysis
- Soumettre tous les types de fichiers inconnus
```

---

### 6. LOGGING ET AUDIT

#### 6.1 Configuration des logs

**Objectif :** Vérifier que tous les événements sont tracés

**Procédure :**
```
Web GUI : Device > Log Settings
Objects > Log Forwarding
```

**Résultats attendus :**
- ✅ Logs envoyés vers serveur syslog externe ou Panorama
- ✅ Traffic logs : Session Start + Session End
- ✅ Threat logs activés
- ✅ URL filtering logs activés
- ✅ Data filtering logs activés
- ✅ WildFire logs activés
- ✅ Authentification logs activés
- ✅ Rétention : minimum 30 jours

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Logs non centralisés | 🟠 ÉLEVÉ | Perte de logs si panne |
| Session Start non loggé | 🟡 MOYEN | Investigation incomplète |
| Rétention < 7 jours | 🟡 MOYEN | Historique insuffisant |

**Recommandations :**
```
Device > Log Settings
- Configure Syslog Server : <IP_SIEM>
- Facility : LOG_USER
- Format : BSD

Objects > Log Forwarding > Add Profile
- Name : Forward-All-Logs
- Traffic Logs : Log at Session Start + Session End
- Threat Logs : Yes
- URL Logs : Yes
- WildFire Logs : Yes
- Data Logs : Yes
- Tunnel Logs : Yes
- Auth Logs : Yes

Appliquer ce profil à toutes les règles de sécurité
```

#### 6.2 Audit des configurations

**Objectif :** Activer l'audit des changements de configuration

**Procédure :**
```
Web GUI : Device > Log Settings > Config
```

**Résultats attendus :**
- ✅ Configuration logs activés
- ✅ Envoyés vers serveur centralisé

**Recommandations :**
```
Device > Log Settings > Config
- Enable : Yes
- Forward to Syslog : Yes
```

---

### 7. HAUTE DISPONIBILITÉ (HA)

#### 7.1 Configuration HA

**Objectif :** Vérifier la configuration haute disponibilité

**Procédure :**
```
Web GUI : Device > High Availability
CLI : show high-availability state
```

**Résultats attendus :**
- ✅ HA configuré (Active/Passive ou Active/Active)
- ✅ État HA : fonctionnel
- ✅ Liens HA dédiés (pas sur interface data)
- ✅ Configuration synchronisée

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Pas de HA | 🟠 ÉLEVÉ | SPOF (Single Point of Failure) |
| HA sur interface data | 🟡 MOYEN | Risque de split-brain |
| Configurations désynchronisées | 🟠 ÉLEVÉ | Comportements incohérents |

---

### 8. MISES À JOUR

#### 8.1 Dynamic Updates

**Objectif :** Vérifier que les signatures sont à jour

**Procédure :**
```
Web GUI : Device > Dynamic Updates
```

**Résultats attendus :**
- ✅ Applications & Threats : < 7 jours
- ✅ Antivirus : < 24 heures
- ✅ WildFire : < 24 heures
- ✅ URL Filtering : < 24 heures
- ✅ Mise à jour automatique activée

**Risques :**
| Configuration | Criticité | Risque |
|---------------|-----------|---------|
| Signatures > 30 jours | 🔴 CRITIQUE | Menaces récentes non détectées |
| Pas de mise à jour auto | 🟠 ÉLEVÉ | Oubli de mises à jour |

**Recommandations :**
```
Device > Dynamic Updates
- Applications & Threats : Download and Install (daily)
- Antivirus : Download and Install (hourly)
- WildFire : Download and Install (every 5 minutes)
- URL Filtering : Download and Install (daily)
```

---

## ✅ Checklist Finale

### Version et licences
- [ ] PAN-OS version supportée (10.2+)
- [ ] Licences actives (Threat Prevention, WildFire, URL)

### Accès administratif
- [ ] Comptes admin avec MFA
- [ ] Management restreint (pas sur Internet)
- [ ] HTTPS uniquement (pas HTTP/Telnet)
- [ ] Timeout de session configuré

### Politiques
- [ ] Zones définies et protégées
- [ ] Pas de règles "any any any"
- [ ] Security Profiles sur toutes les règles
- [ ] Logs activés partout

### Déchiffrement
- [ ] SSL Decryption configuré
- [ ] TLS 1.2+ minimum
- [ ] Exceptions documentées

### Threat Prevention
- [ ] Antivirus : block
- [ ] Anti-Spyware : block
- [ ] Vulnerability Protection : actif
- [ ] URL Filtering : catégories dangereuses bloquées
- [ ] WildFire : activé et configuré

### Logging
- [ ] Logs centralisés (Syslog/Panorama)
- [ ] Traffic logs : start + end
- [ ] Config logs activés

### Mises à jour
- [ ] Signatures < 7 jours
- [ ] Mise à jour automatique activée

---

## 📚 Références

- [Palo Alto Best Practices](https://docs.paloaltonetworks.com/best-practices)
- [CIS Palo Alto Benchmark](https://www.cisecurity.org/benchmark/palo_alto_networks)
- [PAN-OS Administrator's Guide](https://docs.paloaltonetworks.com/pan-os)

---

**Note :** Testez toutes les modifications en dehors des heures de production.
