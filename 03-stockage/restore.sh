#!/bin/bash
set -e

export RESTIC_PASSWORD="root"
REPO="sftp:root@10.0.40.20:/srv/backups/restic-repo"
RESTORE_DIR="/tmp/restore-restic"

echo "==> Nettoyage du dossier temporaire de restauration..."
rm -rf "$RESTORE_DIR"
mkdir -p "$RESTORE_DIR"

echo "==> Téléchargement du dernier snapshot depuis le dépôt Restic distant..."
restic -r "$REPO" restore latest --target "$RESTORE_DIR"

LATEST_RESTORED_BACKUP=$(find "$RESTORE_DIR" -name "ipa-full-*" -type d | head -n 1)

if [ -d "$LATEST_RESTORED_BACKUP" ]; then
echo "> Dossier trouvé : $LATEST_RESTORED_BACKUP"
echo "> Lancement de ipa-restore..."
ipa-restore "$LATEST_RESTORED_BACKUP"
echo "==> Restauration FreeIPA terminée avec succès."
else
echo "Erreur : Aucun dossier ipa-full valide n'a été trouvé dans le snapshot."
exit 1
fi
