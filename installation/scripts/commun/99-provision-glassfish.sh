#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo ""
echo ""
echo ""
echo "----------------------------------"
echo "----------------------------------"
echo "Installation de glassfish $GLASSFISH_VERSION"
echo "----------------------------------"
echo "----------------------------------"
echo " "
echo " "
echo " "
      
# création du dossier $BASE_APP_WEB
mkdir -p $BASE_APP_WEB

if [ -d "$GLASSFISH_HOME" ];then
  echo "installation existante trouvé. Suppression."
  sudo sh $GLASSFISH_HOME/bin/aREP_INSTALL_BASEsadmin stop-domain $NOM_DOMAINE > /dev/null 2>&1 || true
  sudo rm -Rf $GLASSFISH_HOME
fi
export GLASSFISH_HOME=$GLASSFISH_HOME

cd $REP_INSTALL_BASE
sudo wget -q -N -P /var/cache/wget http://dlc-cdn.sun.com/glassfish/$GLASSFISH_VERSION/release/glassfish-$GLASSFISH_VERSION.zip

echo "Installation en cours. veuillez patienter ... "
sudo unzip -q /var/cache/wget/glassfish-$GLASSFISH_VERSION.zip -d $BASE_APP_WEB/

echo "Création de l'utilisateur glassfish"
if ! grep -c '^glassfish:' /etc/passwd; then
  sudo adduser glassfish

fi
# création du mot de passe glassfish
sudo echo -e "$GLASSFISH_PASSWORD\n$GLASSFISH_PASSWORD" | (sudo passwd --stdin glassfish)

# creation du groupe glassfishadm
sudo groupadd glassfishadm
echo "Création et ajout au groupe d'administration glassfish"
sudo usermod -a -G glassfishadm glassfish
sudo usermod -a -G glassfishadm root

# TODO Vagrant garder que le "else" pour la PROD
## donne le droit a l'utilisateur vagrant si il existe de manipuler glassfish
if grep -c '^vagrant:' /etc/passwd; then
  sudo usermod -a -G glassfishadm vagrant
fi
# TODO Fin Vagrant


# Ajout des variables pour qu'elles soit disponible pour tous les utilisateurs
echo "Ajout des variables au fichier /etc/environment"
echo "GLASSFISH_HOME=$GLASSFISH_HOME" >> /etc/environment
echo "PATH=$PATH:$GLASSFISH_HOME/bin" >> /etc/environment
echo "EMPLACEMENT_FICHIER_PASSWORD=$EMPLACEMENT_FICHIER_PASSWORD" >> /etc/environment
export GLASSFISH_HOME=$GLASSFISH_HOME
export PATH=$PATH:$GLASSFISH_HOME/bin
export EMPLACEMENT_FICHIER_PASSWORD=$EMPLACEMENT_FICHIER_PASSWORD
#sudo echo "GLASSFISH_HOME=$GLASSFISH_HOME" >> /home/glassfish/.bashrc
#sudo echo "PATH=$PATH:$GLASSFISH_HOME/bin" >> /home/glassfish/.bashrc
#sudo echo "EMPLACEMENT_FICHIER_PASSWORD=$EMPLACEMENT_FICHIER_PASSWORD" >> /home/glassfish/.bashrc

echo "Modification des droits pour l'utilisateur glassfish"
sudo chown -Rf glassfish:glassfishadm $GLASSFISH_HOME
sudo chgrp -Rf glassfishadm $GLASSFISH_HOME

echo "correction execution nadmin"
sudo chmod +x $GLASSFISH_HOME/glassfish/lib/nadmin


## force la creation des dossiers/fichier enfant a appartenir au groupe glassfishadm plutot qu'à l'utilisateur
sudo chmod g+s $GLASSFISH_HOME
sudo find $GLASSFISH_HOME -type d -exec chmod g+s {} +
# rend executable les binaires.
sudo chmod -R ug+rwx $GLASSFISH_HOME/bin/
sudo chmod -R ug+rwx $GLASSFISH_HOME/glassfish/bin/

echo "Suppression du domaine domain1"
sudo sh $GLASSFISH_HOME/bin/asadmin delete-domain domain1

echo "Création du fichier password domaine $NOM_DOMAINE"
#cd $GLASSFISH_HOME/glassfish/domains/
sh -c "cat > $EMPLACEMENT_FICHIER_PASSWORD" <<EOF
AS_ADMIN_PASSWORD=$GLF4_ADMIN_PASSWORD
AS_ADMIN_MASTERPASSWORD=$GLF4_ADMIN_MASTERPASSWORD
AS_ADMIN_SSHPASSWORD=$GLASSFISH_PASSWORD
EOF




echo "Création du domaine $NOM_DOMAINE"
#cd $GLASSFISH_BIN
sudo sh $GLASSFISH_HOME/bin/asadmin --user $GLF4_USER_ADMIN_DOMAINE  --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-domain --savemasterpassword=true --adminport $PORT_APPLICATION_ADMIN --instanceport $PORT_APPLICATION --domainproperties jms.port=7677:domain.jmxPort=8687:orb.listener.port=3701:http.ssl.port=$PORT_APPLICATION_SSL:orb.ssl.port=3821:orb.mutualauth.port=3921 $NOM_DOMAINE
echo "Démarrage du domaine $NOM_DOMAINE"
sudo sh $GLASSFISH_HOME/bin/asadmin start-domain $NOM_DOMAINE --passwordfile $EMPLACEMENT_FICHIER_PASSWORD

echo "Sécurisation du domaine $NOM_DOMAINE"
sudo sh $GLASSFISH_HOME/glassfish/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD --host localhost --port 4848 --user $GLF4_USER_ADMIN_DOMAINE enable-secure-admin

echo "redémarrage"
sudo sh $GLASSFISH_HOME/bin/asadmin stop-domain $NOM_DOMAINE
sudo sh $GLASSFISH_HOME/bin/asadmin start-domain --passwordfile $EMPLACEMENT_FICHIER_PASSWORD $NOM_DOMAINE






echo -e " "
echo -e "Installation commune de glassfish : ${BLEU}OK${PAS_COULEUR}"
echo -e " "
