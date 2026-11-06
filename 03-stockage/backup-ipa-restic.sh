#!/bin/bash

export RESTIC_PASSWORD="VOTRE_MOT_DE_PASSE_RESTIC"
REPO="sftp:root@10.0.40.20:/srv/restic-repo"

# Lancer la sauvegarde
ipa-backup

LATEST_BACKUP=$(ls -dt /var/lib/ipa/backup/ipa-full-* | head -n 1)
if [ -d "$LATEST_BACKUP" ]; then
restic -r "$REPO" backup "$LATEST_BACKUP"
fi

# Application de la rétention
restic -r "$REPO" forget --keep-daily 7 --keep-weekly 4 --prune
