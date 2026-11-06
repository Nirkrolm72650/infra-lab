## Matrice de Flux - Novatech


| N° | Source (VLAN / Sous-réseau) | Destination (VLAN / Sous-réseau) | Protocoles & Ports | Action | Description / Justification |
| :--- | :--- | :--- | :--- | :---: | :--- |
| **1** | VLAN 10 (Admin / 10.0.10.0/24) | Tous les équipements (Serveurs, Pare-feux, Hyperviseurs) | TCP 22 (SSH), TCP 443 (HTTPS / WebUI) | **ALLOW** | Administration centralisée et sécurisée des équipements de l'infrastructure. |
| **2** | VLAN 10 (Supervision / Zabbix) | VLAN 20 (Serveurs Site A & B) & OPNsense | UDP 161 (SNMPv3), TCP 10050/10051 (Zabbix Agent) | **ALLOW** | Collecte des métriques de supervision et d'intégrité (SNMPv3 authPriv). |
| **3** | VLAN 50 (Clients Site A / 10.0.50.0/24) | VLAN 20 (Serveurs AD/IPA Site A / 10.0.20.0/24) | TCP/UDP 53 (DNS), TCP/UDP 88 (Kerberos), TCP 389/636 (LDAP/LDAPS), TCP 464 (Kpasswd) | **ALLOW** | Authentification des utilisateurs, résolution DNS et requêtes d'annuaire. |
| **4** | VLAN 50 (Clients Site B / 10.1.50.0/24) | VLAN 20 (Serveurs AD/IPA Site A / 10.0.20.0/24) | TCP/UDP 53, 88, 389, 636, 464 | **ALLOW** | Authentification centralisée des utilisateurs du Site B sur le domaine principal (via VPN inter-site). |
| **5** | VLAN 20 (Serveurs / Contrôleurs de domaine) | VLAN 20 (Serveurs / Réplication inter-sites) | TCP/UDP 53 (DNS), TCP 389/636 (LDAP), TCP 88 (Kerberos), TCP 3268/3269 | **ALLOW** | Réplication inter-domaines et synchronisation Active Directory / FreeIPA entre Site A et Site B. |
| **6** | Réseau Site A (10.0.0.0/16) | Réseau Site B (10.1.0.0/16) | UDP 500, UDP 4500 (IPsec / WireGuard) | **ALLOW** | Établissement et maintien du tunnel VPN inter-sites chiffré entre les pare-feux OPNsense. |
| **7** | VLAN 50 (Clients Sites A & B) | Internet (WAN) | TCP 80 (HTTP), TCP 443 (HTTPS) | **ALLOW** | Accès Web pour les utilisateurs (via proxy/filtrage ou NAT sortant OPNsense). |
| **8** | Tout autre flux inter-VLAN | Tous les autres réseaux | Tous protocoles / Tous ports | **DENY** | Règle implicite et explicite de fin de table : Blocage strict de tout trafic non autorisé (Deny All). |
