#!/bin/bash

ipa-backup
LATEST_BACKUP=$(ls -dt /var/lib/ipa/backup/ipa-full-* | head -1)
if [ -d "$LATEST_BACKUP" ]; then
scp -r "$LATEST_BACKUP" root@10.0.40.20:/srv/backups/
fi
