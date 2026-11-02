# Dossier d’Architecture - NovaTech (Architecture Multi-Sites)

**Auteurs :** Brandon | Amine | Rayan
**Date :** Novembre 2026  
**Version :** 1.0

---

## 1. Présentation de l’Entreprise et Contexte Multi-Sites

### 1.1 Profil de NovaTech et Répartition Géographique
NovaTech est une PME industrielle en forte croissance de **250 collaborateurs**, répartie sur **2 sites géographiques stratégiques** :
* **Site 1 : Le Siège Principal & Datacenter Central (180 collaborateurs)**  
  Abrite le cœur du Système d’Information, l'infrastructure de virtualisation principale (Proxmox VE), le stockage centralisé (SAN/NAS), ainsi que l'ensemble des serveurs applicatifs critiques.
* **Site 2 : Le Site Distant / Agence Opérationnelle (70 collaborateurs)**  
  Accueille les équipes opérationnelles, de production locale et de support. Ce site est interconnecté en permanence au site principal via une liaison WAN haut débit redondante et sécurisée.

### 1.2 Enjeux Métiers et Systèmes d’Information
Pour soutenir son activité, le Système d’Information (SI) repose sur un ensemble de services critiques et vitaux répartis sur les deux sites :
* **L’ERP (Enterprise Resource Planning) :** Centralisé sur le Site 1, accédé depuis les deux sites pour la gestion logistique, la production et la facturation.
* **Le Serveur de Fichiers :** Espaces de stockage collaboratifs partagés avec réplication/accès distant sécurisé pour le Site 2.
* **La Messagerie d’Entreprise :** Service centralisé garantissant les communications internes et externes.
* **L’Annuaire Centralisé (LDAP) :** Service d’authentification critique garantissant le contrôle d’accès unifié pour l'ensemble des 250 collaborateurs.
* **Le Site Web institutionnel et e-commerce :** Vitrine externe hébergée en DMZ sur le Datacenter du Site 1.

### 1.3 Modèle Centralisé vs Distribué

| Critères d'Évaluation | Modèle Centralisé (Datacenter Unique) | Modèle Distribué / Hybride |
| :--- | :--- | :--- |
| **Coûts (Licences & Matériel)** | Faible à Modéré : Un seul site central à équiper et maintenir, réduction des coûts de matériel et de gestion. | Élevé : Duplication des baies de stockage, des serveurs physiques et des infrastructures sur chaque site. |
| **Latence & Performances** | Moyen à Élevé : Latence potentielle pour les 100 collaborateurs du site distant accédant aux applications centrales. | Faible : Traitement local des données pour chaque agence, garantissant une réactivité optimale. |
| **Résilience & Disponibilité** | Sensible au WAN : Dépendance critique de la liaison inter-sites (en cas de coupure WAN, le site distant est isolé). | Élevée : Continuité d'activité locale préservée sur chaque site même en cas de rupture de la liaison WAN. |
| **Complexité d'Exploitation** | Faible : Administration centralisée par l'équipe IT du siège, mises à jour et sauvegardes centralisées. | Élevée : Synchronisation complexe des données (ERP/fichiers), maintenance répartie et compétences locales requises. |

Décision retenue pour NovaTech :

Un modèle centralisé avec réplication ciblée (hybride) a été choisi. Le siège (Site 1) héberge le datacenter central (Proxmox VE, ERP, SAN/NAS), tandis que l'agence (Site 2) est interconnectée via une liaison WAN redondante (VPN IPsec / MPLS) avec réplication des sauvegardes (restic). Cela garantit un équilibre optimal entre coûts maîtrisés, sécurité centralisée et continuité d'activité.

### 1.4 Souveraineté Numérique et Choix Technologiques (100 % Open Source & Linux)
Dans le cadre de sa stratégie de gouvernance, NovaTech affirme un positionnement fort en faveur de la **souveraineté numérique et de l'indépendance technologique** :
* **Bannissement des solutions propriétaires :** L'infrastructure est conçue sans aucune dépendance aux écosystèmes propriétaires (absence totale de licences Microsoft Windows Server, de licences VMware/vSphere ou d'outils payants).
* **Stack 100 % Libre (Open Source) :** L'ensemble de la chaîne technique repose sur des briques libres et reconnues : hyperviseur Proxmox VE (AGPLv3), systèmes Debian 13, orchestrateurs Docker / k3s et pare-feu OPNsense. Cela garantit un coût de licence nul (0 €), un contrôle total du code source et une conformité renforcée avec les réglementations européennes (RGPD, directive NIS2).

---

## 2. Cadrage des Services et Exigences de Continuité (RTO / RPO)

Pour chaque service, l’analyse des impacts métier (BIA) intègre la dimension multi-sites :

| Service | Criticité Métier | RTO Cible (Coupure max) | RPO Cible (Perte max) | Impact en cas d’indisponibilité |
| :--- | :--- | :--- | :--- | :--- |
| **ERP** | Critique | $< 1$ heure | $< 15$ minutes | Arrêt de la production et de la facturation (Site 1 & 2). |
| **Annuaire LDAP** | Critique | $< 30$ minutes | $< 1$ heure | Impossibilité de connexion pour l'ensemble des collaborateurs. |
| **Messagerie** | Élevée | $< 4$ heures | $< 1$ heure | Rupture des communications. |
| **Serveur de Fichiers** | Élevée | $< 4$ heures | $< 4$ heures | Perte de productivité sur les deux sites. |
| **Site Web (DMZ)** | Moyenne | $< 24$ heures | $< 24$ heures | Atteinte à l'image de marque. |

---

## 3. Architecture Cible et Plan d’Adressage IP Multi-Sites

L'infrastructure repose sur un hyperviseur de niveau 1 (Proxmox VE) sur le Site 1, un pare-feu centralisé (OPNsense) assurant la segmentation par VLANs, et une interconnexion robuste avec le Site 2.

### 3.1 Plan d’Adressage IP (Sous-réseaux en `/24`)

**Site 1 : Siège Principal & Datacenter Central**
* **VLAN 10 · Management (`10.0.10.0/24`) :** Administration, bastion, VM de gestion (Ansible, Git, `10.0.10.10`) et interfaces d'hyperviseurs.
* **VLAN 20 · Serveurs Internes (`10.0.20.0/24`) :** Hébergement des VMs applicatives (ERP, Annuaire FreeIPA, messagerie, conteneurs Docker/k3s) sur le Datacenter principal.
* **VLAN 30 · DMZ (`10.0.30.0/24`) :** Services exposés sur Internet (Site web, reverse proxy, passerelles VRRP `10.0.30.100`) sur le Site 1.
* **VLAN 40 · Stockage Haute Performance (`10.0.40.0/24`) :** Trafic dédié aux flux SAN iSCSI, NAS NFS/SMB et NVMe over Fabrics (Site 1).
* **VLAN 50 & 51 · Liens Inter-routes (`10.0.50.0/30` & `10.0.51.0/30`) :** Liaisons point-à-point pour le routage dynamique OSPF (FRRouting).

**Site 2 : Site Distant / Agence (Secours)**
* **VLAN 120 · Serveurs Secours (`10.1.20.0/24`) :** Hébergement du second Proxmox et des services de secours pour l'agence.
* **VLAN 140 · Stockage Secours (`10.1.40.0/24`) :** Trafic dédié au NAS de réplication (`restic`) pour la stratégie de sauvegarde PRA.
* **VLAN 150 · Utilisateurs / Postes (`10.1.50.0/24`) :** Sous-réseau dédié aux postes de travail des 70 collaborateurs du site distant, routé via le tunnel VPN IPsec inter-sites.

### 3.2 Topologie Réseau et Interconnexion des 2 Sites
![Schéma NovaTech](/Schéma-NovaTech.png)

### 3.3 Règles de Filtrage et Cloisonnement Multi-Sites
1. **Politique générale :** *Deny All* par défaut sur les deux pare-feux.
2. **Isolation de la DMZ (Site 1) :** Le VLAN 30 a une interdiction formelle et absolue de joindre le réseau interne (`10.0.0.0/16`) et le réseau du Site 2.
3. **Flux Inter-Sites :** Seuls les flux métiers légitimes (ERP, authentification LDAP, transferts de fichiers chiffrés) sont autorisés entre le Site 2 (`10.1.20.0/24`) et le Datacenter du Site 1 via le VPN inter-sites.

### 3.4 Gestion des Identités et Annuaire Souverain (FreeIPA vs Active Directory)
Pour répondre aux besoins d'authentification centralisée et de gestion des accès des 250 collaborateurs sans recourir à un Active Directory (Microsoft Windows Server), NovaTech déploie **FreeIPA** sur une machine virtuelle dédiée du VLAN Serveurs (`10.0.20.0/24`).

* **Justification du choix (FreeIPA vs Active Directory) :**
  * **Souveraineté et Coût :** FreeIPA est une solution 100 % open source (redistribuée sous licence GPL) native Linux, éliminant les coûts prohibitifs des licences CALs Microsoft et garantissant une indépendance totale vis-à-vis des éditeurs propriétaires.
  * **Fonctionnalités Intégrées :** Contrairement à un simple serveur LDAP, FreeIPA combine en une seule brique hautement sécurisée :
    1. Un annuaire LDAP robuste (**389 Directory Server**).
    2. Un système d'authentification forte et de billetterie (**Kerberos**).
    3. Un serveur DNS intégré avec gestion dynamique.
    4. Une **Autorité de Certification (CA)** interne automatisant la délivrance et le renouvellement des certificats TLS/SSL.
  * **Cohérence de l'écosystème :** L'intégration avec les postes clients Linux, les serveurs Debian, l'hyperviseur Proxmox et les outils d'automatisation (Ansible) est native et transparente via `sssd`.

---

## 4. Dimensionnement et Analyse de Croissance (Projection à 3 ans)

En appliquant une hypothèse de croissance annuelle de $15\,\%$ de la volumétrie des données, une marge de sécurité de $25\,\%$ sur la mémoire RAM, et un ratio de sur-engagement vCPU de $4:1$ pour l'ensemble des 250 collaborateurs répartis sur les deux sites :

### 4.1 Formules de Calcul de Référence
$$
\text{RAM\_totale} = \sum(\text{RAM\_Go}) \times 1{,}25
$$
* Exemple de dimensionnement des VMs :
    - ERP : 16 Go de RAM
    - Annuaire FreeIPA : 4 Go de RAM
    - Messagerie : 8 Go de RAM
    - Serveur de fichiers : 12 Go de RAM
    - Site Web (DMZ) : 4 Go de RAM
    - Somme brute ($\sum\text{RAM\_Go}$) : $16 + 4 + 8 + 12 + 4 = 44\text{ Go}$
* Application du calcul :
$$\text{RAM\_totale} = 44 \times 1{,}25 = 55\text{ Go}$$

* Interprétation : Il faut allouer un total de 55 Go de RAM sur l'hyperviseur Proxmox pour absorber la charge nominale et inclure la marge de tolérance de 25 %.

$$\text{vCPU\_phys} = \frac{\sum(\text{vCPU})}{4}$$

* Exemple de dimensionnement des VMs :
    - ERP : 8 vCPU
    - Annuaire FreeIPA : 2 vCPU
    - Messagerie : 4 vCPU
    - Serveur de fichiers : 4 vCPU
    - Site Web (DMZ) : 2 vCPU
    - Somme brute des vCPU ($\sum\text{vCPU}$) : $8 + 2 + 4 + 4 + 2 = 20\text{ vCPU}$
    
* Application du calcul :$$\text{vCPU\_phys} = \frac{20}{4} = 5\text{ cœurs physiques}$$

* Interprétation : Grâce au sur-engagement (plusieurs machines virtuelles partagent les cœurs physiques), 20 vCPU virtuels alloués aux VMs peuvent tourner efficacement sur seulement 5 cœurs physiques de l'hôte Proxmox.

$$\text{StockageUtile} = \sum(\text{Donnees\_Go}) \times (1 + 0{,}15)^3$$

* Exemple de volume de données initial :
    - ERP : 500 Go
    - Serveur de fichiers : 1000 Go (1 To)
    - Messagerie & Logs : 200 Go
    - Somme brute initiale ($\sum\text{Donnees\_Go}$) : $500 + 1000 + 200 = 1700\text{ Go}$
* Application du calcul (projection à $N=3$ ans) :$$\text{StockageUtile} = 1700 \times (1{,}15)^3 = 1700 \times 1{,}520875 \approx 2585{,}49\text{ Go}$$

* Interprétation : Pour absorber la croissance des données de NovaTech sur 3 ans, il faut prévoir un espace utile d'environ 2,58 To.

$$\text{StockageBrut} = \frac{\text{StockageUtile}}{(1 - \text{Penalite\_RAID}) \times 0{,}8} \quad (\text{avec un seuil de remplissage max de } 80\,\%)$$

* Exemple avec un RAID 10 (Pénalité de 0,5, soit 50 % de capacité perdue pour la redondance) :
    - Stockage utile requis : $2585\text{ Go}$ (trouvé à l'étape précédente)
    - Seuil de remplissage maximal : $80\,\%$ (soit $0{,}8$)
* Application du calcul :$$\text{StockageBrut} = \frac{2585}{(1 - 0{,}5) \times 0{,}8} = \frac{2585}{0{,}5 \times 0{,}8} = \frac{2585}{0{,}4} = 6462{,}5\text{ Go}$$
* Interprétation : Il faudra commander et installer une capacité brute de disques d'environ 6,46 To (par exemple, un groupe de disques configuré en RAID 10) pour garantir à la fois la tolérance aux pannes du RAID et le respect de la règle opérationnelle ne dépassant pas 80 % de remplissage.

---

## 5. Analyse des SPOF (Single Points of Failure) et Résilience Multi-Sites

L'identification des points uniques de défaillance intègre la criticité de l'interconnexion :
* **Pare-feu / Routeur :** Implantation d’une haute disponibilité active/passive par protocole VRRP (`keepalived`) sur le site principal.
* **Liaison Inter-Sites (WAN) :** Doublement des liens télécoms (opérateurs tiers distincts) avec routage dynamique (OSPF avec FRRouting) pour assurer une reconvergence transparente en cas de coupure de fibre vers le Site 2.
* **Stockage et Données :** Utilisation de pools OpenZFS et réplication hors-site des sauvegardes vers le Site 2 ou un espace distant via `restic`.

---

## 6. Gouvernance, Conformité et Gestion du Changement

### 6.1 Cadres de Référence
* **ITIL 4 :** Structuration de la gestion des changements et des incidents d'infrastructure multi-sites.
* **COBIT :** Alignement stratégique du SI sur les objectifs de l'entreprise.
* **ANSSI & CNIL :** Application des guides de durcissement et conformité RGPD.

### 6.2 Gestion des Modifications (RFC - Request For Change)
Toute modification sur l'infrastructure (mise à jour pare-feu, modifications de routage inter-sites) passe par une **RFC** versionnée dans le dépôt Git (`gouvernance/RFC-001.md`), validée par le comité de changement (**CAB**).

### 6.3 Matrice RACI (Gouvernance Globale)

| Activité / Processus | Brandon (Réseau & Sécurité) | Rayan (Stockage & PRA) | Amine (Virt. & Conteneurs) | Direction / Métiers |
| :--- | :--- | :--- | :--- | :--- |
| **Architecture Réseau, OPNsense & VPN Inter-Sites** | R | C | C | A / I |
| **Stockage, OpenZFS, iSCSI & Sauvegarde restic (PRA)** | C | R | C | A / I |
| **Virtualisation Proxmox, Conteneurs & Annuaire FreeIPA** | C | C | R | A / I |
| **Validation des RFC et Gouvernance Globale** | R | R | R | A |


*(Légende : R = Réalisateur, A = Accountable / Responsable final, C = Consulté, I = Informé)*

---

## 7. Sécurité, Sauvegarde (3-2-1-1-0) et Plan de Reprise d’Activité (PRA)

* **Chiffrement :** Implémentation de LUKS et de tunnels IPsec chiffrés pour sécuriser les flux inter-sites.
* **Journalisation :** Surveillance proactive via `auditd` sur le site central.
* **Stratégie de Sauvegarde :** Application rigoureuse de la règle 3-2-1-1-0 (3 copies des données, sur 2 supports différents, 1 copie externalisée hors-site, 1 copie immuable/hors-ligne de protection contre les ransomwares, et 0 erreur validée par des tests réguliers de restauration) via la réplication des dépôts de sauvegarde `restic` du Site 1 vers le Site 2.
* **Validation du PRA :** Tests réguliers mesurant le RTO réel sur les services partagés avec le Site 2.