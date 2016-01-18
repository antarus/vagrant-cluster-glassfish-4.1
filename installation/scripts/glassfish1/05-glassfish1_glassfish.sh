#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo "Création du cluster $NOM_CLUSTER"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-cluster $NOM_CLUSTER

echo "creation de l'hote JMS par defaut"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD configure-jms-cluster --clustertype=conventional --configstoretype=masterbroker $NOM_CLUSTER

echo "Haute disponibilité"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD set $NOM_CLUSTER-config.availability-service.availability-enabled=true
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD set $NOM_CLUSTER-config.availability-service.web-container-availability.availability-enabled=true
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD set $NOM_CLUSTER-config.availability-service.ejb-container-availability.availability-enabled=true
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD set $NOM_CLUSTER-config.availability-service.jms-availability.availability-enabled=true


echo "Création de l'instance $NOM_CLUSTER_INSTANCE1 du cluster $NOM_CLUSTER"
#sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-local-instance --cluster $NOM_CLUSTER --systemproperties GMS-BIND-INTERFACE-ADDRESS-$NOM_CLUSTER=$IP_HOST_MACHINE_GLASSFISH1 $NOM_CLUSTER_INSTANCE1
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-local-instance --lbenabled=true --cluster $NOM_CLUSTER $NOM_CLUSTER_INSTANCE1

echo "Copie le master password du domaine dans l'instance $NOM_CLUSTER_INSTANCE1"
sudo cp $GLASSFISH_HOME/glassfish/domains/$NOM_DOMAINE/config/master-password $GLASSFISH_HOME/glassfish/nodes/localhost-$NOM_DOMAINE/agent/


echo "Démarrage du cluster $NOM_CLUSTER"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-cluster $NOM_CLUSTER

echo "Création des noeuds du cluster $NOM_CLUSTER"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD create-node-ssh --force --sshuser glassfish --sshport 22 --nodehost $NOM_HOST_MACHINE_GLASSFISH2 $NOM_HOST_MACHINE_GLASSFISH2




# redemarrage de glassfish via le service pour le lancer avec l'utilisateur glassfish
echo "Arret de glassfish "
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE

echo "Modification droit"
sudo chown -Rf glassfish:glassfishadm $GLASSFISH_HOME
sudo chmod -Rf 755 $GLASSFISH_HOME/glassfish/domains/$NOM_DOMAINE/config
sudo chmod -Rf 755 $GLASSFISH_HOME/glassfish/nodes/localhost-$NOM_DOMAINE/

echo "Demarrage de glassfish"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE





