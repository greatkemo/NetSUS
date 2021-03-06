#!/bin/bash
# This script controls the flow of the SUS installation
pathToScript=$0
detectedOS=$1

# Logger
source logger.sh

logEvent "Starting SUS Installation"

if [[ $detectedOS == 'Ubuntu' ]]; then
    apt-get -qq -y install php5 >> $logFile
    apt-get -qq -y install curl >> $logFile
fi

if [[ $detectedOS == 'CentOS' ]] || [[ $detectedOS == 'RedHat' ]]; then
    yum install mod_ssl -y -q >> $logFile
    yum install php -y -q >> $logFile
    yum install php-xml -y -q >> $logFile
fi


if [ ! -d "/var/lib/reposado/" ]; then
    mkdir /var/lib/reposado/
fi

if [ ! -d "/srv/SUS/" ]; then
    mkdir /srv/SUS/
fi

if [ ! -d "/srv/SUS/html/" ]; then
    mkdir /srv/SUS/html/
fi

if [ ! -d "/srv/SUS/metadata/" ]; then
    mkdir /srv/SUS/metadata/
fi

if [ ! -d "/srv/SUS/html/content/" ]; then
    mkdir /srv/SUS/html/content/
fi

if [ ! -d "/srv/SUS/html/content/catalogs/" ]; then
    mkdir /srv/SUS/html/content/catalogs/
fi

cp -R ./var/* /var/

#Set perms on SUS sync
chmod +x /var/appliance/sus_sync.py

# Enable apache rewrite rules
if [[ $detectedOS == 'Ubuntu' ]]; then
    a2enmod rewrite >> $logFile
fi
#Point Apache to SUS
#TODO - This will not take into account if the installer is run again

if [[ $detectedOS == 'Ubuntu' ]]; then
    sed -i "s/DocumentRoot.*/DocumentRoot \/srv\/SUS\/html\//g" /etc/apache2/sites-enabled/000-default
fi
if [[ $detectedOS == 'CentOS' ]] || [[ $detectedOS == 'RedHat' ]]; then
    sed -i 's/\/var\/www\/html/\/srv\/SUS\/html/' /etc/httpd/conf/httpd.conf
fi
if [[ $detectedOS == 'Ubuntu' ]]; then
sed -i "s|</VirtualHost>||" /etc/apache2/sites-enabled/000-default
cat >>/etc/apache2/sites-enabled/000-default <<ZHEREDOC
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteCond %{HTTP_USER_AGENT} Darwin/9
        RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-leopard.merged-1.sucatalog
        RewriteCond %{HTTP_USER_AGENT} Darwin/10
        RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-leopard-snowleopard.merged-1.sucatalog
        RewriteCond %{HTTP_USER_AGENT} Darwin/11
        RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-lion-snowleopard-leopard.merged-1.sucatalog
        RewriteCond %{HTTP_USER_AGENT} Darwin/12
        RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog
        RewriteCond %{HTTP_USER_AGENT} Darwin/13
        RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog
    </IfModule>

</VirtualHost>
ZHEREDOC
fi

if [[ $detectedOS == 'CentOS' ]] || [[ $detectedOS == 'RedHat' ]]; then
echo '
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{HTTP_USER_AGENT} Darwin/9
RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-leopard.merged-1.sucatalog
RewriteCond %{HTTP_USER_AGENT} Darwin/10
RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-leopard-snowleopard.merged-1.sucatalog
RewriteCond %{HTTP_USER_AGENT} Darwin/11
RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-lion-snowleopard-leopard.merged-1.sucatalog
RewriteCond %{HTTP_USER_AGENT} Darwin/12
RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog
RewriteCond %{HTTP_USER_AGENT} Darwin/13
RewriteRule ^/index\.sucatalog$ http://%{HTTP_HOST}/content/catalogs/others/index-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog
</IfModule>' >> /etc/httpd/conf/httpd.conf
fi


logEvent "OK"

logEvent "Finished deploying the appliance web application"

exit 0

