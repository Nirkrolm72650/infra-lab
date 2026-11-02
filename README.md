# Infra-Lab · Projet NovaTech

**Auteurs :** Brandon | Amine | Rayan  
**Formation :** MCS · Infrastructures Avancées 1
**Contexte :** Conception, déploiement et gouvernance de l'infrastructure souveraine multi-sites de NovaTech (100 % open source).

## Structure du Dépôt (`infra-lab`)

* `01-architecture/` : Schéma cible (`.drawio`), dimensionnement et cadrage RTO/RPO.
* `02-virtualisation/` : Nœud KVM Proxmox, templates cloud-init, conteneurs Docker et k3s.
* `03-stockage/` : Gestion RAID, ZFS, LVM, NAS/SAN et benchmarks (`fio`).
* `04-reseau-securite/` : Segmentation VLAN, routage OSPF, haute disponibilité VRRP et tests PRA.
* `gouvernance/` : RFC, matrice RACI, plan de capacité et politique d'accès.
