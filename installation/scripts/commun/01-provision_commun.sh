#!/usr/bin/env bash

## installation
echo " "
echo " "
echo " "
echo "----------------------------------"
echo "----------------------------------"
echo "configuration de la provision"
echo "----------------------------------"
echo "----------------------------------"
echo " "
echo " "
echo " "

export REP_INSTALL_BASE=/vagrant/installation

# cree un lien symbolic  du fichier des variables
if [ -f /tmp/environnement_configuration ];then
   sudo rm -Rf /tmp/environnement_configuration
fi

# TODO Vagrant garder que le "else" pour la PROD
if grep -c '^vagrant:' /etc/passwd; then
  sudo ln -s $REP_INSTALL_BASE/scripts/commun/environnement_configuration /tmp/environnement_configuration
else
  sudo cp $REP_INSTALL_BASE/scripts/commun/environnement_configuration /tmp/environnement_configuration
fi
# TODO FIN Vagrant 




source /tmp/environnement_configuration


echo "Divers : Nom de l'host pour la machine Glassfish1: "  $test
echo "Divers : IP de l'host pour la machine Glassfish1: "  $IP_HOST_MACHINE_GLASSFISH1
echo "Divers : Nom de l'host pour la machine Glassfish2: "  $NOM_HOST_MACHINE_GLASSFISH2
echo "Divers : IP de l'host pour la machine Glassfish2: "  $IP_HOST_MACHINE_GLASSFISH2
echo "Divers : Nom de l'host pour la machine Glassfish3: "  $NOM_HOST_MACHINE_GLASSFISH3
echo "Divers : IP de l'host pour la machine Glassfish3: "  $IP_HOST_MACHINE_GLASSFISH3
echo "Divers : Nom de l'host pour la machine Glassfish4: "  $NOM_HOST_MACHINE_GLASSFISH4
echo "Divers : IP de l'host pour la machine Glassfish4: "  $IP_HOST_MACHINE_GLASSFISH4

echo "Java : Version du JDK a installer : " $JDK_VERSION  " / "  $JDK_VERSION_2
echo "Glassfish : Base application a utiliser : " $BASE_APP_WEB
echo "Glassfish : Port de l'application : " $PORT_APPLICATION
echo "Glassfish : Port de l'application SSL: " $PORT_APPLICATION_SSL
echo "Glassfish : Port de l'administration : " $PORT_APPLICATION_ADMIN
echo "Glassfish : Base application glassfish a utiliser : " $BASE_WEB_APP_GLASSFISH
echo "Glassfish : Nom Compte administrateur du domaine $NOM_DOMAINE : " $USER_ADMIN_DOMAINE
echo "Glassfish : Nom du domaine a créer: " $NOM_DOMAINE
echo "Glassfish : Adresse IP de la base de données a utiliser: " $BDD_IP
echo "Glassfish : Utilisateur de la base de données a utiliser: " $BDD_USER
echo "Glassfish : Mot de passe de la base de données a utiliser: " $BDD_PWD
echo "Glassfish : Instance de la base de données a utiliser: " $BDD_INSTANCE
echo "Glassfish : Nom de la classe du drivers de la base de données a utiliser: " $BDD_CLASS_NAME
echo "Glassfish : Nom du pool de connexion a créer: " $BDD_POOL
echo "Glassfish : Nom de la ressource JDBC a créer: " $BDD_JDBC

echo "Apache : Base du site HTTP: " $BASE_HTTP_SITE
echo "Apache : Nom du serveur: " $NOM_SERVEUR


source  $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo "Ajout des variables commune au fichier /etc/environment"
echo "BASE_APP_WEB=$BASE_APP_WEB" >> /etc/environment
export BASE_APP_WEB=$BASE_APP_WEB



sh $BASE_SCRIPT_PROVISION/commun/./02-provision-init.sh
#sh $BASE_SCRIPT_PROVISION/commun/./03-provision-java.sh
#changer le hostname de la machine avant de configurer glassfish
#sh $BASE_SCRIPT_PROVISION/commun/./provision-glassfish.sh
#sh $BASE_SCRIPT_PROVISION/./provision-firewall.sh
echo -e " "
echo -e "Fin de configuration commune $NOM_DOMAINE : ${BLEU}OK${PAS_COULEUR}"
echo -e " "
