# Dossier d'Architecture — Jour 2 : Atelier 4
## Nœud de Virtualisation Imbriqué et Fiche Comparative

### 1. Déploiement et Configuration du Nœud Proxmox Imbriqué (`pve-novatech`)
- **Architecture :** Hyperviseur Proxmox VE 9 déployé en VM imbriquée (Nested KVM).
- **Dimensionnement :** 2 vCPU (`--cpu host`), 4 Go de RAM, disque de 40 Go (LVM-thin).
- **Réseau :** Bridge VLAN-aware rattaché au réseau de management (VLAN 10, IP : `10.0.10.21`).
- **Post-installation :** Suppression des dépôts enterprise payants et activation de `pve-no-subscription`.

### 2. Comparatif Pratique : VM vs Conteneur LXC
- **Machine Virtuelle Debian :** Isolation matérielle complète, noyau dédié, démarrage plus lourd (~15-30s), empreinte RAM initiale plus élevée (~512 Mo).
- **Conteneur LXC Debian :** Partage du noyau de l'hôte, démarrage quasi-instantané (<2s), empreinte RAM minime (~128-256 Mo). Idéal pour la densité de micro-services.

### 3. Fiche Comparative des Hyperviseurs (KVM / Proxmox, VMware vSphere, Microsoft Hyper-V)

| Critère | Proxmox VE / KVM | VMware vSphere / vCenter | Microsoft Hyper-V / SCVMM |
| :--- | :--- | :--- | :--- |
| **Licence / Coût** | Open Source (AGPL v3) — 0 € | Propriétaire / Coût par cœur très élevé | Intégré Windows Server + licences CAL/SCVMM |
| **Gestion Centralisée** | Cluster natif sans surcoût (Corosync) | vCenter Server (Complexe et payant) | System Center VMM (SCVMM) |
| **Fonctionnalités HA / Migration** | HA natif, Ceph, ZFS, vMotion équivalent (Live Migration) | vMotion, DRS, HA de référence sur le marché | Live Migration, Failover Clustering |
| **Vendor Lock-in** | Faible (standards ouverts QEMU/KVM) | Très élevé (écosystème fermé VMware/Broadcom) | Élevé (écosystème Windows Server / Azure Stack) |

### 4. Analyse et Arbitrage (Niveau Master)
* **Choix de NovaTech :** Le choix de Proxmox VE s'inscrit dans la stratégie de **Coût Zéro** et d'indépendance technologique, tout en offrant des performances natives grâce à KVM et une flexibilité de stockage (ZFS/LVM) sans dépendre d'une politique de licence restrictive.
