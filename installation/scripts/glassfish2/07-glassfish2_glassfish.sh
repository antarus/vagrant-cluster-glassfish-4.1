#!/usr/bin/env bash
source /tmp/environnement_configuration
source $BASE_SCRIPT_PROVISION/commun/./lib.erreur.sh

echo "création de l'instance $NOM_CLUSTER_INSTANCE2"
sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD --host $NOM_HOST_MACHINE_GLASSFISH1 --port $PORT_APPLICATION_ADMIN create-local-instance --lbenabled=true --cluster $NOM_CLUSTER $NOM_CLUSTER_INSTANCE2
#sudo sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD --host $NOM_HOST_MACHINE_GLASSFISH1 --port $PORT_APPLICATION_ADMIN create-local-instance --cluster $NOM_CLUSTER --systemproperties GMS-BIND-INTERFACE-ADDRESS-$NOM_CLUSTER=$IP_HOST_MACHINE_GLASSFISH2 $NOM_CLUSTER_INSTANCE2


echo "Copie le master password du domaine dans l'instance $NOM_CLUSTER_INSTANCE2"
sudo cp $GLASSFISH_HOME/glassfish/domains/$NOM_DOMAINE/config/master-password $GLASSFISH_HOME/glassfish/nodes/$NOM_HOST_MACHINE_GLASSFISH2/agent/

echo "création service démarrage/arrêt domaine $NOM_DOMAINE "
sh -c "cat > /etc/init.d/glassfish" <<EOF
#!/bin/bash
#
# Glassfish   Script de demarrage et d arret domaine $NOM_DOMAINE
#
# chkconfig: - 86 15
# description: GlassFish
# processname: glassFish

# Linux Platform Services for GlassFish
# See this blog for more details:
# http://blogs.sun.com/foo/entry/run_glassfish_v3_as_a
# Remove the GF_USER setting to have the System account run GlassFish
#
#    Created on : Thu Mar 29 15:31:44 CEST 2012
#     Server Type:  Domain

case "" in
start)
    sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
    ;;
stop)
    sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
    ;;
restart)
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD stop-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
   sh $GLASSFISH_HOME/bin/asadmin --passwordfile $EMPLACEMENT_FICHIER_PASSWORD start-domain --domaindir $GLASSFISH_HOME/glassfish/domains $NOM_DOMAINE
   ;;
*)
    echo "usage: (start|stop|help)"
esac
EOF
## fin fichier

sudo sed -i -e"s@case.*@case \"\$1\" in@" /etc/init.d/glassfish > /dev/null 2>&1


sudo chmod 755 /etc/init.d/glassfish
sudo chkconfig --add glassfish
sudo chkconfig glassfish on

# redemarrage de glassfish via le service pour le lancer avec l'utilisateur glassfish
echo "Arret de glassfish via le service"
sudo /etc/init.d/glassfish stop

echo "Modification droit"
sudo chown -Rf glassfish:glassfishadm $GLASSFISH_HOME
sudo chmod -Rf 755 $GLASSFISH_HOME/glassfish/domains/$NOM_DOMAINE/config
sudo chmod -Rf 755 $GLASSFISH_HOME/glassfish/nodes/$NOM_HOST_MACHINE_GLASSFISH2


echo "Demarrage de glassfish via le service"
sudo /etc/init.d/glassfish start
