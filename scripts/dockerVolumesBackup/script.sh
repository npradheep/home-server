# Crontab expression - 0 3 * * 4 

#!/bin/bash

export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


BACKUPDIR=/mnt/h/dockerVolumesCronJob
DAYS=1
TIMESTAMP=$(date +"%Y%m%d%H%M")
VOLUME=$(docker volume ls -q ) # <| grep -v "portainer_volume\|authentik_redis"> to exclude volumes

echo -e "$TIMESTAMP - Backup for Docker Volumes: \n"
if [ ! -d $BACKUPDIR ]; then
        mkdir -p $BACKUPDIR
fi

for i in $VOLUME; do
        echo -e " Backing up volume:\n  * $i";
        docker run --rm \
        -v $BACKUPDIR:/backup \
        -v $i:/data:ro \
        -e TIMESTAMP=$TIMESTAMP \
        --name volumebackup \
        alpine sh -c "cd /data && /bin/tar -czf /backup/$i-$TIMESTAMP.tar.gz ."

        OLD_BACKUPS=$(ls -1 $BACKUPDIR/$i*.tar.gz |wc -l)
        if [ $OLD_BACKUPS -gt $DAYS ]; then
                find $BACKUPDIR -name "$i*.tar.gz" -daystart -mtime +$DAYS -delete
        fi
done
echo -e "\n$TIMESTAMP - Backup for Docker volumes completed\n"
