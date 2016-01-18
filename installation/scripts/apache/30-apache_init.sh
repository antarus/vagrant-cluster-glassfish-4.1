#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo "Configuration diverses"
echo "Changement hostname definition du nom $NOM_HOST_MACHINE_APACHE:"
sudo sysctl kernel.hostname=$NOM_HOST_MACHINE_APACHE
 
# sauvegarde le fichier host
if [ -f /etc/hosts ];then
   sudo mv /etc/hosts /etc/hosts.old.$(date +"%Y_%m_%d_")
fi

# ajoute les host du cluster au fichier hosts
sudo echo "127.0.0.1 localhost" >> /etc/hosts
sudo echo "127.0.1.1 $NOM_HOST_MACHINE_APACHE" >> /etc/hosts
sudo echo "127.0.0.1 $NOM_HOST_MACHINE_APACHE" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH1 $NOM_HOST_MACHINE_GLASSFISH1" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH2 $NOM_HOST_MACHINE_GLASSFISH2" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH3 $NOM_HOST_MACHINE_GLASSFISH3" >> /etc/hosts
sudo echo "$IP_HOST_MACHINE_GLASSFISH4 $NOM_HOST_MACHINE_GLASSFISH4" >> /etc/hosts

sudo sed -i -e"s@HOSTNAME=.*@HOSTNAME=$NOM_HOST_MACHINE_APACHE@" /etc/sysconfig/network

# TODO Vagrant garder que le "else" pour la PROD
if grep -c '^vagrant:' /etc/passwd; then
#change le hostname
  sudo sed -i 's/centos66/$NOM_HOST_MACHINE_APACHE/g' /etc/hosts
else
  sudo sed -i 's/centos66/$NOM_HOST_MACHINE_APACHE/g' /etc/hosts
fi
# TODO FIN Vagrant 

# active le nouveau hostname sans reboot
sudo hostname $NOM_HOST_MACHINE_APACHE


# installation d'apache
echo "installation d'apache"
sudo yum -y install httpd

echo "Compilation du mod JK"

#sudo cp $REP_INSTALL_BASE/mod_jk-1.2.31-httpd-2.2.x.so /etc/httpd/modules/mod_jk.so
cd /tmp
sudo cp $REP_INSTALL_BASE/tomcat-connectors-1.2.41-src.tar.gz /tmp/tomcat-connectors-1.2.41-src.tar.gz
sudo tar -xf tomcat-connectors-1.2.41-src.tar.gz
sudo yum install -y httpd-devel gcc gcc-c++ make libtool

cd tomcat-connectors-1.2.41-src/native
sudo ./configure --with-apxs=/usr/sbin/apxs #(or where ever the apxs/apxs2 is)
sudo make
sudo libtool --finish /usr/lib64/httpd/modules
sudo make install

echo "Configuration du mod JK"
# creation du fichier de configuration du mod jk
sudo touch /etc/httpd/conf/workers.properties

sudo sh -c "cat > /etc/httpd/conf/workers.properties" <<EOF
# Load balancer configuration
worker.list=loadbalancer

# Configure $NOM_CLUSTER - NOM_CLUSTER_INSTANCE1
worker.$AJP_INSTANCE_NAME1.type=ajp13
worker.$AJP_INSTANCE_NAME1.host=$NOM_HOST_MACHINE_GLASSFISH1
# Port as per the system property AJP_PORT
worker.$AJP_INSTANCE_NAME1.port=$AJP_PORT_INST1
worker.$AJP_INSTANCE_NAME1.lbfactor=50
worker.$AJP_INSTANCE_NAME1.cachesize=10
worker.$AJP_INSTANCE_NAME1.cache_timeout=600
worker.$AJP_INSTANCE_NAME1.socket_keepalive=1
worker.$AJP_INSTANCE_NAME1.socket_timeout=300

# Configure $NOM_CLUSTER - NOM_CLUSTER_INSTANCE2
worker.$AJP_INSTANCE_NAME2.type=ajp13
worker.$AJP_INSTANCE_NAME2.host=$NOM_HOST_MACHINE_GLASSFISH2
worker.$AJP_INSTANCE_NAME2.port=$AJP_PORT_INST2
worker.$AJP_INSTANCE_NAME2.lbfactor=50
worker.$AJP_INSTANCE_NAME2.cachesize=10
worker.$AJP_INSTANCE_NAME2.cache_timeout=600
worker.$AJP_INSTANCE_NAME2.socket_keepalive=1
worker.$AJP_INSTANCE_NAME2.socket_timeout=300

# Configure $NOM_CLUSTER - NOM_CLUSTER_INSTANCE3
worker.$AJP_INSTANCE_NAME3.type=ajp13
worker.$AJP_INSTANCE_NAME3.host=$NOM_HOST_MACHINE_GLASSFISH3
worker.$AJP_INSTANCE_NAME3.port=$AJP_PORT_INST3
worker.$AJP_INSTANCE_NAME3.lbfactor=50
worker.$AJP_INSTANCE_NAME3.cachesize=10
worker.$AJP_INSTANCE_NAME3.cache_timeout=600
worker.$AJP_INSTANCE_NAME3.socket_keepalive=1
worker.$AJP_INSTANCE_NAME3.socket_timeout=300

# Configure $NOM_CLUSTER - NOM_CLUSTER_INSTANCE4
worker.$AJP_INSTANCE_NAME4.type=ajp13
worker.$AJP_INSTANCE_NAME4.host=$NOM_HOST_MACHINE_GLASSFISH3
worker.$AJP_INSTANCE_NAME4.port=$AJP_PORT_INST4
worker.$AJP_INSTANCE_NAME4.lbfactor=50
worker.$AJP_INSTANCE_NAME4.cachesize=10
worker.$AJP_INSTANCE_NAME4.cache_timeout=600
worker.$AJP_INSTANCE_NAME4.socket_keepalive=1
worker.$AJP_INSTANCE_NAME4.socket_timeout=300

# The balancing will be done using round-robin algorithm
worker.loadbalancer.type=lb

# Participating worker instances
worker.loadbalancer.balanced_workers=$AJP_INSTANCE_NAME1,$AJP_INSTANCE_NAME2,$AJP_INSTANCE_NAME3,$AJP_INSTANCE_NAME4

# Add the status worker to the worker list
worker.list=jk-status
# Define a 'jk-status' worker using status
worker.jk-status.type=status
EOF


sudo touch /etc/httpd/conf.d/jk_$NOM_DOMAINE.conf
sudo chmod 644 /etc/httpd/conf.d/jk_$NOM_DOMAINE.conf

sudo sh -c "cat > /etc/httpd/conf.d/jk_$NOM_DOMAINE.conf" <<EOF
LoadModule jk_module modules/mod_jk.so

JkWorkersFile /etc/httpd/conf/workers.properties
JkLogFile     /var/log/httpd/mod_jk_log
JkLogLevel    info
# format du log
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
# Indique d'envoyer la taille de la clé SSL 
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories
# format de la requete
JkRequestLogFormat "%w %V %T"
# Redirige l'application vers glassfish
# /test-jsf2-cluster|/* signifie que /test-jsf2-cluster or /test-jsf2-cluster/*
JkMount /test-jsf2-cluster|/* loadbalancer
EOF


echo "Création des répertoires des sites web"

sudo mkdir -p $BASE_APP_WEB/httpd/sites-available
sudo mkdir -p $BASE_APP_WEB/httpd/sites-enabled
sudo chmod -Rf 644 $BASE_APP_WEB/httpd/sites-available
sudo chmod -Rf 644 $BASE_APP_WEB/httpd/sites-enabled

sudo chown -Rf root:apache $BASE_APP_WEB/httpd
sudo chmod -Rf 2775 $BASE_APP_WEB/httpd

#echo "création et configuration des sites par défaut"
#sudo touch $BASE_APP_WEB/httpd/sites-available/_default_
#sudo chmod 644 $BASE_APP_WEB/httpd/sites-available/_default_
echo "Création du répertoire _default_"
sudo mkdir -p  $BASE_APP_WEB/httpd/sites-available/_default_/
sudo touch  $BASE_APP_WEB/httpd/sites-available/_default_/index.html

echo "Ajout de la configuration _default_"
sudo sh -c "cat > $BASE_APP_WEB/httpd/sites-available/_default_.conf" <<EOF
# ----------------------------------
#   Hote  virtuel par defaut
# ----------------------------------
<VirtualHost _default_:80>
  ServerName    $NOM_HOST_MACHINE_APACHE
  DocumentRoot  "$BASE_APP_WEB/httpd/sites-available/_default_"
</VirtualHost>

<Directory "$BASE_APP_WEB/httpd/sites-available/_default_">
  Options Indexes FollowSymlinks
  AllowOverride All
  Order   allow,deny
  Allow from all
</Directory>
# ----------------------------------
EOF


echo "configuration de apache"
sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
sudo sh -c "cat >> /etc/httpd/conf/httpd.conf" <<EOF
# Minimisation des informations disponible sur le serveur
ServerTokens prod

## Le serveur écoute sur l interfaces réseau
#Listen 80

#Nom du server
ServerName $NOM_HOST_MACHINE_APACHE

## Adresse de l'administrateur du serveur web
ServerAdmin $MAIL_WEBMASTER

## Désactivation de l'affichage de la version du serveur Apache
ServerSignature Off

## Activation des hôtes virtuels nommés pour le port 80
NameVirtualHost *:80

## Chargement des fichiers de définition des sites activés
#Include sites-enabled/_default_
Include $BASE_APP_WEB/httpd/sites-enabled/*.conf

EOF


echo "Création de l'hote virtuel pour $NOM_DOMAINE"
sudo touch $BASE_APP_WEB/httpd/sites-available/$NOM_DOMAINE.conf
sudo mkdir -p  $BASE_APP_WEB/httpd/sites-available/$NOM_DOMAINE/
sudo touch  $BASE_APP_WEB/httpd/sites-available/$NOM_DOMAINE/index.html

sudo sh -c "cat >> $BASE_APP_WEB/httpd/sites-available/$NOM_DOMAINE.conf" <<EOF
<VirtualHost *:80>
  JkMountCopy On
  ServerName    $NOM_HOST_MACHINE_APACHE

  DocumentRoot  "$BASE_APP_WEB/httpd/sites-available/$NOM_DOMAINE"

  ProxyRequests              Off
  ProxyPreserveHost          On
  ProxyPassReverseCookiePath / /

#<Location /app >
 #  ProxyPass            http://127.0.0.1:$PORT_APPLICATION/app
  # ProxyPassReverse     http://127.0.0.1:$PORT_APPLICATION/app/
#</Location>



 # <Proxy *>
 #   Order               deny,allow
  #  Deny from           all
 #   Allow from          all
 # </Proxy>

</VirtualHost>
EOF

#Prise en compte sous apache, de l'hote virtuel pour $NOM_DOMAINE
sudo ln -s $BASE_APP_WEB/httpd/sites-available/$NOM_DOMAINE.conf $BASE_APP_WEB/httpd/sites-enabled


echo "Redemarrage du service apache"
sudo service httpd restart

echo "Activation au démarrage le service Apache"
sudo chkconfig httpd on

echo -e " "
echo -e "Installation et configuration de apache 2 : ${BLEU}OK${PAS_COULEUR}"
echo -e " "


#http://www.codefactorycr.com/glassfish-behind-apache.html

#https://geekyvivek.wordpress.com/2015/08/16/load-balance-glassfish-4-with-modjk/2/

#http://blog.aliecom.com/cluster-glassfish-failover-loadbalancing/

#https://access.redhat.com/documentation/en-US/JBoss_Enterprise_Application_Platform/6/html/Administration_and_Configuration_Guide/Install_the_Mod_jk_Module_Into_Apache_HTTPD_or_Enterprise_Web_Server_HTTPD1.html


                                        # If your host doesn't have a registered DNS name, enter its IP address here.
# You will have to access it by its address anyway, and this will make
# redirections work in a sensible way.
#
#ServerName www.example.com:80

