#!/bin/bash

# Instalar los prerequisitos de Wordpress

# Instal·lació MariaDB
apt-get update
apt-get install -y apt-transport-https curl
curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'
sh -c "echo 'deb https://mirror.mva-n.net/mariadb/repo/10.9/debian bullseye main' >>/etc/apt/sources.list"
apt-get update
apt-get install -y mariadb-server

# Instal·lació Apache, PHP i dependencias
apt-get install -y apache2 libapache2-mod-php php-mysql php-mbstring php-gd
cp /vagrant/main-directory.conf /etc/apache2/conf-available
a2enconf main-directory
cp /vagrant/main-site.conf /etc/apache2/sites-available
a2dissite 000-default
a2ensite main-site
systemctl reload apache2

# Crear la base de datos de Wordpress y el usuario correspondiente
mysql -e "CREATE DATABASE wp_fouadwp;"
mysql -e "CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'super3';"
mysql -e "GRANT ALL PRIVILEGES ON wp_fouadwp.* TO 'wordpress'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Descargar la última versión de Wordpress y descomprimir el archivo
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mkdir -p /var/www/virtual/wordpress/
mv wordpress/* /var/www/virtual/wordpress/
chown -R www-data:www-data /var/www/virtual/wordpress/
chmod -R 755 /var/www/virtual/wordpress/

# Generar el archivo wp-config.php con la configuración adecuada
cd /var/www/virtual/wordpress/
cp /vagrant/wp-config.php .

WP_DOMAIN="192.168.56.12"
WP_ADMIN_USERNAME="fouad"
WP_ADMIN_PASSWORD="super3"
WP_ADMIN_EMAIL="fhassidou@ies-sabadell.cat"

curl "http://$WP_DOMAIN/wp-admin/install.php?step=2" \
  --data-urlencode "weblog_title=FouadSiteHassidou"\
  --data-urlencode "user_name=$WP_ADMIN_USERNAME" \
  --data-urlencode "admin_email=$WP_ADMIN_EMAIL" \
  --data-urlencode "admin_password=$WP_ADMIN_PASSWORD" \
  --data-urlencode "admin_password2=$WP_ADMIN_PASSWORD" \
  --data-urlencode "pw_weak=1"  

# Reiniciar Apache para aplicar los cambios
systemctl restart apache2

# Notificar que la instalación está completa
echo "Wordpress instalado correctamente en http://192.168.56.12/"
