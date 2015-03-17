#!/bin/sh

# Allow image to execute custom migrations before main migrations.
if [ -f /var/www/yii2site/docker/beforemigrate.sh ]; then
	/bin/bash /var/www/yii2site/docker/beforemigrate.sh
fi

# Run migrations.
./yii migrate --interactive=0

# Allow image to execute custom migrations after main migrations.
if [ -f /var/www/yii2site/docker/aftermigrate.sh ]; then
	/bin/bash /var/www/yii2site/docker/aftermigrate.sh
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

# Start apache in the foreground.
/usr/sbin/apache2ctl -D FOREGROUND