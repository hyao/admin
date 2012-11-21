echo "This script will:
1) create a self signed sll certificate
2) setup web2py with mod_wsgi
3) overwrite /etc/apache2/sites-available/default
4) restart apache.

You may want to read this script before running it.
"
#Press a key to continue...[ctrl+C to abort]"

#read CONFIRM

#!/bin/bash
# optional
# dpkg-reconfigure console-setup
# dpkg-reconfigure timezoneconf
# nano /etc/hostname
# nano /etc/network/interfaces
# nano /etc/resolv.conf
# reboot now
# ifconfig eth0


echo "setting up apache modules"
echo "========================="
a2enmod ssl
a2enmod proxy
a2enmod proxy_http
a2enmod headers
a2enmod expires
mkdir /etc/apache2/ssl

echo "creating a self signed certificate"
echo "=================================="
openssl genrsa 1024 > /etc/apache2/ssl/self_signed.key
chmod 400 /etc/apache2/ssl/self_signed.key
openssl req -new -x509 -nodes -sha1 -days 365 -key /etc/apache2/ssl/self_signed.key > /etc/apache2/ssl/self_signed.cert
openssl x509 -noout -fingerprint -text < /etc/apache2/ssl/self_signed.cert > /etc/apache2/ssl/self_signed.info

echo "rewriting your apache config file to use mod_wsgi"
echo "================================================="
echo '
NameVirtualHost *:80
NameVirtualHost *:443
# If the WSGIDaemonProcess directive is specified outside of all virtual
# host containers, any WSGI application can be delegated to be run within
# that daemon process group.
# If the WSGIDaemonProcess directive is specified
# within a virtual host container, only WSGI applications associated with
# virtual hosts with the same server name as that virtual host can be
# delegated to that set of daemon processes.
WSGIDaemonProcess web2py user=www-data group=www-data

<VirtualHost *:80>
  WSGIProcessGroup web2py
  WSGIScriptAlias / /var/www/web2py/wsgihandler.py
  WSGIPassAuthorization On

  <Directory /var/www/web2py>
    AllowOverride None
    Order Allow,Deny
    Deny from all
    <Files wsgihandler.py>
      Allow from all
    </Files>
  </Directory>

  AliasMatch ^/([^/]+)/static/(.*) \
           /var/www/web2py/applications/$1/static/$2
  <Directory /home/www-data/web2py/applications/*/static/>
    Options -Indexes
    Order Allow,Deny
    Allow from all
  </Directory>

  <Location /admin>
  Deny from all
  </Location>

  <LocationMatch ^/([^/]+)/appadmin>
  Deny from all
  </LocationMatch>

  CustomLog /var/log/apache2/access.log common
  ErrorLog /var/log/apache2/error.log
</VirtualHost>

<VirtualHost *:443>
  SSLEngine on
  SSLCertificateFile /etc/apache2/ssl/self_signed.cert
  SSLCertificateKeyFile /etc/apache2/ssl/self_signed.key

  WSGIProcessGroup web2py
  WSGIScriptAlias / /var/www/web2py/wsgihandler.py
  WSGIPassAuthorization On

  <Directory /var/www/web2py>
    AllowOverride None
    Order Allow,Deny
    Deny from all
    <Files wsgihandler.py>
      Allow from all
    </Files>
  </Directory>

  AliasMatch ^/([^/]+)/static/(.*) \
        /var/www/web2py/applications/$1/static/$2

  <Directory /var/www/web2py/applications/*/static/>
    Options -Indexes
    ExpiresActive On
    ExpiresDefault "access plus 1 hour"
    Order Allow,Deny
    Allow from all
  </Directory>

  CustomLog /var/log/apache2/access.log common
  ErrorLog /var/log/apache2/error.log
</VirtualHost>
' > /etc/apache2/sites-available/default

# echo "setting up PAM"
# echo "================"
# sudo apt-get install pwauth
# sudo ln -s /etc/apache2/mods-available/authnz_external.load /etc/apache2/mods-enabled
# ln -s /etc/pam.d/apache2 /etc/pam.d/httpd
# usermod -a -G shadow www-data

echo "restarting apache2"
echo "================"

/etc/init.d/apache2 restart

cd /var/www/web2py
sudo -u www-data python -c "from gluon.widget import console; console();"
sudo -u www-data python -c "from gluon.main import save_password; save_password(raw_input('admin password: '),443)"
echo "done!"

