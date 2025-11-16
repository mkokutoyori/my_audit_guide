# 🎓 Guide d'Audit Technique - Mode Tutoriel Sympa !

Salut ! Bienvenue dans ton nouveau guide d'audit technique. Oublie les documents ennuyeux et corporate - ici, on va apprendre ensemble comment auditer tes systèmes, et je te promets que ça va être clair et accessible !

## 💡 C'est quoi ce projet ?

Imagine que tu dois vérifier si ta maison est bien sécurisée : portes fermées, alarme activée, fenêtres solides, etc. Eh bien, c'est exactement pareil pour les systèmes informatiques ! Ce projet, c'est comme une série de checklists détaillées pour vérifier que tout est bien fermé à clé.

**En gros, tu vas apprendre à :**
- 🔍 Détecter les failles de sécurité avant les méchants hackers
- 🛡️ Comprendre pourquoi certaines configurations sont dangereuses
- 🔧 Savoir comment réparer les problèmes que tu trouves
- 📊 Évaluer le niveau de risque de chaque problème

## 🎯 Pour qui c'est fait ?

Ce guide est pour TOI si :
- ✅ Tu es admin système ou en formation
- ✅ Tu dois auditer des serveurs/équipements mais tu ne sais pas par où commencer
- ✅ Tu connais les bases de l'informatique mais la sécurité te semble compliquée
- ✅ Tu veux des explications claires, pas du jargon incompréhensible
- ✅ Tu préfères apprendre en faisant plutôt qu'en lisant des pavés théoriques

**Niveau requis :** Connaissance de base en informatique. Si tu sais te connecter en SSH ou utiliser le terminal, c'est bon !

## 📚 Qu'est-ce qu'il y a dans la boîte ?

Voici tous les tutoriels disponibles, organisés par catégorie :

### 🖥️ Systèmes d'Exploitation (OS)

**Linux** - Pour les serveurs sous pingouin 🐧
- [Ubuntu Server](os/linux/ubuntu.md) - Le plus populaire, parfait pour débuter
- [Debian](os/linux/debian.md) - Le cousin stable d'Ubuntu
- [Red Hat / CentOS](os/linux/rhel.md) - Pour l'entreprise sérieuse

**Windows** - Pour les serveurs sous fenêtres 🪟
- [Windows Server 2019](os/windows/windows-server-2019.md)
- [Windows Server 2022](os/windows/windows-server-2022.md) - La dernière version

### 🗄️ Bases de Données

Où vivent tes précieuses données ! 💎

- [MySQL / MariaDB](databases/mysql.md) - Le duo le plus utilisé au monde
- [PostgreSQL](databases/postgresql.md) - Le choix des puristes
- [MongoDB](databases/mongodb.md) - Pour les données NoSQL
- [Oracle Database](databases/oracle.md) - Le grand frère enterprise
- [Microsoft SQL Server](databases/mssql.md) - L'option Microsoft

### 🌐 Équipements Réseau

Les gardiens de ton réseau ! 🛡️

**Firewalls (Pare-feux)** - Tes vigiles numériques
- [Palo Alto Networks](network/firewalls/palo-alto.md) - Le Ferrari des firewalls
- [Fortinet FortiGate](network/firewalls/fortinet.md) - Très populaire en entreprise
- [Cisco ASA](network/firewalls/cisco-asa.md) - Le classique de Cisco

**Routeurs** - Les facteurs du réseau
- [Cisco IOS](network/routers/cisco.md) - Le standard de l'industrie
- [Juniper JunOS](network/routers/juniper.md) - L'alternative premium

**Switches** - Les aiguilleurs
- [Cisco Catalyst](network/switches/cisco.md)
- [HP ProCurve / Aruba](network/switches/hp.md)

### 🌍 Applications Web

Les serveurs qui font tourner tes sites !

- [Nginx](applications/web/nginx.md) - Rapide et moderne
- [Apache](applications/web/apache.md) - Le vétéran fiable
- [Microsoft IIS](applications/web/iis.md) - Pour les environnements Windows

### 🐳 Conteneurs

La nouvelle génération de déploiement !

- [Docker](applications/containers/docker.md) - Pour containeriser tes apps
- [Kubernetes](applications/containers/kubernetes.md) - Pour orchestrer tout ça

## 🚀 Comment utiliser ces guides ?

### Méthode en 5 étapes (facile !)

**Étape 1 : Choisis ton guide** 🎯
Clique sur le système que tu veux auditer dans la liste ci-dessus.

**Étape 2 : Lis l'intro** 📖
Chaque guide commence par expliquer ce qu'on va faire et pourquoi. Ne saute pas cette partie !

**Étape 3 : Prépare tes outils** 🔧
On te donnera la liste des commandes/outils nécessaires. C'est comme préparer tes ingrédients avant de cuisiner.

**Étape 4 : Suis le guide pas à pas** 👣
Chaque point de contrôle est expliqué simplement :
- **Ce qu'on vérifie** - En français clair
- **Pourquoi c'est important** - Avec des analogies du quotidien
- **Comment faire** - Les commandes exactes à taper
- **C'est bon ou pas ?** - Comment interpréter le résultat
- **Si c'est cassé, comment réparer ?** - Les solutions concrètes

**Étape 5 : Coche la checklist finale** ✅
À la fin, tu auras une checklist pour vérifier que t'as rien oublié !

## 🎨 Comment c'est présenté ?

Chaque tutoriel suit le même format (histoire que tu ne sois pas perdu) :

### 📋 Intro Sympa
On t'explique ce qu'on va faire, sans blabla inutile.

### 🎓 Les Fondamentaux
Les concepts de base expliqués simplement. Par exemple :
> "Un firewall, c'est comme un videur de boîte de nuit : il laisse entrer seulement les personnes autorisées et bloque les indésirables."

### 🔍 Les Points de Contrôle
Pour chaque vérification, tu auras :

**💬 En français simple** - Qu'est-ce qu'on cherche ?
> "On va vérifier si ton serveur a un mot de passe ou s'il est ouvert à tous comme une porte de grange !"

**🤔 Pourquoi c'est important ?**
> "Si ton serveur n'a pas de mot de passe, c'est comme laisser ta maison ouverte avec un panneau 'Servez-vous' - pas génial pour la sécurité !"

**⚙️ Comment vérifier** - Les commandes à taper
```bash
# On copie-colle cette commande
sudo cat /etc/shadow
```

**✅ Résultat normal** - Ce que tu dois voir
> "Si tu vois des lignes avec des $ et plein de caractères bizarres, c'est bon ! Ce sont les mots de passe chiffrés."

**❌ Résultat inquiétant** - Ce qui pue
> "Si tu vois des lignes vides ou juste '!', Houston on a un problème !"

**🎨 Niveau de danger**
- 🔴 **URGENT** - Faut réparer ça MAINTENANT (genre, là, tout de suite !)
- 🟠 **Important** - À corriger cette semaine
- 🟡 **À surveiller** - Pas top mais pas la fin du monde
- 🟢 **Nickel** - Continue comme ça champion !

**🔧 Comment réparer** - Les solutions concrètes
```bash
# Voilà ce qu'il faut faire pour réparer
sudo passwd username
```

### ✅ Checklist Finale
Une petite liste pour vérifier que t'as tout fait. Tu coches au fur et à mesure, c'est satisfaisant !

### 📚 Pour aller plus loin
Des liens vers la doc officielle si tu veux creuser. Mais sans obligation hein, on jugera pas !

## ⚠️ Règles du Jeu (Important !)

**🚨 À ne faire QUE sur tes propres systèmes !**

N'utilise JAMAIS ces techniques sur des systèmes qui ne t'appartiennent pas, même "juste pour voir". C'est :
- Illégal (genre prison potentielle)
- Contraire à l'éthique
- Un excellent moyen de ruiner ta carrière

**OK pour :**
- ✅ Tes propres serveurs
- ✅ Les systèmes de ton entreprise (si tu as l'autorisation)
- ✅ Ton lab de test perso
- ✅ Les machines virtuelles pour apprendre

**PAS OK pour :**
- ❌ Le serveur du voisin "juste pour voir"
- ❌ Tester tes nouvelles compétences sur des sites au hasard
- ❌ "Aider" quelqu'un sans autorisation écrite

## 🎯 Conseils du Prof

**Commence petit** 🐣
Ne te lance pas direct sur le serveur de prod ! Crée une VM de test et expérimente là-dessus.

**Prends des notes** 📝
Note ce que tu trouves au fur et à mesure. Ton futur toi te remerciera !

**Google est ton ami** 🔍
Si tu comprends pas un terme, cherche ! J'ai essayé de tout expliquer simplement, mais des fois un petit coup de Google ne fait pas de mal.

**Demande de l'aide** 🤝
Coincé ? Pose des questions sur les forums (Stack Overflow, Reddit, etc.). La communauté tech est généralement sympa.

**Fais des sauvegardes** 💾
Avant de modifier quoi que ce soit, SAUVEGARDE. Sérieusement. Fais-le.

## 🔄 Ce Guide Évolue !

Ces tutoriels sont vivants ! Ils sont mis à jour régulièrement avec :
- 🆕 Les nouvelles failles découvertes
- 🛠️ Les nouveaux outils et techniques
- 💡 Les retours de la communauté
- 📖 Plus d'explications si quelque chose n'est pas clair

Si tu trouves une typo, une explication pas claire, ou si tu as une suggestion, n'hésite pas à contribuer !

## 🎓 Philosophie de ce Projet

**Pas de gatekeeping** 🚫🚪
La cybersécurité ne devrait pas être réservée à une élite. Si tu veux apprendre, tu es le bienvenu !

**Apprendre en faisant** 🛠️
La théorie c'est bien, la pratique c'est mieux. Chaque tutoriel est hands-on.

**Expliquer simplement ≠ Simpliste** 🧠
On peut expliquer des concepts complexes avec des mots simples. C'est justement ça, être un bon prof !

**Erreurs = Apprentissage** 💪
Tu vas sûrement planter des trucs en testant. C'est normal ! C'est même comme ça qu'on apprend le mieux.

## 🚀 Prêt·e à commencer ?

Choisis un guide dans la liste ci-dessus et lance-toi ! Et souviens-toi : même les meilleurs hackers éthiques ont commencé par "bonjour monde" un jour.

Bon audit ! 🎉

---

**PS :** Si tu trouves ce guide utile, partage-le avec tes collègues. Plus on est de fous, plus on rit ! Et la cybersécurité, c'est l'affaire de tous.

**PPS :** Des questions ? Des remarques ? Des blagues de dev ? N'hésite pas à ouvrir une issue sur le repo !
